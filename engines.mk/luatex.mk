LUATEX_BYTECODE_EXTENSION := texluabc

# See [the LUAC man page](https://www.lua.org/manual/5.2/luac.html) for a description of the options
%.$(LUATEX_BYTECODE_EXTENSION) : %.lua
ifeq ($(LUATEX_LUA_STRIP),y)
	'$(LUATEX)' --luaconly -s -o $@ -- $<
else
	'$(LUATEX)' --luaconly -o $@ -- $<
endif

LUATEX_OWN_ARGUMENTS += $(LUATEX_EXTRA_ARGUMENTS)