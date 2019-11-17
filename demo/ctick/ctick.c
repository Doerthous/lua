#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "tick_ms.h"

#ifdef DEBUG
  #include <stdio.h>
#else
  #define printf(...)
#endif

static int ms(lua_State *L)
{
    lua_pushnumber(L, tick_ms());
    return 1;
}

static const struct luaL_Reg lib[] =
{
    {"ms",ms},
    {NULL,NULL}
};

int luaopen_ctick(lua_State *L) 
{
  #ifdef LUA_V51
    luaL_register(L, "ctick", lib);
  #else
    luaL_newlib(L, lib);
  #endif
    return 1;
}
