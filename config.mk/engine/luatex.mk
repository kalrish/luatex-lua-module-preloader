# Configuration specific to LuaTeX

# The LuaTeX command
LUATEX := luatex

# Whether to strip in byte-compiling Lua chunks
#  either 'y' or 'n'
LUATEX_LUA_STRIP := y

# LaTeX format to build upon in tests
LUATEX_LATEX_FORMAT := lualatex

# Additional arguments to pass to the engine in tests, both in dumping formats and in producing documents
#  e.g.: --nosocket
LUATEX_EXTRA_ARGUMENTS := 