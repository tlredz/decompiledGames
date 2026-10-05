local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local Coal = {}
Coal.Name = "Coal"
Coal.Icon = "rbxassetid://77305276325049"
Coal.Description = "Decreases Stealth by 10% and Walk and Run Speed by 10%."
Coal.Rarity = "Common"
Coal.TrinketType = "Passive"
Coal.HolidayTrinket = true
Coal.Cost = 500
Coal.MonsterTrinket = true
Coal.Requirement1 = { "HolidayPoints", 500 }

function Coal.ApplyTrinket(p)
	v[p] = {
		speed = StatModifierManager.ApplySpeedModifiers(p, 0.9, "Coal", {
			category = "trinket"
		}),
		stealthId = StatModifierManager.ApplyModifier(p, "StealthModifier", 0.9, "Coal", {
			category = "trinket"
		})
	}
end

function Coal.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"

		if not v[instance] then
			return "Slot1"
		end

		StatModifierManager.RemoveSpeedModifiers(instance, v[instance].speed)

		if v[instance].stealthId then
			StatModifierManager.RemoveModifier(instance, "StealthModifier", v[instance].stealthId)
		end

		v[instance] = nil
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"

		if not v[instance] then
			return "Slot2"
		end

		StatModifierManager.RemoveSpeedModifiers(instance, v[instance].speed)

		if v[instance].stealthId then
			StatModifierManager.RemoveModifier(instance, "StealthModifier", v[instance].stealthId)
		end

		v[instance] = nil
		return "Slot2"
	end
end

return Coal