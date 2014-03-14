-module (idealib_flops).
-export ([
  add/2, substract/2,
  integral/1, fractional/1,
  round/1, round/2
]).

-define (FP_PRECISION, 1000000000000000).
-define (FP_PP (X), ((X)*?FP_PRECISION)).
-define (FP_UNPP (X), ((X)/?FP_PRECISION)).

%% @doc Add two float numbers `X' and `Y'.
add (X, Y) -> ?FP_UNPP (?FP_PP (X) + ?FP_PP (Y)).

%% @doc Substract two float numbers `X' and `Y'.
substract (X, Y) -> ?FP_UNPP (?FP_PP (X) - ?FP_PP (Y)).

%% @doc Get an integral part of the float argument.
integral (X) when is_float (X) -> erlang:trunc (X).

%% @doc Get a fractional part of the float argument.
fractional (X) when is_float (X) ->
  substract (X, integral (X)).

-spec round (X::float ()) -> float ().
%% @doc Round a float->float.
%% Unlike the erlang:round/1, we don't return integer, but float.
round (X) when is_float (X) ->
    erlang:round (X) + 0.0.

-spec round (X::float (), Precision::non_neg_integer ()) -> float ().
%% @doc Round a float->float with specified precision.
%% Unlike the erlang:round/1, we don't return integer, but float.
round (X, 0) when is_float (X) -> % not necessary, but probably faster
    ?MODULE:round (X);
round (X, N) when is_float (X), is_integer (N), N >= 0 ->
    Shift = math:pow (10, N),
    ?MODULE:round (X * Shift) / Shift.

%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

common_test () ->

  %% Basic
  Frac = 0.123, Frac2 = 0.678, Int = 678, F = add (Int, Frac),
  ?assertEqual (F, add (Int, Frac)),
  ?assertEqual (Int, integral (F)),
  ?assertEqual (Frac, fractional (F)),
  ?assertEqual (F, add (integral (F), fractional (F))),
  ?assertEqual (0.0, ?MODULE:round (Frac)),
  ?assertEqual (0.12, ?MODULE:round (Frac, 2)),
  ?assertEqual (0.123000, ?MODULE:round (Frac, 6)),
  ?assertEqual (-0.0, ?MODULE:round (-Frac)),
  ?assertEqual (-0.12, ?MODULE:round (-Frac, 2)),
  ?assertEqual (-0.123000, ?MODULE:round (-Frac, 6)),
  ?assertEqual (1.0, ?MODULE:round (Frac2)),
  ?assertEqual (0.68, ?MODULE:round (Frac2, 2)),
  ?assertEqual (0.678000, ?MODULE:round (Frac2, 6)),
  ?assertEqual (-1.0, ?MODULE:round (-Frac2)),
  ?assertEqual (-0.68, ?MODULE:round (-Frac2, 2)),
  ?assertEqual (-0.678000, ?MODULE:round (-Frac2, 6)),

  ok.

-endif.

