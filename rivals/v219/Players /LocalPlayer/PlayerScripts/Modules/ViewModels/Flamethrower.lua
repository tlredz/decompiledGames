local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local flamethrowerAirblasts = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("FlamethrowerAirblasts")
local flamethrowerFlames = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("FlamethrowerFlames")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._flame_particles = {}
	self._flame_particles_hash = 0
	self._flame_sounds = nil
	self._flame_particles_enabled_count = 0
	self._flame_particles_enabled = false
	self:_Init()
	return self
end

function object:SetFlameParticlesEnabled(p)
	self._flame_particles_enabled_count += p and 1 or -1
	local flame_particles_enabled = self._flame_particles_enabled_count > 0

	if flame_particles_enabled == self._flame_particles_enabled then
		return
	end

	self._flame_particles_enabled = flame_particles_enabled
	self._flame_particles_hash += 1
	local _flame_particles_hash = self._flame_particles_hash

	for _, instance in pairs(self._flame_particles) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = self._flame_particles_enabled
		elseif instance:IsA("Light") then
			if self._flame_particles_enabled then
				instance.Brightness = 10
			else
				local v2 = instance
				task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 10, function(p2)
					if _flame_particles_hash ~= self._flame_particles_hash then
						return true
					end

					v2.Brightness = 20 * (1 - p2 / 100)
				end)
			end
		end
	end

	if self._flame_particles_enabled then
		self:PlayFlameSoundEffect()
	else
		self:StopFlameSoundEffect()
	end
end

function object:PlayFlameSoundEffect(_)
	self:StopFlameSoundEffect(false)
	self._flame_sounds = self._flame_sounds or self:_CreateFlameSoundEffects()

	for _, _flame_sound in pairs(self._flame_sounds) do
		_flame_sound.Looped = true
	end
end

function object:StopFlameSoundEffect(_)
	local v = self._flame_sounds and Utility:CloneTable(self._flame_sounds)
	self._flame_sounds = nil

	if not v or #v == 0 then
		return
	end

	local volumes = {}

	for _, v2 in pairs(v) do
		volumes[v2] = v2.Volume
	end

	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p2)
		for _, v2 in pairs(v) do
			v2.Volume = volumes[v2] * (1 - p2 / 100)
		end
	end)
end

function object:PlayAirblastSoundEffect()
	self:CreateSound("rbxassetid://17209245422", 1, 1, true, 5)
end

function object:AirblastEffect()
	local clones = {}

	for _, child in pairs((flamethrowerAirblasts:FindFirstChild(self.Name) or flamethrowerAirblasts.Default).Attachment:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._muzzle_attachments[1]
		BetterDebris:AddItem(clone, 5)
		table.insert(clones, clone)
	end

	Utility:PlayParticles(clones)
	self:PlayAirblastSoundEffect()
end

function object:_CreateFlameSoundEffects()
	return { self:CreateSound("rbxassetid://17209245734", 1.5, 1, true) }
end

function object:_Setup()
	for _, child in pairs((flamethrowerFlames:FindFirstChild(self.Name) or flamethrowerFlames.Default).Attachment:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._muzzle_attachments[1]
		table.insert(self._flame_particles, clone)
	end
end

function object:_Init()
	self:_Setup()
end

return object