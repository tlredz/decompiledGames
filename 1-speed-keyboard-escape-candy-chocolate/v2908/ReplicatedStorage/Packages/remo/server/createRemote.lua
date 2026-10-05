local Players = game:GetService("Players")
local Promise = require(script.Parent.Parent.Promise)
require(script.Parent.Parent.types)
local compose = require(script.Parent.Parent.utils.compose)
local instances = require(script.Parent.Parent.utils.instances)
local testRemote = require(script.Parent.Parent.utils.testRemote)

local function createRemote(name: string, p2)
	local remoteEvent = instances.createRemoteEvent(name, p2.metadata.unreliable)
	local testRemote2 = testRemote.createTestRemote()
	local v = true
	local v2 = {}
	local count = 0
	local v3 = {
		name = name,
		type = "event",
		test = testRemote2,
		connect = function(self, p3)
			assert(v, (`Cannot connect to destroyed event remote '{name}'`))
			local v4 = count
			count += 1
			v2[v4] = p3
			return function()
				v2[v4] = nil
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
		fire = function(_, player, ...)
			assert(v, (`Cannot fire destroyed event remote '{name}'`))
			remoteEvent:FireClient(player, ...)
			testRemote2:_fire(player, ...)
		end,
		fireAll = function(_, ...)
			assert(v, (`Cannot fire destroyed event remote '{name}'`))
			remoteEvent:FireAllClients(...)
			testRemote2:_fire(...)
		end,
		fireAllExcept = function(_, p3, ...)
			assert(v, (`Cannot fire destroyed event remote '{name}'`))

			for _, player in Players:GetPlayers() do
				if player ~= p3 then
					remoteEvent:FireClient(player, ...)
				end
			end

			testRemote2:_fire(...)
		end,
		firePlayers = function(_, items, ...)
			assert(v, (`Cannot fire destroyed event remote '{name}'`))

			for _, player in items do
				remoteEvent:FireClient(player, ...)
			end

			testRemote2:_fire(...)
		end,
		destroy = function(_)
			if not v then
				return
			end

			v = false
			remoteEvent:Destroy()
			remoteEvent = nil
			table.clear(v2)
		end
	}
	local v4 = compose(p2.metadata.middleware)(function(...)
		for _, callback in v2 do
			task.spawn(callback, ...)
		end
	end, v3)
	remoteEvent.OnServerEvent:Connect(function(p3, ...)
		for k, parameter in p2.metadata.parameters do
			local v5 = select(k, ...)
			assert(parameter(v5), (`Invalid parameter #{k} for event remote '{name}': got {v5}`))
		end

		v4(p3, ...)
	end)
	setmetatable(v3, {
		__call = v3.fire
	})
	return v3
end

return createRemote