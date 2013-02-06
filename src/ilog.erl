%%
%% $Id: $
%%
%% Module:  ilog -- description
%% Created: 01-JAN-2013 00:50
%% Author:  tmr
%%

-module (ilog).

-export ([start/0, stop/0]).
-export ([
  debug/1, debug/2, dbg/1, dbg/2,
  info/1, info/2,
  notice/1, notice/2,
  warn/1, warn/2, warning/1, warning/2,
  err/1, err/2, error/1, error/2 %,
%  crit/1, crit/2, critical/1, critical/2,
%  alert/1, alert/2,
%  emergency/1, emergency/2
]).

start () -> application:start (lager).
stop () -> application:stop (lager).

dbg (Msg) -> debug (Msg).
dbg (Msg, Args) -> debug (Msg, Args).
debug (Msg) -> debug (Msg, []).
debug (Msg, Args) -> xlog (debug, Msg, Args).

info (Msg) -> info (Msg, []).
info (Msg, Args) -> xlog (info, Msg, Args).

notice (Msg) -> notice (Msg, []).
notice (Msg, Args) -> xlog (notice, Msg, Args).

warn (Msg) -> warn (Msg, []).
warn (Msg, Args) -> xlog (warn, Msg, Args).
warning (Msg) -> warn (Msg).
warning (Msg, Args) -> warn (Msg, Args).

err (Msg) -> err (Msg, []).
err (Msg, Args) -> xlog (error, Msg, Args).
error (Msg) -> err (Msg).
error (Msg, Args) -> err (Msg, Args).

xlog (Level, Msg, Args) ->
  lager:Level (Msg, Args).

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
