local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local CombatMode = require(CAM.Global.CombatMode)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local name = script.Parent.Name
local Clans = require(CAM.Clans)
local v = {
	Kamado = {
		duration = 10,
		bank = "Taken",
		rankedConversion = 0.07
	},
	Soyama = {
		duration = 12,
		stat = "Damage Reduction Factor",
		amount = 0.08,
		bank = "Dealt",
		bankPvp = 0.75,
		bankPve = 0.5
	}
}
local kamado = v.Kamado

-- equivalent calls inferred from this helper; original call sites unknown
local function variantFor(p)
	return v[Clans.ClanOfCharacter(p) or ""] or kamado
end

local statToAttribute = StatTypes.StatToAttribute(name)
local DebrisModule = require(CAM.DebrisModule)

local function auraOf(instance)
	local child = instance:FindFirstChild(name)

	if child == nil or child:GetAttribute("_ClanAura") ~= true then
		return nil
	end

	return child
end

local function retimeAura(instance, duration: number, p: number)
	local child = instance:FindFirstChild(name)

	if child == nil or child:GetAttribute("_ClanAura") ~= true then
		child = nil
	end

	if child == nil then
		return
	end

	child:SetAttribute("_Started", workspace:GetServerTimeNow())
	child:SetAttribute("_Duration", duration)
	DebrisModule:AddItem(child, p)
end

local function release(instance, instance2, instance3, _: boolean)
	local combatIntuitionStorage = instance3:FindFirstChild("CombatIntuitionStorage")

	if combatIntuitionStorage == nil then
		return
	end

	local value = combatIntuitionStorage.Value
	combatIntuitionStorage:Destroy()
	local combatIntuitionStore = instance3:FindFirstChild("CombatIntuitionStore")

	if combatIntuitionStore ~= nil then
		combatIntuitionStore:Destroy()
	end

	local child

	if instance ~= nil then
		child = instance:FindFirstChild(name .. Skill_Switch_Adder.extension) or nil
	end

	if child ~= nil then
		child:Destroy()
	end

	local rankedConversion = (variantFor(instance2)).rankedConversion
	local v2 = value * ((rankedConversion == nil or instance == nil or not CombatMode.IsRanked(instance)) and 0.1 or rankedConversion)

	if v2 <= 0 then
		local child2 = instance3:FindFirstChild(name)

		if child2 == nil or child2:GetAttribute("_ClanAura") ~= true then
			child2 = nil
		end

		if child2 ~= nil then
			child2:Destroy()
		end
	else
		retimeAura(instance3, 7, 7)
		local v3 = Utility.AddValue(instance3, "CombatIntuitionBonus", 7)
		v3:AddTag(StatTypes.ValueStatTag)
		v3:SetAttribute(StatTypes.StatToAttribute("Additional Damage"), v2)
		v3:SetAttribute(statToAttribute, true)

		if instance2.Parent ~= nil then
			EffectsEvent.ToAllInRange(
				instance2:FindFirstChild("HumanoidRootPart") or instance2,
				"ActivationVFX",
				instance2,
				name,
				"Release"
			)
		end
	end
end

local EffectServer = {}

function EffectServer.Activate(player, p, instance, _)
	if instance:FindFirstChild("CombatIntuitionStorage") ~= nil then
		return
	end

	local v2 = variantFor(p) -- equivalent call inferred; original call site unknown
	local v3 = Utility.AddValue(instance, "CombatIntuitionStorage", nil, "NumberValue", 0)
	v3:SetAttribute("_Started", workspace:GetServerTimeNow())
	v3:SetAttribute("_Length", v2.duration)
	v3:SetAttribute("_Storing", true)
	v3:SetAttribute("_Bank", v2.bank)
	v3:SetAttribute("_BankPvp", v2.bankPvp or 1)
	v3:SetAttribute("_BankPve", v2.bankPve or 1)
	local v4 = Utility.AddValue(instance, "CombatIntuitionStore", v2.duration)
	v4:AddTag(StatTypes.ValueStatTag)

	if v2.stat ~= nil then
		v4:SetAttribute(StatTypes.StatToAttribute(v2.stat), v2.amount)
	end

	v4:SetAttribute(statToAttribute, true)

	if player ~= nil then
		Skill_Switch_Adder.Add(player, name, v2.duration)
	end

	retimeAura(instance, v2.duration, v2.duration + 7)
	task.delay(v2.duration, function()
		if v3.Parent == nil then
			return
		end

		if player == nil or player.Parent ~= nil then
			release(player, player ~= nil and player.Character or p, instance, false)
		else
			v3:Destroy()
		end
	end)
end

function EffectServer.Switch(instance, p, instance2, _)
	local combatIntuitionStorage = instance2:FindFirstChild("CombatIntuitionStorage")

	if combatIntuitionStorage ~= nil then
		local _Started = combatIntuitionStorage:GetAttribute("_Started")
		local v2 = typeof(_Started) ~= "number" and 1e999 or workspace:GetServerTimeNow() - _Started or 1e999

		if v2 < 0.3 then
			local v3 = (combatIntuitionStorage:GetAttribute("_Length") or 0) - v2

			if v3 > 0 and instance:FindFirstChild(name .. Skill_Switch_Adder.extension) == nil then
				Skill_Switch_Adder.Add(instance, name, v3)
			end

			return
		end
	end

	release(instance, p, instance2, true)
end

function EffectServer.Cancel(_, _, _, _) end

return EffectServer