local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Medkit = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Medkit)
local object = setmetatable({}, Medkit)
object.__index = object

function object.new(...)
	local self = setmetatable(Medkit.new(...), object)
	self.PlayEquipAnimationOnHeal = false
	self._heal_particles_attachment = self.ItemModel:WaitForChild("Head"):WaitForChild("Head"):WaitForChild("_medkitty_heal")
	self:_Init()
	return self
end

function object:_Init()
	task.defer(function()
		table.insert(self._connections, self.ClientItem.AnimationReachedHealTimestamp:Connect(function()
			Utility:PlayParticles(self._heal_particles_attachment)
		end))
	end)
end

return object