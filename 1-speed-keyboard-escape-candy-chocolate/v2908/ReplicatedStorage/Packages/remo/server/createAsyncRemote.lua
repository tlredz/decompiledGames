local Promise = require(script.Parent.Parent.Promise)
require(script.Parent.Parent.types)
local compose = require(script.Parent.Parent.utils.compose)
local instances = require(script.Parent.Parent.utils.instances)
local unwrap = require(script.Parent.Parent.utils.unwrap)
local testRemote = require(script.Parent.Parent.utils.testRemote)

local function createAsyncRemote(name: string, p2)
	assert(p2.metadata.returns, (`Missing return value validator for async remote '{name}'`))
	local remoteFunction = instances.createRemoteFunction(name)
	local testAsyncRemote = testRemote.createTestAsyncRemote()
	local flag = true

	local function fn() end

	local v = {
		name = name,
		type = "function",
		test = testAsyncRemote,
		onRequest = function(_, p3)
			assert(flag, (`Cannot use destroyed async remote '{name}'`))
			fn = p3
		end,
		request = function(_, player, ...)
			assert(flag, (`Cannot use destroyed async remote '{name}'`))
			return Promise.try(function(...)
				local v2

				if testAsyncRemote:hasRequestHandler() then
					v2 = table.pack(testAsyncRemote:_request(player, ...))
				else
					v2 = table.pack(remoteFunction:InvokeClient(player, ...))
				end

				for k, v3 in p2.metadata.returns do
					local v4 = v2[k]
					assert(v3(v4), (`Invalid return value #{k} for async remote '{name}': got {v4}`))
				end

				return table.unpack(v2, 1, v2.n)
			end, ...)
		end,
		destroy = function(_)
			if flag then
				flag = false
				remoteFunction:Destroy()
			end
		end
	}
	local v2 = compose(p2.metadata.middleware)(function(...)
		return unwrap(fn(...))
	end, v)

	remoteFunction.OnServerInvoke = function(p3, ...)
		for k, parameter in p2.metadata.parameters do
			local v3 = select(k, ...)
			assert(parameter(v3), (`Invalid parameter #{k} for async remote '{name}': got {v3}`))
		end

		return v2(p3, ...)
	end

	setmetatable(v, {
		__call = v.request
	})
	return v
end

return createAsyncRemote