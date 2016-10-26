TEXLUA_BYTECODE_EXTENSION_luajittex := texluajitbc

%.$(TEXLUA_BYTECODE_EXTENSION_luajittex) : %.lua
ifeq ($(LUA_STRIP),y)
	texluajitc -bst raw $< $@
else
	texluajitc -bgt raw $< $@
endif