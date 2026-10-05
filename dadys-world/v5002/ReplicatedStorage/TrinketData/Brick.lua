local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local Brick = {
	Name = "Brick",
	Icon = "rbxassetid://17653809949",
	Rarity = "Common",
	Description = "Lowers both Walk and Run Speed by 10%. It's a brick, what did you expect?",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
Brick.Requirement1 = { "Coin", Brick.Cost }

function Brick.ApplyTrinket(p)
	v[p] = StatModifierManager.ApplySpeedModifiers(p, 0.9, "Brick", {
		category = "trinket"
	})
end

function Brick.RemoveTrinket(instance)
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

return Brick