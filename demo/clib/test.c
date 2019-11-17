#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int add(lua_State *L)
{
    int a,b,c;
    a = lua_tonumber(L,1);
    b = lua_tonumber(L,2);
    c = a+b;
    lua_pushnumber(L,c);
    return 1;
}

static const struct luaL_Reg lib[] =
{
    {"add",add},
    {NULL,NULL}
};

int luaopen_test(lua_State *L) 
{
    luaL_newlib(L, lib);
    return 1;
}
