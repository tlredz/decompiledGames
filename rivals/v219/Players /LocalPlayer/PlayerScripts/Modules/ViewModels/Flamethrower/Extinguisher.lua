local Players = game:GetService("Players")
local Flamethrower = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flamethrower)
local object = setmetatable({}, Flamethrower)
object.__index = object

function object.new(...)
	local self = setmetatable(Flamethrower.new(...), object)
	self._inspect_fire_effect_hash = 0
	self:_Init()
	return self
end

function object:Destroy()
	self._inspect_fire_effect_hash += 1
	Flamethrower.Destroy(self)
end

function object._CreateFlameSoundEffects(object2)
	return {
		object2:CreateSound("rbxassetid://17209245734", 0.5, 1.5, true),
		object2:CreateSound("rbxassetid://85294603652818", 1.5, 1, true)
	}
end

function object:_InspectFireEffect()
	self._inspect_fire_effect_hash += 1
	local _inspect_fire_effect_hash = self._inspect_fire_effect_hash
	wait(1.7)

	if self._inspect_fire_effect_hash ~= _inspect_fire_effect_hash then
		return
	end

	self:SetFlameParticlesEnabled(true)
	local _flame_particles_hash = self._flame_particles_hash
	wait(0.1)

	if self._flame_particles_hash == _flame_particles_hash then
		self:SetFlameParticlesEnabled(false)
	end

	wait(0.2)

	if self._inspect_fire_effect_hash ~= _inspect_fire_effect_hash then
		return
	end

	self:SetFlameParticlesEnabled(true)
	local _flame_particles_hash2 = self._flame_particles_hash
	wait(0.1)

	if self._flame_particles_hash == _flame_particles_hash2 then
		self:SetFlameParticlesEnabled(false)
	end
end

function object:_Init()
	self.AnimationPlayed:Connect(function(p)
		if p == "Inspect" then
			self:_InspectFireEffect()
		end
	end)
	self.Unequipped:Connect(function()
		self._inspect_fire_effect_hash += 1
	end)
	task.defer(function()
		self.ClientItem.Airblasted:Connect(function()
			self._inspect_fire_effect_hash += 1
		end)
	end)
end

return object