local typeof2 = typeof
local graph = require(script.Parent.graph)
local get_scope = graph.get_scope
local push_cleanup = graph.push_cleanup

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
	local v = get_scope()

	if not v then
		error("cannot cleanup outside a stable or reactive scope")
	end

	assert(v)

	if type(callback) == "function" then
		push_cleanup(v, callback)
	else
		push_cleanup(v, (helper(callback)))
	end
end

return cleanup