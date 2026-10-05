local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Model = require(game.ReplicatedStorage.React.Components.MapVictorySequence.Model)
local currentMap = Map.findCurrentMap()
local fakeIslands = game.ReplicatedStorage:WaitForChild("FakeIslands")
local createElement = React.createElement
return function(props)
	local v = React.useMemo(function()
		if not (currentMap and props.Island) then
			return nil
		end

		local island = Map.findIsland(currentMap, props.Island)

		if island then
			return island.Reference.LOD
		end

		return nil
	end, { props.Island })
	local mergeInstance = RobloxTypes.mergeInstance({}, props)
	mergeInstance.Template = v and fakeIslands:FindFirstChild(v) or nil
	mergeInstance.Scale = props.Scale
	mergeInstance.CFrame = props.CFrame
	mergeInstance.ResetPivot = true
	return createElement(Model, mergeInstance, {})
end