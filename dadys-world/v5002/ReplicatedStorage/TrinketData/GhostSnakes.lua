local GhostSnakes = {
	Name = "Ghost Snakes In A Can",
	Icon = "rbxassetid://116222123791569",
	Rarity = "Rare",
	Description = "Reduces your Active Ability cooldown by 5 seconds.",
	TrinketType = "Active",
	TrinketState = "AbilityCooldown",
	MonsterTrinket = true,
	Cost = 500
}
GhostSnakes.Requirement1 = { "Coin", GhostSnakes.Cost }

function GhostSnakes.ApplyTrinket(instance)
	local ability1 = instance:WaitForChild("Abilities"):FindFirstChild("Ability1")

	if ability1 and not instance:GetAttribute("HasToggleAbility") then
		local cooldown = ability1:WaitForChild("Cooldown")
		cooldown.Value -= 5

		if cooldown.Value <= 5 then
			cooldown.Value = 5
		end
	end
end

function GhostSnakes.RemoveTrinket(instance)
	local ability1 = instance:WaitForChild("Abilities"):FindFirstChild("Ability1")

	if ability1 and not instance:GetAttribute("HasToggleAbility") then
		local cooldown = ability1:WaitForChild("Cooldown")
		cooldown.Value += 5
	end
end

return GhostSnakes