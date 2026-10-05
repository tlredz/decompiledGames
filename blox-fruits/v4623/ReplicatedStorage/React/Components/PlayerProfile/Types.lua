local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfile = require(ReplicatedStorage.Modules.SerData.PlayerProfile)
require(ReplicatedStorage.React.Components.Inventory.Types)
local PlayerProfile2 = require(game.ReplicatedStorage.Modules.SerData.PlayerProfile)

function newSeed(object)
	return object:NextInteger(1000, 1000000)
end

function generateWord(p: number?, value: number?, value2: number?)
	local random = Random.new(p)
	local v = value or 3
	local v2 = value2 or 8
	assert(v and v2, "minLen and maxLen must be defined")
	local v3 = ""
	local v4 = {
		"a",
		"e",
		"i",
		"o",
		"u",
		"y"
	}
	local v5 = {
		"b",
		"c",
		"d",
		"f",
		"g",
		"h",
		"j",
		"k",
		"l",
		"m",
		"n",
		"p",
		"r",
		"s",
		"t",
		"v",
		"w",
		"x",
		"z"
	}

	for i = 1, random:NextInteger(v, v2) do
		if i % 2 == 1 then
			v3 ..= v5[random:NextInteger(1, #v5)]
		else
			v3 ..= v4[random:NextInteger(1, #v4)]
		end
	end

	return string.upper((string.sub(v3, 1, 1))) .. string.sub(v3, 2)
end

local Types = {
	LoadedPlayer = {}
}
local v = {
	912348,
	3095250,
	31265920,
	52187831,
	45124586,
	29462080,
	305444644,
	289823073,
	17744998,
	7693729,
	1164626,
	8166616593,
	17884881,
	5946737,
	1490972462,
	1490972462,
	5224370,
	42223924
}

function Types.LoadedPlayer.random(p: number?)
	local random = Random.new(p)
	return {
		UserId = v[random:NextInteger(1, #v)],
		IsLocalPlayer = false,
		FishIndex = nil,
		IsPreviewMode = false,
		OwnedBackgrounds = {},
		NewBackgrounds = {},
		ProfileData = PlayerProfile.Random.Type(newSeed(random))
	}
end

Types.PlayerStatOptionProperties = {
	random = function(p: number?)
		local random = Random.new(p)
		local playerStat = PlayerProfile2.Random.PlayerStat(newSeed(random))
		return {
			LoadedPlayer = Types.LoadedPlayer.random(newSeed(random)),
			SelectedStatSlotId = random:NextInteger(1, 5),
			StatId = playerStat.StatId,
			DisplayName = generateWord(newSeed(random), 4, 8),
			Progression = playerStat.Progression,
			MaxProgression = playerStat.MaxProgression,
			SetLoadedPlayer = function(_: number?) end,
			PatchProfileData = function(_) end,
			SetStatSelectionVisible = function(_: boolean) end
		}
	end
}
return Types