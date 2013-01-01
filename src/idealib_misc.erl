%%
%% $Id: $
%%
%% Module:  misc -- description
%% Created: 31-DEC-2012 18:45
%% Author:  tmr
%%

-module (idealib_misc).
-export ([post_init/2, post_init/3]).
-compile ([
  {nowarn_unused_function, [
    %% We use it, but indirectly in spawn
    {post_init_internal, 3}
  ]}
]).

%% @doc Wait for the `App' to start and run `Fun' function finally.
post_init (App, Fun) ->
  post_init (App, Fun, 500).
post_init (App, Fun, TimeOut) ->
  spawn (?MODULE, post_init_internal, [App, Fun, TimeOut]).

post_init_internal (App, Fun, TimeOut) ->
  ilib:info ("~p Waiting for `~p' application...~n", [self (), App]),
  case proplists:is_defined (App, application:which_applications ()) of
    true -> Fun ();
    false ->
      timer:sleep (TimeOut),
      post_init_internal (App, Fun, TimeOut)
  end.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
