# The name of this file is `GNUmakefile' and not e.g. `Makefile' because it follows GNU Make and is not intended for other Make versions.


##############################################################################
#  Targets
##############################################################################
#
# all
# 	Byte-compile the module and the initialization script and perform all
# 	tests.
# 
# module
# 	Byte-compile the module.
# 
# initscript
# 	Byte-compile the initialization script.
# 
# tests
# 	Perform all tests.
# 
# test-basic
# 	Perform the basic test, which serves both as an usage and an automation
# 	example.
# 
# test-already_preloaded
# 	Perform the test about handling already preloaded modules.
# 
# clean
# 	Remove generated files.
# 
##############################################################################


##############################################################################
#  Configuration - play with these variables
##############################################################################

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

##############################################################################


# Tell Make to use Bash to execute recipes, as otherwise we would have very little guarantee on the syntax and features that are available and it's Bash I'm testing this against. Use another shell at your own.
SHELL := bash

all: module initscript tests

module: luampl.texluabc luampl.texluajitbc

initscript: luaplms.texluabc luaplms.texluajitbc

tests: test-basic test-already_preloaded

test-basic: tests/basic/normal.$(OUTPUT_FORMAT) tests/basic/mitfmt.$(OUTPUT_FORMAT) tests/basic/allprl.$(OUTPUT_FORMAT)

test-already_preloaded: tests/already_preloaded/fmt2.fmt

ENGINE_ARGUMENTS := --interaction=nonstopmode --halt-on-error --recorder $(EXTRA_ENGINE_ARGUMENTS)

ifeq ($(ENGINE),luatex)
	TEXLUA_BYTECODE_EXTENSION := texluabc
else ifeq ($(ENGINE),luajittex)
	TEXLUA_BYTECODE_EXTENSION := texluajitbc
endif

%.texluabc : %.lua
	texluac -s -o $@ -- $<

%.texluajitbc : %.lua
	texluajitc -bt raw $< $@

tests/basic/normal.$(OUTPUT_FORMAT): tests/basic/preamble.tex tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=normal --fmt=$(FORMAT) --output-format=$(OUTPUT_FORMAT) -- '\input{preamble.tex}\input{body.tex}'

tests/basic/first.fmt: tests/basic/preamble.tex
	cd tests/basic ; time '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=first -- '&$(FORMAT)' '\input{preamble.tex}\dump'

tests/basic/mitfmt.$(OUTPUT_FORMAT) tests/basic/mitfmt-lua_modules_to_preload.txt: luaplms.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/first.fmt tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=mitfmt --lua=../../luaplms.$(TEXLUA_BYTECODE_EXTENSION) --lua-module-record=mitfmt-lua_modules_to_preload.txt --fmt=first --output-format=$(OUTPUT_FORMAT) -- body.tex

tests/basic/second.fmt: tests/basic/first.fmt luampl.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/mitfmt-lua_modules_to_preload.txt
	cd tests/basic ; time '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=second -- '&first' '\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("mitfmt-lua_modules_to_preload.txt")}\dump'

tests/basic/allprl.$(OUTPUT_FORMAT): luaplms.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/second.fmt tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=allprl --lua=../../luaplms.$(TEXLUA_BYTECODE_EXTENSION) --fmt=second --output-format=$(OUTPUT_FORMAT) -- body.tex

tests/already_preloaded/fmt1.fmt: luampl.$(TEXLUA_BYTECODE_EXTENSION)
	cd tests/already_preloaded ; '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=fmt1 -- '&$(FORMAT)' '\input{preamble.tex}\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("lua_modules_to_preload_in_format.txt")}\dump'

tests/already_preloaded/fmt2.fmt: tests/already_preloaded/fmt1.fmt luampl.$(TEXLUA_BYTECODE_EXTENSION)
	cd tests/already_preloaded ; '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=fmt2 -- '&fmt1' '\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("lua_modules_to_preload_in_format.txt")}\dump'

clean:
	rm -f -- {luampl,luaplms}.{texlua,texluajit}bc tests/basic/normal.{log,fls,aux,$(OUTPUT_FORMAT)} tests/basic/first.{log,fls,fmt} tests/basic/mitfmt.{log,fls} tests/basic/mitfmt-lua_modules_to_preload.txt tests/basic/mitfmt.{aux,$(OUTPUT_FORMAT)} tests/basic/second.{log,fls,fmt} tests/basic/allprl.{log,fls,aux,$(OUTPUT_FORMAT)} tests/already_preloaded/fmt{1,2}.{log,fls,fmt}

.PHONY: all module initscript tests test-basic test-already_preloaded clean