-module (idealib_flops).
-export ([
  add/2, substract/2,
  integral/1, fractional/1
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


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

common_test () ->

  %% Basic
  Frac = 0.123, Int = 678, F = add (Int, Frac),
  ?assertEqual (F, add (Int, Frac)),
  ?assertEqual (Int, integral (F)),
  ?assertEqual (Frac, fractional (F)),
  ?assertEqual (F, add (integral (F), fractional (F))),

  ok.

-endif.

