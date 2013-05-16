%%
%% $Id: $
%%
%% Module:  misc -- description
%% Created: 31-DEC-2012 18:45
%% Author:  tmr
%%

-module (idealib_misc).
-export ([
  uuidv4str/0,
  re_esc/1,
  get_priv_dir_item/2,
  post_init/2, post_init/3, post_init_internal/3
]).

%% @doc UUIDv4 string generator.
uuidv4str () ->
  <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> =
    crypto:rand_bytes (16),
  <<Ux0:32, Ux1:16, Ux2:16, Ux3:16, Ux4:48>> =
    <<U0:32, U1:16, 4:4, U2:12, 2#10:2, U3:30, U4:32>>,
  lists:flatten (io_lib:format (
    "~8.16.0b-~4.16.0b-~4.16.0b-~4.16.0b-~12.16.0b",
    [Ux0, Ux1, Ux2, Ux3, Ux4])).

%% @doc regex pattern escaper.
re_esc ({re_pattern, _} = Pat) -> Pat;
re_esc ([]) -> [];
re_esc ([H|T]) when H >= $0, H =< $9; H >= $a, H =< $z; H >= $A, H =< $Z ->
  [H|re_esc (T)];
re_esc ([H|T]) -> [$\\, H|re_esc (T)].

%% @doc Get full path of item stored in private directory.
get_priv_dir_item (App, Name) ->
  case code:priv_dir (App) of
    {error, bad_name} ->
      case filelib:is_dir (filename:join (["..", priv])) of
        true -> filename:join (["..", priv, Name]);
        _    -> filename:join ([priv, Name])
      end;
    Dir -> filename:join (Dir, Name)
  end.


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
