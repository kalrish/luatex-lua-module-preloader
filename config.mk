# Whether to strip in byte-compiling Lua chunks
#  either 'y' or 'n'
LUA_STRIP := y

# Which engine to use
#  examples: luatex, luajittex
ENGINE := luatex

# Base format to build upon
#  e.g.: lualatex, luajitlatex
FORMAT := lualatex

# Additional arguments to pass to the engine both in dumping formats and in
# producing documents
#  e.g.: --jiton, --jithash=luajit20
EXTRA_ENGINE_ARGUMENTS := 

# Format of the final document
#  e.g.: dvi, pdf
OUTPUT_FORMAT := pdf