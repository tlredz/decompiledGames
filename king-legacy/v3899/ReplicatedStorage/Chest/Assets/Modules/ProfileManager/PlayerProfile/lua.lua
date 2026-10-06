local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signallua = require(script.Parent:WaitForChild("Signal.lua"))
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TaskManager = require(ReplicatedStorage.Chest.Assets.Modules.TaskManager)
local DamageIndicator = require(ReplicatedStorage.Chest.Assets.Modules.Features.DamageIndicator)
local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile

function PlayerProfile.new(player)
	return (setmetatable({
		_Animations = {},
		_Events = {},
		_Caches = {},
		_Registered = {},
		_Player = player
	}, PlayerProfile))
end

function PlayerProfile:SetCharacter(folder)
	if not folder then
		return
	end

	for _, _Event in pairs(self._Events) do
		_Event:Disconnect()
	end

	for _, _Animation in pairs(self._Animations) do
		_Animation:Destroy()
	end

	table.clear(self._Events)
	table.clear(self._Animations)
	table.clear(self._Caches)
	table.clear(self._Registered)
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart", 7)
	local humanoid = folder:WaitForChild("Humanoid", 7)

	if not (humanoidRootPart and humanoid) then
		return
	end

	self.Character = folder
	self.Humanoid = humanoid
	self.RootPart = humanoidRootPart
	RunService:IsServer()

	if RunService:IsClient() then
		table.insert(self._Events, DamageIndicator.new(folder))
		table.insert(self._Events, humanoid.Died:Connect(function()
			for _, descendant in ipairs(folder:GetDescendants()) do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
					continue
				end

				if descendant:IsA("BasePart") then
					descendant.Anchored = true
				end

				descendant.Transparency = 1
			end

			local clone = ReplicatedStorage.Chest.Assets.Effects.DeathFX:Clone()
			clone:PivotTo(folder:GetPivot())
			clone.Parent = workspace.Effects
			PeoUtils.EmitParticles(clone)
			PeoUtils:Dust(clone, 1.5)
		end))
	end

	Signallua:Fire("OnCharacterAdded", folder)
end

function PlayerProfile:GetPartName(childName: string)
	if self._Caches[childName] then
		return self._Caches[childName]
	end

	local character = self.Character

	if not character then
		return
	end

	local child = character:FindFirstChild(childName)

	if not child then
		return
	end

	self._Caches[childName] = child
	return child
end

function PlayerProfile.GetRootPart(p)
	return p.RootPart
end

function PlayerProfile:GetHumanoid()
	return self.Humanoid
end

function PlayerProfile.GetCharacter(player)
	return player.Character
end

function PlayerProfile.GetCharacterComponents(player)
	return player.Character, player.RootPart, player.Humanoid
end

function PlayerProfile:PlayerStats()
	if self._PlayerStats then
		return self._PlayerStats
	end

	local playerStats = self._Player:FindFirstChild("PlayerStats")

	if not playerStats then
		return
	end

	self._PlayerStats = playerStats
	return playerStats
end

function PlayerProfile:GetAnimation(p: string, p2)
	if not self._Animations then
		return
	end

	if self._Animations[p] then
		return self._Animations[p]
	end

	local humanoid = self:GetHumanoid()

	if not humanoid then
		return
	end

	local track = humanoid:LoadAnimation(ReplicatedStorage.GameAssets.Animations.Profiles[p])
	track.Priority = p2 or track.Priority
	self._Animations[p] = track
	return track
end

function PlayerProfile:RegisterInstance(p2: string, instance)
	local _Registered = self._Registered
	local maids = _Registered[p2] and _Registered[p2].Maids

	if maids then
		local success, result = pcall(function()
			maids:Destroy()
		end)

		if not success then
			warn(result)
		end
	end

	local maid = TaskManager.new()
	maid:LinkToInstance(instance)
	maid:GiveTask(function()
		_Registered[p2] = nil
	end)
	_Registered[p2] = {
		Instance = instance,
		Maids = maid
	}
end

function PlayerProfile:GetRegisteredInstance(p2)
	local v = self._Registered[p2]

	if v then
		return v.Instance
	end
end

function ClearEnchantParticles(instance)
	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "EnchantEffect" then
			emitter:Destroy()
		end
	end
end

function PlayerProfile:UpdateEnchant(p: string)
	local character = self.Character

	if not character then
		return
	end

	local enchantType = character:GetAttribute("EnchantType")
	local _ = self._Registered
	local registeredInstance = self:GetRegisteredInstance(p)

	if not registeredInstance then
		return
	end

	local child = enchantType and ServerStorage.ServerChest.Tools.Etc.EnchantParticles:FindFirstChild(enchantType)

	for _, part in ipairs(registeredInstance:GetDescendants()) do
		if not (part:IsA("BasePart") and part:GetAttribute("EnchantParticle")) then
			continue
		end

		ClearEnchantParticles(part)

		if not child then
			continue
		end

		for _, child2 in ipairs(child:GetChildren()) do
			local clone = child2:Clone()
			clone.Enabled = part.Transparency < 1 or nil
			clone.Name = "EnchantEffect"
			clone.Parent = part
		end
	end
end

function PlayerProfile:Destroy()
	self.Character = nil
	self.Humanoid = nil
	self.RootPart = nil

	for _, _Event in pairs(self._Events) do
		_Event:Disconnect()
	end

	for _, _Animation in pairs(self._Animations) do
		_Animation:Destroy()
	end

	table.clear(self._Events)
	table.clear(self._Animations)
	table.clear(self._Caches)
end

function PlayerProfile:WaitForCharacterReady()
	while not self.Character and not self.Humanoid and not self.RootPart and self._Player:IsDescendantOf(Players) do
		task.wait(0.03333333333333333)
	end
end

return PlayerProfile