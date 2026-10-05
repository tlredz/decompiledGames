local RunService = game:GetService("RunService")
local Utility = require(script.Parent.Utility)
local v = {}

local function concatCharMap(items)
	local clone = table.clone(items)

	for k, _ in items do
		clone[k] = v[k]
	end

	return string.gsub(table.concat(clone), "%z*$", "")
end

local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local itemIds = {}
local PlayerProfile = {}
local v2 = {}
local v3 = {
	Human = 0,
	Fishman = 1,
	Mink = 2,
	Skypiea = 3,
	Ghoul = 4,
	Cyborg = 5,
	Draco = 6
}
local v4 = {}

for _, v5 in ItemConfig.Query.select({
	Index = {
		IdType = "Redeemable"
	}
}) do
	table.insert(itemIds, v5.Index.ItemId)
end

local itemIds2 = {}

if RunService:IsServer() then
	local accessories = game.ServerStorage:WaitForChild("Accessories")

	for _, v5 in ItemConfig.Query.select({
		Index = {
			IdType = "Accessory"
		}
	}) do
		if accessories:FindFirstChild(v5.Index.StorageKey) then
			table.insert(itemIds2, v5.Index.ItemId)
		end
	end
end

table.freeze(itemIds2)
local itemIds3 = {}

if RunService:IsServer() then
	local fruits = game.ServerStorage:WaitForChild("Fruits")

	for _, v5 in ItemConfig.Query.select({
		Index = {
			IdType = "PhysicalMoveset"
		}
	}) do
		if fruits:FindFirstChild(v5.Index.StorageKey) then
			table.insert(itemIds3, v5.Index.ItemId)
		end
	end
end

table.freeze(itemIds3)
local itemIds4 = {}
local v5 = {
	"Slingshot",
	"Refined Slingshot",
	"Flintlock",
	"Dual Flintlock",
	"Musket",
	"Magma Blaster",
	"Cannon",
	"Bazooka",
	"Kabucha",
	"Venom Bow",
	"Skull Guitar",
	"Acidum Rifle",
	"Bizarre Revolver",
	"Dragonstorm",
	"Gun"
}

if RunService:IsServer() then
	for _, v6 in ItemConfig.Query.select({
		Index = {
			IdType = "Moveset"
		}
	}) do
		if table.find(v5, v6.Index.StorageKey) then
			table.insert(itemIds4, v6.Index.ItemId)
		end
	end
end

table.freeze(itemIds4)
local itemIds5 = {}
local v6 = {
	"Twin Hooks",
	"Spikey Trident",
	"Buddy Sword",
	"Dual Katana",
	"Katana",
	"Cutlass",
	"Dark Blade",
	"Triple Dark Blade",
	"Fishing Trophy",
	"Dark Dagger",
	"Shark Anchor",
	"Fox Lamp",
	"Bisento",
	"Flail",
	"Koko",
	"Triple Katana",
	"True Triple Katana",
	"Hallow Scythe",
	"Trident",
	"Dragon Trident",
	"Rengoku",
	"Saber",
	"Shark Saw",
	"Iron Mace",
	"Wardens Sword",
	"Pipe",
	"Dual-Headed Blade",
	"Soul Cane",
	"Pole (1st Form)",
	"Pole (2nd Form)",
	"Gravity Blade",
	"Shizu",
	"Canvander",
	"Yama",
	"Cursed Dual Katana",
	"Tushita",
	"Saishi",
	"Oroshi",
	"Longsword",
	"Midnight Blade",
	"Dragonheart"
}

if RunService:IsServer() then
	for _, v7 in ItemConfig.Query.select({
		Index = {
			IdType = "Moveset"
		}
	}) do
		if table.find(v6, v7.Index.StorageKey) then
			table.insert(itemIds5, v7.Index.ItemId)
		end
	end
end

table.freeze(itemIds5)

local function newSeed(random)
	return random:NextInteger(1000, 1000000)
end

PlayerProfile.Random = {}

function PlayerProfile.Random.PlayerStat(p: number)
	local random = Random.new(p)
	local integer = random:NextInteger(500, 5000)
	return {
		StatId = random:NextInteger(1, 5),
		Progression = random:NextInteger(0, integer),
		MaxProgression = integer
	}
end

function PlayerProfile.Random.SettingOption(p: number)
	local integer = Random.new(p):NextInteger(1, 3)

	if integer == 1 then
		return "Everyone"
	elseif integer == 2 then
		return "FriendsOnly"
	end

	return "Nobody"
end

local function getRandRarity(p: number?)
	return Random.new(p):NextInteger(1, 5)
end

local function generateWord(p: number?, value: number?, value2: number?)
	local random = Random.new(p)
	local v7 = value or 3
	local v8 = value2 or 8
	assert(v7 and v8, "minLen and maxLen must be defined")
	local v9 = ""
	local v10 = {
		"a",
		"e",
		"i",
		"o",
		"u",
		"y"
	}
	local v11 = {
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

	for i = 1, random:NextInteger(v7, v8) do
		if i % 2 == 1 then
			v9 ..= v11[random:NextInteger(1, #v11)]
		else
			v9 ..= v10[random:NextInteger(1, #v10)]
		end
	end

	return string.upper((string.sub(v9, 1, 1))) .. string.sub(v9, 2)
end

function PlayerProfile.Random.Type(p: number)
	local random = Random.new(p)
	local verified = random:NextInteger(1, 3) == 1
	local online = random:NextInteger(1, 2) == 1
	local isInCrew = random:NextInteger(1, 2) == 1
	local isStarCreator = random:NextInteger(1, 2) == 1
	local isDeveloper = random:NextInteger(1, 2) == 1
	local race = v2[random:NextInteger(0, 6)]
	local integer = random:NextInteger(0, 100)
	local integer2 = random:NextInteger(1, 2650)
	local equippedAccessory = random:NextInteger(1, 3) ~= 1 and 0 or itemIds2[random:NextInteger(1, #itemIds2)]
	local equippedGun = (random:NextInteger(1, 3) ~= 1 or not (#itemIds4 > 0)) and 0 or itemIds4[random:NextInteger(
		1,
		#itemIds4
	)]
	local equippedSword = (random:NextInteger(1, 3) ~= 1 or not (#itemIds5 > 0)) and 0 or itemIds5[random:NextInteger(
		1,
		#itemIds5
	)]
	local equippedFruit = (random:NextInteger(1, 2) ~= 1 or not (#itemIds3 > 0)) and 0 or itemIds3[random:NextInteger(
		1,
		#itemIds3
	)]
	local settings = {
		JoinServer = PlayerProfile.Random.SettingOption(newSeed(random)),
		LevelVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		RaceVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		AccessoriesVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		CombatToolsVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		ShowcaseVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		CrewVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		LocationVisible = PlayerProfile.Random.SettingOption(newSeed(random)),
		FindInRecent = PlayerProfile.Random.SettingOption(newSeed(random)),
		CanReceiveGifts = PlayerProfile.Random.SettingOption(newSeed(random))
	}
	local showcaseSlot1Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot2Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot3Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot4Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot5Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot6Id = (random:NextInteger(1, 3) ~= 1 or not (#itemIds > 0)) and 0 or itemIds[random:NextInteger(
		1,
		#itemIds
	)]
	local showcaseSlot1Rarity

	if showcaseSlot1Id == 0 then
		showcaseSlot1Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot1Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot2Rarity

	if showcaseSlot2Id == 0 then
		showcaseSlot2Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot2Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot3Rarity

	if showcaseSlot3Id == 0 then
		showcaseSlot3Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot3Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot4Rarity

	if showcaseSlot4Id == 0 then
		showcaseSlot4Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot4Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot5Rarity

	if showcaseSlot5Id == 0 then
		showcaseSlot5Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot5Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot6Rarity

	if showcaseSlot6Id == 0 then
		showcaseSlot6Rarity = 0
	else
		local integer3 = random:NextInteger(1000, 1000000)
		showcaseSlot6Rarity = Random.new(integer3):NextInteger(1, 5)
	end

	local showcaseSlot1Quantity = showcaseSlot1Id == 0 and 0 or random:NextInteger(1, 99)
	local showcaseSlot2Quantity = showcaseSlot2Id == 0 and 0 or random:NextInteger(1, 99)
	local showcaseSlot3Quantity = showcaseSlot3Id == 0 and 0 or random:NextInteger(1, 99)
	local showcaseSlot4Quantity = showcaseSlot4Id == 0 and 0 or random:NextInteger(1, 99)
	local showcaseSlot5Quantity = showcaseSlot5Id == 0 and 0 or random:NextInteger(1, 99)
	local showcaseSlot6Quantity = showcaseSlot6Id == 0 and 0 or random:NextInteger(1, 99)
	local stat

	if random:NextInteger(1, 3) == 1 then
		stat = PlayerProfile.Random.PlayerStat(newSeed(random))
	end

	local stat2

	if random:NextInteger(1, 3) == 1 then
		stat2 = PlayerProfile.Random.PlayerStat(newSeed(random))
	end

	local stat3

	if random:NextInteger(1, 3) == 1 then
		stat3 = PlayerProfile.Random.PlayerStat(newSeed(random))
	end

	local stat4

	if random:NextInteger(1, 3) == 1 then
		stat4 = PlayerProfile.Random.PlayerStat(newSeed(random))
	end

	return {
		Verified = verified,
		Online = online,
		IsInCrew = isInCrew,
		IsStarCreator = isStarCreator,
		IsDeveloper = isDeveloper,
		Race = race,
		RaceLevel = integer,
		Level = integer2,
		EquippedAccessory = equippedAccessory,
		EquippedGun = equippedGun,
		EquippedSword = equippedSword,
		EquippedFruit = equippedFruit,
		EquippedFightingStyle = 0,
		EquippedTrinket1 = 0,
		EquippedTrinket2 = 0,
		Settings = settings,
		ShowcaseSlot1Id = showcaseSlot1Id,
		ShowcaseSlot2Id = showcaseSlot2Id,
		ShowcaseSlot3Id = showcaseSlot3Id,
		ShowcaseSlot4Id = showcaseSlot4Id,
		ShowcaseSlot5Id = showcaseSlot5Id,
		ShowcaseSlot6Id = showcaseSlot6Id,
		ShowcaseSlot1Rarity = showcaseSlot1Rarity,
		ShowcaseSlot2Rarity = showcaseSlot2Rarity,
		ShowcaseSlot3Rarity = showcaseSlot3Rarity,
		ShowcaseSlot4Rarity = showcaseSlot4Rarity,
		ShowcaseSlot5Rarity = showcaseSlot5Rarity,
		ShowcaseSlot6Rarity = showcaseSlot6Rarity,
		ShowcaseSlot1Quantity = showcaseSlot1Quantity,
		ShowcaseSlot2Quantity = showcaseSlot2Quantity,
		ShowcaseSlot3Quantity = showcaseSlot3Quantity,
		ShowcaseSlot4Quantity = showcaseSlot4Quantity,
		ShowcaseSlot5Quantity = showcaseSlot5Quantity,
		ShowcaseSlot6Quantity = showcaseSlot6Quantity,
		Stat1 = stat,
		Stat2 = stat2,
		Stat3 = stat3,
		Stat4 = stat4,
		CrewName = not isInCrew and "" or generateWord(random:NextInteger(1000, 1000000), 3, 10) .. (random:NextInteger(
			1,
			3
		) ~= 1 and "" or "-" .. generateWord(random:NextInteger(1000, 1000000), 3, 10)),
		TitleText = generateWord(random:NextInteger(1000, 1000000), 3, 10) .. (random:NextInteger(1, 3) ~= 1 and "" or " the " .. generateWord(
			random:NextInteger(1000, 1000000),
			3,
			10
		)),
		TitleColor = Color3.fromRGB(random:NextInteger(0, 255), random:NextInteger(0, 255), random:NextInteger(0, 255)),
		StatusId = random:NextInteger(0, 10),
		SubStatusId = 0,
		BackgroundIndex = 16,
		LastLocation = random:NextInteger(0, 6),
		StanceOverrideId = 0
	}
end

function PlayerProfile.encode(data)
	local writer = Utility.newWriter()
	writer(16, 4)
	writer(
		8,
		(bit32.bor(
			data.Verified and 1 or 0,
			data.Online and 2 or 0,
			data.IsInCrew and 4 or 0,
			data.IsStarCreator and 8 or 0,
			data.IsDeveloper and 16 or 0
		))
	)
	writer(8, v3[data.Race])
	writer(8, data.RaceLevel)
	writer(32, data.Level)
	writer(16, data.EquippedAccessory)
	writer(16, data.EquippedGun)
	writer(16, data.EquippedSword)
	writer(16, data.EquippedFruit)
	writer(16, data.EquippedFightingStyle)
	writer(16, data.EquippedTrinket1)
	writer(16, data.EquippedTrinket2)
	writer(
		16,
		(bit32.bor(
			data.Settings.JoinServer == "Everyone" and 1 or 0,
			data.Settings.LevelVisible == "Everyone" and 2 or 0,
			data.Settings.RaceVisible == "Everyone" and 4 or 0,
			data.Settings.AccessoriesVisible == "Everyone" and 8 or 0,
			data.Settings.CombatToolsVisible == "Everyone" and 16 or 0,
			data.Settings.ShowcaseVisible == "Everyone" and 32 or 0,
			data.Settings.CrewVisible == "Everyone" and 64 or 0,
			data.Settings.LocationVisible == "Everyone" and 128 or 0,
			data.Settings.CanReceiveGifts == "Everyone" and 256 or 0,
			data.Settings.FindInRecent == "Everyone" and 512 or 0
		))
	)
	writer(
		16,
		(bit32.bor(
			data.Settings.JoinServer == "FriendsOnly" and 1 or 0,
			data.Settings.LevelVisible == "FriendsOnly" and 2 or 0,
			data.Settings.RaceVisible == "FriendsOnly" and 4 or 0,
			data.Settings.AccessoriesVisible == "FriendsOnly" and 8 or 0,
			data.Settings.CombatToolsVisible == "FriendsOnly" and 16 or 0,
			data.Settings.ShowcaseVisible == "FriendsOnly" and 32 or 0,
			data.Settings.CrewVisible == "FriendsOnly" and 64 or 0,
			data.Settings.LocationVisible == "FriendsOnly" and 128 or 0,
			data.Settings.CanReceiveGifts == "FriendsOnly" and 256 or 0,
			data.Settings.FindInRecent == "FriendsOnly" and 512 or 0
		))
	)
	writer(16, data.ShowcaseSlot1Id)
	writer(16, data.ShowcaseSlot2Id)
	writer(16, data.ShowcaseSlot3Id)
	writer(16, data.ShowcaseSlot4Id)
	writer(16, data.ShowcaseSlot5Id)
	writer(16, data.ShowcaseSlot6Id)
	writer(3, data.ShowcaseSlot1Rarity)
	writer(3, data.ShowcaseSlot2Rarity)
	writer(3, data.ShowcaseSlot3Rarity)
	writer(3, data.ShowcaseSlot4Rarity)
	writer(3, data.ShowcaseSlot5Rarity)
	writer(3, data.ShowcaseSlot6Rarity)
	writer(16, data.ShowcaseSlot1Quantity)
	writer(16, data.ShowcaseSlot2Quantity)
	writer(16, data.ShowcaseSlot3Quantity)
	writer(16, data.ShowcaseSlot4Quantity)
	writer(16, data.ShowcaseSlot5Quantity)
	writer(16, data.ShowcaseSlot6Quantity)
	writer(
		8,
		(bit32.bor(
			data.Stat1 == nil and 0 or 1,
			data.Stat2 == nil and 0 or 2,
			data.Stat3 == nil and 0 or 4,
			data.Stat4 == nil and 0 or 8
		))
	)

	if data.Stat1 ~= nil then
		writer(16, data.Stat1.StatId)
		writer(32, data.Stat1.Progression)
		writer(32, data.Stat1.MaxProgression)
	end

	if data.Stat2 ~= nil then
		writer(16, data.Stat2.StatId)
		writer(32, data.Stat2.Progression)
		writer(32, data.Stat2.MaxProgression)
	end

	if data.Stat3 ~= nil then
		writer(16, data.Stat3.StatId)
		writer(32, data.Stat3.Progression)
		writer(32, data.Stat3.MaxProgression)
	end

	if data.Stat4 ~= nil then
		writer(16, data.Stat4.StatId)
		writer(32, data.Stat4.Progression)
		writer(32, data.Stat4.MaxProgression)
	end

	local v7 = string.split(data.CrewName, "")

	for i = 1, 32 do
		local v8 = v7[i]
		writer(8, v8 and v4[v8] or 0)
	end

	local v8 = string.split(data.TitleText, "")

	for i = 1, 32 do
		local v9 = v8[i]
		writer(8, v9 and v4[v9] or 0)
	end

	writer(8, data.TitleColor.R * 255 // 1)
	writer(8, data.TitleColor.G * 255 // 1)
	writer(8, data.TitleColor.B * 255 // 1)
	writer(16, data.StatusId)
	writer(16, data.SubStatusId)
	writer(16, data.LastLocation)
	writer(8, data.BackgroundIndex)
	writer(8, data.StanceOverrideId)
	return Utility.Trim(writer(16, 36925))
end

function PlayerProfile.decode(buf: buffer)
	local reader = Utility.newReader(buf)
	local v7 = reader(16)
	local v8 = nil

	if v7 == 0 or v7 == 1 or v7 == 2 or v7 == 3 or v7 == 4 then
		local v9 = reader(8)
		local v10 = reader(8)
		local raceLevel = reader(8)
		local level = reader(32)
		local equippedAccessory = reader(16)
		local equippedGun = reader(16)
		local equippedSword = reader(16)
		local equippedFruit = reader(16)
		local equippedFightingStyle = reader(16)
		local equippedTrinket, equippedTrinket2

		if v7 >= 2 then
			equippedTrinket = reader(16)
			equippedTrinket2 = reader(16)
		else
			equippedTrinket = 0
			equippedTrinket2 = 0
		end

		local v20 = v7 >= 3 and 16 or 8
		local v21 = reader(v20)
		local v22 = reader(v20)
		local settings = {
			JoinServer = bit32.band(v21, 1) ~= 0 and "Everyone" or bit32.band(v22, 1) == 0 and "Nobody" or "FriendsOnly",
			LevelVisible = bit32.band(v21, 2) ~= 0 and "Everyone" or bit32.band(v22, 2) == 0 and "Nobody" or "FriendsOnly",
			RaceVisible = bit32.band(v21, 4) ~= 0 and "Everyone" or bit32.band(v22, 4) == 0 and "Nobody" or "FriendsOnly",
			AccessoriesVisible = bit32.band(v21, 8) ~= 0 and "Everyone" or bit32.band(v22, 8) == 0 and "Nobody" or "FriendsOnly",
			CombatToolsVisible = bit32.band(v21, 16) ~= 0 and "Everyone" or bit32.band(v22, 16) == 0 and "Nobody" or "FriendsOnly",
			ShowcaseVisible = bit32.band(v21, 32) ~= 0 and "Everyone" or bit32.band(v22, 32) == 0 and "Nobody" or "FriendsOnly",
			CrewVisible = bit32.band(v21, 64) ~= 0 and "Everyone" or bit32.band(v22, 64) == 0 and "Nobody" or "FriendsOnly",
			LocationVisible = bit32.band(v21, 128) ~= 0 and "Everyone" or bit32.band(v22, 128) == 0 and "Nobody" or "FriendsOnly",
			CanReceiveGifts = v20 ~= 16 and "Everyone" or bit32.band(v21, 256) ~= 0 and "Everyone" or bit32.band(
				v22,
				256
			) == 0 and "Nobody" or "FriendsOnly",
			FindInRecent = v20 ~= 16 and "Everyone" or bit32.band(v21, 512) ~= 0 and "Everyone" or bit32.band(v22, 512) == 0 and "Nobody" or "FriendsOnly"
		}
		local showcaseSlot1Id = reader(16)
		local showcaseSlot2Id = reader(16)
		local showcaseSlot3Id = reader(16)
		local showcaseSlot4Id = reader(16)
		local showcaseSlot5Id = reader(16)
		local showcaseSlot6Id = reader(16)
		local showcaseSlot1Rarity = reader(3)
		local showcaseSlot2Rarity = reader(3)
		local showcaseSlot3Rarity = reader(3)
		local showcaseSlot4Rarity = reader(3)
		local showcaseSlot5Rarity = reader(3)
		local showcaseSlot6Rarity = reader(3)
		local showcaseSlot1Quantity = reader(16)
		local showcaseSlot2Quantity = reader(16)
		local showcaseSlot3Quantity = reader(16)
		local showcaseSlot4Quantity = reader(16)
		local showcaseSlot5Quantity = reader(16)
		local showcaseSlot6Quantity = reader(16)
		local v42 = reader(8)
		local stat = bit32.band(v42, 1) ~= 0 and {
			StatId = reader(16),
			Progression = reader(32),
			MaxProgression = reader(32)
		} or nil
		local stat2 = bit32.band(v42, 2) ~= 0 and {
			StatId = reader(16),
			Progression = reader(32),
			MaxProgression = reader(32)
		} or nil
		local stat3 = bit32.band(v42, 4) ~= 0 and {
			StatId = reader(16),
			Progression = reader(32),
			MaxProgression = reader(32)
		} or nil
		local stat4 = bit32.band(v42, 8) ~= 0 and {
			StatId = reader(16),
			Progression = reader(32),
			MaxProgression = reader(32)
		} or nil
		local v47 = table.create(32)

		for i = 1, 32 do
			v47[i] = reader(8)
		end

		local crewName = concatCharMap(v47)
		local v49 = table.create(32)

		for i = 1, 32 do
			v49[i] = reader(8)
		end

		local titleText = concatCharMap(v49)
		local v51 = reader(8)
		local v52 = reader(8)
		local v53 = reader(8)
		local statusId = reader(16)
		local subStatusId = reader(16)
		local lastLocation = reader(16)
		local backgroundIndex = not (v7 >= 1) and 0 or reader(8)
		local stanceOverrideId = not (v7 >= 4) and 0 or reader(8)
		v8 = {
			Verified = bit32.band(v9, 1) ~= 0,
			Online = bit32.band(v9, 2) ~= 0,
			IsInCrew = bit32.band(v9, 4) ~= 0,
			IsStarCreator = bit32.band(v9, 8) ~= 0,
			IsDeveloper = bit32.band(v9, 16) ~= 0,
			Race = v2[v10] or "Human",
			RaceLevel = raceLevel,
			Level = level,
			EquippedAccessory = equippedAccessory,
			EquippedGun = equippedGun,
			EquippedSword = equippedSword,
			EquippedFruit = equippedFruit,
			EquippedFightingStyle = equippedFightingStyle,
			EquippedTrinket1 = equippedTrinket,
			EquippedTrinket2 = equippedTrinket2,
			Settings = settings,
			ShowcaseSlot1Id = showcaseSlot1Id,
			ShowcaseSlot2Id = showcaseSlot2Id,
			ShowcaseSlot3Id = showcaseSlot3Id,
			ShowcaseSlot4Id = showcaseSlot4Id,
			ShowcaseSlot5Id = showcaseSlot5Id,
			ShowcaseSlot6Id = showcaseSlot6Id,
			ShowcaseSlot1Rarity = showcaseSlot1Rarity,
			ShowcaseSlot2Rarity = showcaseSlot2Rarity,
			ShowcaseSlot3Rarity = showcaseSlot3Rarity,
			ShowcaseSlot4Rarity = showcaseSlot4Rarity,
			ShowcaseSlot5Rarity = showcaseSlot5Rarity,
			ShowcaseSlot6Rarity = showcaseSlot6Rarity,
			ShowcaseSlot1Quantity = showcaseSlot1Quantity,
			ShowcaseSlot2Quantity = showcaseSlot2Quantity,
			ShowcaseSlot3Quantity = showcaseSlot3Quantity,
			ShowcaseSlot4Quantity = showcaseSlot4Quantity,
			ShowcaseSlot5Quantity = showcaseSlot5Quantity,
			ShowcaseSlot6Quantity = showcaseSlot6Quantity,
			Stat1 = stat,
			Stat2 = stat2,
			Stat3 = stat3,
			Stat4 = stat4,
			CrewName = crewName,
			TitleText = titleText,
			TitleColor = Color3.fromRGB(v51, v52, v53),
			StatusId = statusId,
			SubStatusId = subStatusId,
			LastLocation = lastLocation,
			BackgroundIndex = backgroundIndex,
			StanceOverrideId = stanceOverrideId
		}
	else
		error((`UNSUPPORTED FORMAT VERSION -> {v7}`))
	end

	local v9 = reader(16)

	if v9 ~= 36925 then
		error((`CORRUPT END IDENTIFIER -> {v9}`))
	end

	return v8
end

for i = 0, 255 do
	local v7 = string.char(i)
	v[i] = v7
	v4[v7] = i
end

for k, v7 in v3 do
	v2[v7] = k
end

return PlayerProfile