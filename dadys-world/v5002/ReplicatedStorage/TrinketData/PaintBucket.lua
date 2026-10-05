local PaintBucket = {
	Name = "Paint Bucket",
	Icon = "rbxassetid://137652927158345",
	Rarity = "Common",
	Description = "Increases Skill Check Size and Chance by 10%. As Brusha, receive a +25% speed boost for 5 seconds after a successful machine buff.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	TrinketState = "SkillCheck",
	Cost = 350
}
PaintBucket.Requirement1 = { "Coin", PaintBucket.Cost }
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}

function PaintBucket.ApplyTrinket(p)
	StatModifierManager.ApplyModifier(p, "BoundarySize", 1.1, "PaintBucket", {
		category = "trinket"
	})
	StatModifierManager.ApplyAdditiveSkillCheckChance(p, 10, "PaintBucket")
end

PaintBucket.MachineBuffEvent = true

function PaintBucket.TriggerMachineBuffEvent(instance)
	if instance:GetAttribute("ModuleName") ~= "Brusha" then
		return
	end

	local v2 = v[instance]

	if v2 then
		StatModifierManager.RemoveSpeedModifiers(instance, v2.ids)
		v[instance] = nil
	end

	local ids = StatModifierManager.ApplySpeedModifiers(instance, 1.25, "PaintBucket", {
		category = "trinket"
	})
	local token = {}
	v[instance] = {
		ids = ids,
		token = token
	}
	task.delay(5, function()
		local v5 = v[instance]

		if not v5 or v5.token ~= token then
			return
		end

		v[instance] = nil

		if instance.Parent then
			StatModifierManager.RemoveSpeedModifiers(instance, ids)
		end
	end)
end

function PaintBucket.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		v[instance] = nil
		StatModifierManager.RemoveModifiersBySource(instance, "PaintBucket")
		StatModifierManager.RemoveAdditiveModifiersBySource(instance, "PaintBucket")
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		v[instance] = nil
		StatModifierManager.RemoveModifiersBySource(instance, "PaintBucket")
		StatModifierManager.RemoveAdditiveModifiersBySource(instance, "PaintBucket")
		return "Slot2"
	end
end

return PaintBucket