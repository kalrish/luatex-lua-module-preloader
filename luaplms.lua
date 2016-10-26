local arg = arg
local tostring = tostring
local string_match = string.match
local lua_getbytecode = lua.getbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl
local token_create

local token_charzero_mode
local lua_bytecode_register_name_prefix = 'luamoduleloaderbytecode@'

local errors = false

local logging_identifier = "Lua module preloader"

local debug_logging_target = 'log'
local log_debug = function( ... )
	texio_write_nl(debug_logging_target, logging_identifier)
	texio_write(debug_logging_target, ": debug: ", ...)
end

local warning_logging_target = 'term and log'
local log_warning = function( ... )
	texio_write_nl(warning_logging_target, logging_identifier)
	texio_write(warning_logging_target, ": warning: ", ...)
end

local error_logging_target = 'term and log'
local log_error = function( ... )
	errors = true
	texio_write_nl(error_logging_target, logging_identifier)
	texio_write(error_logging_target, ": error: ", ...)
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

local times_that_the_module_record_file_was_already_tried_to_be_set = 0
while argument do
	local lua_module_record_file_name = string_match( argument , '^%-%-lua%-module%-record=(.+)$' )
	if lua_module_record_file_name then
		times_that_the_module_record_file_was_already_tried_to_be_set = times_that_the_module_record_file_was_already_tried_to_be_set + 1
		if times_that_the_module_record_file_was_already_tried_to_be_set == 1 then
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
			end
		elseif times_that_the_module_record_file_was_already_tried_to_be_set == 2 then
			log_error( "--lua-module-record specified multiple times" )
		end
	elseif argument == '--lua-module-record' or argument == '--lua-module-record=' then
		times_that_the_module_record_file_was_already_tried_to_be_set = times_that_the_module_record_file_was_already_tried_to_be_set + 1
		if times_that_the_module_record_file_was_already_tried_to_be_set == 1 then
			log_error( "missing argument for --lua-module-record" )
		elseif times_that_the_module_record_file_was_already_tried_to_be_set == 2 then
			log_error( "--lua-module-record specified multiple times" )
		end
	end
	
	i = i + 1
	argument = arg[i]
end

if errors then
	os.exit(false)
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