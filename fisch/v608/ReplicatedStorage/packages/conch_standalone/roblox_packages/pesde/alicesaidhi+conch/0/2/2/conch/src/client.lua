local Players = game:GetService("Players")
local module = require("./console")
local module2 = require("./net")
local module3 = require("./state")
require("./types")
local module4 = require("./user")
local localPlayer = Players.LocalPlayer
local count = 0
local Src = {}

function Src.create_local_user(p)
	module3.local_user = module4.create_user({
		name = p.name,
		player = localPlayer
	})
end

function Src.update_user_roles(p)
	local user = module3.users[p.id]
	assert(user, "local user does not exist")
	user.roles = p.roles
end

function Src.update_role_permissions(p)
	module3.roles[p.name] = p.permissions
end

function Src.register_command(data)
	module.register_command(data.name, {
		description = data.description,
		permissions = data.permissions,
		arguments = function()
			return unpack(data.arguments)
		end,
		callback = function(...)
			local thread = coroutine.running()
			count += 1
			module3.continuations[count] = thread
			module2.client.invoke_command(count, data.name, { ... })
			local v = coroutine.yield()

			if v.status == "ok" then
				return unpack(v.results)
			end

			error("something went wrong on the server")
		end
	})
end

function Src.receive_server_results(p)
	local continuation = module3.continuations[p.invoke_id]

	if not continuation then
		return
	end

	module3.continuations[p.invoke_id] = nil
	task.spawn(continuation, p)
end

function Src.log(p)
	module.console.output(p)
end

return Src