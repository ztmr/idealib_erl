-module (idealib_crypto).
-export ([hmac/3, hmac_hex/3, hash/2, hash_hex/2]).

hmac (sha1, Key, Data) -> hmac_ (sha, Key, Data);
hmac (sha = A, Key, Data) -> hmac_ (A, Key, Data);
hmac (md5 = A, Key, Data) -> hmac_ (A, Key, Data);
hmac (_, _, _) -> throw (unsupported_hmac_algorithm).

hmac_ (HashAlgorithm, Key, Data) ->
    Ctx0 = crypto:hmac_init (HashAlgorithm, Key),
    Ctx1 = crypto:hmac_update (Ctx0, Data),
    crypto:hmac_final (Ctx1).

hmac_hex (HashAlgorithm, Key, Data) ->
    idealib_binary:to_hex (hmac (HashAlgorithm, Key, Data)).

hash (sha = A, D) -> hash_ (A, D);
hash (sha1, D) -> hash_ (sha, D);
hash (md5 = A, D) -> hash_ (A, D);
hash (sha256 = A, D) -> hash_ (A, D);
hash (sha512 = A, D) -> hash_ (A, D).

hash_ (HashAlgorithm, Data) ->
    crypto:HashAlgorithm (Data).

hash_hex (HashAlgorithm, Data) ->
    idealib_binary:to_hex (hash (HashAlgorithm, Data)).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

hmac_test () ->
    Fun = fun (A, K, D) ->
                  [$0, $x | hmac_hex (A, K, D)]
          end,

    crypto:start (),

    ?assertEqual ("0x74e6f7298a9c2d168935f58c001bad88",
                  Fun (md5, "", "")),
    ?assertEqual ("0xfbdb1d1b18aa6c08324b7d64b71fb76370690e1d",
                  Fun (sha1, "", "")),
    %?assertEqual ("0xb613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad",
    %              Fun (sha256, "", "")),

    Key = "key",
    Data = "The quick brown fox jumps over the lazy dog",

    ?assertEqual ("0x80070713463e7749b90c2dc24911e275",
                  Fun (md5, Key, Data)),
    ?assertEqual ("0xde7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9",
                  Fun (sha1, Key, Data)),
    %?assertEqual ("0xf7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8",
    %              Fun (sha256, Key, Data)),

    crypto:stop (),

    ok.

-endif.

