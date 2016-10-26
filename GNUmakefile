# The name of this file is `GNUmakefile' and not e.g. `Makefile' because it follows GNU Make and is not intended for other Make versions.


##############################################################################
#  Targets
##############################################################################
#
# all
# 	Byte-compile the initialization script and generate the document in the
# 	three manners.
# 
# initscript
# 	Byte-compile the initialization script.
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

all: initscript normal mitfmt allprl

initscript: luaplms.texluabc luaplms.texluajitbc
normal: normal.$(OUTPUT_FORMAT)
mitfmt: mitfmt.$(OUTPUT_FORMAT)
allprl: allprl.$(OUTPUT_FORMAT)

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
	rm -f -- luaplms.{texlua,texluajit}bc normal.{log,fls,aux,$(OUTPUT_FORMAT)} first.{log,fls,fmt} mitfmt.{log,fls} mitfmt-lua_modules_to_preload.txt mitfmt.{aux,$(OUTPUT_FORMAT)} second.{log,fls,fmt} allprl.{log,fls,aux,$(OUTPUT_FORMAT)}

.PHONY: all initscript normal mitfmt allprl clean