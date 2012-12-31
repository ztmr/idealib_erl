-module(idealib_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-export ([register_modules/1, unregister_modules/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    idealib_sup:start_link().

stop(_State) ->
    ok.

register_modules (Modules) ->
  ok.

unregister_modules () ->
  ok.

