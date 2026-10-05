local ThinkingCap = {
	Name = "Thinking Cap",
	Icon = "rbxassetid://17660111536",
	Rarity = "Common",
	Description = "Increases Skill Check window size by 40 units.",
	TrinketType = "Passive",
	Cost = 350
}
ThinkingCap.Requirement1 = { "Coin", ThinkingCap.Cost }
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)

function ThinkingCap.ApplyTrinket(p)
	StatModifierManager.ApplyAdditiveBoundarySize(p, 40, "ThinkingCap")
end

function ThinkingCap.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		StatModifierManager.RemoveAdditiveModifiersBySource(instance, "ThinkingCap")
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		StatModifierManager.RemoveAdditiveModifiersBySource(instance, "ThinkingCap")
		return "Slot2"
	end
end

return ThinkingCap