require(script.Parent.types)
local constants = require(script.Parent.constants)
local client = require(script.Parent.client)
local server = require(script.Parent.server)
local deepApplyMiddleware

deepApplyMiddleware = function(items, ...)
	for _, item in items do
		if item.type == "namespace" then
			deepApplyMiddleware(item.remotes, ...)
		else
			item.middleware(...)
		end
	end
end

local function createRemotes(p, ...)
	local result = {}
	deepApplyMiddleware(p, ...)
	local v

	if constants.IS_SERVER then
		v = server.createRemotes(p)
	else
		v = client.createRemotes(p)
	end

	local recursiveDestroy

	recursiveDestroy = function(items)
		for _, item in items do
			if type(item) ~= "table" then
				break
			end

			if item.destroy then
				item:destroy()
			else
				recursiveDestroy(item)
			end
		end
	end

	function result:destroy()
		recursiveDestroy(v)
	end

	for k, v2 in v do
		result[k] = v2
	end

	return result
end

return createRemotes