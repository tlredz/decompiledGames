local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local RunService = game:GetService("RunService")
local Drag = {}
Drag.__index = Drag

function Drag.New(instance)
	local self = setmetatable({}, Drag)
	self.Instance = instance
	self.Active = false
	return self
end

function Drag:Start()
	if not self.Active then
		self.Active = true
		local mouseLocation = UserInputService:GetMouseLocation()
		local position = self.Instance.Position
		self._dragFunc = RunService.Heartbeat:Connect(function()
			local v = UserInputService:GetMouseLocation() - mouseLocation
			self.Instance.Position = position + UDim2.fromOffset(v.X, v.Y)
		end)
	end
end

function Drag:Stop()
	self.Active = false

	if self._dragFunc then
		self._dragFunc:Disconnect()
		self._dragFunc = nil
	end
end

return Drag