LUA_HOME ?= C:/Users/Doerthous/Desktop/env/lua-5.3.5

LUA_V = $(shell echo $(LUA_HOME) | grep -q "5.3"; echo $$?)
ifeq (0,$(LUA_V))
	LUA_A = $(LUA_HOME)/src/lua53.dll
else
	LUA_V = $(shell echo $(LUA_HOME) | grep -q "5.2"; echo $$?)
ifeq (0,$(LUA_V))
	LUA_A = $(LUA_HOME)/src/lua52.dll
else
	LUA_V = $(shell echo $(LUA_HOME) | grep -q "5.1"; echo $$?)
ifeq (0,$(LUA_V))
	CFLAGS = -DLUA_V51
	LUA_A = $(LUA_HOME)/src/lua51.dll
endif
endif
endif

$(info LUA_A $(LUA_A))

CFLAGS += -I$(LUA_HOME)/src -I. -fPIC -shared

run:
	gcc $(CFLAGS) cserial.c serial.c $(LUA_A) -o cserial.dll

clean:
	-rm cserial.dll