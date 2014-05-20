-module (epiece).
-export ([piece/2, piece/3]).

%% @doc Alias for epiece_nif:piece/2.
piece ([], _) -> [];
piece (S, D) -> piece_implementation (S, D).

%% @doc Piece on steroids (returns a proplist).
%% Example:
%% ```
%% erl> piece ("a|b|c", "|", [foo, bar, zoo])
%% [{zoo, "c"}, {bar, "b"}, {foo, "a"}]
%% '''
piece ([], _, _) -> [];
piece (_, _, []) -> [];
piece (S, D, F) when is_list (S) ->
  idealib_lists:xzip (F, piece (S, D)).

piece_implementation ([], _) -> [];
piece_implementation (S, []) ->
  [ [Si] || Si <- S ];
piece_implementation (S, [D]) ->
  epz_ (S, D, [], []);
piece_implementation (S, D) ->
  epiece_nif:piece (S, D).

%% D is a single character
epz_ ([], _, [], []) -> []; 
epz_ ([], _, Buf, Res) ->
  lists:reverse ([lists:reverse (Buf)|Res]);
epz_ ([D|S], D, Buf, Res) ->
  epz_ (S, D, [], [lists:reverse (Buf)|Res]);
epz_ ([X|S], D, Buf, Res) ->
  epz_ (S, D, [X|Buf], Res).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

piece_test () ->

  %% XXX: add more scenarios!
  ?assertEqual (["a", "b", "c"], piece ("a|b|c", "|")),
  ?assertEqual ([{zoo, "c"}, {bar, "b"}, {foo, "a"}],
                piece ("a|b|c", "|", [foo, bar, zoo])),

  R = [50,28,28,116,114,117,101,28,57,99,54,56,97,100,101,101,53,
       49,98,56,99,56,99,99,97,55,50,57,98,102,102,51,50,99,52,56,
       54,100,50,102,50,52,49,54,51,52,49,98,28,28,28,28,77,111,
       114,115,116,101,105,110,28,84,111,109,97,115,28,28,116,109,
       114,35,105,100,101,97,46,99,111,109,28,28],
  F = [id,confirm_ticket,enabled,password,timezone,member_since,
       code,surname,name,lang,email,last_login],
  X1 = ["2",[],"true","9c68adee51b8c8cca729bff32c486d2f2416341b",
        [],[],[],"Morstein","Tomas",[],"tmr#idea.com",[],[]],
  X2 = [{last_login,[]},
        {email,"tmr#idea.com"},
        {lang,[]},
        {name,"Tomas"},
        {surname,"Morstein"},
        {code,[]},
        {member_since,[]},
        {timezone,[]},
        {password,"9c68adee51b8c8cca729bff32c486d2f2416341b"},
        {enabled,"true"},
        {confirm_ticket,[]},
        {id,"2"}],
  Delim = [28],

  ?assertEqual (X1, piece (R, Delim)),
  ?assertEqual (X2, piece (R, Delim, F)),

  ok.

empty_delimiter_test () ->
  ?assertEqual (["a", "b", "c"], piece ("abc", "")),
  ok.

known_nif_segfault_test () ->
  %% This works on almost all the boxes, but the production one :-(
  X = [85,67,84,48,50,28,90,195,161,118,97,122,107,121,28,51,49,
       49,49,48,48,44,51,49,49,50,48,48,44,51,49,49,51,48,48,44,51,
       49,52,49,48,48,44,51,49,53,49,48,48,44,51,49,53,57,48,48,44,
       51,50,49,49,48,48,44,51,50,49,49,53,48,44,51,50,49,50,48,48,
       44,51,50,52,49,48,48,44,51,51,49,49,48,48,44,51,51,53,49,48,
       48,44,51,51,53,50,48,48,44,51,51,54,49,49,48,44,51,51,54,49,
       50,48,44,51,52,49,49,48,48,44,51,52,50,49,48,48,44,51,52,50,
       49,49,48,44,51,52,51,49,49,48,44,51,52,51,49,50,48,44,51,52,
       51,49,52,48,44,51,52,51,50,49,48,44,51,52,51,50,50,48,44,51,
       52,51,51,48,49,44,51,52,51,51,48,50,44,51,52,51,51,48,51,44,
       51,52,51,51,48,52,44,51,52,51,51,48,53,44,51,52,51,51,48,54,
       44,51,52,51,51,48,55,44,51,52,51,51,48,56,44,51,52,51,51,48,
       57,44,51,52,51,51,49,48,44,51,52,51,51,49,49,44,51,52,51,51,
       49,50,44,51,52,51,52,48,48,44,51,52,51,52,49,48,44,51,52,51,
       52,50,48,44,51,52,53,49,48,48,44,51,53,53,49,48,48,44,51,55,
       56,49,48,48,44,51,55,56,51,48,48,44,51,55,57,49,48,48,44,51,
       55,57,49,53,48,44,51,55,57,50,48,48,44,51,55,57,51,48,48,44,
       51,55,57,52,48,48,44,51,55,57,53,48,48,44,51,55,57,54,48,48,
       44,51,55,57,57,48,48,44,51,56,49,49,48,48,44,51,56,49,50,48,
       48,44,51,56,49,51,48,48,44,51,56,51,49,48,48,44,51,56,56,49,
       48,48,44,51,56,57,49,48,48,44,51,57,49,49,48,48,28,28,54,28,
       28,28],
  piece (X, [28]),
  ok.

-endif.

