-module (idealib_binary).
-export ([concat/1]).

concat (L) when is_list (L) ->
  concat (lists:reverse (L), <<>>).

concat ([], Acc) -> Acc;
concat (<<>>, Acc) -> Acc;
concat ([H|T], Acc) when is_binary (H) ->
  concat (T, <<H/binary, Acc/binary>>).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

concat_test () ->
  Fun = fun ?MODULE:concat/1,

  ?assertEqual (<<>>, Fun ([])),
  ?assertEqual (<<>>, Fun ([<<>>, <<>>])),
  ?assertEqual (<<"A">>, Fun ([<<>>, <<>>, <<"A">>])),

  ?assertEqual (<<"ABCD">>,
    Fun ([<<"A">>, <<>>, <<"BC">>, <<"D">>])),

  ok.

-endif.

