# The name of this file is `GNUmakefile' and not e.g. `Makefile' because it follows GNU Make and is not intended for other Make versions.

# User-facing goals. Scroll down for a description of each.
.PHONY: all module initscript tests test-basic test-already_preloaded clean

# User-facing configuration sits in the config.mk directory. Have a look at the files there.
include config.mk/general.mk
include config.mk/engine/$(ENGINE).mk


# Tell Make to execute recipes with Bash, as otherwise we would have very little guarantee on the syntax and features that are available and it's Bash I'm testing this against. Use another shell at your own.
SHELL := bash

# Include rules and variables specific to the chosen engine
include engines.mk/$(ENGINE).mk


uppercasize = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$1))))))))))))))))))))))))))

# The extension of files containing bytecode of the chosen engine
TEXLUA_BYTECODE_EXTENSION := $($(call uppercasize,$(ENGINE))_BYTECODE_EXTENSION)
# The shell command to invoke the chosen engine
ENGINE_COMMAND := $($(call uppercasize,$(ENGINE)))
# Arguments to pass to the chosen engine in tests, both in dumping formats and in producing documents
ENGINE_ARGUMENTS := --interaction=nonstopmode --halt-on-error --recorder $($(call uppercasize,$(ENGINE))_OWN_ARGUMENTS)
# LaTeX format to build upon in tests
LATEX_FORMAT := $($(call uppercasize,$(ENGINE))_LATEX_FORMAT)


# Byte-compile the module and the initialization script for the chosen engine and perform all tests
all: module initscript tests

# Byte-compile the module for the chosen engine
module: luampl.$(TEXLUA_BYTECODE_EXTENSION)

# Byte-compile the initialization script for the chosen engine
initscript: luaplms.$(TEXLUA_BYTECODE_EXTENSION)

# Perform all tests
tests: test-basic test-already_preloaded

# See tests/basic/README.md
test-basic: tests/basic/normal.$(OUTPUT_FORMAT) tests/basic/mitfmt.$(OUTPUT_FORMAT) tests/basic/allprl.$(OUTPUT_FORMAT)

# See tests/already_preloaded/README.md
test-already_preloaded: tests/already_preloaded/fmt2.fmt

# Remove files that would be generated per the current configuration
clean:
	rm -f -- \
		{luampl,luaplms}.$(TEXLUA_BYTECODE_EXTENSION) \
		tests/basic/normal.{log,fls,aux,$(OUTPUT_FORMAT)} tests/basic/first.{log,fls,fmt} tests/basic/mitfmt.{log,fls} tests/basic/mitfmt-lua_modules_to_preload.txt tests/basic/mitfmt.{aux,$(OUTPUT_FORMAT)} tests/basic/second.{log,fls,fmt} tests/basic/allprl.{log,fls,aux,$(OUTPUT_FORMAT)} \
		tests/already_preloaded/fmt{1,2}.{log,fls,fmt}


tests/basic/normal.$(OUTPUT_FORMAT): tests/basic/preamble.tex tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE_COMMAND)' $(ENGINE_ARGUMENTS) --jobname=normal --fmt=$(LATEX_FORMAT) --output-format=$(OUTPUT_FORMAT) -- '\input{preamble.tex}\input{body.tex}'

tests/basic/first.fmt: tests/basic/preamble.tex
	cd tests/basic ; time '$(ENGINE_COMMAND)' --ini $(ENGINE_ARGUMENTS) --jobname=first -- '&$(LATEX_FORMAT)' '\input{preamble.tex}\dump'

tests/basic/mitfmt.$(OUTPUT_FORMAT) tests/basic/mitfmt-lua_modules_to_preload.txt: luaplms.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/first.fmt tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE_COMMAND)' $(ENGINE_ARGUMENTS) --jobname=mitfmt --lua=../../luaplms.$(TEXLUA_BYTECODE_EXTENSION) --lua-module-record=mitfmt-lua_modules_to_preload.txt --fmt=first --output-format=$(OUTPUT_FORMAT) -- body.tex

tests/basic/second.fmt: tests/basic/first.fmt luampl.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/mitfmt-lua_modules_to_preload.txt
	cd tests/basic ; time '$(ENGINE_COMMAND)' --ini $(ENGINE_ARGUMENTS) --jobname=second -- '&first' '\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("mitfmt-lua_modules_to_preload.txt")}\dump'

tests/basic/allprl.$(OUTPUT_FORMAT): luaplms.$(TEXLUA_BYTECODE_EXTENSION) tests/basic/second.fmt tests/basic/body.tex
	cd tests/basic ; time '$(ENGINE_COMMAND)' $(ENGINE_ARGUMENTS) --jobname=allprl --lua=../../luaplms.$(TEXLUA_BYTECODE_EXTENSION) --fmt=second --output-format=$(OUTPUT_FORMAT) -- body.tex

tests/already_preloaded/fmt1.fmt: luampl.$(TEXLUA_BYTECODE_EXTENSION)
	cd tests/already_preloaded ; '$(ENGINE_COMMAND)' --ini $(ENGINE_ARGUMENTS) --jobname=fmt1 -- '&$(LATEX_FORMAT)' '\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("lua_modules_to_preload_in_format.txt")}\dump'

tests/already_preloaded/fmt2.fmt: tests/already_preloaded/fmt1.fmt luampl.$(TEXLUA_BYTECODE_EXTENSION)
	cd tests/already_preloaded ; '$(ENGINE_COMMAND)' --ini $(ENGINE_ARGUMENTS) --jobname=fmt2 -- '&fmt1' '\directlua{dofile("../../luampl.$(TEXLUA_BYTECODE_EXTENSION)")("lua_modules_to_preload_in_format.txt")}\dump'