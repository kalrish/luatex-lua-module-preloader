assert( status.ini_version == true,
	"this module is to be loaded in format dumping sessions, also known as iniTeX runs or --ini mode" )

local tostring = tostring
local type = type
-- Up to Lua 5.1, it was `package.loaders`; from Lua 5.2 onwards, it's `package.searchers`. LuaTeX implements the latter, LuaJITTeX the former.
local package_searchers = package.searchers or package.loaders
local lua_setbytecode = lua.setbytecode
local tex_sprint = tex.sprint
local texio_write = texio.write
local texio_write_nl = texio.write_nl
require('ltluatex')
local luatexbase_new_bytecode = luatexbase.new_bytecode

local catcodetable_atletter = luatexbase.registernumber('catcodetable@atletter')
local lua_bytecode_register_name_prefix = 'luamoduleloaderbytecode@'


luatexbase.provides_module{
	name="luampl",
	date="2016/10/20",
	version=2
}


local logging_prefix = "Lua module preloader: "

local debug_logging_target = 'log'
local log_debug = function( ... )
	texio_write_nl(debug_logging_target, logging_prefix)
	texio_write(debug_logging_target, "debug: ", ...)
end

local error_logging_target = 'term and log'
local log_error = function( ... )
	texio_write_nl(error_logging_target, logging_prefix)
	texio_write(error_logging_target, "error: ", ...)
end

return function( list_of_modules_to_preload_file_path )
	local preload_lua_module = function( module_name )
		local i = 1
		local searcher = package_searchers[1]
		local error_details = ""
		
		repeat
			local loader_or_error, extra_value = searcher(module_name)
			if type(loader_or_error) == 'function' then
				log_debug( "loader for module '" , module_name , "' found by module searcher #" , tostring(i) )
				
				if not extra_value then
					local bytecode_register = luatexbase_new_bytecode( "loader for Lua module '" .. module_name .. "'" )
					lua_setbytecode( bytecode_register , loader_or_error )
					log_debug( "loader for module '" , module_name , "' stored in bytecode register #" , tostring(bytecode_register) )
					tex_sprint( catcodetable_atletter , [[\expandafter\chardef\csname]] , lua_bytecode_register_name_prefix , module_name , [[\endcsname=]] , tostring(bytecode_register) , [[\relax]] )
					return true
				else
					log_error( "along with a loader, searcher returned, for module '" , module_name , "', an extra value, which cannot be handled" )
				end
			elseif type(loader_or_error) == 'string' then
				error_details = error_details .. loader_or_error
			end
			
			i = i + 1
			searcher = package_searchers[i]
		until searcher == nil
		
		log_error( "module '" , module_name , "' not found:" , error_details , "\n" )
	end
	
	local fd, error_message, error_number = io.open(list_of_modules_to_preload_file_path, 'rb')
	if fd then
		local contents = fd:read('*a')
		fd:close()
		if contents then
			local all_modules_requested_to_be_preloaded_have_been_preloaded = true
			for line in contents:gmatch('(.-)\n') do
				if not preload_lua_module(line) then
					all_modules_requested_to_be_preloaded_have_been_preloaded = false
				end
			end
			assert( all_modules_requested_to_be_preloaded_have_been_preloaded,
				"not all modules requested to be preloaded have been preloaded" )
		else
			error("couldn't read from the list of modules to preload file")
		end
	else
		error( "couldn't open the list of modules to preload file: " .. error_message .. " (error " .. tostring(error_number) .. ")" )
	end
end