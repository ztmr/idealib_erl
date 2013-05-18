-module (epiece).
-export ([piece/2, piece/3]).

%% @doc Alias for epiece_nif:piece/2.
piece ([], _) -> [];
piece (S, D) -> epiece_nif:piece (S, D).

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
       114,64,105,100,101,97,46,99,122,28,28],
  F = [id,confirm_ticket,enabled,password,timezone,member_since,
       code,surname,name,lang,email,last_login],
  X1 = ["2",[],"true","9c68adee51b8c8cca729bff32c486d2f2416341b",
        [],[],[],"Morstein","Tomas",[],"tmr@idea.cz",[],[]],
  X2 = [{last_login,[]},
        {email,"tmr@idea.cz"},
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

-endif.

