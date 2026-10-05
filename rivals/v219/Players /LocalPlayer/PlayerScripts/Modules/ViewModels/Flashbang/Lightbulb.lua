local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Flashbang = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flashbang)
local object = setmetatable({}, Flashbang)
object.__index = object

function object.new(...)
	local self = setmetatable(Flashbang.new(...), object)
	self:_Init()
	return self
end

function object.PlayFlashSound(p, p2)
	Flashbang.PlayFlashSound(p, p2)
	Utility:CreateSound("rbxassetid://137109782386847", 2, 1, p2, true, 10)
end

function object:_Init()
	task.defer(function()
		table.insert(self._connections, self.ClientItem.ProjectileThrown:Connect(function(instance, p2)
			local neon = p2.Neon
			local lastTime = tick()

			while instance:IsDescendantOf(workspace) do
				neon.Transparency = 1 - math.min(1, (tick() - lastTime) / self.ClientItem.Info.DetonateDelay) ^ 4
				RunService.RenderStepped:Wait()
			end
		end))
	end)
end

return object