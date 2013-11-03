-module (idealib_xml).
-export ([from_url/2, from_file/2, from_string/2]).
-export ([to_file/3, to_string/2]).

%load_file (XSDFile, XMLFile) ->
%  {ok, Xml} = file:read_file (XMLFile),
%  load_string (XSDFile, Xml).

%% @doc Load `XSDFile' model and use it to parse `XMLUrl' (remote URL).
from_url (XSDFile, XMLUrl) ->
  ok = idealib_misc:ensure_app (ibrowse),
  {ok, _Code, _Hdrs, XMLString} = ibrowse:send_req (XMLUrl, [], get),
  from_string (XSDFile, XMLString).

%% @doc Load `XSDFile' model and use it to parse `XMLFile' (local file path).
from_file (XSDFile, XMLFile) ->
  %% Hm, there was a way how to pre-compile XSD once for future needs
  {ok, Model} = erlsom:compile_xsd_file (XSDFile),
  {ok, Document, _} = erlsom:scan_file (XMLFile, Model),
  Document.

%% @doc Load `XSDFile' model and use it to parse `XMLString'.
from_string (XSDFile, XMLString) ->
  %% Hm, there was a way how to pre-compile XSD once for future needs
  {ok, Model} = erlsom:compile_xsd_file (XSDFile),
  {ok, Document, _} = erlsom:scan (XMLString, Model),
  Document.

%% @doc Serialize `XMLDocument' as a string with use of `XSDFile' model.
to_string (XSDFile, XMLDocument) ->
  %% Hm, there was a way how to pre-compile XSD once for future needs
  {ok, Model} = erlsom:compile_xsd_file (XSDFile),
  {ok, XMLString} = erlsom:write (XMLDocument, Model),
  XMLString.

%% @doc Serialize `XMLDocument' and write it to `XMLFile'.
to_file (XSDFile, XMLDocument, XMLFile) ->
  Cvt = fun unicode:characters_to_binary/1,
  file:write_file (XMLFile, Cvt (to_string (XSDFile, XMLDocument))).
