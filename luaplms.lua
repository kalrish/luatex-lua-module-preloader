local arg = arg
local tostring = tostring
local string_match = string.match
local lua_getbytecode = lua.getbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl
local token_create

local token_charzero_mode
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

-- Taken from ltluatex
local registernumber = function( name )
	token_create = token_create or token.create
	token_charzero_mode = token_charzero_mode or token_create('charzero').mode
	
	local to = token_create(name)
	if to.cmdname == 'char_given' then
		return to.mode - token_charzero_mode
	else
		return false
	end
end

local record_used_module = function()
end

local i = 1
local argument = arg[1]

local lua_module_record_file_name_already_specified = false
while argument do
	local lua_module_record_file_name = string_match( argument , '^%-%-lua%-module%-record=(.+)$' )
	if lua_module_record_file_name then
		if not lua_module_record_file_name_already_specified then
			lua_module_record_file_name_already_specified = true
			
			local fd, error_message, error_number_or_first_retval_of_write = io.open(lua_module_record_file_name, 'wb')
			if fd then
				log_debug( "used modules record file (" , lua_module_record_file_name , ") opened successfully" )
				record_used_module = function( module_name )
					error_number_or_first_retval_of_write, error_message = fd:write( module_name , "\n" )
					if not error_number_or_first_retval_of_write then
						log_error( "couldn't write to the used modules record file: " , error_message )
					end
				end
			else
				log_error( "couldn't open the used modules record file (" , lua_module_record_file_name , "): " , error_message , " (error ", tostring(error_number_or_first_retval_of_write) , ")" )
				error()
			end
		else
			error("Lua module record specified multiple times")
		end
	end
	
	i = i + 1
	argument = arg[i]
end

table.insert( package.searchers or package.loaders, 2,
	function( module_name )
		record_used_module(module_name)
		local bytecode_register_number = registernumber(lua_bytecode_register_name_prefix .. module_name)
		if bytecode_register_number then
			log_debug( "loader for module '" , module_name , "' found in bytecode register #" , tostring(bytecode_register_number) )
			return lua_getbytecode(bytecode_register_number)
		else
			log_warning( "module '" , module_name , "' was not preloaded" )
			return "\n\tno matching bytecode register allocation csname"
		end
	end
)