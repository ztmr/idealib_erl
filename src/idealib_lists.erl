%%
%% $Id: $
%%
%% Module:  idealib_lists
%% Created: 01-JAN-2013 03:02
%% Author:  tmr
%%

-module (idealib_lists).
-export ([
  pad/3, lpad/3, rpad/3,
  xzip/2,
  is_ascii_printable/1,
  is_ascii_string/1,
  is_utf_string/1
]).

%% @equiv lpad/3
pad (L, N, E) -> lpad (L, N, E).

%% @doc Right padding of the `L' by `E' to length of `N'.
%% Append `E' element to the right of the `L' list
%% until the result is length of `N'.
rpad (L, N, E) when is_list (L) ->
  lists:reverse (lpad (lists:reverse (L), N, E)).

%% @doc Left padding of the `L' by `E' to length `N'.
%% Append `E' element to the left of the `L' list
%% until the result is length of `N'.
lpad (L, N, E) when is_list (L), is_integer (N) ->
  lists:flatten (lpad (L, N, N, E)).
lpad (L, N, M, E) when (N > 0) andalso (M > length (L)) ->
  lpad ([E|L], N-1, M, E);
lpad (L, _, _, _) -> L. %% non-list fallback XXX (report error?)

%% @doc lists:zip for lists of unequal length.
xzip (L1, L2) -> xzip (L1, L2, []).

xzip ([], _, Acc) -> Acc;
xzip (_, [], Acc) -> Acc;
xzip ([H1|T1], [H2|T2], Acc) ->
  xzip (T1, T2, [{H1, H2}|Acc]).

%% @doc Check if the `X' is printable ASCII character.
is_ascii_printable (X) when X >= 32, X < 127 -> true;
is_ascii_printable (_) -> false.

%% @doc Check if the `L' list is printable ASCII string.
%% Uses `is_ascii_printable' function.
is_ascii_string (L) when is_list (L) -> lists:all (fun is_ascii_printable/1, L);
is_ascii_string (_) -> false.

%% @doc Check if the `L' list is printable Unicode string.
is_utf_string (L) ->
  io_lib:printable_unicode_list (L).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

padding_test () ->

  %% Basic
  ?assertEqual ([0,0,0,0,0,0,0,1], lpad ([1], 8, 0)),
  ?assertEqual ([1,0,0,0,0,0,0,0], rpad ([1], 8, 0)),
  ?assertEqual ([0,0,0,0,1,0,0,0], lpad ([1,0,0,0], 8, 0)),
  ?assertEqual ([0,0,0,0,1,0,0,0], lpad ([1,0,0,0], 8, 0)),

  %% NOTE: Is the following behaviour what we want?
  ?assertEqual ([1,2,3,4], pad ([1,2,3,4], 4, 0)),
  ?assertEqual ([1,2,3,4], pad ([1,2,3,4], 2, 0)),
  ?assertEqual ([1,2,3,4], pad ([1,2,3,4], 0, 0)),

  ok.

xzip_test () ->

  ?assertEqual ([{b, 2}, {a, 1}], xzip ([a, b], [1, 2])),
  ?assertEqual ([{a, 1}], xzip ([a, b], [1])),
  ?assertEqual ([{a, 1}], xzip ([a], [1, 2])),
  ?assertEqual ([], xzip ([], [])),
  ?assertEqual ([], xzip ([a, b], [])),
  ?assertEqual ([], xzip ([], [1, 2])),

  ok.

printable_test () ->

  ?assertEqual (true, is_ascii_printable ($A)),
  ?assertEqual (false, is_ascii_printable (0)),
  ?assertEqual (false, is_ascii_printable ("č")),

  ?assertEqual (true, is_ascii_string ([$A,$B,$C])),
  ?assertEqual (false, is_ascii_string ([$A,$B,$C,0])),
  ?assertEqual (false, is_ascii_string ({ok})),

  ?assertEqual (true, is_utf_string ([$A,$B,$C])),
  ?assertEqual (false, is_utf_string ([$A,$B,$C,0])),
  ?assertEqual (true, is_utf_string ([283,353,269,345,382,253,225,237,233])),

  ok.

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
