local tostring = tostring
local type = type
local package_searchers = package.searchers or package.loaders
local lua_setbytecode = _G.lua.setbytecode
local tex_sprint = _G.tex.sprint
local texio_write = _G.texio.write
local texio_write_nl = _G.texio.write_nl
require('ltluatex')
local luatexbase_new_bytecode = _G.luatexbase.new_bytecode

local catcodetable_atletter = _G.luatexbase.registernumber('catcodetable@atletter')
local lua_bytecode_register_name_prefix = 'luamoduleloaderbytecode@'


_G.luatexbase.provides_module{
	name="luampl",
	date="2016/10/20"
}


assert( _G.status.ini_version == true,
	"this module is to be loaded in format dumping sessions, also known as iniTeX runs or --ini mode" )

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

return {
	preload = function( list_of_modules_to_preload_file_path )
		list_of_modules_to_preload_file_path = list_of_modules_to_preload_file_path or ( _G.tex.jobname .. "-lua_modules_to_preload.txt" )
		
		local all_modules_requested_to_be_preloaded_have_been_found = true
		
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
					else
						log_error( "along with a loader, searcher returned, for module '" , module_name , "', an extra value, which cannot be handled" )
					end
					
					return
				elseif type(loader_or_error) == 'string' then
					error_details = error_details .. loader_or_error
				end
				
				i = i + 1
				searcher = package_searchers[i]
			until searcher == nil
			
			all_modules_requested_to_be_preloaded_have_been_found = false
			log_error( "module '" , module_name , "' not found:" , error_details )
		end
		
		local fd, error_message, error_number = io.open(list_of_modules_to_preload_file_path, 'rb')
		if fd then
			local contents = fd:read('*a')
			fd:close()
			if contents then
				for line in contents:gmatch('(.-)\r?\n') do
					preload_lua_module(line)
				end
				assert( all_modules_requested_to_be_preloaded_have_been_found,
					"not all modules requested to be preloaded have been found" )
			else
				log_error( "couldn't read the list of modules to preload file (" , list_of_modules_to_preload_file_path , ")" )
			end
		else
			log_error( "couldn't open the list of modules to preload file (" , list_of_modules_to_preload_file_path , "): " , error_message , " (error ", _G.tostring(error_number) , ")" )
		end
	end,
	setup = function()
		local bytecode_register = luatexbase_new_bytecode()
		lua_setbytecode( bytecode_register,
			function()
				if not _G.status.ini_version then
					local tostring = _G.tostring
					local lua_getbytecode = _G.lua.getbytecode
					local texio_write = _G.texio.write
					local texio_write_nl = _G.texio.write_nl
					_G.require('ltluatex')
					local luatexbase_registernumber = _G.luatexbase.registernumber
					
					local lua_bytecode_register_name_prefix = 'luamoduleloaderbytecode@'
					
					local logging_prefix = "Lua module preloader: "
					
					local debug_logging_target = 'log'
					local log_debug = function( ... )
						texio_write_nl(debug_logging_target, logging_prefix)
						texio_write(debug_logging_target, "debug: ", ...)
					end
					
					local warning_logging_target = 'term and log'
					local log_warning = function( ... )
						texio_write_nl(warning_logging_target, logging_prefix)
						texio_write(warning_logging_target, "warning: ", ...)
					end
					
					local error_logging_target = 'term and log'
					local log_error = function( ... )
						texio_write_nl(error_logging_target, logging_prefix)
						texio_write(error_logging_target, "error: ", ...)
					end
					
					local file_name = _G.tex.jobname .. "-lua_modules_to_preload.txt"
					local fd, error_message, error_number_or_first_retval_of_write = _G.io.open(file_name, 'wb')
					local register_used_module
					if fd then
						register_used_module = function( module_name )
							error_number_or_first_retval_of_write, error_message = fd:write( module_name , "\n" )
							if not error_number_or_first_retval_of_write then
								log_error( "couldn't write to the list of modules to preload file (" , file_name , "): " , error_message )
							end
						end
					else
						log_error( "couldn't open the list of modules to preload file (" , file_name , ") for writing: " , error_message , " (error ", _G.tostring(error_number_or_first_retval_of_write) , ")" )
						register_used_module = function() end
					end
					
					_G.table.insert( _G.package.searchers or _G.package.loaders, 2,
						function( module_name )
							register_used_module(module_name)
							local register_number = luatexbase_registernumber(lua_bytecode_register_name_prefix .. module_name)
							if register_number then
								log_debug( "loader for module '" , module_name , "' found in bytecode register #" , tostring(register_number) )
								return lua_getbytecode(register_number)
							else
								log_warning( "module '" , module_name , "' was not preloaded" )
								return "\n\tno matching bytecode register allocation csname"
							end
						end
					)
				end
			end
		)
		tex_sprint( catcodetable_atletter , [[\everyjob\expandafter{\the\everyjob\directlua{lua.getbytecode(]] , tostring(bytecode_register) , [[)()}}]] )
	end
}