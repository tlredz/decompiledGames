local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local typeof2 = game and typeof or require3("../test/mock").typeof
local v = require3("./graph")
local get_scope = v.get_scope
local push_cleanup = v.push_cleanup

local function helper(connection)
	if typeof2(connection) == "RBXScriptConnection" then
		return function()
			connection:Disconnect()
		end
	end

	if type(connection) == "thread" then
		return function()
			task.cancel(connection)
		end
	end

	if typeof2(connection) == "Instance" then
		return function()
			connection:Destroy()
		end
	end

	if connection.destroy then
		return function()
			connection:destroy()
		end
	end

	if connection.disconnect then
		return function()
			connection:disconnect()
		end
	end

	if connection.Destroy then
		return function()
			connection:Destroy()
		end
	end

	if connection.Disconnect then
		return function()
			connection:Disconnect()
		end
	end

	return (error("cannot cleanup given object"))
end

local function cleanup(callback)
	local v2 = get_scope()

	if not v2 then
		error("cannot cleanup outside a stable or reactive scope")
	end

	assert(v2)

	if type(callback) == "function" then
		push_cleanup(v2, callback)
	else
		push_cleanup(v2, (helper(callback)))
	end
end

return cleanup