-module (idealib_binary).
-export ([concat/1, to_hex/1]).

%% NOTE: the list_to_binary does the same job probably!
concat (L) when is_list (L) ->
    concat (lists:reverse (L), <<>>).

concat ([], Acc) -> Acc;
concat (<<>>, Acc) -> Acc;
concat ([H|T], Acc) when is_binary (H) ->
    concat (T, <<H/binary, Acc/binary>>).

%% Not the fastest method, but...
%% mochihex is probably better
to_hex (Bin) ->
    R = [ idealib_lists:pad (integer_to_list (X, 16), 2, "0")
          || <<X>> <= iolist_to_binary (Bin) ],
    string:to_lower (lists:flatten (R)).

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

to_hex_test () ->
    "ff000ff1" = to_hex ([255, 0, 15, 241]),

    ok.

-endif.

