TEXLUA_BYTECODE_EXTENSION_luajittex := texluajitbc

# See [Running LuaJIT](http://luajit.org/running.html) for a description of the options
%.$(TEXLUA_BYTECODE_EXTENSION_luajittex) : %.lua
ifeq ($(LUA_STRIP),y)
	texluajitc -bst raw $< $@
else
	texluajitc -bgt raw $< $@
endif