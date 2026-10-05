local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local itemDisplayInfo = require(ReplicatedStorage.client.modules.ui.Backpack.itemDisplayInfo)
local library = require(ReplicatedStorage.shared.modules.library)
local fishing = require(ReplicatedStorage.shared.modules.fishing)
local ordersByName = {}

for _, rarity in library.rarities.Rarities do
	ordersByName[rarity.Name] = rarity.Order
end

local SortHelper = {}

function SortHelper.Favorite(p, p2, p3)
	local v = p.sub.Favourited and 1 or 0
	local v2 = p2.sub.Favourited and 1 or 0

	if v ~= v2 then
		return v2 < v
	end

	local weight = p.sub.Weight
	local weight2 = p2.sub.Weight

	if weight and weight2 then
		if weight == weight2 then
			return (SortHelper.Rarity(p, p2))
		end

		if p3 then
			return weight < weight2
		end

		return weight2 < weight
	else
		if weight then
			return false
		end

		if weight2 then
			return true
		end

		return (SortHelper.Rarity(p, p2))
	end
end

function SortHelper.Name(p, p2)
	local displayName = itemDisplayInfo[p.name].displayName
	local displayName2 = itemDisplayInfo[p2.name].displayName

	if displayName ~= displayName2 then
		return displayName < displayName2
	end

	if p.sub.Weight and p2.sub.Weight then
		return p.sub.Weight < p2.sub.Weight
	end

	if p.sub.x and p2.sub.x then
		return p.sub.x < p2.sub.x
	end

	return displayName < displayName2
end

function SortHelper.Rarity(p, p2)
	local v = ordersByName[itemDisplayInfo[p.name].rarity]
	local v2 = ordersByName[itemDisplayInfo[p2.name].rarity]

	if v == v2 then
		return (SortHelper.Name(p, p2))
	end

	return v < v2
end

function SortHelper.Weight(p, p2, p3)
	local weight = p.sub.Weight
	local weight2 = p2.sub.Weight

	if weight and weight2 then
		if weight == weight2 then
			return (SortHelper.Rarity(p, p2))
		end

		if p3 then
			return weight < weight2
		end

		return weight2 < weight
	else
		if weight then
			return false
		end

		if weight2 then
			return true
		end

		return (SortHelper.Rarity(p, p2))
	end
end

function SortHelper.Value(p, p2, p3)
	local v

	if library.fish[p.name] then
		v = fishing:SellFish(Players.LocalPlayer, p, true) or nil
	end

	local v2

	if library.fish[p2.name] then
		v2 = fishing:SellFish(Players.LocalPlayer, p2, true) or nil
	end

	if v and v2 then
		if v == v2 then
			return (SortHelper.Weight(p, p2))
		end

		if p3 then
			return v < v2
		end

		return v2 < v
	else
		if v then
			return false
		end

		if v2 then
			return true
		end

		return (SortHelper.Weight(p, p2))
	end
end

return SortHelper