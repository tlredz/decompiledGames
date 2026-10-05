local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		Decoration = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://130309505550960",
			Position = UDim2.fromScale(0.5, 0.3),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1.08, 1.299)
		}),
		Sale = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://111264630016135",
			Position = UDim2.fromScale(0.6, -0.2),
			Size = UDim2.fromScale(0.6, 0.6),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
				Position = UDim2.fromScale(0.5, 0.5),
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = "SALE!",
				TextColor3 = Color3.fromRGB(252, 241, 103),
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				UIStroke = createElement("UIStroke", {
					Color = Color3.fromRGB(134, 77, 15),
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		})
	})
end