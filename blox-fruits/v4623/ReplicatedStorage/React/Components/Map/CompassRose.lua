local React = require(game.ReplicatedStorage.Packages.React)
local Textures = require(game.ReplicatedStorage.Textures)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("ImageButton", RobloxTypes.mergeImageButton({
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		[React.Event.InputBegan] = function(_, _) end
	}, p), {
		Icon = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = Textures.misc["compass.png"],
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5)
		})
	})
end