local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local ChromaticTile = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.ChromaticTile)
return function(p)
	local fruit

	if p.Items[1] ~= nil then
		fruit = createElement(ChromaticTile, {
			Item = p.Items[1],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.0537845, 0.524506),
				Size = UDim2.fromScale(0.124963, 0.315103)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.686968, 0.244492),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://129906000942737",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.9, 0.9)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 1.067),
				RichText = true,
				Size = UDim2.fromScale(0.858583, 0.45),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.03, 0.000999959),
				Size = UDim2.fromScale(0.620442, 0.274357),
				ZIndex = 999
			}
		})
	end

	local fruit2

	if p.Items[2] ~= nil then
		fruit2 = createElement(ChromaticTile, {
			Item = p.Items[2],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.179342, 0.438),
				Size = UDim2.fromScale(0.124963, 0.315103)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.686968, 0.244492),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://79856528160595",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.95, 0.95)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 1.067),
				RichText = true,
				Size = UDim2.fromScale(0.818868, 0.45),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.03, 0.000999959),
				Size = UDim2.fromScale(0.620442, 0.274357),
				ZIndex = 999
			}
		})
	end

	local fruit3

	if p.Items[3] ~= nil then
		fruit3 = createElement(ChromaticTile, {
			Item = p.Items[3],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.303919, 0.524506),
				Size = UDim2.fromScale(0.124963, 0.315103)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.686968, 0.244492),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://104553061489626",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.9, 0.9)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 1.067),
				RichText = true,
				Size = UDim2.fromScale(0.858583, 0.45),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.03, 0.000999959),
				Size = UDim2.fromScale(0.620442, 0.274357),
				ZIndex = 999
			}
		})
	end

	local fruit4

	if p.Items[4] ~= nil then
		fruit4 = createElement(ChromaticTile, {
			Item = p.Items[4],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.414763, 0.438),
				Size = UDim2.fromScale(0.124963, 0.315103)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.686968, 0.244492),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://116717557149902",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 1.067),
				RichText = true,
				Size = UDim2.fromScale(0.891875, 0.45),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.03, 0.000999959),
				Size = UDim2.fromScale(0.620442, 0.274357),
				ZIndex = 999
			}
		})
	end

	local fruit5

	if p.Items[5] ~= nil then
		fruit5 = createElement(ChromaticTile, {
			Item = p.Items[5],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.549149, 0.524506),
				Size = UDim2.fromScale(0.144188, 0.36071)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.686968, 0.244492),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://70509356128502",
				Position = UDim2.fromScale(0.5, 0.485035),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.929931, 0.929931)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 1.067),
				RichText = true,
				Size = UDim2.fromScale(0.859, 0.45),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.0300004, 0.0240394),
				Size = UDim2.fromScale(0.516237, 0.228278),
				ZIndex = 999
			}
		})
	end

	local fruit6

	if p.Items[6] ~= nil then
		fruit6 = createElement(ChromaticTile, {
			Item = p.Items[6],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.705, 0.4),
				Size = UDim2.fromScale(0.19599, 0.490302)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(1, 0.92),
				Size = UDim2.fromScale(0.8, 0.22),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://128792790321197",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.95, 0.95)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.95),
				RichText = true,
				Size = UDim2.fromScale(1.03, 0.35),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.0300004, 0.0240394),
				Size = UDim2.fromScale(0.516237, 0.228278),
				ZIndex = 999
			}
		})
	end

	local fruit7

	if p.Items[7] ~= nil then
		fruit7 = createElement(ChromaticTile, {
			Item = p.Items[7],
			ImageButton = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.9, 0.47),
				Size = UDim2.fromScale(0.19599, 0.490302)
			},
			PityCounter = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(1, 0.92),
				Rotation = -0.00001,
				Size = UDim2.fromScale(0.8, 0.22),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 999
			},
			FruitIcon = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://126115710010253",
				Position = UDim2.fromScale(0.45, 0.45),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.9, 0.9)
			},
			NameLabel = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.95),
				RichText = true,
				Size = UDim2.fromScale(0.859, 0.35),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			},
			Odds = {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.0300004, 0.0240394),
				Size = UDim2.fromScale(0.516237, 0.228278),
				ZIndex = 999
			}
		})
	end

	return createElement("Folder", nil, {
		Fruit1 = fruit,
		Fruit2 = fruit2,
		Fruit3 = fruit3,
		Fruit4 = fruit4,
		Fruit5 = fruit5,
		Fruit6 = fruit6,
		Fruit7 = fruit7
	})
end