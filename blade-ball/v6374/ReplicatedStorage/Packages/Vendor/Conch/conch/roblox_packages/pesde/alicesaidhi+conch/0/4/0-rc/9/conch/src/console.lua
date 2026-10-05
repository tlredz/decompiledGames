local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("./arguments")
local module2 = require("./context")
local module3 = require("../roblox_packages/language")
local module4 = require("./net")
local module5 = require("./signal")
local module6 = require("./state")
require("./types")
local module7 = require("./user")
local isServer = RunService:IsServer()
local create_vm = module3.create_vm()
local commands = {}
local after_command_run = module5()
local console = {
	vm = create_vm,
	commands = commands,
	output = print
}

local function replicate_to_player(p, data)
	local obtain_user_key = module7.obtain_user_key(p)
	local user = module6.users[obtain_user_key]

	if not (user and module7.has_permissions(user, unpack(data.permissions))) then
		return
	end

	module4.server.fire_register_command(p, {
		name = data.name,
		description = data.description,
		permissions = data.permissions,
		type = data.type
	})
end

local thread = nil
local thread2 = nil

local function noop() end

local v4 = {}

local function determine_cmd_type(p, ...)
	assert(p.kind == "intersection" or p.kind == "command", "not a command")

	if p.kind == "intersection" then
		local fields = {}

		for _, field in p.fields do
			assert(field.kind == "command", (`cannot determine overload with type {field.kind}`))
			local v5 = false

			for k, argument in field.arguments do
				if not argument.type or module3.matches_type(select(k, ...), argument.type, true) then
					continue
				end

				v5 = true
				break
			end

			if not v5 then
				table.insert(fields, field)
			end
		end

		if #fields > 1 then
			error((`could not determine valid overload for {fields[1].name}, consider separating the command or introducing a literal to differentiate by?`))
		end

		if #fields == 0 then
			error((`could not determine valid overload for {p.fields[1].name}, no options matched`))
		end

		return fields[1]
	else
		if p.kind == "command" then
			return p
		end

		error("no valid command; unreachable?")
	end
end

local coerce_value_into_type

coerce_value_into_type = function(data, p)
	if not (data.kind ~= "command" and data.kind ~= "function" and data.kind ~= "intersection" and data.kind ~= "literal") then
		return p
	end

	if data.kind == "strange" then
		if data.convert then
			return data.convert(p)
		end
	elseif data.kind == "table" then
		assert(typeof(p) == "table", (`not a table, should match table type but got {typeof(p)}`))
		local v5 = {}

		if data.fields then
			for k, field in data.fields do
				if k.value == nil then
					continue
				end

				local v6 = rawget(p, k.value)
				v5[k.value] = coerce_value_into_type(field, v6)
			end
		end

		if data.indexer and data.value then
			for k, v6 in pairs(v5) do
				if module3.matches_type(k, data.indexer, true) then
					v5[coerce_value_into_type(data.indexer, k)] = coerce_value_into_type(data.value, v6)
				end
			end

			return p
		end
	elseif data.kind == "union" then
		for _, field in data.fields do
			if module3.matches_type(p, field, true) then
				return coerce_value_into_type(field, p)
			end
		end
	end

	return p
end

local function unregister_command(p)
	if not v4[p] then
		return
	end

	commands[p.name] = nil
	v4[p]:remove()
	v4[p] = nil
	local name = p.name
	assert(not isServer, "cannot set global on server")
	assert(string.match(name, "^[A-z%-@_]*$"), (`{name} is not a valid name`))
	module3.set_command(create_vm, name, nil)
end

local function fix_arguments(items)
	for k, item in items do
		if not (item.kind ~= "argument" and item.kind ~= "overload") then
			continue
		end

		local obtain_type_name = module.obtain_type_name(item)
		items[k] = {
			kind = "argument",
			name = obtain_type_name,
			description = obtain_type_name,
			type = item,
			varargs = false
		}
	end
end

local function from_arguments_or_overload(name: string, description: string?, arguments)
	local v5 = arguments[1]

	if not v5 or v5.kind ~= "overload" then
		fix_arguments(arguments)
		return {
			kind = "command",
			name = name,
			description = description or "",
			arguments = arguments
		}
	end

	local fields = {}

	for _, overload in v5.overloads do
		fix_arguments(overload)
		table.insert(fields, {
			kind = "command",
			name = name,
			description = description or "",
			arguments = overload
		})
	end

	return {
		kind = "intersection",
		fields = fields
	}
end

local function register_command(p: string, data)
	local arguments = { data.arguments() }
	local callback = data.callback
	local v6 = from_arguments_or_overload(p, data.description, arguments)
	local representation = {
		name = p,
		description = data.description,
		permissions = data.permissions,
		type = v6,
		dirty_replicate = true,
		callback = function(...)
			local v8 = determine_cmd_type(v6, ...)

			if not v8 then
				error("could not match with an overload")
			end

			local arguments2 = { ... }
			local v10 = nil

			for i = 1, select("#", ...) do
				local v11 = arguments2[i]
				local argument = v8.arguments[i]

				if argument == nil and v10 and #v8.arguments < i then
					argument = v10
				end

				if not (argument and argument.type) then
					continue
				end

				if argument.varargs and i == #v8.arguments then
					v10 = argument
				end

				arguments2[i] = coerce_value_into_type(argument.type, v11)
			end

			local v11 = { pcall(callback, unpack(arguments2, 1, select("#", ...))) }
			local ok = table.remove(v11, 1)
			local v13 = module6.command_context[coroutine.running()]
			after_command_run:fire({
				ok = ok,
				who = v13 and v13.executor,
				command = p,
				arguments = arguments2,
				result = v11
			})

			if not ok then
				warn(unpack(v11))
				error(v11[2], 0)
			end

			return unpack(v11)
		end
	}

	if isServer then
		for _, v8 in Players:GetPlayers() do
			replicate_to_player(v8, representation)
		end

		commands[p] = representation
	end

	if isServer then
		return representation
	end

	if module6.local_user and module7.has_permissions(module6.local_user, unpack(data.permissions)) and not v4[representation] then
		local name = representation.name
		local callback2 = representation.callback
		assert(not isServer, "cannot set global on server")
		assert(string.match(name, "^[A-z%-@_]*$"), (`{name} is not a valid name`))
		module3.set_command(create_vm, name, callback2)
		commands[representation.name] = representation
		v4[representation] = module3.attach_info(create_vm, false, representation.name, representation.type)
	end

	module6.local_commands[p] = {
		representation = representation,
		arguments = arguments
	}
	return representation
end

local function register(name: string, callback, ...)
	register_command(name, {
		name = name,
		callback = callback,
		arguments = function() end,
		permissions = { ... }
	})
end

local Console = {}
Console.console = console
Console.register_quick = register
Console.register_command = register_command
Console.replicate_to_player = replicate_to_player

function Console.execute(p: string)
	assert(thread == nil, "thread is already running!")
	thread = coroutine.running()
	console.output({
		kind = "info",
		text = `> {p}`
	})
	local v4 = false
	local get_command_context = module2.get_command_context()
	task.spawn(function()
		local v5

		if get_command_context then
			v5 = module2.create_command_context(get_command_context.executor, get_command_context.invocation_id)
		else
			v5 = noop
		end

		thread2 = coroutine.running()
		local v6 = module3.run(create_vm, p)

		if v6.ok then
			for _, v7 in ipairs(v6.values or {}) do
				console.output({
					kind = "normal",
					text = tostring(v7)
				})
			end
		else
			warn(table.concat(v6.why, "\n"))
			console.output({
				kind = "error",
				text = table.concat(v6.why, "\n")
			})
		end

		v5()

		if thread then
			coroutine.resume(thread)
		end

		v4 = true
	end)

	if not v4 then
		coroutine.yield()
	end

	thread2 = nil
	thread = nil
end

function Console.cancel()
	if thread and thread2 then
		task.cancel(thread2)
		coroutine.resume(thread)
		thread2 = nil
		thread = nil
	end
end

function Console.analyze(p: string, p2: number)
	return module3.analyze(create_vm, p, p2)
end

function Console.write_global(value: string, p)
	assert(not isServer, "cannot set global on server")
	assert(string.match(value, "^[A-z%-@_]*$"), (`{value} is not a valid name`))
	module3.set_command(create_vm, value, p)
end

Console.after_command_run = after_command_run

function Console.set_command_from_representation(data)
	if v4[data] then
		return
	end

	local name = data.name
	local callback = data.callback
	assert(not isServer, "cannot set global on server")
	assert(string.match(name, "^[A-z%-@_]*$"), (`{name} is not a valid name`))
	module3.set_command(create_vm, name, callback)
	commands[data.name] = data
	v4[data] = module3.attach_info(create_vm, false, data.name, data.type)
end

Console.unset_command_from_representation = unregister_command
return Console