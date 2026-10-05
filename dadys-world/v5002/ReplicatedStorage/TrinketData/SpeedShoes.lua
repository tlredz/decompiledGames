local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local SpeedShoes = {}
SpeedShoes.Name = "Speedy Shoes"
SpeedShoes.Icon = "rbxassetid://17660071418"
SpeedShoes.Rarity = "Common"
SpeedShoes.Description = "Increases both Walk and Run Speed by 5%."
SpeedShoes.TrinketType = "Passive"
SpeedShoes.Cost = 325
SpeedShoes.Requirement1 = { "Coin", 325 }

function SpeedShoes.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplySpeedModifiers(p, 1.05, "SpeedyShoes", {
		category = "trinket"
	})
end

function SpeedShoes.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"

		if v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"

		if v[instance] then
			StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
			v[instance] = nil
		end

		return "Slot2"
	end
end

return SpeedShoes