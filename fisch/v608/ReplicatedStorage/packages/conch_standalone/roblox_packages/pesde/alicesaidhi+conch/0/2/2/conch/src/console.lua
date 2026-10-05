local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local module = require("../roblox_packages/ast")
local module2 = require("../roblox_packages/compiler")
local module3 = require("../roblox_packages/vm")
require("../roblox_packages/types")
local module4 = require("../roblox_packages/intel")
local module5 = require("./net")
local module6 = require("./state")
require("./types")
local module7 = require("./user")
local isServer = RunService:IsServer()
local v = {
	locals = {},
	upvalues = {},
	instructions = {}
}
local vm = module3()
local commands = {}
local console = {
	vm = vm,
	commands = commands,
	output = print
}
local v5 = {}

local function replicate_to_player(p, data)
	local obtain_user_key = module7.obtain_user_key(p)
	local user = module6.users[obtain_user_key]

	if not (user and user.net_ready and module7.has_permissions(user, unpack(data.permissions))) then
		return
	end

	module5.server.fire_register_command(p, {
		name = data.name,
		description = data.description,
		permissions = data.permissions,
		arguments = data.arguments
	})
end

local v6 = false

local function register_command(name: string, data)
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

	for k, v9 in arguments do
		local v10 = v5[v9.type] or warn(`{name}: no argument of type "{v9.type}" is registered`, arguments) or v5.any
		local clone = table.clone(v10.analysis)
		converts[k] = v10.convert
		arguments2[k] = {
			kind = v9.kind == "varargs" and "variadic" or "argument",
			name = v9.name or clone.name,
			description = v9.description,
			type = clone.type,
			suggestion_generator = clone.suggestion_generator
		}
	end

	local v9 = {
		name = name,
		description = data.description,
		permissions = data.permissions,
		arguments = arguments,
		type_info = {
			kind = "command",
			name = name,
			description = data.description,
			arguments = arguments2
		},
		callback = data.callback,
		dirty_replicate = true
	}
	commands[name] = v9

	vm.commands[name] = function(...)
		local v10 = { ... }

		local function move(p2: number, ...)
			for i = 0, select("#", ...) - 1 do
				v10[i + p2] = select(i + 1, ...)
			end
		end

		local v11 = nil
		local v12 = nil

		for k, v14 in arguments do
			if v14.variadic then
				v11 = converts[k]
				v12 = k
				break
			else
				v10[k] = converts[k]((select(k, ...)))
			end
		end

		if v11 and v12 then
			for i = v12 + 1, select("#", ...) do
				v10[i] = v11((select(i, ...)))
			end
		end

		return data.callback(unpack(v10))
	end

	if isServer then
		for _, v10 in Players:GetPlayers() do
			replicate_to_player(v10, v9)
		end
	end

	return v9
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
	local v7 = module(p, false)
	assert(v7.status ~= "pending", "unfinished block")
	assert(not v6, "already executing!")
	console.output({
		kind = "info",
		text = `> {v7.src}`
	})

	if v7.status == "error" then
		return console.output({
			kind = "error",
			text = v7.why
		})
	end

	v6 = true
	local v8 = module2(v7.value, v)
	v.instructions = {}

	local function on_complete(flag: boolean, p2, ...)
		if not flag then
			console.output({
				kind = "error",
				text = tostring(p2)
			})
		end
	end

	on_complete(pcall(vm.run, v8))
	v6 = false
end

function Console.analyze(code: string, where: number)
	local type_infos = {}
	local v7 = 1
	local variables = {}

	for _, v9 in commands do
		type_infos[v7] = v9.type_info
		v7 += 1
	end

	for k, global in vm.globals do
		variables[k] = global
	end

	for k, v9 in v.locals do
		variables[v9] = vm.locals[k]
	end

	return module4.generate_analysis_info({
		code = code,
		where = where,
		variables = variables,
		commands = type_infos
	})
end

function Console.write_global(value: string, p)
	assert(module6.local_user, "cannot set global on server")
	assert(string.match(value, "^[A-z%-@_]*$"), (`{value} is not a valid name`))
	vm.globals[value] = p
end

function Console.register_type(p: string, p2)
	v5[p] = p2
	return function(name: string?, description: string?)
		return {
			name = name,
			description = description,
			kind = "arg",
			type = p
		}
	end
end

function Console.get_type(p: string)
	return v5[p]
end

Console.ast = module
return Console