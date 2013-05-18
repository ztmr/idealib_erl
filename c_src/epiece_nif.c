
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "erl_nif.h"

#define EPIECE$MAXINPUT           (1024*1024)
#define EPIECE$MAXDELIM           128
#define EPIECE$MAXITEMS           ((EPIECE$MAXINPUT)/2)

#define NIFARGS \
  ErlNifEnv * env, int argc, const ERL_NIF_TERM argv []
#define NIF(name) \
  ERL_NIF_TERM (name) (NIFARGS)

static int load_internal (ErlNifEnv * env, void ** priv, void ** old_priv,
                          ERL_NIF_TERM load_info, bool upgrade) { return 0; }

static int load (ErlNifEnv * env, void ** priv,
                 ERL_NIF_TERM load_info) {

  return load_internal (env, priv, NULL, load_info, false);
}

static int upgrade (ErlNifEnv * env, void ** priv, void ** old_priv,
                    ERL_NIF_TERM load_info) {

  return load_internal (env, priv, old_priv, load_info, true);
}

static int reload (ErlNifEnv * env, void ** priv,
                   ERL_NIF_TERM load_info) { return 0; }

static void unload (ErlNifEnv * env, void * priv) { }

NIF (piece) {

  if (argc != 2) return enif_make_badarg (env);

  char input [EPIECE$MAXINPUT];
  char delim [EPIECE$MAXDELIM];
  ERL_NIF_TERM result [EPIECE$MAXITEMS];

  int dataLen = enif_get_string (env, argv [0], input, EPIECE$MAXINPUT, ERL_NIF_LATIN1);
  if (dataLen-- < 0) return enif_make_badarg (env);

  int delimLen = enif_get_string (env, argv [1], delim, EPIECE$MAXDELIM, ERL_NIF_LATIN1);
  if (delimLen-- < 0) return enif_make_badarg (env);

  unsigned n;
  int j, bufLen;
  bool delimFollows = false;
  char buf [256], *pos, *data;
  for (n = 0, buf [0] = 0, data = input, pos = data,
       bufLen = 0; pos <= data+dataLen; ) {

    // Look forward and try to find delimiter
    for (j = 0, delimFollows = true; j < delimLen; j++)
      if (!*(pos+j) || *(pos+j) != delim [j])
        { delimFollows = false; break; }

    // If we're before delimiter, print what we've gathered
    // until now and continue after the delimiter
    if (delimFollows) {
      result [n++] = enif_make_string (env, buf, ERL_NIF_LATIN1);
      bufLen = 0; buf [0] = 0; pos += delimLen;
    }
    else {
      // Collect input bytes one by one
      buf [bufLen++] = *pos++;
      buf [bufLen]   = 0;
    }
  }

  // If we're at the end of input data, just print
  // what remains in the buffer
  result [n++] = enif_make_string (env, buf, ERL_NIF_LATIN1);

  return enif_make_list_from_array (env, result, n);
}

static ErlNifFunc nif_funcs [] = {
  {"piece", 2, piece}
};

ERL_NIF_INIT (epiece_nif, nif_funcs, &load, &reload, &upgrade, &unload);

// vim: fdm=syntax:fdn=1:tw=74:ts=2:syn=c
