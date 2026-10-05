local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ViewModelParticlesLogic = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModelParticlesLogic)
local Molotov = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Molotov)
local object = setmetatable({}, Molotov)
object.__index = object

function object.new(...)
	local self = setmetatable(Molotov.new(...), object)
	self._particles_logic = ViewModelParticlesLogic.new(self)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, p2, p3)
	Molotov.ExplosionEffect(p, p2, p3)
	Utility:CreateSound("rbxassetid://72790275842437", 0.5, 1 + 0.25 * math.random(), p2, true, 10)
end

function object:Unequip(...)
	self._particles_logic:CancelEffect()
	Molotov.Unequip(self, ...)
end

function object:Destroy()
	self._particles_logic:Destroy()
	Molotov.Destroy(self)
end

function object:_Init()
	self.Equipped:Connect(function(p)
		self._particles_logic:PlayEffect(0, p and 0 or 0.55)
	end)
	self.AnimationPlayed:Connect(function(p)
		if p == "ThrowFinish" then
			self._particles_logic:PlayEffect(0.65, 0.5)
		elseif p == "LobFinish" then
			self._particles_logic:PlayEffect(0.65, 0.5)
		end
	end)
end

return object