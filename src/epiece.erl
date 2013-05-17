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

  ok.

-endif.

