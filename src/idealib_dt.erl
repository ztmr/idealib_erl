%%
%% $Id: $
%%
%% Module:  idealib_dt -- DateTime Conversions
%% Created: 15-MAY-2013 09:02
%% Author:  tmr
%%
%% @doc Date and time library.
%% Base time epoch is the UNIX one, so microsecond (us),
%% now and datetime functions operate with positive or
%% negative shift relative to 01-JAN-1970 00:00:00.
%%
%% Gsec functions operates relatively to the 01-JAN-0000 00:00:00,
%% so for example `idealib_dt:gsec2now (0)' correctly gives result
%% of {-62167,-219200,0}, the equivalent of Gregorian zero-time.
%%
%% Horolog functions are relative to the standard MUMPS epoch
%% of 31-DEC-1840 00:00:00, so for example `idealib_dt:gsec2horolog (0)'
%% correctly gives {-672411,0}.
%%
%% WARNING: be careful when converting microseconds (us2* function family)
%% to whatever else and back (*2us functions) -- only the `now' format
%% handle microseconds! All the rest (datetime, gregorian seconds) looses
%% the information on anything smaller than a single second.
%% So, for example:
%% ```
%% erl> N = erlang:timestamp ().
%% {1368,803088,971319}
%% erl> X = idealib_dt:now2us (N).
%% 1368803088971319
%% erl> Y = idealib_dt:dt2us (idealib_dt:us2dt (X)).
%% 1368803088000000
%% erl> idealib_dt:us2now (Y).
%% {1368,803088,0}
%% '''

-module (idealib_dt).
-export ([
  sec2us/1, days2sec/1,
  now2us/0, now2us/1, now2dt/0, now2dt/1,
  dt2gsec/1, dt2now/1, dt2us/1,
  us2now/1, us2dt/1,
  gsec2dt/1, gsec2now/1,

  dt2iso/1, iso2dt/1,

  dt2horolog/1, dt2horologstr/1,
  horolog2dt/1, horolog2str/1,
  gsec2horolog/1, horolog2gsec/1,

  epoch2gsec/1,
  now2local/2, dt2local/2, timezones/0,
  %% TODO: ISO timestamps
  %% dates library usage: shifts and ranges

  str2dt/2,

  dt_compare/2
]).

-include_lib ("tz_database.hrl").


%% @doc Convert erlang:timestamp () to microseconds integer.
%% Since the argument is not supplied, default is
%% erlang:timestamp () of the time when this function was called.
now2us () -> now2us (erlang:timestamp ()).

%% @doc Convert erlang:timestamp () to microseconds integer.
now2us ({MegaSecs, Secs, MicroSecs}) ->
  (MegaSecs*1000000 + Secs)*1000000 + MicroSecs.

%% @doc Convert microseconds integer back to erlang:timestamp () format.
us2now (Ms) when is_integer (Ms) ->
  X = Ms div 1000000, MicroSecs = Ms rem 1000000,
  Secs = X rem 1000000, MegaSecs = X div 1000000,
  {MegaSecs, Secs, MicroSecs}.

%% @doc Convert erlang:timestamp () to {date (), time ()}.
%% Use current value of erlang:timestamp ().
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2dt () -> now2dt (erlang:timestamp ()).

%% @doc Convert erlang:timestamp () to {date (), time ()}.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2dt ({_, _, _} = Now) ->
  calendar:now_to_datetime (Now).

%% @doc Convert microseconds integer to {date (), time ()}.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
us2dt (Ms) -> now2dt (us2now (Ms)).

%% @doc Convert a datetime to erlang:timestamp format.
dt2now ({{_,_,_}, {_,_,_}} = DT) ->
  GregSec = calendar:datetime_to_gregorian_seconds (DT),
  Sec = GregSec - epoch2gsec (unix),
  {Sec div 1000000, Sec rem 1000000, 0}.

%% @doc Convert a datetime to microseconds.
dt2us ({{_,_,_}, {_,_,_}} = DT) ->
  now2us (dt2now (DT)).

%% @doc Convert a specified epoch to gregorian seconds.
epoch2gsec (erlang) -> epoch2gsec (unix);
epoch2gsec (unix)   -> 62167219200; %% = dt2gsec ({{1970,01,01},{0,0,0}})
epoch2gsec (mumps)  -> 58096310400; %% = dt2gsec ({{1840,12,31},{0,0,0}})
epoch2gsec (vms)    -> 58660502400; %% = dt2gsec ({{1858,11,17},{0,0,0}})
epoch2gsec (_)      -> 0.

%% @doc Convert a specified date-time to gregorian seconds.
dt2gsec ({{_,_,_}, {_,_,_}} = DT) ->
  calendar:datetime_to_gregorian_seconds (DT).

%% @doc Convert seconds to microseconds.
sec2us (S) when is_integer (S) ->
  S*1000000.

%% @doc Convert number of days to seconds.
days2sec (D) when is_integer (D) -> D*86400.

%% @doc Convert gregorian seconds to erlang:timestamp format.
gsec2now (S) when is_integer (S) ->
  us2now (sec2us (S - epoch2gsec (unix))).

%% @doc Convert gregorian seconds to datetime tuple.
gsec2dt (S) -> now2dt (gsec2now (S)).

%% @doc Convert date-time tuple to MUMPS $Horolog.
dt2horolog (S) -> gsec2horolog (dt2gsec (S)).

%% @doc Convert MUMPS $Horolog to date-time tuple.
horolog2dt (S) -> gsec2dt (horolog2gsec (S)).

%% @doc Convert Gregorian seconds to MUMPS $Horolog.
gsec2horolog (S) when is_integer (S) ->
  DaySec = days2sec (1),
  HoroSec = (S - epoch2gsec (mumps)),
  {HoroSec div DaySec, HoroSec rem DaySec}.

%% @doc Convert MUMPS $Horolog to gregorian seconds.
%% For $H="62959,49838", we accept {62959, 49838}, "62959,49838",
%% or 62959, or "62959".
horolog2gsec ({HD, HS}) when is_number (HD), is_number (HS) ->
  DaySec = days2sec (1),
  epoch2gsec (mumps) + HD*DaySec + HS;
horolog2gsec (HD) when is_number (HD) ->
  horolog2gsec ({HD, 0});
horolog2gsec (H) when is_binary (H) ->
  horolog2gsec (binary_to_list (H));
horolog2gsec (H) when is_list (H) ->
  S2I = fun idealib_conv:str2int0/1,
  case epiece:piece (H, ",") of
    [HD, HS] -> horolog2gsec ({S2I (HD), S2I (HS)});
    [HD]     -> horolog2gsec (S2I (HD));
    _        -> 0
  end.

%% @doc Convert $Horolog tuple to $H string.
horolog2str ({HD,HS}) ->
  idealib_conv:x2str (HD) ++ "," ++ idealib_conv:x2str (HS).

%% @doc Convert Erlang DateTime to $H string.
dt2horologstr (D) ->
  horolog2str (dt2horolog (D)).

%% @doc List of all the available TimeZones.
timezones () ->
  proplists:get_keys (?tz_database).

%% @doc Apply timezone shift on {date (), time ()}.
dt2local ({{_, _, _}, {_, _, _}} = DT, Tz) ->
  case localtime:utc_to_local (DT, Tz) of
    {error, _} -> DT;
    WithTz     -> WithTz
  end.

%% @doc Convert erlang:timestamp () to DateTime with TimeZone.
%% WARNING: this is one-way function since it looses
%% information (datetime is based on number of seconds)!
now2local ({_, _, _} = Now, Tz) ->
  dt2local (now2dt (Now), Tz).

dt2iso (DateTime) ->
  binary_to_list (iso8601:format (DateTime)).

%dt2iso ({{Year, Month, Day}, {Hr, Min, Sec}}) ->
%  S = fun (X, L) ->
%    idealib_lists:pad (idealib_conv:x2str (X), L, $0)
%  end,
%  lists:concat ([
%    S (Year,  4), "-",
%    S (Month, 2), "-",
%    S (Day,   2), "T",
%    S (Hr,    2), ":",
%    S (Min,   2), ":",
%    S (Sec,   2), "Z" ]).

iso2dt (IsoBinary) when is_binary (IsoBinary) ->
  iso2dt (binary_to_list (IsoBinary));
iso2dt (IsoString) when is_list (IsoString) ->
  iso8601:parse (IsoString).

%% XXX: Ignores zone!
%iso2dt (IsoString) when is_list (IsoString) ->
%  [D, Tz] = epiece:piece (IsoString, [$T]),
%  [T, _Z] = epiece:piece (Tz, [$Z]),
%  {DY@, DM@, DD@} = list_to_tuple ([ idealib_conv:str2int0 (X)
%                                     || X <- epiece:piece (D, [$-]) ]),
%  {TH@, TM@, TS@} = list_to_tuple ([ idealib_conv:str2int0 (X)
%                                     || X <- epiece:piece (T, [$:]) ]),
%  {{DY@, DM@, DD@}, {TH@, TM@, TS@}}.

%% Example usage:
%%  str2dt ("08.9  . 2013", "%m.%d.%Y") -> {{2013, 9, 8}, {0, 0, 0}}
%% XXX: we currently support only %m, %d and %Y
%str2dt (DTString, Format) ->
%    G = fun (Key, Props) -> proplists:get_value (Key, Props) end,
%    X2I0 = fun idealib_conv:x2int0/1,
%    ParseIntRangeFun =
%        fun (Min, Max) ->
%                fun
%                    (X) when Min =< X andalso Max =< Max -> {ok, X};
%                    (_) -> {error, invalid_format}
%                end
%        end,
%    Handlers = [
%                {"Y", ParseIntRangeFun (1000, 9999)},
%                {"m", ParseIntRangeFun (1, 12)},
%                {"D", ParseIntRangeFun (1, 31)},  %% XXX: check it in context of the month
%                {"H", ParseIntRangeFun (0, 24)},
%                {"M", ParseIntRangeFun (0, 59)},
%                {"S", ParseIntRangeFun (0, 59)}
%               ],
%    case idealib_fmt:parse (DTString, Format, Handlers) of
%        {ok, Res} ->
%            {ok, {{G ("Y", Res), G ("m", Res), G ("D", Res)},
%                  {G ("H", Res), G ("M", Res), G ("S", Res)}}};
%        {error, _} = Error ->
%            Error
%    end.

%% Predefined, well-known, and temporary solutions
str2dt (DTBinary, Fmt) when is_binary (DTBinary) ->
  str2dt (binary_to_list (DTBinary), Fmt);
str2dt (DTString, cz_standard_date) when is_list (DTString) ->
    G = fun (X) ->
                idealib_conv:x2int0 (string:strip (X))
        end,
    case string:tokens (DTString, ".") of
        [D0, M0, Y0] ->
            Y1 = G (Y0),
            M1 = G (M0),
            D1 = G (D0),
            {ok, {{Y1, M1, D1}, {0, 0, 0}}};
        _ ->
            {error, invalid_format}
    end.


%% @doc True if DateTime `DT1' is before DateTime `DT2'.
%% False otherwise.
dt_compare (DT1, DT2) ->
  dt2gsec (DT1) < dt2gsec (DT2).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

common_test () ->
  %% Basic
  {N0,N1,N2} = Now = erlang:timestamp (), R = random:uniform (N0+N1+N2),
  DT = now2dt (Now), DTSec = dt2gsec (DT),
  ?assertEqual (Now, us2now (now2us (Now))),
  ?assertEqual ({N0,N1,0}, dt2now (now2dt (Now))),
  ?assertEqual (DT, us2dt (dt2us (DT))),
  ?assertEqual (DTSec, dt2gsec (us2dt (dt2us (DT)))),
  ?assertEqual (DTSec+R, dt2gsec (us2dt (dt2us (DT)+R*1000000))),
  ok.

compare_test () ->
  ?assertEqual (true, dt_compare ({{2013,1,1},{1,2,3}}, {{2013,1,1}, {4,5,6}})),
  ?assertEqual (false, dt_compare ({{2013,1,1},{1,2,3}}, {{2012,1,1}, {4,5,6}})),
  ?assertEqual (true, dt_compare ({{2012,1,1},{1,2,3}}, {{2013,1,1}, {4,5,6}})),
  ?assertEqual (false, dt_compare ({{2012,1,1},{1,2,3}}, {{2012,1,1}, {1,2,3}})),
  ok.

horolog_test () ->
  %% GTM>w $zd("62959,50058","YEAR-MM-DD 24:60:SS")
  %% 2013-05-17 13:54:18
  GSecs = round (now2us ({1,1,0}) / 1000000) - epoch2gsec (unix),
  DaySecs = idealib_dt:days2sec (1),
  Horo1 = "62959,50058", Horo2 = {62959, 50058},
  DThd = {2013,5,17}, DT = {DThd, {13,54,18}},
  ?assertEqual (epoch2gsec (mumps), horolog2gsec ({0,0})),
  ?assertEqual (epoch2gsec (mumps)+60, horolog2gsec ({0,60})),
  ?assertEqual (epoch2gsec (mumps)+DaySecs, horolog2gsec ({1,0})),
  ?assertEqual (GSecs, horolog2gsec (gsec2horolog (GSecs))),
  ?assertEqual (DT, horolog2dt (Horo1)),
  ?assertEqual (DT, horolog2dt (list_to_binary (Horo1))),
  ?assertEqual (DT, horolog2dt (Horo2)),
  ?assertEqual ({DThd, {0,0,0}}, horolog2dt (element (1, Horo2))),
  ?assertEqual ({DThd, {0,0,0}}, horolog2dt (idealib_conv:x2str (element (1, Horo2)))),
  ?assertEqual (Horo1, horolog2str (Horo2)),
  ?assertEqual (Horo1, dt2horologstr (DT)),
  ok.

epoch_test () ->
  ?assertEqual (dt2gsec ({{1970, 1, 1},{0,0,0}}), epoch2gsec (unix)),
  ?assertEqual (dt2gsec ({{1840,12,31},{0,0,0}}), epoch2gsec (mumps)),
  ?assertEqual (dt2gsec ({{1858,11,17},{0,0,0}}), epoch2gsec (vms)),
  ok.

dtiso_test () ->
  ?assertEqual ("2013-01-01T01:02:03Z", dt2iso ({{2013,1,1},{1,2,3}})),
  ?assertEqual ({{2013,1,1},{1,2,3}}, iso2dt ("2013-01-01T01:02:03Z")),
  ?assertEqual ({{2013,1,1},{1,2,3}}, iso2dt (<<"2013-01-01T01:02:03Z">>)),
  NowDT = {date (), time ()},
  ?assertEqual (NowDT, iso2dt (dt2iso (NowDT))),
  ?assertMatch ({'EXIT', _}, catch (iso2dt (""))),
  ok.

str2dt_test () ->
    DT = {{2013, 6, 3}, {0, 0, 0}},
    ?assertMatch ({ok, DT},
                  str2dt ("3.6.2013", cz_standard_date)),
    ?assertMatch ({ok, DT},
                  str2dt ("  3.  6.  2013  ", cz_standard_date)),
    ?assertMatch ({ok, DT},
                  str2dt ("03.06.2013", cz_standard_date)),
    ?assertMatch ({ok, DT},
                  str2dt ("  03. 06.  2013", cz_standard_date)),
    ?assertMatch ({ok, DT},
                  str2dt (<<"  03. 06.  2013">>, cz_standard_date)),
    ok.

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
