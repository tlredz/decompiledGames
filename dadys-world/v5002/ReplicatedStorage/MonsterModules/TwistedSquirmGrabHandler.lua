local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local monsterModules = ReplicatedStorage:WaitForChild("MonsterModules")
local TwistedSquirmConfig = require(monsterModules:WaitForChild("TwistedSquirmConfig"))
local StatModifierManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("StatModifierManager"))
local character = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Character")
local DamageHandler = require(character:WaitForChild("DamageHandler"))
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
local v = {}
local v2 = nil

local function ensureGrabEvent()
	if v2 then
		return v2
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		warn("[TwistedSquirmGrabHandler] Events folder not found!")
		return nil
	end

	v2 = events:FindFirstChild("TwistedSquirmGrab")

	if not v2 then
		v2 = Instance.new("RemoteEvent")
		v2.Name = "TwistedSquirmGrab"
		v2.Parent = events
	end

	return v2
end

ensureGrabEvent()

-- equivalent calls inferred from this helper; original call sites unknown
local function isRealPlayer(player)
	return typeof(player) == "Instance" and player:IsA("Player")
end

local function fireClientEvent(player, p, p2)
	local v3

	if typeof(player) == "Instance" then
		v3 = player:IsA("Player")
	else
		v3 = false
	end

	if not v3 then
		return false
	end

	local grabEvent = ensureGrabEvent()

	if not grabEvent then
		return false
	end

	grabEvent:FireClient(player, p, p2)
	return true
end

local object = setmetatable({}, {
	__mode = "k"
})

local function resolveGrabKey(model)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter then
		return playerFromCharacter
	end

	if model:GetAttribute("IsBotCharacter") ~= true then
		return nil
	end

	local v3 = object[model]

	if v3 then
		return v3
	end

	local v4 = {
		Name = model.Name,
		Character = model,
		IsBotGrabKey = true,
		SetAttribute = function(self, p, p2)
			if model.Parent then
				model:SetAttribute(p, p2)
			end
		end,
		GetAttribute = function(self, attributeName)
			return model:GetAttribute(attributeName)
		end,
		IsA = function()
			return false
		end
	}
	object[model] = v4
	return v4
end

local TwistedSquirmGrabHandler = {
	ResolveGrabKey = resolveGrabKey
}
local v3 = nil

local function provisionEscapeGui(player)
	if not RunService:IsServer() then
		return
	end

	local v4

	if typeof(player) == "Instance" then
		v4 = player:IsA("Player")
	else
		v4 = false
	end

	if not v4 then
		return
	end

	if not v3 then
		local success, result = pcall(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			return require(ServerScriptService.Modules.GuiProvisioner)
		end)

		if success then
			v3 = result
		else
			warn("[TwistedSquirmGrabHandler] GuiProvisioner unavailable:", result)
			return
		end
	end

	v3.give(player, "TwistedSquirmEscapeUI")
end

local function fireAllClientsEvent(p, p2)
	local grabEvent = ensureGrabEvent()

	if not grabEvent then
		return false
	end

	grabEvent:FireAllClients(p, p2)
	return true
end

local function alertMonsters(p)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local machineEvent = events:FindFirstChild("MachineEvent")

	if not machineEvent then
		return
	end

	machineEvent:Fire(p, nil)
end

local function playEscapeSound(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Audio:Play("Sounds.Twisted.Squirm.Escape", {
		Volume = TwistedSquirmConfig.ESCAPE_EFFECTS.SCREAM_VOLUME,
		RollOffMaxDistance = TwistedSquirmConfig.ESCAPE_EFFECTS.SCREAM_ROLLOFF,
		Parent = humanoidRootPart
	})
end

local class = {}
class.__index = class

function class.new(controller, player)
	local self = setmetatable({}, class)
	self.controller = controller
	self.player = player
	self.character = player.Character
	self.startTime = workspace.DistributedGameTime
	self.connection = nil
	self.active = true
	self.escapeProgress = 0
	self.lastStruggleSide = nil
	self.lastStruggleTime = 0
	self.struggleCount = 0
	self.lastProgressSyncTime = 0
	self.mobileBonus = 1
	self.speedModifierIds = nil
	return self
end

function class:Start()
	if not self.character then
		return false
	end

	local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	if self.character:GetAttribute("HoldAbilityActive") then
		local characterModules = ReplicatedStorage:FindFirstChild("CharacterModules")
		local squirmAbility = characterModules and characterModules:FindFirstChild("SquirmAbility")

		if squirmAbility then
			local success, result = pcall(require, squirmAbility)

			if success and result and result.CancelChannel then
				result.CancelChannel(self.character, "Grabbed by Twisted Squirm")
			end
		end
	end

	self.speedModifierIds = StatModifierManager.ApplySpeedModifiers(
		self.character,
		TwistedSquirmConfig.GRAB.GRAB_SPEED_MULTIPLIER,
		"SquirmGrab",
		{
			category = "debuff",
			antiCheat = true
		}
	)
	self.unequippedTool = nil
	local humanoid = self.character:FindFirstChildOfClass("Humanoid")
	local tool = humanoid and self.character:FindFirstChildOfClass("Tool")

	if tool then
		self.unequippedTool = tool
		pcall(function()
			humanoid:UnequipTools()
		end)
	end

	self.character:SetAttribute("GrabbedBySquirm", self.controller.id)
	self.controller.monster:SetAttribute("GrabbedPlayer", self.player.Name)

	if TwistedSquirmConfig.GRAB_EFFECTS.SOUND_ENABLED then
		local rootPart = self.controller.rootPart

		if rootPart then
			Audio:Play("Sounds.Twisted.Squirm.Grab", {
				Volume = TwistedSquirmConfig.GRAB_EFFECTS.SOUND_VOLUME,
				Parent = rootPart
			})
		end

		if humanoidRootPart then
			Audio:Play("Sounds.Twisted.Squirm.Gasp", {
				Volume = TwistedSquirmConfig.GRAB_EFFECTS.SOUND_VOLUME * 0.9,
				Parent = humanoidRootPart
			})
		end

		local holdingSound = rootPart and Audio:Play("Sounds.Twisted.Squirm.HoldingLoop", {
			Volume = 0.5,
			Looped = true,
			RollOffMaxDistance = 50,
			Parent = rootPart
		})

		if holdingSound then
			self.holdingSound = holdingSound
		end
	end

	provisionEscapeGui(self.player)
	local STRUGGLE = TwistedSquirmConfig.STRUGGLE or {}
	local player = self.player
	local v4 = {
		strugglesToEscape = STRUGGLE.STRUGGLES_TO_ESCAPE or 20,
		decayRate = STRUGGLE.DECAY_RATE or 3,
		decayDelay = STRUGGLE.DECAY_DELAY or 0.8,
		speedMultiplier = TwistedSquirmConfig.GRAB.GRAB_SPEED_MULTIPLIER,
		maxDuration = TwistedSquirmConfig.GRAB.MAX_DURATION,
		grabServerTime = self.startTime,
		shake = TwistedSquirmConfig.GRAB_EFFECTS.SHAKE_ENABLED,
		shakeDuration = TwistedSquirmConfig.GRAB_EFFECTS.SHAKE_DURATION,
		shakeIntensity = TwistedSquirmConfig.GRAB_EFFECTS.SHAKE_INTENSITY,
		blur = TwistedSquirmConfig.GRAB_EFFECTS.BLUR_ENABLED,
		blurDuration = TwistedSquirmConfig.GRAB_EFFECTS.BLUR_DURATION,
		blurSize = TwistedSquirmConfig.GRAB_EFFECTS.BLUR_SIZE,
		armWiggle = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_ENABLED,
		armWiggleDuration = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_DURATION,
		armWiggleIntensity = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_INTENSITY,
		armWiggleFlail = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_FLAIL
	}
	local v6 = isRealPlayer(player) and ensureGrabEvent()

	if v6 then
		v6:FireClient(player, "GrabStart", v4)
	end

	local v7 = {
		character = self.character,
		armWiggle = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_ENABLED,
		armWiggleDuration = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_DURATION,
		armWiggleIntensity = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_INTENSITY
	}
	local grabEvent = ensureGrabEvent()

	if grabEvent then
		grabEvent:FireAllClients("ObserverGrabStart", v7)
	end

	self.connection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
	local humanoid2 = self.character:FindFirstChildOfClass("Humanoid")

	if humanoid2 then
		self.diedConnection = humanoid2.Died:Connect(function()
			self:End("killed")
		end)
	end

	local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
	return true
end

function class:ProcessStruggle(lastStruggleSide)
	if not self.active then
		return false
	end

	local decoding = self.character and self.character:FindFirstChild("Decoding")

	if decoding and decoding.Value or lastStruggleSide ~= "left" and lastStruggleSide ~= "right" then
		return false
	end

	local now = tick()
	local STRUGGLE = TwistedSquirmConfig.STRUGGLE or {}

	if self.lastStruggleSide == lastStruggleSide or (STRUGGLE.MIN_INPUT_INTERVAL or 0.05) > now - self.lastStruggleTime then
		return false
	end

	self.lastStruggleSide = lastStruggleSide
	self.lastStruggleTime = now
	self.struggleCount += 1
	local v4 = (STRUGGLE.PROGRESS_PER_STRUGGLE or 5) * self.mobileBonus
	self.escapeProgress = math.min(100, self.escapeProgress + v4)
	local _ = TwistedSquirmConfig.DEBUG.LOG_GRAB_PROGRESS
	local player = self.player
	local v5 = {
		percentage = self.escapeProgress / 100,
		struggleCount = self.struggleCount
	}
	local v7 = isRealPlayer(player) and ensureGrabEvent()

	if v7 then
		v7:FireClient(player, "GrabProgress", v5)
	end

	if self.escapeProgress >= 100 then
		self:End("escaped")
	end

	return true
end

function class:Update(p)
	if not self.active then
		return
	end

	if not (self.character and self.character.Parent) then
		self:End("character_gone")
	elseif self.character:FindFirstChild("NoTarget") or self.character:FindFirstChild("Invincible") then
		self.character:FindFirstChild("NoTarget")
		self:End("stealth")
	elseif workspace.DistributedGameTime - self.startTime >= TwistedSquirmConfig.GRAB.MAX_DURATION then
		local TIMEOUT_DAMAGE = TwistedSquirmConfig.GRAB.TIMEOUT_DAMAGE or 1

		if TIMEOUT_DAMAGE > 0 and self.character then
			local success, result = pcall(DamageHandler.handleDamage, self.character, TIMEOUT_DAMAGE, "Squirm", 0)

			if not success then
				warn("[TwistedSquirmGrabHandler] Timeout damage failed:", result)
			end

			local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
		end

		self:End("timeout")
	else
		local STRUGGLE = TwistedSquirmConfig.STRUGGLE or {}
		local DECAY_DELAY = STRUGGLE.DECAY_DELAY or 0.8
		local DECAY_RATE = STRUGGLE.DECAY_RATE or 3
		local now = tick()

		if DECAY_DELAY < now - self.lastStruggleTime then
			local escapeProgress = self.escapeProgress
			self.escapeProgress = math.max(0, self.escapeProgress - DECAY_RATE * p)

			if self.escapeProgress ~= escapeProgress and now - self.lastProgressSyncTime >= 0.2 then
				self.lastProgressSyncTime = now
				local player = self.player
				local v4 = {
					percentage = self.escapeProgress / 100
				}
				local v5

				if typeof(player) == "Instance" then
					v5 = player:IsA("Player")
				else
					v5 = false
				end

				if not v5 then
					return
				end

				local grabEvent = ensureGrabEvent()

				if not grabEvent then
					return
				end

				grabEvent:FireClient(player, "GrabProgress", v4)
			end
		end
	end
end

function class:End(reason)
	if not self.active then
		return
	end

	self.active = false

	if self.holdingSound then
		pcall(function()
			self.holdingSound:Stop()
			self.holdingSound:Destroy()
		end)
		self.holdingSound = nil
	end

	if self.connection then
		pcall(function()
			self.connection:Disconnect()
		end)
		self.connection = nil
	end

	if self.diedConnection then
		pcall(function()
			self.diedConnection:Disconnect()
		end)
		self.diedConnection = nil
	end

	if self.character and self.character.Parent then
		if self.speedModifierIds then
			pcall(function()
				StatModifierManager.RemoveSpeedModifiers(self.character, self.speedModifierIds)
			end)
			self.speedModifierIds = nil
		end

		if self.unequippedTool and self.unequippedTool.Parent then
			local humanoid = self.character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid:EquipTool(self.unequippedTool)
				end)
			end

			self.unequippedTool = nil
		end

		pcall(function()
			self.character:SetAttribute("GrabbedBySquirm", nil)
		end)
	end

	if self.controller and self.controller.monster and self.controller.monster.Parent then
		pcall(function()
			self.controller.monster:SetAttribute("GrabbedPlayer", nil)
		end)
	end

	pcall(function()
		local player = self.player
		local v4 = {
			reason = reason,
			escaped = reason == "escaped"
		}
		local v5

		if typeof(player) == "Instance" then
			v5 = player:IsA("Player")
		else
			v5 = false
		end

		if not v5 then
			return
		end

		local grabEvent = ensureGrabEvent()

		if not grabEvent then
			return
		end

		grabEvent:FireClient(player, "GrabEnd", v4)
	end)
	pcall(function()
		local v4 = {
			character = self.character
		}
		local grabEvent = ensureGrabEvent()

		if not grabEvent then
			return
		end

		grabEvent:FireAllClients("ObserverGrabEnd", v4)
	end)

	if reason == "escaped" and self.character and self.character.Parent and self.character:FindFirstChild("HumanoidRootPart") then
		pcall(playEscapeSound, self.character)

		if TwistedSquirmConfig.GRAB.ALERT_TWISTEDS_ON_ESCAPE then
			pcall(alertMonsters, self.character)
		end

		pcall(function()
			local player = self.player
			local v4 = {
				shake = TwistedSquirmConfig.ESCAPE_EFFECTS.SHAKE_ENABLED,
				shakeDuration = TwistedSquirmConfig.ESCAPE_EFFECTS.SHAKE_DURATION,
				shakeIntensity = TwistedSquirmConfig.ESCAPE_EFFECTS.SHAKE_INTENSITY,
				blur = TwistedSquirmConfig.ESCAPE_EFFECTS.BLUR_ENABLED,
				blurDuration = TwistedSquirmConfig.ESCAPE_EFFECTS.BLUR_DURATION,
				blurSize = TwistedSquirmConfig.ESCAPE_EFFECTS.BLUR_SIZE
			}
			local v5

			if typeof(player) == "Instance" then
				v5 = player:IsA("Player")
			else
				v5 = false
			end

			if not v5 then
				return
			end

			local grabEvent = ensureGrabEvent()

			if not grabEvent then
				return
			end

			grabEvent:FireClient(player, "EscapeEffect", v4)
		end)
	end

	v[self.player] = nil

	if self.controller then
		local success, result = pcall(function()
			self.controller:OnGrabEnded(reason)
		end)

		if not success then
			warn("[TwistedSquirmGrabHandler] ⚠ OnGrabEnded() failed:", result)
		end
	else
		warn("[TwistedSquirmGrabHandler] ⚠ No controller reference - cannot call OnGrabEnded!")
	end
end

local function setupClientEventHandler()
	local grabEvent = ensureGrabEvent()

	if not grabEvent then
		return
	end

	grabEvent.OnServerEvent:Connect(function(p, p2, p3)
		local v4 = v[p]

		if not v4 then
			return
		end

		if p2 == "Struggle" then
			v4:ProcessStruggle(p3)
		elseif p2 == "SetMobile" then
			v4.mobileBonus = 1.25
		elseif p2 == "StruggleFail" then
			local _ = TwistedSquirmConfig.DEBUG.LOG_GRAB_PROGRESS
		end
	end)
end

local grabEvent = ensureGrabEvent()

if grabEvent then
	grabEvent.OnServerEvent:Connect(function(p, p2, p3)
		local v4 = v[p]

		if not v4 then
			return
		end

		if p2 == "Struggle" then
			v4:ProcessStruggle(p3)
		elseif p2 == "SetMobile" then
			v4.mobileBonus = 1.25
		elseif p2 == "StruggleFail" then
			local _ = TwistedSquirmConfig.DEBUG.LOG_GRAB_PROGRESS
		end
	end)
end

function TwistedSquirmGrabHandler.StartGrab(p, player)
	if not (player and player.Character) then
		return false
	end

	local character2 = player.Character

	if v[player] then
		local grabbedBySquirm = character2:GetAttribute("GrabbedBySquirm")

		if grabbedBySquirm then
			if TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES then
				warn("[TwistedSquirmGrabHandler] Player already grabbed:", player.Name, "by", grabbedBySquirm)
			end

			return false
		else
			warn("[TwistedSquirmGrabHandler] Clearing stale activeGrabs entry for", player.Name)
			v[player] = nil
		end
	end

	if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
		return false
	end

	if character2:GetAttribute("GrabbedBySquirm") then
		warn(
			"[TwistedSquirmGrabHandler] Clearing stale GrabbedBySquirm attribute from",
			player.Name,
			"- no active grab exists for this player"
		)
		character2:SetAttribute("GrabbedBySquirm", nil)
	end

	local v4 = class.new(p, player)

	if not v4:Start() then
		return false
	end

	v[player] = v4
	return true
end

function TwistedSquirmGrabHandler.ForceRelease(character2, value)
	if not character2 then
		return false
	end

	local grabKey = resolveGrabKey(character2)

	if not grabKey then
		return false
	end

	local v4 = v[grabKey]

	if not v4 then
		return false
	end

	v4:End(value or "forced")
	return true
end

function TwistedSquirmGrabHandler.ForceGrab(instance, instance2)
	if not (instance and instance2) then
		return false
	end

	local grabKey = resolveGrabKey(instance2)

	if not grabKey then
		return false
	end

	if instance2:GetAttribute("GrabbedBySquirm") then
		warn("[TwistedSquirmGrabHandler] ForceGrab: Player already grabbed")
		return false
	end

	local rootPart = instance:FindFirstChild("RootPart") or instance.PrimaryPart
	local v4 = {
		id = "admin_" .. tostring(tick()),
		monster = instance,
		rootPart = rootPart,
		isAdmin = true,
		OnGrabEnded = function() end
	}
	local v5 = class.new(v4, grabKey)

	if v5:Start() then
		v[grabKey] = v5
		return true
	end

	warn("[TwistedSquirmGrabHandler] ForceGrab: Failed to start grab")
	return false
end

function TwistedSquirmGrabHandler.IsGrabbed(p)
	return v[p] ~= nil
end

function TwistedSquirmGrabHandler.GetGrabData(p)
	return v[p]
end

function TwistedSquirmGrabHandler.GetActiveGrabs()
	return v
end

Players.PlayerRemoving:Connect(function(player)
	local v4 = v[player]

	if v4 then
		v4:End("player_left")
	end
end)
return TwistedSquirmGrabHandler