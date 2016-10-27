# Configuration specific to LuaJITTeX

# The LuaJITTeX command
LUAJITTEX := luajittex

# Whether to strip in byte-compiling Lua chunks
#  either 'y' or 'n'
LUAJITTEX_LUA_STRIP := y

# Whether to turn on the JIT compiler
#  either 'y' or 'n'
LUAJITTEX_LUA_JIT := n

# Hash function for Lua strings
#  either nothing to take the default, or one of the supported hash functions ('lua51' and 'luajit20', as of this writing)
LUAJITTEX_LUA_JITHASH := 

# LaTeX format to build upon in tests
LUAJITTEX_LATEX_FORMAT := luajitlatex

# Additional arguments to pass to the engine in tests, both in dumping formats and in producing documents
#  e.g.: --nosocket
LUAJITTEX_EXTRA_ARGUMENTS := 