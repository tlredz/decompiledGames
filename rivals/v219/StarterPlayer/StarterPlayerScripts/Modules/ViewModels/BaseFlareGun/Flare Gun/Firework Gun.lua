local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FlareGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseFlareGun["Flare Gun"])
local object = setmetatable({}, FlareGun)
object.__index = object

function object.new(...)
	local self = setmetatable(FlareGun.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileShot:Connect(function(p2, instance)
			local primary = instance.Primary
			local explode = instance.Primary.explode
			Utility:CreateSound("rbxassetid://17684836623", 1.25, 1, primary, true, 5)
			local v = tick() + 0.5

			while not self._destroyed and instance:IsDescendantOf(workspace) and (tick() < v or p2.Velocity.Y >= 0) do
				RunService.RenderStepped:Wait()
			end

			Utility:PlayParticles(explode)
			Utility:CreateSound("rbxassetid://17684836889", 1.25, 1, primary, true, 5)
		end)
	end)
end

return object