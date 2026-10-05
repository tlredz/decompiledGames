local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = {
	tool = 0,
	item = 1,
	fish = 2,
	rod = 3,
	utility = 4,
	spear = 5
}
local library = require(ReplicatedStorage.shared.modules.library)
local Utilities = require(ReplicatedStorage.shared.modules.Utilities)
local ItemDisplayInfo = {}
local displayImages = {
	fish = "rbxassetid://94456521699988",
	item = "rbxassetid://109908396333853",
	rod = "rbxassetid://110276457326464",
	spear = "rbxassetid://113705241307272"
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
		displayName = k,
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
		tooltip = item.CustomDescription
	}
end

for k, _ in library.rods do
	ItemDisplayInfo[k] = {
		icon = displayImages.rod,
		displayName = k,
		rarity = "",
		type = 3
	}
end

for k, _ in library.spears do
	ItemDisplayInfo[k] = {
		icon = displayImages.spear,
		displayName = k,
		rarity = "",
		type = 5
	}
end

ItemDisplayInfo.DisplayImages = displayImages
return ItemDisplayInfo