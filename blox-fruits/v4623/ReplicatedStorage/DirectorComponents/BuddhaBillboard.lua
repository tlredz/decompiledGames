local class = {}
class.__index = class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Director"))

function class:Init()
	self.HeartbeatThread = RunService.Heartbeat:Connect(function()
		local v = tick() - self.StartTime

		if v <= 2 then
			self.Instance.ImageTransparency = math.clamp(1 - v / 2, 0, 1)
			return
		end

		self.Instance.ImageTransparency = 0
		self.Instance.Rotation = 10 * (v - 2) % 360
	end)
end

function class.Destroy(p)
	if p.HeartbeatThread then
		p.HeartbeatThread:Disconnect()
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			StartTime = tick()
		}, class))
	end,
	ancestor = workspace
}