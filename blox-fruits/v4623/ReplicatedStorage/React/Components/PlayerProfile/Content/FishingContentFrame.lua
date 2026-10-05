local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.651458, 0.552436),
		Selectable = true,
		SelectionGroup = true,
		Size = UDim2.fromScale(0.678562, 0.847019),
		Visible = p.Category == "FishIndex"
	}, {
		container = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0.002, 0),
				PaddingRight = UDim.new(0.002, 0)
			}),
			uIListLayout = createElement("UIListLayout", {
				Padding = CONSTANTS.SPACING.PADDING.SCALE.XS,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			header = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(1, 0.09)
			}, {
				headerTextLabel = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					LayoutOrder = 2,
					Position = UDim2.fromScale(0, -2.52211e-7),
					Size = UDim2.fromScale(0.781, 1),
					Text = "Fish Index",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					uIStroke = createElement("UIStroke"),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0, 0.4),
						Size = UDim2.fromScale(1, 1),
						Text = "Fish Index",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = CONSTANTS.LAYER.RAISED
					}, {
						uIStroke = createElement("UIStroke")
					})
				}),
				counter = createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					LayoutOrder = 2,
					Position = UDim2.fromScale(1, 0.475),
					Size = UDim2.fromScale(0.504, 0.7),
					Text = "15/20 Discovered",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextTransparency = CONSTANTS.ALPHA.HALF,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = CONSTANTS.LAYER.RAISED
				})
			}),
			scrollingFrame = createElement("ScrollingFrame", {
				Active = true,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				CanvasSize = UDim2.fromScale(0, 1.7),
				LayoutOrder = 1,
				Position = UDim2.fromScale(-1.52718e-7, 0.1),
				ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
				Size = UDim2.fromScale(0.989527, 0.892542)
			}, {
				uIGridLayout = createElement("UIGridLayout", {
					CellPadding = UDim2.fromScale(0.023, 0.02),
					CellSize = UDim2.fromScale(0.175, 0.22),
					SortOrder = Enum.SortOrder.LayoutOrder
				})
			})
		}),
		infoOverlay = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(17, 17, 17),
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.495142, 1),
			Size = UDim2.fromScale(0.979996, 0.157653)
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.323523, 0.34207),
				Size = UDim2.fromScale(0.34922, 0.348615),
				Text = "Rainbow-bellied Carp",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			}),
			uICorner = createElement("UICorner"),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			fade = createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(102, 187, 216),
				BackgroundTransparency = 0.45,
				Position = UDim2.fromScale(0, -9.08347e-7),
				Size = UDim2.fromScale(0.256597, 1),
				ZIndex = CONSTANTS.LAYER.BASE
			}, {
				uIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				uICorner = createElement("UICorner")
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=15243506332",
				ImageRectOffset = Vector2.new(750, 450),
				ImageRectSize = Vector2.new(150, 150),
				Position = UDim2.fromScale(0.0712479, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.14215, 0.977068),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			creator = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.32379, 0.685929),
				Size = UDim2.fromScale(0.349931, 0.3),
				Text = "Times Caught: 2",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = 0.4,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			bar = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 230, 53),
				BackgroundTransparency = 0.65,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.606203, 0.26714),
				Size = UDim2.fromScale(0.284, 0.16)
			}, {
				progressBar = createElement("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 230, 53),
					BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromScale(0.625571, 1)
				}, {
					arrow = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://105014044988846",
						Position = UDim2.fromScale(1, 0.5),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromScale(0.229, 1.75)
					}),
					highestWeight = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						Position = UDim2.fromScale(1, 3.535),
						Size = UDim2.fromScale(2, 2),
						Text = "Heaviest: 1,587 kg",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true
					})
				}),
				highestWeight = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(1.05, 0.485999),
					Size = UDim2.fromScale(0.361257, 2),
					Text = "2k kg",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				lowestWeight = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(-0.419365, 0.486006),
					Size = UDim2.fromScale(0.358, 2),
					Text = "100 kg",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right
				})
			})
		})
	})
end