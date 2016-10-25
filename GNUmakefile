# The name of this file is `GNUmakefile' and not e.g. `Makefile' because it follows GNU Make and is not intended for other Make versions.


##############################################################################
#  Targets
##############################################################################
#
# all
# 	Generate the document in the three manners.
# 
# normal
# 	Generate the document processing the preamble, without using a custom
# 	format.
# 
# mitfmt
# 	Dump a format having processed the preamble and set up the Lua module
# 	preloading system, and then generate the document using that format.
# 
# allprl
# 	Preload the modules specified by the list that's produced in performing
# 	`mitfmt` thanks to the setup, dump a format based on that which was
# 	already dumped and generate the document using it.
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

all: normal mitfmt allprl

normal: normal.$(OUTPUT_FORMAT)
mitfmt: mitfmt.$(OUTPUT_FORMAT)
allprl: allprl.$(OUTPUT_FORMAT)

ENGINE_ARGUMENTS := --interaction=nonstopmode --halt-on-error --recorder $(EXTRA_ENGINE_ARGUMENTS)

ifeq ($(ENGINE),luatex)
	TEXLUA_BYTECODE_EXTENSION := texluabc
else ifeq ($(ENGINE),luajittex)
	TEXLUA_BYTECODE_EXTENSION := texluajitbc
endif

%.$(TEXLUA_BYTECODE_EXTENSION) : %.lua
ifeq ($(ENGINE),luatex)
	texluac -s -o $@ -- $<
else ifeq ($(ENGINE),luajittex)
	texluajitc -bt raw $< $@
endif

normal.$(OUTPUT_FORMAT): preamble.tex body.tex
	time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=normal --fmt=$(FORMAT) --output-format=$(OUTPUT_FORMAT) -- '\input{preamble.tex}\input{body.tex}'

first.fmt: preamble.tex
	time '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=first -- '&$(FORMAT)' '\input{preamble.tex}\dump'

mitfmt.$(OUTPUT_FORMAT) mitfmt-lua_modules_to_preload.txt: luaplms.$(TEXLUA_BYTECODE_EXTENSION) first.fmt body.tex
	time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=mitfmt --lua=luaplms.$(TEXLUA_BYTECODE_EXTENSION) --lua-module-record=mitfmt-lua_modules_to_preload.txt --fmt=first --output-format=$(OUTPUT_FORMAT) -- body.tex

second.fmt: first.fmt mitfmt-lua_modules_to_preload.txt
	time '$(ENGINE)' --ini $(ENGINE_ARGUMENTS) --jobname=second -- '&first' '\directlua{require("luampl")("mitfmt-lua_modules_to_preload.txt")}\dump'

allprl.$(OUTPUT_FORMAT): luaplms.$(TEXLUA_BYTECODE_EXTENSION) second.fmt body.tex
	time '$(ENGINE)' $(ENGINE_ARGUMENTS) --jobname=allprl --lua=luaplms.$(TEXLUA_BYTECODE_EXTENSION) --fmt=second --output-format=$(OUTPUT_FORMAT) -- body.tex

clean:
	rm -f -- normal.log normal.fls normal.aux normal.$(OUTPUT_FORMAT) first.log first.fls first.fmt luaplms.$(TEXLUA_BYTECODE_EXTENSION) mitfmt.log mitfmt.fls mitfmt-lua_modules_to_preload.txt mitfmt.aux mitfmt.$(OUTPUT_FORMAT) second.log second.fls second.fmt allprl.log allprl.fls allprl-lua_modules_to_preload.txt allprl.aux allprl.$(OUTPUT_FORMAT)

.PHONY: all normal mitfmt allprl clean