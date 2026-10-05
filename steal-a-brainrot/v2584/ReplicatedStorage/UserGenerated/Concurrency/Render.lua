local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Logging = require(ReplicatedStorage.UserGenerated.Logging)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local frozen = table.freeze({
	__index = table.freeze({
		Disconnect = function(self)
			self.Connection:Disconnect()
			self:OnDisconnected()
		end,
		OnDisconnected = function(self)
			if self.Vars.Disconnected then
				return
			end

			self.Vars.Disconnected = true

			for _, callback in ipairs(self.Callbacks) do
				task.spawn(callback)
			end

			table.clear(self.Callbacks)
		end,
		Then = function(p, callback)
			Asserts.Function(callback)

			if p.Vars.Disconnected then
				task.spawn(callback)
			else
				table.insert(p.Callbacks, callback)
			end
		end
	})
})

function new(p: number, callback)
	Asserts.FiniteNonNegative(p)
	Asserts.Function(callback)
	local object = setmetatable({
		Callbacks = {},
		Connection = nil,
		Vars = {
			Disconnected = false
		}
	}, frozen)
	local v = 0
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local flag = false
		local v2 = v
		v += dt

		if p <= v then
			v = p
			renderSteppedConnection:Disconnect()
			flag = true
		end

		local v3 = p <= v and 1 or v / p
		local v4 = v
		local v5 = v - v2
		local success, result = pcall(callback, v3, v4, v5)

		if not success then
			Logging.Warn("RenderError", result)
		end

		if not success or result ~= nil then
			renderSteppedConnection:Disconnect()
			flag = true
		end

		if flag then
			object:OnDisconnected()
		end
	end)
	object.Connection = renderSteppedConnection
	table.freeze(object)
	return object
end

return new