local Favorites = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local Stats = require(ReplicatedStorage.Modules.Stats)
require(ReplicatedStorage.Modules.Types)
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Favorites2 = require(ReplicatedStorage.Assets.Data.Favorites)
local v = {}

function Favorites:GetFavoritesUpdatedSignal(p: string)
	if not v[p] then
		v[p] = FastSignal.new()
	end

	return v[p]
end

function Favorites.GetFavorites(_, p: string)
	return Stats.Favorites[p] or {}
end

function Favorites.IsFavorited(_, p: string, p2: number)
	if Stats.Favorites[p] then
		return Stats.Favorites[p][tostring(p2)] and true or false
	end

	return false
end

function Favorites.IsDefault(_, p: string, p2: number)
	if not Favorites2[p] then
		return false
	end

	local default = Favorites2[p].Default

	if default then
		return default[p2] and true or false
	end

	return false
end

function Favorites.GetMaxFavorites(_, p: string)
	return Favorites2[p].Max or 10
end

Network:listen("Favorites/Initialize", function(items)
	for k, favorite in next, Favorites2, nil do
		if not favorite.Default then
			continue
		end

		if not items[k] then
			items[k] = {}
		end

		for k2, name in next, favorite.Default, nil do
			items[k][tostring(k2)] = {
				Time = 0,
				Name = name,
				Id = k2,
				IsDefault = true
			}
		end
	end

	for k, item in next, items, nil do
		Stats.Favorites[k] = item
		Favorites:GetFavoritesUpdatedSignal(k):Fire()
	end
end)
Network:listen("Favorites/Add", function(p: string, p2)
	if not Stats.Favorites[p] then
		Stats.Favorites[p] = {}
	end

	Stats.Favorites[p][tostring(p2.Id)] = p2
	Favorites:GetFavoritesUpdatedSignal(p):Fire()
end)
Network:listen("Favorites/Remove", function(p: string, p2: number)
	if not Stats.Favorites[p] then
		return
	end

	Stats.Favorites[p][tostring(p2)] = nil
	Favorites:GetFavoritesUpdatedSignal(p):Fire()
end)
return Favorites