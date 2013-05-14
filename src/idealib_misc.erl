%%
%% $Id: $
%%
%% Module:  misc -- description
%% Created: 31-DEC-2012 18:45
%% Author:  tmr
%%

-module (idealib_misc).
-export ([uuid4str/0, post_init/2, post_init/3, post_init_internal/3]).

%% @doc UUIDv4 string generator.
uuidv4str () ->
  <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> =
    crypto:rand_bytes (16),
  <<Ux0:32, Ux1:16, Ux2:16, Ux3:16, Ux4:48>> =
    <<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>,
  lists:flatten (io_lib:format (
    "~8.16.0b-~4.16.0b-~4.16.0b-~4.16.0b-~12.16.0b",
    [Ux0, Ux1, Ux2, Ux3, Ux4])).

%% @doc Wait for the `App' to start and run `Fun' function finally.
post_init (App, Fun) ->
  post_init (App, Fun, 500).
post_init (App, Fun, TimeOut) ->
  spawn (?MODULE, post_init_internal, [App, Fun, TimeOut]).

%% @doc INTERNAL PURPOSES ONLY (`post_init/3').
post_init_internal (App, Fun, TimeOut) ->
  ilog:info ("~p Waiting for `~p' application...~n", [self (), App]),
  case proplists:is_defined (App, application:which_applications ()) of
    true -> Fun ();
    false ->
      timer:sleep (TimeOut),
      post_init_internal (App, Fun, TimeOut)
  end.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
