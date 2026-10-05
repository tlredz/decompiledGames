local rewards = {
	Boulder = {
		FishName = "Boulder",
		Rewards = {
			{
				Type = "lantern",
				Value = "Lil Dave",
				Display = "Lil Dave"
			}
		},
		Description = "A small lil dave to carry on your shoulder!"
	},
	["Cataclysm Carp"] = {
		FishName = "Cataclysm Carp",
		Rewards = {
			{
				Type = "bobber",
				Value = "Cataclysm Cranium",
				Display = "Cataclysm Cranium"
			}
		},
		Description = "A skull infused with cataclysmic energy."
	}
}
local DivineHunterRewards = {}
DivineHunterRewards.Rewards = rewards

function DivineHunterRewards.GetEligibleFish()
	local result = {}

	for k in rewards do
		table.insert(result, k)
	end

	return result
end

function DivineHunterRewards.IsFishEligible(p: string)
	return rewards[p] ~= nil
end

function DivineHunterRewards.GetFishReward(p: string)
	return rewards[p]
end

return DivineHunterRewards