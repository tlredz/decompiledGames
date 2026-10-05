local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local EggSkins = require(ReplicatedStorage.Data.EggSkins)
local ScrambleTradeIn = require(ReplicatedStorage.Data.ScrambleTradeIn)
local frozen = table.freeze({
	Category = "Mecha Scrambler",
	Scale = 1
})
local frozen2 = table.freeze({
	Kind = "Banner",
	BannerId = "Biohazard",
	Mutated = false
})
local frozen3 = table.freeze({
	Kind = "Banner",
	BannerId = "Biohazard",
	Mutated = true
})
local frozen4 = table.freeze({
	Kind = "Banner",
	BannerId = "Experimental",
	Mutated = false
})
local frozen5 = table.freeze({
	Kind = "Banner",
	BannerId = "Experimental",
	Mutated = true
})
local frozen6 = table.freeze({
	Kind = "Banner",
	BannerId = "UnstableDNA",
	Mutated = false
})
local frozen7 = table.freeze({
	Kind = "Banner",
	BannerId = "UnstableDNA",
	Mutated = true
})
local frozen8 = table.freeze({
	Kind = "RandomBanner",
	Mutated = true
})
local frozen9 = table.freeze({
	Kind = "Pet",
	Category = "Eye Bat",
	Scale = 1
})
local frozen10 = table.freeze({
	Kind = "Pet",
	Category = "Citadel Snail",
	Scale = 1
})
local frozen11 = table.freeze({
	Kind = "Pet",
	Category = "Uncoiled Armadillo",
	Scale = 1
})
local frozen12 = table.freeze({
	Kind = "Pet",
	Category = "Mecha Chompa",
	Scale = 1
})
local frozen13 = table.freeze({
	Kind = "Pet",
	Category = "Pink Dragon Experiment",
	Scale = 1
})
local frozen14 = table.freeze({
	table.freeze({
		Id = "Scramble1",
		Kills = 1,
		Reward = frozen2
	}),
	table.freeze({
		Id = "Scramble3",
		Kills = 3,
		Reward = frozen4
	}),
	table.freeze({
		Id = "Scramble5",
		Kills = 5,
		Reward = frozen3
	}),
	table.freeze({
		Id = "Scramble7",
		Kills = 7,
		Reward = frozen6
	}),
	table.freeze({
		Id = "Scramble10",
		Kills = 10,
		Reward = frozen9
	}),
	table.freeze({
		Id = "Scramble13",
		Kills = 13,
		Reward = frozen2
	}),
	table.freeze({
		Id = "Scramble15",
		Kills = 15,
		Reward = frozen3
	}),
	table.freeze({
		Id = "Scramble18",
		Kills = 18,
		Reward = frozen5
	}),
	table.freeze({
		Id = "Scramble21",
		Kills = 21,
		Reward = frozen6
	}),
	table.freeze({
		Id = "Scramble25",
		Kills = 25,
		Reward = frozen10
	}),
	table.freeze({
		Id = "Scramble30",
		Kills = 30,
		Reward = frozen2
	}),
	table.freeze({
		Id = "Scramble35",
		Kills = 35,
		Reward = frozen3
	}),
	table.freeze({
		Id = "Scramble40",
		Kills = 40,
		Reward = frozen7
	}),
	table.freeze({
		Id = "Scramble45",
		Kills = 45,
		Reward = frozen3
	}),
	table.freeze({
		Id = "Scramble50",
		Kills = 50,
		Reward = frozen11
	}),
	table.freeze({
		Id = "Scramble57",
		Kills = 57,
		Reward = frozen5
	}),
	table.freeze({
		Id = "Scramble64",
		Kills = 64,
		Reward = frozen5
	}),
	table.freeze({
		Id = "Scramble70",
		Kills = 70,
		Reward = frozen6
	}),
	table.freeze({
		Id = "Scramble75",
		Kills = 75,
		Reward = frozen12
	}),
	table.freeze({
		Id = "Scramble82",
		Kills = 82,
		Reward = frozen3
	}),
	table.freeze({
		Id = "Scramble90",
		Kills = 90,
		Reward = frozen7
	}),
	table.freeze({
		Id = "Scramble100",
		Kills = 100,
		Reward = frozen13
	})
})

-- equivalent calls inferred from this helper; original call sites unknown
local function petConfig(category: string)
	local v = assert(Assets.Directory[category], (`Unknown Scramble mastery egg {category}`))
	assert(type(v.Egg.Icon) == "string", (`{category} has no egg icon`))
	assert(type(v.Egg.DisplayName) == "string", (`{category} has no egg name`))
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bannerSkin(p: string)
	local v = assert(ScrambleTradeIn.GetBannerEggSkin(p), (`Unknown Scramble banner {p}`))
	return assert(EggSkins.Get(v), (`Scramble banner {p} has no egg skin`))
end

local function validate(data)
	if data.Kind == "Pet" then
		petConfig(data.Category) -- equivalent call inferred; original call site unknown
	elseif data.Kind == "Banner" then
		local bannerId = data.BannerId
		local v = assert(ScrambleTradeIn.GetBannerEggSkin(bannerId), (`Unknown Scramble banner {bannerId}`))
		assert(EggSkins.Get(v), (`Scramble banner {bannerId} has no egg skin`))
	else
		for _, v in ScrambleTradeIn.BannerIds() do
			local v2 = assert(ScrambleTradeIn.GetBannerEggSkin(v), (`Unknown Scramble banner {v}`))
			assert(EggSkins.Get(v2), (`Scramble banner {v} has no egg skin`))
		end
	end
end

local function rollBannerId(object)
	local total = 0

	for _, v in ScrambleTradeIn.BannerIds() do
		total += math.max(ScrambleTradeIn.GetBannerWeight(v), 0)
	end

	assert(total > 0, "Scramble banners have no weight")
	local v = object:NextNumber() * total
	local v2 = ""

	for _, v3 in ScrambleTradeIn.BannerIds() do
		local bannerWeight = ScrambleTradeIn.GetBannerWeight(v3)

		if not (bannerWeight > 0) then
			continue
		end

		v -= bannerWeight

		if v <= 0 then
			return v3
		else
			v2 = v3
		end
	end

	return v2
end

local v = {
	Milestones = frozen14,
	InfiniteMilestoneId = "ScrambleInfinite",
	InfiniteEveryKills = 10,
	InfiniteReward = frozen8,
	BossDropEgg = frozen,
	Roll = function(data, p)
		if data.Kind == "Pet" then
			return {
				Category = data.Category,
				Scale = data.Scale
			}
		end

		local bannerId

		if data.Kind == "Banner" then
			bannerId = data.BannerId
		else
			bannerId = rollBannerId(p)
		end

		return {
			Category = assert(ScrambleTradeIn.RollPet(bannerId, p), (`Scramble banner {bannerId} has no pets`)),
			Mutation = data.Mutated and "Scrambled" or nil,
			EggSkin = ScrambleTradeIn.GetBannerEggSkin(bannerId)
		}
	end,
	GetMilestone = function(p: string)
		for _, v2 in frozen14 do
			if v2.Id == p then
				return v2
			end
		end

		return nil
	end,
	FinalMilestone = function()
		return frozen14[#frozen14]
	end
}

function v.ClaimableInfiniteCount(data)
	local finalMilestone = v.FinalMilestone()

	if data.ClaimedMilestoneIds[finalMilestone.Id] then
		return (math.max(math.max((data.Mastery - finalMilestone.Kills) // 10, 0) - data.InfiniteRewardsClaimed, 0))
	end

	return 0
end

function v.Presentation(data)
	if data.Kind == "Pet" then
		local v2 = petConfig(data.Category) -- equivalent call inferred; original call site unknown
		return {
			Title = v2.DisplayName,
			Rarity = v2.Rarity.DisplayName,
			Icon = v2.Icon,
			Amount = "x1"
		}
	elseif data.Kind == "Banner" then
		local v2 = bannerSkin(data.BannerId) -- equivalent call inferred; original call site unknown
		local displayName

		if data.Mutated then
			displayName = `Scrambled {v2.DisplayName}`
		else
			displayName = v2.DisplayName
		end

		local v3 = {
			Title = displayName,
			Icon = v2.Icon,
			Amount = "x1",
			HoverTitle = string.upper(displayName),
			HoverDescription = 0
		}
		local hoverDescription

		if data.Mutated then
			hoverDescription = `Awards a random {v2.DisplayName} pet with the Scrambled mutation`
		else
			hoverDescription = `Awards a random {v2.DisplayName} pet`
		end

		v3.HoverDescription = hoverDescription
		return v3
	else
		local icons = {}

		for _, v2 in ScrambleTradeIn.BannerIds() do
			table.insert(icons, (bannerSkin(v2)).Icon)
		end

		local title = data.Mutated and "Random Scrambled Egg" or "Random Egg"
		return {
			Title = title,
			Icon = icons[1],
			CycleIcons = icons,
			Amount = "x1",
			HoverTitle = string.upper(title),
			HoverDescription = data.Mutated and "Awards a random lab egg with the Scrambled mutation" or "Awards a random lab egg"
		}
	end
end

for _, v2 in frozen14 do
	validate(v2.Reward)
end

validate(v.InfiniteReward)
petConfig(v.BossDropEgg.Category) -- equivalent call inferred; original call site unknown
return table.freeze(v)