LUAJITTEX_BYTECODE_EXTENSION := texluajitbc

# See [Running LuaJIT](http://luajit.org/running.html) for a description of the options
%.$(LUAJITTEX_BYTECODE_EXTENSION) : %.lua
ifeq ($(LUAJITTEX_LUA_STRIP),y)
	'$(LUAJITTEX)' --luaconly -bst raw $< $@
else
	'$(LUAJITTEX)' --luaconly -bgt raw $< $@
endif

LUAJITTEX_OWN_ARGUMENTS += $(LUAJITTEX_EXTRA_ARGUMENTS)

ifeq ($(LUAJITTEX_LUA_JIT),y)
LUAJITTEX_OWN_ARGUMENTS += --jiton
endif

LUAJITTEX_OWN_ARGUMENTS += $(if $(LUAJITTEX_LUA_JITHASH),--jithash=$(LUAJITTEX_LUA_JITHASH))