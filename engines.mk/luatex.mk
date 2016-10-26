TEXLUA_BYTECODE_EXTENSION_luatex := texluabc

# See [the LUAC man page](https://www.lua.org/manual/5.2/luac.html) for a description of the options
%.$(TEXLUA_BYTECODE_EXTENSION_luatex) : %.lua
ifeq ($(LUA_STRIP),y)
	texluac -s -o $@ -- $<
else
	texluac -o $@ -- $<
endif