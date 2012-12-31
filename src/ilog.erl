%%
%% $Id: $
%%
%% Module:  ilog -- description
%% Created: 01-JAN-2013 00:50
%% Author:  tmr
%%

-module (ilog).

-export ([start/0, stop/0]).
-export ([info/1, info/2, warn/1, warn/2, err/1, err/2]).

start () -> application:start (lager).
stop () -> application:stop (lager).

info (Msg) -> info (Msg, []).
info (Msg, Args) -> lager:info (Msg, Args).

warn (Msg) -> warn (Msg, []).
warn (Msg, Args) -> lager:warn (Msg, Args).

err (Msg) -> err (Msg, []).
err (Msg, Args) -> lager:error (Msg, Args).

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
