LUA_HOME ?= C:/Users/Doerthous/Desktop/env/lua-5.3.5
CFLAGS = -I$(LUA_HOME)/src -fPIC -shared
LUA_A = $(LUA_HOME)/src/lua53.dll

run:
	gcc $(CFLAGS) test.c $(LUA_A) -o test.dll

clean:
	-rm test.dll