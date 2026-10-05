local Players = game:GetService("Players")
local module = require("./arguments")
local module2 = require("./console")
require("../roblox_packages/language")
local module3 = require("./net")
local module4 = require("./state")
require("./types")
local module5 = require("./user")
local localPlayer = Players.LocalPlayer
local count = 0
local fill_types

fill_types = function(state)
	if not state then
		return
	end

	if state.kind == "command" then
		for _, argument in state.arguments do
			fill_types(argument.type)
		end
	else
		if state.kind == "function" then
			return
		end

		if state.kind == "intersection" then
			for _, field in state.fields do
				fill_types(field)
			end
		else
			if state.kind == "literal" then
				return
			end

			if state.kind == "strange" then
				local get_strange_type = module.get_strange_type(state.id)

				if get_strange_type == nil then
					return warn((`{state.type} {state.id} is unregistered`))
				end

				state.match = get_strange_type.match
				state.suggestions = get_strange_type.suggestions
				state.exact_match = get_strange_type.exact_match
			elseif state.kind == "table" then
				fill_types(state.indexer)
				fill_types(state.value)

				if state.fields then
					for k, field in state.fields do
						fill_types(k)
						fill_types(field)
					end
				end
			elseif state.kind == "union" then
				for _, field in state.fields do
					fill_types(field)
				end
			end
		end
	end
end

local Src = {}

function Src.create_local_user(p)
	module4.local_user = module5.create_user({
		name = p.name,
		player = localPlayer
	})
end

function Src.update_user_roles(p)
	local user = module4.users[p.id]
	assert(user, "local user does not exist")
	user.roles = p.roles

	if user ~= module4.local_user then
		return
	end

	for _, local_command in module4.local_commands do
		if module5.has_permissions(user, unpack(local_command.representation.permissions or {})) then
			module2.set_command_from_representation(local_command.representation, local_command.arguments)
		else
			module2.unset_command_from_representation(local_command.representation)
		end
	end
end

function Src.update_role_permissions(p)
	module4.roles[p.name] = p.permissions
	local local_user = module4.local_user

	if not local_user then
		return
	end

	for _, local_command in module4.local_commands do
		if module5.has_permissions(local_user, unpack(local_command.representation.permissions or {})) then
			module2.set_command_from_representation(local_command.representation, local_command.arguments)
		else
			module2.unset_command_from_representation(local_command.representation)
		end
	end
end

function Src.register_command(data)
	fill_types(data.type)
	assert(data.type.kind == "command")
	module2.register_command(data.name, {
		description = data.description,
		permissions = data.permissions,
		arguments = function()
			return unpack(data.type.arguments)
		end,
		callback = function(...)
			local thread = coroutine.running()
			count += 1
			module4.continuations[count] = thread
			module3.client.invoke_command(count, data.name, { ... })
			local v = coroutine.yield()

			if v.status == "ok" then
				return unpack(v.results)
			end

			error("something went wrong on the server")
		end
	})
end

function Src.receive_server_results(p)
	local continuation = module4.continuations[p.invoke_id]

	if not continuation then
		return
	end

	module4.continuations[p.invoke_id] = nil
	task.spawn(continuation, p)
end

function Src.log(p)
	module2.console.output(p)
end

return Src