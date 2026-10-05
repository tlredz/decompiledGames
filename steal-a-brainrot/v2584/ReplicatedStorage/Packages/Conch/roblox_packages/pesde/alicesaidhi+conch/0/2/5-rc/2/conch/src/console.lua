local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("../roblox_packages/ast")
local module2 = require("../roblox_packages/compiler")
local module3 = require("../roblox_packages/vm")
require("../roblox_packages/types")
local module4 = require("../roblox_packages/intel")
local module5 = require("./net")
local module6 = require("./signal")
local module7 = require("./state")
require("./types")
local module8 = require("./user")
local isServer = RunService:IsServer()
local v = {
	locals = {},
	upvalues = {},
	instructions = {}
}
local vm = module3()
local commands = {}
local after_command_run = module6()
local console = {
	vm = vm,
	commands = commands,
	output = print
}
local v6 = {}

local function replicate_to_player(p, data)
	local obtain_user_key = module8.obtain_user_key(p)
	local user = module7.users[obtain_user_key]

	if not (user and module8.has_permissions(user, unpack(data.permissions))) then
		return
	end

	module5.server.fire_register_command(p, {
		name = data.name,
		description = data.description,
		permissions = data.permissions,
		arguments = data.arguments
	})
end

local v7 = false

local function register_command(p: string, data)
	local arguments = { data.arguments() } or {
		{
			kind = "varargs",
			type = "any",
			name = "...",
			description = "unspecified"
		}
	}
	local converts = {}
	local arguments2 = {}

	for k, v10 in arguments do
		local v11 = v6[v10.type] or warn((`no argument of type "{v10.type}" is registered`)) or v6.any
		local clone = table.clone(v11.analysis)
		converts[k] = v11.convert
		arguments2[k] = {
			kind = v10.kind == "varargs" and "variadic" or "argument",
			optional = v10.optional,
			name = v10.name or clone.name,
			description = v10.description,
			type = clone.type,
			suggestion_generator = clone.suggestion_generator
		}
	end

	local v10 = {
		name = p,
		description = data.description,
		permissions = data.permissions,
		arguments = arguments,
		type_info = {
			kind = "command",
			name = p,
			description = data.description,
			arguments = arguments2
		},
		callback = data.callback,
		dirty_replicate = true
	}
	commands[p] = v10

	vm.commands[p] = function(...)
		local arguments3 = { ... }

		local function move(p2: number, ...)
			for i = 0, select("#", ...) - 1 do
				arguments3[i + p2] = select(i + 1, ...)
			end
		end

		local v12 = nil
		local v13 = nil

		for k, v15 in arguments do
			if v15.variadic then
				v12 = converts[k]
				v13 = k
				break
			elseif v15.optional and select(k, ...) == nil then
				arguments3[k] = nil
			else
				arguments3[k] = converts[k]((select(k, ...)))
			end
		end

		if v12 and v13 then
			for i = v13 + 1, select("#", ...) do
				arguments3[i] = v12((select(i, ...)))
			end
		end

		local v15 = { pcall(data.callback, unpack(arguments3, 1, select("#", ...))) }
		local ok = table.remove(v15, 1)
		local v17 = module7.command_context[coroutine.running()]
		after_command_run:fire({
			ok = ok,
			who = v17 and v17.executor,
			command = p,
			arguments = arguments3,
			result = v15
		})

		if not ok then
			error(v15[2])
		end

		return unpack(v15)
	end

	if isServer then
		for _, v11 in Players:GetPlayers() do
			replicate_to_player(v11, v10)
		end
	end

	return v10
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
	local v8 = module(p, false)
	assert(v8.status ~= "pending", "unfinished block")
	assert(not v7, "already executing!")
	console.output({
		kind = "info",
		text = `> {v8.src}`
	})

	if v8.status == "error" then
		return console.output({
			kind = "error",
			text = v8.why
		})
	end

	v7 = true
	local v9 = module2(v8.value, v)
	v.instructions = {}

	local function on_complete(flag: boolean, p2, ...)
		if not flag then
			console.output({
				kind = "error",
				text = tostring(p2)
			})
			return
		end

		for i = 1, select("#", ...) do
			console.output({
				kind = "normal",
				text = tostring((select(i, ...)))
			})
		end
	end

	on_complete(pcall(vm.run, v9))
	v7 = false
end

function Console.analyze(code: string, where: number)
	local type_infos = {}
	local v8 = 1
	local variables = {}

	for _, v10 in commands do
		type_infos[v8] = v10.type_info
		v8 += 1
	end

	for k, global in vm.globals do
		variables[k] = global
	end

	for k, v10 in v.locals do
		variables[v10] = vm.locals[k]
	end

	return module4.generate_analysis_info({
		code = code,
		where = where,
		variables = variables,
		commands = type_infos
	})
end

function Console.write_global(value: string, p)
	assert(module7.local_user, "cannot set global on server")
	assert(string.match(value, "^[A-z%-@_]*$"), (`{value} is not a valid name`))
	vm.globals[value] = p
end

Console.after_command_run = after_command_run

function Console.register_type(p: string, p2)
	v6[p] = p2
	return function(name: string?, description: string?)
		return {
			name = name,
			description = description,
			optional = false,
			kind = "arg",
			type = p
		}
	end
end

function Console.get_type(p: string)
	return v6[p]
end

Console.ast = module
return Console