local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = {
	tool = 0,
	item = 1,
	fish = 2,
	rod = 3,
	utility = 4,
	spear = 5,
	cage = 6,
	harpoonGun = 7
}
local library = require(ReplicatedStorage.shared.modules.library)
local Utilities = require(ReplicatedStorage.shared.modules.Utilities)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local ItemDisplayInfo = {}
local displayImages = {
	fish = "rbxassetid://94456521699988",
	item = "rbxassetid://109908396333853",
	rod = "rbxassetid://110276457326464",
	spear = "rbxassetid://113705241307272",
	harpoonGun = "rbxassetid://70502746092006"
}

for k, keyItem in library.keyItems do
	ItemDisplayInfo[k] = {
		icon = keyItem.Icon,
		displayName = k,
		rarity = keyItem.Rarity or "",
		type = 0
	}
end

for k, v2 in Utilities.all do
	ItemDisplayInfo[k] = {
		icon = v2.Icon,
		displayName = k,
		rarity = "",
		type = 4
	}
end

for k, v2 in library.fish do
	if not (type(v2) == "table" and v2.Rarity) then
		continue
	end

	local icon

	if v2.IsCrate then
		icon = displayImages.item
	else
		icon = displayImages.fish
	end

	ItemDisplayInfo[k] = {
		icon = icon,
		displayName = k:gsub("’", "'"),
		rarity = v2.Rarity,
		type = 2
	}
end

for k, item in library.items do
	ItemDisplayInfo[k] = {
		icon = displayImages.item,
		displayName = k,
		rarity = item.Rarity,
		type = 1,
		tooltip = item.CustomDescription,
		color = item.CustomColor
	}
end

for k, v2 in library.crabcages.byName do
	local v3 = {}
	table.insert(v3, string.format("Luck: %+d%%", v2.Luck))
	table.insert(v3, string.format("Lure: %+d%%", v2.Lure))
	table.insert(v3, string.format("Max Kg: %s", NumberUtils:Comma(v2.Strength)))

	if v2.Durability and v2.Durability > 0 then
		table.insert(v3, string.format("Durability: %d", v2.Durability))
	end

	if v2.FishCountMin and v2.FishCountMax then
		table.insert(v3, string.format("%d-%d Catches", v2.FishCountMin, v2.FishCountMax))
	end

	ItemDisplayInfo[k] = {
		icon = displayImages.item,
		displayName = k,
		rarity = library.items[k].Rarity,
		type = 6,
		tooltip = table.concat(v3, "\n"),
		color = v2.Color
	}
end

for k, rod in library.rods do
	if typeof(rod) == "table" then
		ItemDisplayInfo[k] = {
			icon = displayImages.rod,
			displayName = k,
			rarity = "",
			type = 3,
			color = rod.Color
		}
	end
end

for k, spear in library.spears do
	ItemDisplayInfo[k] = {
		icon = displayImages.spear,
		displayName = k,
		rarity = "",
		type = 5,
		color = spear.Color
	}
end

for k, harpoonGun in library.harpoonGuns do
	ItemDisplayInfo[k] = {
		icon = displayImages.harpoonGun,
		displayName = k,
		rarity = "",
		type = 7,
		color = harpoonGun.Color
	}
end

ItemDisplayInfo.DisplayImages = displayImages
return ItemDisplayInfo