-module (epiece_nif).

-export ([piece/2]).
-on_load (nif_init/0).

nif_init () ->
  SoName = idealib_misc:get_priv_dir_item (idealib, "idealib_drv"),
  erlang:load_nif (SoName, 0).

piece (_, _) -> not_loaded (?LINE).

not_loaded (Line) ->
  exit ({not_loaded, [{module, ?MODULE}, {line, Line}]}).

%% vim: fdm=syntax:fdn=3:tw=74:ts=2:syn=erlang
