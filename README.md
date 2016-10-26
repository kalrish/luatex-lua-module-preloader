# luatex-lua-module-preloader
Lua module preloading system for LuaTeX engines

##  Overview
`luampl` is a Lua module for LuaTeX engines to be loaded in format dumping sessions, also known as iniTeX runs or --ini mode, which allows to preload Lua modules in the format so that they don't have to be read and possibly translated to bytecode every time the document is generated.

`luaplms` is a LuaTeX Lua initialization script that hooks into the Lua module loading mechanism so as to load preloaded modules. It can optionally record which modules have been required in a separate file.

##  Context
TeX engines have traditionally allowed to dump their state in a format and restore it later from it. This shortens the document generation time, which helps with small documents that are compiled often, and removes the need for most of the files which were processed in the dumping session, which may lighten custom TeX deployments. LuaTeX engines support this feature, with a caveat: the Lua state is not dumped. The execution of any Lua code that alters the state must thus be delayed until document generation time. In practice, this means that LaTeX packages that make use of Lua code, such as `fontspec`, `microtype` or `polyglossia`, cannot be dumped in the format, with the consequence that build times are longer and all the files they comprise are required at document generation time. While this is somewhat frustrating and one would wish the Lua state would be dumped as well, for consistency if not for anything else, this limitation may still be overcome. Build times may be slightly shortened by loading Lua modules from bytecode instead of source. This would ideally be achieved by compiling Lua modules in advance and having the Lua module loading system slightly tweaked so as to load bytecode files (could be just a matter of adjusting [`package.path`](http://www.lua.org/manual/5.3/manual.html#pdf-package.path)). However, TeX distributions don't handle this, meaning that, unless one is willing to maintain such a system, small hacks are the way to go. The [Lua module cache manager](https://github.com/kalrish/luatex-lua-module-cache-manager) is one such hack which manages a cache at document generation time storing the loader of the Lua modules used, in a similar fashion to LaTeX's aux file. This system is another hack.

##  Advantages
 -  slightly faster document generation
	
	Generating the document with a custom format and preloaded Lua modules is slightly faster than with a custom format but no modules preloaded.

 -  no need to ship Lua module sources
	
	Lua module sources, either in source or bytecode form, are not required when generating the document, as the loaders are already available in the format. This might be useful if you are deploying a custom TeX installation and would like to avoid shipping dozens of Lua source files, although most Lua modules this system is able to catch come with LaTeX packages you would have to distribute anyway.

##  How it works
For each module requested to be preloaded, a loader is searched for following the same logic as [`require`](http://www.lua.org/manual/5.3/manual.html#pdf-require). When a loader is found, it is stored in a bytecode register and the register number is `\chardef`ed to a control sequence name derived from the module name.

Then, in the document generation run, the Lua initialization script adds a custom module searcher that retrieves the module loader from the appropriate bytecode register. To check whether a module has been preloaded and to know in which bytecode register its loader resides, it looks for the control sequence name that would have been defined in preloading it. The searcher may optionally record which modules have been required in a separate file.

##  Differences with the module cache manager
 -  With the module cache manager, module sources, either in source or bytecode form, are still required when generating the document. With this system they are not, as module loaders are stored in the format.
 -  The module cache manager automatically handles the case that a Lua module starts being used. This system is just able to record which modules should be preloaded, with it being up to another system to handle addition and removal of modules.

##  Requirements
 -  a recent LuaTeX engine
	
	Both LuaTeX and LuaJITTeX 0.95.0 work.

 -  the Lua module `ltluatex`, part of the LaTeX kernel

##  Building
A couple build systems are supported to handle byte-compiling the module and the initialization script and automating the tests.

###  Make
The targets and configuration options are detailed in `GNUmakefile`.

####  Requirements

 -  GNU Make

	Version 4.2.1 works.

 -  GNU Bash

	Version 4.3.46 works.

 -  rm, from GNU coreutils, or similar

	The one provided by GNU coreutils 8.2.5 works.

###  Tup
Tup version 0.7.5 works. No additional requirements with this build system. The configuration options are explained in `tup.config`.