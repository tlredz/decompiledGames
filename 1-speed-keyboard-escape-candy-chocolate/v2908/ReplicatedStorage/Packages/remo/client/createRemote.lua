local Promise = require(script.Parent.Parent.Promise)
require(script.Parent.Parent.types)
local compose = require(script.Parent.Parent.utils.compose)
local instances = require(script.Parent.Parent.utils.instances)
local testRemote = require(script.Parent.Parent.utils.testRemote)

local function createRemote(name: string, p2)
	local onClientEventConnection = nil
	local testRemote2 = testRemote.createTestRemote()
	local v = true
	local v2 = {}
	local count = 0
	local v3 = {}

	local function noop()
		error((`Attempted to use a server-only function on the client remote '{name}'`))
	end

	local v4 = {
		name = name,
		type = "event",
		test = testRemote2,
		fireAll = noop,
		fireAllExcept = noop,
		firePlayers = noop,
		connect = function(self, callback)
			assert(v, (`Cannot use destroyed remote '{name}'`))
			local v5 = count
			count += 1
			v2[v5] = callback

			if #v3 > 0 then
				for _, list in v3 do
					task.spawn(callback, table.unpack(list))
				end

				table.clear(v3)
			end

			return function()
				v2[v5] = nil
			end
		end,
		promise = function(self, callback, callback2)
			assert(v, (`Cannot promise destroyed event remote '{name}'`))
			return Promise.new(function(callback3, _, callback4)
				local connection = nil
				connection = self:connect(function(...)
					if not callback or callback(...) then
						connection()

						if callback2 then
							callback3(callback2(...))
						else
							callback3(...)
						end
					end
				end)
				callback4(connection)
			end)
		end,
		fire = function(_, ...)
			assert(v, (`Cannot use destroyed remote '{name}'`))
			local v5 = table.pack(...)
			instances.promiseRemoteEvent(name):andThen(function(object)
				object:FireServer(table.unpack(v5, 1, v5.n))
				testRemote2:_fire(table.unpack(v5, 1, v5.n))
			end, function(p3)
				warn((`Failed to fire remote '{name}': {p3}`))
			end)
		end,
		destroy = function(_)
			if not v then
				return
			end

			v = false

			if onClientEventConnection then
				onClientEventConnection:Disconnect()
				onClientEventConnection = nil
			end

			table.clear(v2)
			table.clear(v3)
		end
	}
	local v5 = compose(p2.metadata.middleware)(function(...)
		if not next(v2) then
			table.insert(v3, table.pack(...))
			return
		end

		for _, callback in v2 do
			task.spawn(callback, ...)
		end
	end, v4)
	instances.promiseRemoteEvent(name):andThen(function(p3)
		if not v then
			return
		end

		onClientEventConnection = p3.OnClientEvent:Connect(function(...)
			for k, parameter in p2.metadata.parameters do
				local v6 = select(k, ...)
				assert(parameter(v6), (`Invalid parameter #{k} for remote '{name}': got {v6}`))
			end

			v5(...)
		end)
	end, function(p3)
		warn((`Failed to initialize remote '{name}': {p3}`))
	end)
	setmetatable(v4, {
		__call = v4.fire
	})
	return v4
end

return createRemote