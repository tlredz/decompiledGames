local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Map.Types)
local IslandTile = require(game.ReplicatedStorage.React.Components.IslandTile)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.useLevel)
local useStarCount = require(game.ReplicatedStorage.React.Hooks.Island.useStarCount)
local useCompleted = require(game.ReplicatedStorage.React.Hooks.Island.useCompleted)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(props)
	local island = props.Island
	local isSelected = props.IsSelected
	local v = useCurrentSea()
	local v2 = useLevel()
	local minimumLevel = nil

	if props.Island.Requirements then
		for _, requirement in props.Island.Requirements do
			if requirement.Type ~= "Level" then
				continue
			end

			minimumLevel = requirement.MinimumLevel
			break
		end
	end

	local starsFilled, v4 = useStarCount(v, island.Index.Key)
	local v5 = useCompleted()
	local isGlowEnabled = React.useMemo(function()
		for _, v7 in v5 do
			if v7.Index.Key == island.Index.Key then
				return true
			end
		end

		return false
	end, { island, v5 })
	local mergeGuiObject = RobloxTypes.mergeGuiObject({}, props)
	mergeGuiObject.Level = minimumLevel
	mergeGuiObject.Stars = v4 > 0 and v4 or nil
	mergeGuiObject.IconMode = "Default"
	mergeGuiObject.SelectionEmblem = island.Index.Key == "Pirate Starter" and "Pirate" or island.Index.Key == "Marine Starter" and "Marines" or nil
	mergeGuiObject.Island = island
	mergeGuiObject.IsSelected = isSelected
	mergeGuiObject.IsRecommended = props.IsRecommended
	mergeGuiObject.IsGlowEnabled = isGlowEnabled

	if not isSelected then
		starsFilled = nil
	end

	mergeGuiObject.StarsFilled = starsFilled
	mergeGuiObject.IsLocked = minimumLevel and (v2 or 0) < minimumLevel
	mergeGuiObject.OnClick = props.OnClick

	if minimumLevel and v2 and v2 < minimumLevel then
		mergeGuiObject.OnClick = nil
	end

	return createElement(IslandTile, mergeGuiObject)
end