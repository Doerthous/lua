#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "serial.h"

#ifdef DEBUG
  #include <stdio.h>
#else
  #define printf(...)
#endif

static serial_t sr;

static int open(lua_State *L)
{
    const char *com;
    int baud_rate;

    if (sr) {
        serial_close(sr);
        sr = NULL;
    }

    com = lua_tostring(L,1);
    baud_rate = lua_tointeger(L,2);
    printf("%s %d\n", com, baud_rate);
    sr = serial_open(com, SRL_BAUD_RATE, 115200, 0);
    lua_pushnumber(L, sr != 0);

    return 1;
}

static int read(lua_State *L)
{
    char ch;

    if (sr) {
        sr->rx_timeout = lua_tointeger(L,1);
        if (serial_read(sr, &ch, 1) == 0) {
            lua_pushnil(L);
        }
        else {
            lua_pushnumber(L,ch);
        }
    }
    else {
        lua_pushnil(L);
    }

    return 1;
}

static int write(lua_State *L)
{
    char ch;

    if (sr) {
        ch = lua_tointeger(L,1);
        serial_write(sr, &ch, 1);
    }

    lua_pushnil(L);

    return 1;
}

static int close(lua_State *L)
{
    if (sr) {
        serial_close(sr);
        sr = NULL;
    }

    lua_pushnil(L);

    return 1;
}

static const struct luaL_Reg lib[] =
{
    {"open",open},
    {"read",read},
    {"write",write},
    {"close",close},
    {NULL,NULL}
};

int luaopen_cserial(lua_State *L) 
{
    luaL_newlib(L, lib);
    return 1;
}
