%%
%% $Id: $
%%
%% Module:  idealib_dt -- DateTime Conversions
%% Created: 15-MAY-2013 09:02
%% Author:  tmr
%%

-module (idealib_dt).
-export ([
  now2ms/0, now2ms/1, ms2now/1,
  now2dt/0, now2dt/1, ms2dt/1,
  now2local/2, dt2local/2, timezones/0
  %% TODO: ISO timestamps
  %% dates library usage: shifts and ranges
]).

-include_lib ("tz_database.hrl").


%% @doc Convert erlang:now () to microseconds integer.
%% Since the argument is not supplied, default is
%% erlang:now () of the time when this function was called.
now2ms () -> now2ms (erlang:now ()).

%% @doc Convert erlang:now () to microseconds integer.
now2ms ({MegaSecs, Secs, MicroSecs}) ->
  (MegaSecs*1000000 + Secs)*1000000 + MicroSecs.

%% @doc Convert microseconds integer back to erlang:now () format.
ms2now (Ms) when is_integer (Ms) ->
  X = Ms div 1000000, MicroSecs = Ms rem 1000000,
  Secs = X rem 1000000, MegaSecs = X div 1000000,
  {MegaSecs, Secs, MicroSecs}.

%% @doc Convert erlang:now () to {date (), time ()}.
%% Use current value of erlang:now ().
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2dt () -> now2dt (now ()).

%% @doc Convert erlang:now () to {date (), time ()}.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2dt ({_, _, _} = Now) ->
  calendar:now_to_datetime (Now).

%% @doc Convert microseconds integer to {date (), time ()}.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
ms2dt (Ms) -> now2dt (ms2now (Ms)).

%% @doc List of all the available TimeZones.
timezones () ->
  proplists:get_keys (?tz_database).

%% @doc Apply timezone shift on {date (), time ()}.
dt2local ({{_, _, _}, {_, _, _}} = DT, Tz) ->
  case localtime:utc_to_local (DT, Tz) of
    {error, _} -> DT;
    WithTz     -> WithTz
  end.

%% @doc Convert erlang:now () to DateTime with TimeZone.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2local ({_, _, _} = Now, Tz) ->
  dt2local (now2dt (Now), Tz).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

common_test () ->

  %% Basic
  Now = now (),
  ?assertEqual (Now, ms2now (now2ms (Now))),

  ok.

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
