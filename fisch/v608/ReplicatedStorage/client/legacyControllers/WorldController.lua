local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("shared").modules
local Worlds = require(modules.Worlds)
local WorldController = {
	GetWorlds = function(_)
		return Worlds
	end,
	GetCurrencyData = function(_, p)
		return Worlds.Currencies[p]
	end
}

function WorldController.GetCurrentCurrency(_)
	return WorldController:GetCurrentWorldData().Currency
end

function WorldController.GetCurrentWorldBestiary(_)
	return WorldController:GetCurrentWorldData().DefaultBestiary
end

function WorldController.GetCurrentWorldLevelCap(_)
	return WorldController:GetCurrentWorldData().LevelCap
end

function WorldController.GetCurrentWorldXpPerLevel(_)
	return WorldController:GetCurrentWorldData().XpPerLevel
end

function WorldController:GetCurrentWorldIndex()
	local placeId = game.PlaceId
	return Worlds.Places[placeId] or Worlds.DefaultPlace
end

function WorldController:GetCurrentWorldData()
	return Worlds.WorldStats[WorldController:GetCurrentWorldIndex()]
end

return WorldController