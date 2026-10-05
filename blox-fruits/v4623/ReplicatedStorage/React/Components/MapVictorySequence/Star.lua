local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local BasePart = require(game.ReplicatedStorage.React.Components.MapVictorySequence.BasePart)
local star = game.ReplicatedStorage.Assets:FindFirstChild("Meshes") and game.ReplicatedStorage.Assets.Meshes:FindFirstChild("Star") or nil
local createElement = React.createElement
return function(props)
	local mergeInstance = RobloxTypes.mergeInstance({}, props)
	mergeInstance.Template = star
	mergeInstance.Size = props.Size
	mergeInstance.CFrame = props.CFrame
	mergeInstance.Scale = props.Scale
	mergeInstance.Transparency = props.Transparency
	mergeInstance.Material = props.Material
	mergeInstance.ResetPivot = true
	return createElement(BasePart, mergeInstance, {})
end