local State = {}
local v = {
	RunningState = {
		Priority = -1
	}
}
v.__index = v
local Maid = require(script.Parent.Maid)
local Signal = require(script.Parent.Signal)

function State.new()
	local maid = Maid.new()
	return (setmetatable({
		Priorities = {},
		Maid = maid,
		Destroy = maid.Destroy
	}, v))
end

function v:AddState(p, p2, callback)
	local priority2 = tonumber(p) or 0

	if priority2 < self.RunningState.Priority then
		return
	end

	local v3 = priority2 ~= self.RunningState.Priority or p2

	if self.Maid.CurrentState and not v3 then
		return false
	end

	local finished = Signal.new()
	local runningState = {
		Remove = function()
			if not self.Priorities[priority2] then
				return
			end

			if self.Priorities[priority2] == self.RunningState then
				self.Maid.CurrentState = nil
				self.RunningState = nil
			end

			self.Priorities[priority2] = nil

			if next(self.Priorities) then
				local v6 = nil

				for _, priority in pairs(self.Priorities) do
					v6 = priority
				end

				self:AddState(v6.Priority, true, v6.Function)
			end

			finished:Fire()
		end,
		Priority = priority2,
		Function = callback,
		Finished = finished
	}
	self.RunningState = runningState
	self.Priorities[priority2] = runningState
	local connection = nil

	function self.Maid.CurrentState()
		if connection then
			if type(connection) == "function" then
				connection()
			elseif typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif typeof(connection) == "table" then
				if connection.Destroy and typeof(connection.Destroy) == "function" then
					connection:Destroy()
				end

				if connection.Disconnect and typeof(connection.Disconnect) == "function" then
					connection:Disconnect()
				end
			elseif typeof(connection) == "Instance" then
				connection:Destroy()
			end
		end
	end

	connection = callback()
	return runningState
end

function v.RemoveState(p, p2)
	local priority = p.Priorities[p2]

	if priority then
		return priority:Remove()
	end
end

return State