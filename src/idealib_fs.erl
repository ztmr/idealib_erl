-module (idealib_fs).
-export ([last_modified/1]).

-include_lib ("kernel/include/file.hrl").

%% @doc Like filelib:last_modified/1, but in UTC.
last_modified (File) ->
  case file:read_file_info (File, [{time, universal}]) of
      {error, _}                   -> 0;
      {ok, #file_info {mtime = X}} -> X
  end.


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

common_test () ->
  ?assertEqual (true, is_tuple (last_modified ("idealib_fs.erl"))),
  ?assertEqual (0, last_modified ("non.existent.file")),
  ok.

-endif.

