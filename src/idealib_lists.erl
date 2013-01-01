%%
%% $Id: $
%%
%% Module:  idealib_lists
%% Created: 01-JAN-2013 03:02
%% Author:  tmr
%%

-module (idealib_lists).
-export ([pad/3, lpad/3, rpad/3]).

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

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
