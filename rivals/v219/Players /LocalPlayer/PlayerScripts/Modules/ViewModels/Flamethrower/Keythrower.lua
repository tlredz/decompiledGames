local Players = game:GetService("Players")
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
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
		object2:CreateSound("rbxassetid://17209245734", 1, 1, true),
		object2:CreateSound("rbxassetid://129124742663895", 2.25, 2, true)
	}
end

function object:_InspectFireEffect()
	self._inspect_fire_effect_hash += 1
	local _inspect_fire_effect_hash = self._inspect_fire_effect_hash
	wait(2.9)

	if self._inspect_fire_effect_hash ~= _inspect_fire_effect_hash then
		return
	end

	self:SetFlameParticlesEnabled(true)
	local _flame_particles_hash = self._flame_particles_hash
	wait(0.2)

	if self._flame_particles_hash ~= _flame_particles_hash then
		return
	end

	self:SetFlameParticlesEnabled(false)
end

function object:_Setup()
	WrapController:ApplyWrap(
		WrapController:RecordOriginalWrapProperties(self._flame_particles),
		self.ClientItem:GetWrap(),
		true
	)
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
	self:_Setup()
end

return object