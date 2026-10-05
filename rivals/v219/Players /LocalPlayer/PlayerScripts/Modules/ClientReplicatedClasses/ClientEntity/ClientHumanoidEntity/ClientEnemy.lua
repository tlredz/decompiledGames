local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.SoundLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientHumanoidEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity)
local particles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ZombieSpawnEffect"):WaitForChild("Particles")
local object = setmetatable({}, ClientHumanoidEntity)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientHumanoidEntity.new(...), object)
	self._run_track = nil
	self._idle_track = nil
	self._death_animation_override = false
	self._death_sound_override = false
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "ZombieSpawn" then
		ClientHumanoidEntity.ReplicateFromServer(object2, p, ...)
		return
	end

	object2:_PlayAnimation("ZombieSpawn")
	object2:_CreateSound("rbxassetid://109012456164853", 0.5 + 1 * math.random(), 0.875 + 0.25 * math.random())
	local clone = particles:Clone()
	clone.Parent = object2.Model:FindFirstChild("Head") or object2.Model:FindFirstChild("UpperTorso") or object2.RootPart
	BetterDebris:AddItem(clone, 10)
	Utility:PlayParticles(clone)
	wait(0.5)
	clone.LockedToPart = false
end

function object._DelayedVisibility(p)
	local descendants = {}

	for _, descendant in pairs(p.Model:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		table.insert(descendants, descendant)
	end

	for _, v in pairs(descendants) do
		v.LocalTransparencyModifier = 1
	end

	wait(0.2)

	for _, v in pairs(descendants) do
		v.LocalTransparencyModifier = 0
	end
end

function object:_LoadAnimation(p)
	if p then
		return (self.Humanoid:LoadAnimation(self:_CreateAnimation(p)))
	end

	return nil
end

function object:_SetupTracks()
	self._run_track = self:_LoadAnimation(self:Get("RunAnimation"))
	self._idle_track = self:_LoadAnimation(self:Get("IdleAnimation"))

	if self._idle_track then
		self._idle_track:Play()
	end

	if self._run_track then
		self._run_track:AdjustWeight(0, 0)
		self.Humanoid.Running:Connect(function(p)
			if not self:IsAlive() then
				return
			end

			if not self._run_track.IsPlaying then
				self._run_track:Play()
			end

			self._run_track:AdjustWeight(p >= 0.5 and 1 or 0)
			self._run_track:AdjustSpeed(p * 1.25 / 16 / (self.RootPart.Size.Y / 2))
		end)
	end
end

function object:_Init()
	self.Died:Connect(function()
		if self._idle_track then
			self._idle_track:Stop(0)
			self._idle_track:Play()
			self._idle_track = nil
		end

		if self._run_track then
			self._run_track:Stop(0)
			self._run_track:Destroy()
			self._run_track = nil
		end

		local _ = self._death_sound_override
		local _ = self._death_animation_override
	end)
	pcall(self._SetupTracks, self)
	task.defer(self._DelayedVisibility, self)
end

return object