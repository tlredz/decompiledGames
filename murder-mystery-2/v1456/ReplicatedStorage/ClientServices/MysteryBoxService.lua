local _ = {
	Min = 20,
	Max = 25
}
local MysteryBoxService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ItemModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ItemModule"))
local localPlayer = game.Players.LocalPlayer
local mysteryBoxOpen = script:WaitForChild("MysteryBoxOpen")
local main = mysteryBoxOpen:WaitForChild("Container"):WaitForChild("Main")
main.Parent = script
local newItem = main:WaitForChild("Container"):WaitForChild("Background"):WaitForChild("ItemContainer"):WaitForChild("OffsetContainer"):WaitForChild("MainContainer"):WaitForChild("NewItem")
newItem.Parent = script
local offset = main:WaitForChild("Container"):WaitForChild("Background"):WaitForChild("ItemContainer"):WaitForChild("OffsetContainer"):WaitForChild("MainContainer"):WaitForChild("UIGridLayout").CellSize.X.Offset
local random = Random.new()

local function GetRarityFromRoll(p)
	local rarityChances = p.RarityChances
	local total = 0

	for _, rarityChance in rarityChances do
		total += rarityChance.Chance
	end

	assert(total == 100)
	assert(rarityChances[1].Rarity == "Common")
	assert(rarityChances[2].Rarity == "Uncommon")
	assert(rarityChances[3].Rarity == "Rare")
	assert(rarityChances[4].Rarity == "Legendary")
	assert(#rarityChances == 4)
	local number = Random.new():NextNumber(1, 100)
	local total2 = 0

	for _, rarityChance in rarityChances do
		total2 += rarityChance.Chance

		if number <= total2 then
			return rarityChance.Rarity
		end
	end
end

local function GetPossibleRewards(p)
	local v = {
		Common = {},
		Uncommon = {},
		Rare = {},
		Legendary = {}
	}

	for _, content in p.Contents do
		table.insert(v[Sync.Weapons[content].Rarity], content)
	end

	return v
end

local function GetRandomItemFromBox(p, p2)
	local v, godlyCover

	if random:NextInteger(1, 500) == 500 then
		v = "Godly"

		if p.GodlyCover then
			godlyCover = p.GodlyCover
		elseif p.Godly then
			godlyCover = p.Godly
		end

		if godlyCover and random:NextInteger(1, 50) == 50 then
			local v2 = godlyCover .. "Chroma"

			if Sync.Weapons[v2] then
				godlyCover = v2
			end
		end
	end

	if not godlyCover then
		v = GetRarityFromRoll(p)
		godlyCover = p2[v][random:NextInteger(1, #p2[v])]
	end

	return godlyCover, Sync.Weapons[godlyCover], v
end

function MysteryBoxService.PlayOpeningAnimation(_, list)
	local clone = mysteryBoxOpen:Clone()
	clone.Parent = localPlayer.PlayerGui
	local v = 3 + random:NextNumber()

	for k, v2 in list do
		local clone2 = main:Clone()
		local offsetContainer = clone2:WaitForChild("Container"):WaitForChild("Background"):WaitForChild("ItemContainer"):WaitForChild("OffsetContainer")
		local mainContainer = offsetContainer:WaitForChild("MainContainer")
		local v3 = Sync.MysteryBox[v2.MysteryBoxId]
		local possibleRewards = GetPossibleRewards(v3)
		local integer = random:NextInteger(20, 25)
		offsetContainer.Size = UDim2.new(0, offset * (integer + 5), 1, 0)
		offsetContainer.Position = UDim2.new(0.5, offset / 2, 0, 0)
		local rewardedItemId = v2.RewardedItemId

		for i = 1, integer + 5 do
			local v5

			if i == integer then
				if Sync.Weapons[rewardedItemId].Rarity == "Godly" and v3.GodlyCover then
					if Sync.Weapons[rewardedItemId].Chroma == true and v3.GodlyCover then
						local v6 = v3.GodlyCover .. "Chroma"
						v5 = Sync.Weapons[v6]
						local _ = v5.Rarity
					else
						local _ = v3.GodlyCover
						v5 = Sync.Weapons[v3.GodlyCover]
						local _ = v5.Rarity
					end
				else
					v5 = Sync.Weapons[rewardedItemId]
					local _ = v5.Rarity
				end
			else
				local v6, v7
				v6, v5, v7 = GetRandomItemFromBox(v3, possibleRewards)
			end

			local clone3 = newItem:Clone()
			ItemModule.DisplayItem(clone3, v5)
			clone3.LayoutOrder = i
			clone3.Parent = mainContainer
		end

		local _, v5, _ = GetRandomItemFromBox(v3, possibleRewards)
		ItemModule.DisplayItem(offsetContainer["PreItem" .. 1], v5)
		local _, v6, _ = GetRandomItemFromBox(v3, possibleRewards)
		ItemModule.DisplayItem(offsetContainer["PreItem" .. 2], v6)
		clone2.Parent = clone:WaitForChild("Container")
		local v7 = -(offset * integer) + random:NextInteger(-(offset / 2 - 5), offset / 2 - 5) + offset - offset / 2
		TweenService:Create(
			offsetContainer,
			TweenInfo.new(v, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, k * 0.5),
			{
				Position = UDim2.new(0.5, v7, 0, 0)
			}
		):Play()
	end

	task.wait(v + #list * 0.5)
	clone:Destroy()
end

return MysteryBoxService