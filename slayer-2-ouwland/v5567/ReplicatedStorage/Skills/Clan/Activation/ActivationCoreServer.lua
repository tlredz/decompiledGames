local ReplicatedStorage = game:GetService("ReplicatedStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local Utility = require(global:WaitForChild("Utility"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local StatTypes = require(global.Types.StatTypes)

-- equivalent calls inferred from this helper; original call sites unknown
local function dropAura(instance, childName: string, flag: boolean?)
	if instance == nil then
		return
	end

	local child = instance:FindFirstChild(childName)

	if child ~= nil and child:GetAttribute("_ClanAura") == true then
		if flag then
			child:SetAttribute("_ClanAuraReplaced", true)
		end

		child:Destroy()
	end
end

local v = {
	["Poison Generation"] = true
}
local tickEnabled = ReplicatedStorage:WaitForChild("Effects"):WaitForChild("TickEffects"):WaitForChild("TickEnabled")

local function hasAuraTemplate(childName: string)
	if tickEnabled:FindFirstChild(childName) ~= nil then
		return true
	end

	if not v[childName] then
		return false
	end

	local clans = ReplicatedStorage.Effects:FindFirstChild("Clans")
	local activationVFX

	if clans ~= nil then
		activationVFX = clans:FindFirstChild("ActivationVFX") or nil
	end

	local effects

	if activationVFX ~= nil then
		effects = activationVFX:FindFirstChild("Effects") or nil
	end

	return effects ~= nil and effects:FindFirstChild(childName) ~= nil
end

local v2 = {
	Duration = true,
	Enemies = true,
	EnemyDuration = true
}

local function raiseAura(instance, instance2, childName: string, p: number?)
	if instance == nil or instance2 == nil then
		return
	end

	dropAura(instance2, childName, true) -- equivalent call inferred; original call site unknown
	local v3 = Config.STAT_MARKS[childName]
	local v4

	if not (v3 == nil or v3.Enemies == true) then
		v4 = v3
	end

	local v5 = p or v3 ~= nil and v3.Duration or Config.DEFAULT_DURATION
	local v6 = Utility.AddTimedValue(instance2, childName, v5)
	v6:SetAttribute("_ClanAura", true)

	if v4 ~= nil then
		local flag = false

		for k in v4 do
			if v2[k] then
				continue
			end

			flag = true
			break
		end

		if flag then
			v6:AddTag(StatTypes.ValueStatTag)

			for k, v8 in v4 do
				if not v2[k] then
					v6:SetAttribute(StatTypes.StatToAttribute(k), v8)
				end
			end
		end
	end

	if hasAuraTemplate(childName) then
		EffectsEvent.ToAllInRange(instance, "TickEnabled", instance, childName, true, true)
		v6.Destroying:Once(function()
			EffectsEvent.ToAll("TickEnabled", instance, childName, false, true)
		end)
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		local diedConnection = nil
		diedConnection = humanoid.Died:Once(function()
			diedConnection = nil

			if v6.Parent ~= nil then
				v6:Destroy()
			end
		end)
		v6.Destroying:Once(function()
			if diedConnection ~= nil then
				diedConnection:Disconnect()
			end
		end)
	end
end

local function effectOf(instance)
	local effectServer = instance ~= nil and instance:FindFirstChild("EffectServer") or nil

	if effectServer == nil or not effectServer:IsA("ModuleScript") then
		return nil
	end

	local module = require(effectServer)
	return module
end

local ActivationCoreServer = {}
ActivationCoreServer.ReplacedAttribute = "_ClanAuraReplaced"

function ActivationCoreServer.Raise(p, childName: string, p2: number?)
	local getvaluesfolder = Utility.getvaluesfolder(p)
	raiseAura(p, getvaluesfolder, childName, p2)
	local child = script.Parent.Parent:FindFirstChild(childName)
	local effectServer

	if child ~= nil then
		effectServer = child:FindFirstChild("EffectServer") or nil
	end

	local module

	if not (effectServer == nil or not effectServer:IsA("ModuleScript")) then
		module = require(effectServer)
	end

	if module ~= nil and module.Activate ~= nil then
		module.Activate(nil, p, getvaluesfolder, {})
	end
end

function ActivationCoreServer.new(p: string, p2)
	local v3 = {
		Id = {},
		Type = p
	}
	local v4 = nil
	local flag = false

	local function getEffect()
		if flag then
			return v4
		end

		flag = true
		local parent = p2 ~= nil and p2.Parent or nil
		local effectServer = parent ~= nil and parent:FindFirstChild("EffectServer") or nil
		local v5

		if not (effectServer == nil or not effectServer:IsA("ModuleScript")) then
			v5 = require(effectServer)
		end

		v4 = v5
		return v4
	end

	function v3.Hold(player, _, p3)
		local character = player.Character

		if character == nil then
			return false
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return false
		end

		p3.Type = p
		local getvaluesfolder = Utility.getvaluesfolder(character)
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK)
		EffectsEvent.ToAllInRange(player, "ActivationVFX", character, p)
		local v5 = v3.Id[player.UserId]
		local v6, v7 = ManuelCancel.new(player, Config.LOCK)
		v6:Connect(function()
			v5 = -1
			v7()
		end)
		task.wait(Config.LOCK)

		if v5 ~= v3.Id[player.UserId] or humanoidRootPart.Parent == nil then
			v7()
			return false
		end

		raiseAura(character, getvaluesfolder, p)

		if not flag then
			flag = true
			local parent

			if p2 ~= nil then
				parent = p2.Parent or nil
			end

			local effectServer

			if parent ~= nil then
				effectServer = parent:FindFirstChild("EffectServer") or nil
			end

			local v8

			if not (effectServer == nil or not effectServer:IsA("ModuleScript")) then
				v8 = require(effectServer)
			end

			v4 = v8
		end

		local v8 = v4

		if v8 ~= nil and v8.Activate ~= nil then
			v8.Activate(player, character, getvaluesfolder, p3)
		end

		v7()
		return true
	end

	function v3.Switch(player, _, p3)
		local character = player and player.Character

		if character == nil then
			return
		end

		if not flag then
			flag = true
			local parent

			if p2 ~= nil then
				parent = p2.Parent or nil
			end

			local effectServer

			if parent ~= nil then
				effectServer = parent:FindFirstChild("EffectServer") or nil
			end

			local v5

			if not (effectServer == nil or not effectServer:IsA("ModuleScript")) then
				v5 = require(effectServer)
			end

			v4 = v5
		end

		local v5 = v4

		if v5 ~= nil and v5.Switch ~= nil then
			v5.Switch(player, character, Utility.getvaluesfolder(character), p3)
		end
	end

	function v3.Cancel(player, _, p3)
		if player == nil then
			return
		end

		local character = player.Character

		if not flag then
			flag = true
			local parent

			if p2 ~= nil then
				parent = p2.Parent or nil
			end

			local effectServer

			if parent ~= nil then
				effectServer = parent:FindFirstChild("EffectServer") or nil
			end

			local v5

			if not (effectServer == nil or not effectServer:IsA("ModuleScript")) then
				v5 = require(effectServer)
			end

			v4 = v5
		end

		local v5 = v4

		if character ~= nil and v5 ~= nil and v5.Cancel ~= nil then
			v5.Cancel(player, character, Utility.getvaluesfolder(character), p3)
		end
	end

	return v3
end

return ActivationCoreServer