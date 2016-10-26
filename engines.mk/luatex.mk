TEXLUA_BYTECODE_EXTENSION_luatex := texluabc

%.$(TEXLUA_BYTECODE_EXTENSION_luatex) : %.lua
ifeq ($(LUA_STRIP),y)
	texluac -s -o $@ -- $<
else
	texluac -o $@ -- $<
endif