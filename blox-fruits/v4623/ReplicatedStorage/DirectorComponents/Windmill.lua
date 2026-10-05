local class = {}
class.__index = class
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Director"))
local localPlayer = Players.LocalPlayer

function class:Init()
	self.Connection = RunService.PreSimulation:Connect(function()
		local position = localPlayer.Character and localPlayer.Character:GetPivot().Position or workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position

		if position ~= nil and (self.StartCFrame.Position - position).Magnitude <= 500 then
			local cframe = CFrame.Angles(0, 0, (math.rad(workspace:GetServerTimeNow() * 60 % 360)))
			self.Instance:PivotTo(self.StartCFrame * cframe)
		end
	end)
end

function class:Destroy()
	if self.Connection ~= nil then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			StartCFrame = instance:GetPivot()
		}, class))
	end,
	ancestor = workspace
}