local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	BannerId = t.string,
	AssetId = t.string
})
local v = {
	Mastery = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	ClaimedMilestoneIds = {
		check = t.map(t.string, t.boolean),
		blank = function()
			return {}
		end
	},
	ClaimedTokenBoostPercents = {
		check = t.map(t.string, t.number),
		blank = function()
			return {}
		end
	},
	InfiniteRewardsClaimed = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	HasUsedMutationConsumable = {
		check = t.boolean,
		blank = function()
			return false
		end
	},
	MutationConsumables = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	EggGrowthBoostExpiresAt = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	LuckBoostExpiresAt = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	SpeedBoostExpiresAt = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	RevealedRewards = {
		check = t.map(t.string, interface),
		blank = function()
			return {}
		end
	}
}
local checks = {}

for k, v2 in v do
	checks[k] = v2.check
end

local BossMastery = {
	State = t.interface(checks),
	Blank = function()
		local result = {}

		for k, v2 in v do
			result[k] = v2.blank()
		end

		return result
	end
}

function BossMastery.Reconcile(p)
	if type(p) ~= "table" then
		return BossMastery.Blank()
	end

	local clone = table.clone(p)

	for k, v2 in v do
		if k == "RevealedRewards" and type(clone[k]) == "table" then
			local revealedRewards = {}

			for k2, v4 in clone.RevealedRewards do
				if type(k2) == "string" and interface(v4) then
					revealedRewards[k2] = v4
				end
			end

			clone.RevealedRewards = revealedRewards
		elseif not v2.check(clone[k]) then
			clone[k] = v2.blank()
		end
	end

	return clone
end

return BossMastery