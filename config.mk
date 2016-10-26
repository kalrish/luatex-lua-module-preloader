# Whether to strip in byte-compiling Lua chunks
#  either 'y' or 'n'
LUA_STRIP := y

# Which engine to use for the tests
#  examples: luatex, luajittex
ENGINE := luatex

# Base format to build upon in tests
#  e.g.: lualatex, luajitlatex
BASE_FORMAT := lualatex

# Additional arguments to pass to the engine in tests, both in dumping formats and in producing documents
#  e.g.: --jiton, --jithash=luajit20
EXTRA_ENGINE_ARGUMENTS := 

# Format of the document produced in the tests
#  e.g.: dvi, pdf
OUTPUT_FORMAT := pdf