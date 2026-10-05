local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Parent.Promise)
require(script.Parent.Parent.types)
local constants = require(script.Parent.Parent.constants)
local getSender = require(script.Parent.Parent.getSender)

-- equivalent calls inferred from this helper; original call sites unknown
local function timeout(fn, p: number)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if p <= total then
			heartbeatConnection:Disconnect()
			fn()
		end
	end)
	return function()
		heartbeatConnection:Disconnect()
	end
end

local function throttleMiddleware(value)
	local throttle = 0.1
	local trailing = false

	if type(value) == "number" then
		throttle = value
	elseif type(value) == "table" then
		if value.throttle ~= nil then
			throttle = value.throttle
		end

		if value.trailing ~= nil then
			trailing = value.trailing
		end
	end

	local function fn(callback, p)
		local v = {}
		local v2 = {}
		return function(...)
			local sender = getSender(...)
			local v3 = not sender and "(SERVER)" or sender.Name
			local v4 = v[v3]
			v2[v3] = table.pack(...)

			if v4 then
				if not constants.IS_TEST and constants.IS_STUDIO then
					warn((`🔴 throttled remote '{p.name}' fired by '{v3}'`))
				end
			else
				local function fn2()
					local v6 = v2[v3]
					v[v3] = nil
					v2[v3] = nil

					if trailing then
						callback(table.unpack(v6, 1, v6.n))
					end
				end

				v[v3] = timeout(fn2, throttle)
				return callback(...)
			end
		end
	end

	local function fn2(callback, p)
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {}

		local function clearCacheOnPlayerDisconnect(sender)
			if v4[sender.Name] then
				return
			end

			v4[sender.Name] = Promise.fromEvent(Players.PlayerRemoving, function(p2)
				return p2 == sender
			end):andThen(function()
				v[sender.Name] = nil
				v2[sender.Name] = nil
				v3[sender.Name] = nil
				v4[sender.Name] = nil
			end)
		end

		return function(...)
			local sender = getSender(...)
			local v5 = not sender and "(SERVER)" or sender.Name
			local v6 = v[v5]
			local v7 = v3[v5]

			if sender then
				clearCacheOnPlayerDisconnect(sender)
			end

			if v6 or v7 then
				local v8 = assert(v2[v5], (`🔴 throttled remote '{p.name}' requested by '{v5}'`))
				return table.unpack(v8, 1, v8.n)
			end

			v3[v5] = true
			local success, result = pcall(function(...)
				return table.pack(callback(...))
			end, ...)
			v3[v5] = nil

			local function fn3()
				v[v5] = nil
			end

			v[v5] = timeout(fn3, throttle)
			assert(success, result)
			v2[v5] = result
			return table.unpack(result, 1, result.n)
		end
	end

	return function(p, p2)
		if p2.type == "event" then
			return (fn(p, p2))
		end

		if p2.type == "function" then
			return (fn2(p, p2))
		end

		return p
	end
end

return throttleMiddleware