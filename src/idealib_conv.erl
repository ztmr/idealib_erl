%%
%% $Id: $
%%
%% Module:  idealib_conv -- Scalar Conversions
%% Created: 01-JAN-2013 03:02
%% Author:  tmr
%%

-module (idealib_conv).
-export ([
  str2int/1, str2int/2, str2int0/1,
  str2float/1, str2float/2, str2float0/1,

  x2bool/1, x2bool/2, x2bool0/1, x2bool1/1,
  x2int0/1, x2int/2, x2float0/1, x2float/2,
  x2str/1,

  int2float0/1, int2float/2,
  float2str/1,

  bool2str/1, bool2str/2, bool2str0/1, bool2str1/1,

  bits2int/1, bitstring2int/1
]).

%% XXX: Are we Unicode ready? NO! :-(

%% @doc Convert a string `S' to integer.
%% If it is not possible, fall back to
%% zero as a default value.
str2int0 (S) -> str2int (S, 0).

%% @doc Convert a string `S' to integer.
%% If it is not possible, fall back to
%% {error, invalid_integer}.
str2int (S) -> str2int (S, {error, invalid_integer}).

%% @doc Convert a string `S' to integer.
%% If it is not possible, fall back to
%% the specified default value of `D'.
%%
%% XXX: what about catch-error trapping
%% performance implications? how significant
%% is the penalty?
str2int ([], D) -> D;
str2int (S, _) when is_integer (S) -> S;
str2int (S, D) when is_list (S) ->
  % NOTE: what's the difference between
  % string:to_integer and erlang:list_to_integer?
  case catch (string:to_integer (S)) of
    {error, _}  -> D;
    {X, _}      -> X;
    _           -> D
  end;
str2int (_, D) -> D.


%% @doc Convert a string `S' to float.
%% If it is not possible, fall back to
%% zero as a default value.
str2float0 (S) -> str2float (S, 0.0).

%% @doc Convert a string `S' to float.
%% If it is not possible, fall back to
%% {error, invalid_float}.
str2float (S) -> str2float (S, {error, invalid_float}).

%% @doc Convert a string `S' to float.
%% If it is not possible, fall back to
%% the specified default value of `D'.
%%
%% XXX: what about catch-error trapping
%% performance implications? how significant
%% is the penalty?
%%
%% XXX: possible multiculture issues since the
%% comma character is treated as a fullfeatured
%% FP separator equivalent to the dot character.
str2float ([], D) -> D;
str2float (S, _) when is_float (S) -> S;
str2float ([$.|S], D) -> str2float ([$0,$.|S], D);
str2float ([$-,$.|S], D) -> str2float ([$-,$0,$.|S], D);
str2float ([$+,$.|S], D) -> str2float ([$0,$.|S], D);
str2float (S, D) when is_list (S) ->
  case catch (string:to_float (S)) of
    {error, _} ->
      case str2int (S) of
        {error, _} -> D;
        Value      -> Value + 0.0
      end;
    {X, _}     -> X
  end;
str2float (_, D) -> D.

float2str (X) when is_float (X) ->
    mochinum:digits (X).

%% @doc Convert value of `S' to a boolean value.
%% If it is not possible, fall back to `false'.
x2bool0 (S) ->
  x2bool (S, false).

%% @doc Convert value of `S' to a boolean value.
%% If it is not possible, fall back to `true'.
x2bool1 (S) ->
  x2bool (S, true).

%% @doc Convert value of `S' to boolean.
%% If it is not possible, fall back to
%% {error, invalid_boolean}.
x2bool (S) -> x2bool (S, {error, invalid_boolean}).

%% @doc Convert value of `S' to boolean.
%% If it is not possible, fall back to
%% the specified default value of `D'.

%% Default fallback phase 1:
x2bool ([], D) -> D;
x2bool (undefined, D) -> D;

%% Straightforward true/false representation:
x2bool (0, _) -> false;
x2bool (1, _) -> true;
x2bool (0.0, _) -> false;
x2bool (1.0, _) -> true;
x2bool (false, _) -> false;
x2bool (true, _) -> true;
x2bool ("1", _) -> true;    %% x2bool_s optimization
x2bool ("0", _) -> false;   %% x2bool_s optimization
x2bool (S, D) when is_list (S) -> x2bool_s (string:to_lower (S), D);

%% Default fallback phase 2:
x2bool (_, D) -> D.

%% String representations
x2bool_s ("false", _) -> false;
x2bool_s ("true", _) -> true;
x2bool_s ("n", _) -> false;
x2bool_s ("y", _) -> true;
%% Double-trick:
%% (1) str2float ("0") = str2float ("0.0") = 0.0 -> false;
%% (2) str2float may return {error, _}, and x2bool ({error, _}, D) -> D.
x2bool_s (X, D) -> x2bool (str2float (X), D).


%% @doc Convert a boolean value `B' to a string.
%% If it is not possible, fall back to `0'.
%% Default string representation is true="1", false="0".
bool2str0 (B) ->
  bool2str (B, "0").

%% @doc Convert a boolean value `B' to a string.
%% If it is not possible, fall back to `1'.
%% Default string representation is true="1", false="0".
bool2str1 (B) ->
  bool2str (B, "1").

%% @doc Convert a boolean value `B' to a string.
%% If it is not possible, fall back to
%% {error, invalid_boolean}.
%% Default string representation is true="1", false="0".
bool2str (B) -> bool2str (B, {error, invalid_boolean}).

%% @doc Convert a boolean value `B' to a string.
%% If it is not possible, fall back to
%% the specified default value of `D'.
%% Default string representation is true="1", false="0".
bool2str (true, _) -> "1";
bool2str (false, _) -> "0";

%% A little trick: x2bool may return {error, _} what fallbacks to D.
bool2str ({error, _}, D) -> D;
bool2str (B, D) -> bool2str (x2bool (B), D).


x2str (undefined) -> [];
x2str (T) when is_list (T) ->
  case idealib_lists:is_utf_string (T) of
    true -> T;
    false -> x2str_fallback (T)
  end;
x2str (T) when is_atom (T) -> atom_to_list (T);
x2str (T) when is_integer (T) -> integer_to_list (T);
x2str (T) when is_float (T) -> float2str (T);
%% XXX: what about binaries?
x2str (T) -> x2str_fallback (T).

x2str_fallback (T) -> lists:flatten (io_lib:format ("~w", [T])).


%% @doc Try to convert whatever to integer.
%% If the number is float, only the integral part
%% is used. That means two things:
%%   * fractional part is loosed => irreversible operation
%%   * if you want to round up/down the float,
%%     use another functions shipped with this library
x2int0 (X) -> x2int (X, 0).

%% @doc Try to convert whatever to integer.
%% If the number is float, only the integral part
%% is used. That means two things:
%%   * fractional part is loosed => irreversible operation
%%   * if you want to round up/down the float,
%%     use another functions shipped with this library
x2int (X, _) when is_integer (X) -> X;
x2int (X, _) when is_float (X) -> idealib_flops:integral (X);
x2int (X, D) -> str2int (x2str (X), D).


%% @doc Try to convert whatever to float.
%% Default value is 0.0.
x2float0 (X) -> x2float (X, 0.0).

%% @doc Try to convert whatever to float with optional fallback value.
x2float (X, _) when is_float (X) -> X;
x2float (X, D) when is_integer (X) -> int2float (X, D);
x2float (X, D) -> str2float (x2str (X), D).


%% XXX: To be moved to idealib_flops...

%% @doc Convert integer to float.
%% Fall back to zero.
int2float0 (X) -> int2float (X, 0.0).

%% @doc Convert integer to float.
%% XXX: what's the difference to erlang:float (X)?
int2float (X, _) when is_integer (X) -> X+0.0;  %% trick :)
int2float (_, D) -> D.

%% @doc Alias for `bitstring2int/0'.
bits2int (Bits) -> bitstring2int (Bits).

%% @doc Convert a list of bits into a valid integer.
%% The list length must be divisible by eight.
bitstring2int (Bits) ->
    bitstring2int_ (Bits, 0).

bitstring2int_ ([], Acc) -> Acc;
bitstring2int_ ([X8, X7, X6, X5, X4, X3, X2, X1 | T], Acc) ->
    X = (X8 bsl 7) bor (X7 bsl 6) bor (X6 bsl 5) bor (X5 bsl 4) bor
        (X4 bsl 3) bor (X3 bsl 2) bor (X2 bsl 1) bor X1,
    bitstring2int_ (T, X bor (Acc bsl 8)).

%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

str2int_test () ->

  %% Basic
  ?assertEqual (0, str2int ("0", error)),
  ?assertEqual (123, str2int ("123", error)),
  ?assertEqual (-123, str2int ("-123", error)),
  ?assertEqual (-123, str2int ("-123", error)),
  ?assertEqual (-123, str2int ([$-,$1,$2,$3], error)),

  %% Get only the number on the beginning of the string
  ?assertEqual (0, str2int ("0.0", error)),
  ?assertEqual (-123, str2int ("-123b", error)),

  %% Errors due to non-integer string content
  ?assertEqual (error, str2int ("a123", error)),
  ?assertEqual (error, str2int ("akdfs", error)),

  %% Errors due to non-string argument
  ?assertEqual (error, str2int ([1,2,3,4], error)),
  ?assertEqual (error, str2int ({"123"}, error)),
  ?assertEqual (error, str2int ({-123}, error)),

  ok.

str2float_test () ->

  %% Basic
  ?assertEqual (0.0, str2float ("0.0", error)),
  ?assertEqual (123.456, str2float ("123.456", error)),
  ?assertEqual (-123.456, str2float ("-123.456", error)),
  ?assertEqual (-123.456, str2float ("-123.456", error)),
  ?assertEqual (-123.456, str2float ([$-,$1,$2,$3,$.,$4,$5,$6], error)),

  %% Get only the number on the beginning of the string
  ?assertEqual (0.123, str2float ("0.123.4.5.6.7.8", error)),
  ?assertEqual (123.0, str2float ("123", error)),
  ?assertEqual (-123.456, str2float ("-123.456b", error)),

  %% Handle the MUMPS-like floats in ".123" and "-.123"
  %% format what is the same as 0.123 and -0.123
  ?assertEqual (0.123, str2float (".123", error)),
  ?assertEqual (0.123, str2float ("+.123", error)),
  ?assertEqual (-0.123, str2float ("-.123", error)),

  %% Errors due to non-integer string content
  ?assertEqual (error, str2float ("a123", error)),
  ?assertEqual (error, str2float ("akdfs", error)),

  %% Errors due to non-string argument
  ?assertEqual (error, str2float ([1,2,3,4], error)),
  ?assertEqual (error, str2float ({"123"}, error)),
  ?assertEqual (error, str2float ({-123}, error)),

  ok.

float2str_test () ->

  %% Basic
  ?assertEqual ("0.0", float2str (0.0)),
  ?assertEqual ("1500.0", float2str (1.5e3)),
  ?assertEqual ("123.456", float2str (123.456)),
  ?assertEqual ("-123.456", float2str (-123.456)),
  ?assertEqual ("-123.456", float2str (-123.45600)),
  ?assertMatch ({'EXIT', {function_clause, _}},
                catch (float2str (undefined))),

  ok.

x2bool_test () ->

  %% Basic
  ?assertEqual (false, x2bool0 ([])),
  ?assertEqual (true, x2bool1 (undefined)),
  ?assertEqual (false, x2bool (0.0)),
  ?assertEqual (false, x2bool0 (123.456)),
  ?assertEqual (true, x2bool1 (123.456)),
  ?assertEqual (true, x2bool (true)),
  ?assertEqual (true, x2bool ("1")),
  ?assertEqual (false, x2bool ("0")),
  ?assertEqual (false, x2bool (0.0)),
  ?assertEqual (true, x2bool (1.0)),
  ?assertEqual ({error, invalid_boolean}, x2bool (123.456)),
  ?assertEqual ({error, invalid_boolean}, x2bool ([])),
  ?assertEqual ({error, invalid_boolean}, x2bool (undefined)),
  ?assertEqual (false, x2bool ("N")),
  ?assertEqual (true, x2bool ("Y")),
  ?assertEqual (false, x2bool ("0", test)),
  ?assertEqual (false, x2bool ("0.0", test)),
  ?assertEqual (test, x2bool ("0.1", test)),
  ?assertEqual (test, x2bool ("whatever", test)),

  ok.

bool2str_test () ->

  %% Basic
  ?assertEqual ("0", bool2str0 (false_liar)),
  ?assertEqual ("1", bool2str1 (truly_liar)),
  ?assertEqual ("0", bool2str (0.0)),
  ?assertEqual ("0", bool2str0 (123.456)),
  ?assertEqual ("1", bool2str1 (123.456)),
  ?assertEqual ("1", bool2str (true)),
  ?assertEqual ("1", bool2str ("1")),
  ?assertEqual ("0", bool2str ("0")),
  ?assertEqual ("0", bool2str (0.0)),
  ?assertEqual ("1", bool2str (1.0)),
  ?assertEqual ({error, invalid_boolean}, bool2str (123.456)),
  ?assertEqual ({error, invalid_boolean}, bool2str ([])),
  ?assertEqual ({error, invalid_boolean}, bool2str (undefined)),
  ?assertEqual ("0", bool2str ("N")),
  ?assertEqual ("1", bool2str ("Y")),
  ?assertEqual ("0", bool2str ("0", test)),
  ?assertEqual ("0", bool2str ("0.0", test)),
  ?assertEqual (test, bool2str ("0.1", test)),
  ?assertEqual (test, bool2str ("whatever", test)),

  ok.

x2str_test () ->

  %% Basic
  ?assertEqual ("", x2str ([])),
  ?assertEqual ("0.0", x2str (0.0)),
  ?assertEqual ("123.456", x2str (123.456)),
  ?assertEqual ("-123.456", x2str (-123.456)),
  ?assertEqual ("1500.0", x2str (1.5e3)),
  ?assertEqual ("-123.456", x2str ([$-,$1,$2,$3,$.,$4,$5,$6])),
  ?assertEqual ([283,353,269,345,382,253,225,237,233],
         x2str ([283,353,269,345,382,253,225,237,233])),
  ?assertEqual ("abc", x2str ("abc")),
  ?assertEqual ("abc", x2str ([$a,$b,$c])),
  ?assertEqual ("[1,2,3]", x2str ([1,2,3])),
  ?assertEqual ("", x2str (undefined)),
  ?assertEqual ("true", x2str (true)),
  ?assertEqual ("false", x2str (false)),
  ?assertEqual ("{ok,{the,{result,{is,1}}}}",
    x2str ({ok, {the, {result, {is, 1}}}})),

  ok.

x2int_test () ->

  %% Basic
  ?assertEqual (0, x2int0 (0)),
  ?assertEqual (0, x2int0 ([])),
  ?assertEqual (0, x2int0 ("0")),
  ?assertEqual (0, x2int0 ("0.1")),
  ?assertEqual (0, x2int0 (0.1)),
  ?assertEqual (0, x2int0 ("0,1")),
  ?assertEqual (error, x2int ([], error)),
  ?assertEqual (1, x2int (1.0, error)),

  ok.

x2float_test () ->

  %% Basic
  ?assertEqual (0.0, x2float0 (0)),
  ?assertEqual (0.0, x2float0 ([])),
  ?assertEqual (0.0, x2float0 ("0")),
  ?assertEqual (0.1, x2float0 ("0.1")),
  ?assertEqual (0.1, x2float0 (0.1)),
  ?assertEqual (0.1, x2float0 ("0,1")), %% XXX: should depend on culture!!
  ?assertEqual (error, x2float ([], error)),
  ?assertEqual (1.2, x2float (1.2, error)),

  ok.

int2float_test () ->

  %% Basic
  ?assertEqual (0.0, int2float0 (0)),
  ?assertEqual (1.0, int2float0 (1)),
  ?assertEqual (0.0, int2float0 ("1")),
  ?assertEqual (0.0, int2float0 ("0")),
  ?assertEqual (0.0, int2float0 ("0.1")),
  ?assertEqual (0.0, int2float0 (0.1)),
  ?assertEqual (0.0, int2float0 ("0,1")),
  ?assertEqual (error, int2float ([], error)),
  ?assertEqual (1.0, int2float (1, error)),
  ?assertEqual (error, int2float (1.0, error)),

  ok.

bitstring2int_test () ->

  %% Basic
  ?assertEqual (5,   bitstring2int ([0,0,0,0, 0,1,0,1])),
  ?assertEqual (128, bitstring2int ([1,0,0,0, 0,0,0,0])),
  ?assertEqual (133, bitstring2int ([1,0,0,0, 0,1,0,1])),

  MkRand = fun (N) ->
                   [ random:uniform (1024) rem 2
                     || _ <- lists:seq (1, N) ]
           end,
  BL2I = fun (X) -> list_to_integer ([ $0+Xi || Xi <- X ], 2) end,

  [ (?assertEqual (BL2I (R), bitstring2int (R)))
    || R <- [ MkRand (4 bsl Si) || Si <- lists:seq (1, 10) ] ],

  ok.

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
