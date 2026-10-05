require(script.Parent.Parent.types)
local compose = require(script.Parent.Parent.utils.compose)
local instances = require(script.Parent.Parent.utils.instances)
local unwrap = require(script.Parent.Parent.utils.unwrap)
local testRemote = require(script.Parent.Parent.utils.testRemote)

local function createAsyncRemote(name: string, p2)
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
		request = function(_, ...)
			assert(flag, (`Cannot use destroyed async remote '{name}'`))
			local v2 = table.pack(...)
			return (instances.promiseRemoteFunction(name):andThen(function(object)
				local v3

				if testAsyncRemote:hasRequestHandler() then
					v3 = table.pack(testAsyncRemote:_request(table.unpack(v2, 1, v2.n)))
				else
					v3 = table.pack(object:InvokeServer(table.unpack(v2, 1, v2.n)))
				end

				for k, v4 in p2.metadata.returns do
					local v5 = v3[k]
					assert(v4(v5), (`Invalid return value #{k} for async remote '{name}': got {v5}`))
				end

				return table.unpack(v3, 1, v3.n)
			end, function(p3)
				warn((`Failed to invoke async remote '{name}': {p3}`))
			end))
		end,
		destroy = function(_)
			if flag then
				flag = false

				fn = function() end
			end
		end
	}
	local v2 = compose(p2.metadata.middleware)(function(...)
		return unwrap(fn(...))
	end, v)
	instances.promiseRemoteFunction(name):andThen(function(p3)
		if not flag then
			return
		end

		p3.OnClientInvoke = function(...)
			assert(flag, (`Async remote '{name}' was invoked after it was destroyed`))

			for k, parameter in p2.metadata.parameters do
				local v3 = select(k, ...)
				assert(parameter(v3), (`Invalid parameter #{k} for async remote '{name}': got {v3}`))
			end

			return v2(...)
		end
	end, function(p3)
		warn((`Failed to initialize async remote '{name}': {p3}`))
	end)
	setmetatable(v, {
		__call = v.request
	})
	return v
end

return createAsyncRemote