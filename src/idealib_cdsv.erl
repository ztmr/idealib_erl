-module (idealib_cdsv).
-export ([oneshot/2, oneshot/4, oneshot/5]).

%% Common delimiter-separated values parsing library

%-define (IDEALIB_CDSV_TIMEOUT, 2000).

oneshot (Data, Len) ->
  oneshot (Data, Len, $\n, $;).

oneshot (Data, Len, Rs, Fs) ->
  oneshot (Data, Len, Rs, Fs, fun list_to_tuple/1).

oneshot (Data, Len, Rs, Fs, Fun) ->
  parse (Data, Len, Rs, Fs, Fun).

%% XXX: stream parser server --> convert to gen_server
%% XXX: just a concept:
%%   {ok, SrvPid, SrvRef} = stream_open (fun record_mapper:map/1),
%%   stream_submit (SrvPid, SrvRef, <<"Hello,World;Foo,Bar,;Tom,Jerry">>),
%%   stream_close (SrvPid, SrvRef).
%stream_open (Fun) when is_fun (Fun, 1) ->
%  SrvRef = make_ref (),
%  Pid = spawn (stream_loop/2, [SrvRef, Fun, ?IDEALIB_CDSV_TIMEOUT]),
%  {ok, Pid, SrvRef}.
%
%stream_submit (Pid, SrvRef, Buffer) ->
%  MsgRef = make_ref (),
%  Pid ! {self (), SrvRef, submit, MsgRef, Buffer),
%  receive
%    {Server, SrvRef, done, MsgRef, Result} ->
%      Result;
%    Error -> {error, Error};
%    after ?IDEALIB_CDSV_TIMEOUT ->
%      throw (timed_out)
%  end.
%
%stream_close (Pid, SrvRef) ->
%  Pid ! {self (), SrvRef, close}.
%
%stream_loop (SrvRef, Fun, Timeout) ->
%  receive
%    {Client, SrvRef, submit, MsgRef, Buffer} ->
%      spawn (fun () ->
%               Client ! {self (), SrvRef, done, MsgRef, Fun (Buffer)}
%             end),
%      stream_loop (SrvRef, Fun, Timeout);
%    {Client, SrvRef, close} ->
%      ok;
%    after Timeout ->
%      throw (timed_out)
%  end.

parse (Data, Len, Rs, Fs, Fun) ->
  parse (Data, Len, Rs, Fs, Fun, [], [], []).

parse (<<>>, _Len, _Rs, _Fs, _Fun, RecAcc, _FieldAcc, []) ->
  lists:reverse (RecAcc);
parse (<<>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, Buf) ->
  parse (<<>>, Len, Rs, Fs, Fun,
    [map_record (Fun, Buf, FieldAcc, Len)|RecAcc], FieldAcc, []);
parse (<<Rs, T/binary>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, Buf) ->
  parse (T, Len, Rs, Fs, Fun,
    [map_record (Fun, Buf, FieldAcc, Len)|RecAcc], [], []);
parse (<<Fs, T/binary>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, Buf)
  when length (FieldAcc) < Len ->
  parse (T, Len, Rs, Fs, Fun, RecAcc,
    [idealib_binary:concat (lists:reverse (Buf))|FieldAcc], []);
parse (<<Fs, T/binary>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, _Buf) ->
  parse (T, Len, Rs, Fs, Fun, RecAcc, FieldAcc, [<<>>]);
parse (<<X, T/binary>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, []) ->
  parse (T, Len, Rs, Fs, Fun, RecAcc, FieldAcc, [<<X>>]);
parse (<<X, T/binary>>, Len, Rs, Fs, Fun, RecAcc, FieldAcc, Buf) ->
  parse (T, Len, Rs, Fs, Fun, RecAcc, FieldAcc, [<<X>>|Buf]).

map_record (RecMapFun, Buf, FieldAcc, Len) ->
  map_record (RecMapFun, Buf, FieldAcc, Len, <<>>).
map_record (RecMapFun, Buf, FieldAcc, Len, Default)
  when length (FieldAcc) < Len ->
  FlatBuf = idealib_binary:concat (lists:reverse (Buf)),
  WithPad = idealib_lists:pad ([FlatBuf|FieldAcc], Len, Default),
  RecMapFun (lists:reverse (WithPad));
map_record (RecMapFun, _Buf, FieldAcc, _Len, _Default) ->
  RecMapFun (lists:reverse (FieldAcc)).


%% EUnit Tests
-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").

oneshot_test () ->
  Fun = fun ?MODULE:oneshot/4,

  ?assertEqual ([
      {<<"Hello">>,<<"World">>,<<>>,<<>>},
      {<<"Foo">>,<<"Bar">>,<<>>,<<>>},
      {<<"Tom">>,<<"Jerry">>,<<>>,<<>>}],
    Fun (<<"Hello,World;Foo,Bar,;Tom,Jerry">>, 4, $;, $,)),

  ?assertEqual ([
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<"Bar">>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<"Hello,World;Foo,Bar,;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<"Hello">>,<<>>},
      {<<>>, <<>>},
      {<<"Foo">>,<<"Bar">>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<"Hello,,World;;Foo,Bar,;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>},
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<>>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<",;Hello,World;Foo,,Bar;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>},
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<>>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<";Hello,World;Foo,,Bar;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>},
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<>>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<",,,,,;Hello,World;Foo,,Bar;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>},
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<>>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<",;Hello,World;Foo,,Bar;Tom,Jerry,,,,">>, 2, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>,<<>>,<<>>},
      {<<"Hello">>,<<"World">>,<<>>,<<>>},
      {<<"Foo">>,<<>>,<<"Bar">>,<<>>},
      {<<"Tom">>,<<"Jerry">>,<<>>,<<>>}],
    Fun (<<",;Hello,World;Foo,,Bar;Tom,Jerry,,,,">>, 4, $;, $,)),

  ?assertEqual ([
      {<<>>,<<>>},
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<>>},
      {<<"Tom">>,<<"Jerry">>},
      {<<>>,<<>>},
      {<<>>,<<>>}],
    Fun (<<",;Hello,World;Foo,,Bar;Tom,Jerry;;;">>, 2, $;, $,)),

  ?assertEqual ([
      {<<"Hello">>,<<"World">>},
      {<<"Foo">>,<<"Bar">>},
      {<<"Tom">>,<<"Jerry">>}],
    Fun (<<"Hello,World;Foo,Bar,;Tom,Jerry">>, 2, $;, $,)),

  ?assertEqual ([
      {<<"Hello">>},
      {<<"Foo">>},
      {<<"Tom">>}],
    Fun (<<"Hello,World;Foo,Bar,,;Tom,Jerry">>, 1, $;, $,)),

  ?assertEqual ([{}, {}, {}],
    Fun (<<"Hello,World;Foo,Bar,,;Tom,Jerry">>, 0, $;, $,)),

  ok.

-endif.

