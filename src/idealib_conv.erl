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
  str2float/1, str2float/2, str2float0/1 %,
  %x2int/1,
  %x2float/1,
  %x2str/1
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
%% XXX: what about error trapping
%% performance implications?
str2int ([], D) -> D;
str2int (S, _) when is_integer (S) -> S;
str2int (S, D) when is_list (S) ->
  % NOTE: what's the difference between
  % string:to_integer and erlang:list_to_integer?
  case catch (string:to_integer (S)) of
    {'EXIT', _} -> D;
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
%% XXX: what about error trapping
%% performance implications?
str2float ([], D) -> D;
str2float (S, _) when is_float (S) -> S;
str2float ([$.|S], D) -> str2float ([$0,$.|S], D);
str2float (S, D) when is_list (S) ->
  case catch (string:to_float (S)) of
    {'EXIT',_} -> str2int (S, D) + 0.0;
    {error, _} -> D;
    {X, _}     -> X
  end;
str2float (_, D) -> D.


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
  ?assertEqual (0.123, str2float ("0.123a.4.5.6.7.8", error)),
  ?assertEqual (-123.456, str2float ("-123.456b", error)),

  %% Errors due to non-integer string content
  ?assertEqual (error, str2float ("a123", error)),
  ?assertEqual (error, str2float ("akdfs", error)),

  %% Errors due to non-string argument
  ?assertEqual (error, str2float ([1,2,3,4], error)),
  ?assertEqual (error, str2float ({"123"}, error)),
  ?assertEqual (error, str2float ({-123}, error)),

  ok.

-endif.

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
