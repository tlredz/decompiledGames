local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FishHelper = require(ReplicatedStorage.Modules.FishHelper)
local FishTile = require(script.FishTile)
local useSprite = require(ReplicatedStorage.React.Hooks.useSprite)
local Spritesheets = require(ReplicatedStorage.Spritesheets)
local FishTileUndiscovered = require(script.FishTileUndiscovered)
local React = require(ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(ReplicatedStorage.Packages.MaterialIconsHD)
local FishingIndexInventoryData = require(ReplicatedStorage.FishReplicated.FishingIndexInventoryData)
require(ReplicatedStorage.React.Components.FishIndex.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local pufferfish1 = Spritesheets.MAP.Pufferfish1 or MaterialIconsHD.broken_image
return function(props)
	local v = React.useMemo(function()
		return FishingIndexInventoryData.FishIndex[props.CurrentFishIndex]
	end, { props.CurrentFishIndex })
	local v2 = React.useMemo(function()
		return props.Fish[props.CurrentFishIndex]
	end, { props.CurrentFishIndex })
	local v3 = v2 == nil
	local v5

	if v then
		v5 = v.Name .. (v3 and "2" or "1")
	end

	local v6 = useSprite(v5) or pufferfish1
	local children = {}

	for k, v7 in ItemConfig.Query.select({
		Index = {
			IdType = "Fish"
		}
	}) do
		local itemId = v7.Index.ItemId

		if not (props.Fish[itemId] ~= nil or props.Fish[itemId] ~= nil or not (FishingIndexInventoryData.FishIndex[itemId] and FishingIndexInventoryData.FishIndex[itemId].Hidden)) then
			continue
		end

		children[`Fish-{itemId}`] = React.createElement(
			props.Fish[itemId] ~= nil and FishTile or FishTileUndiscovered,
			{
				FishId = itemId,
				LayoutIndex = k,
				CurrentFish = props.CurrentFishIndex,
				SetCurrentFish = props.SetCurrentFish,
				Visible = true
			}
		)
	end

	return React.createElement("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.5, 0.5),
		Selectable = true,
		SelectionGroup = true,
		Size = UDim2.fromScale(1, 1),
		Visible = true
	}, {
		container = React.createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1)
		}, {
			uIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0.002, 0),
				PaddingRight = UDim.new(0.002, 0)
			}),
			uIListLayout = React.createElement("UIListLayout", {
				Padding = CONSTANTS.SPACING.PADDING.SCALE.XS,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}),
			header = React.createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(1, 0.09)
			}, {
				counter = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					LayoutOrder = 2,
					Position = UDim2.fromScale(1, 0.475),
					Size = UDim2.fromScale(0.504, 0.7),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextTransparency = CONSTANTS.ALPHA.HALF,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = CONSTANTS.LAYER.RAISED
				})
			}),
			scrollingFrame = React.createElement("ScrollingFrame", {
				Active = true,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Position = UDim2.fromScale(-1.52718e-7, 0.1),
				ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
				Size = UDim2.fromScale(0.989527, 0.71)
			}, {
				uIGridLayout = React.createElement("UIGridLayout", {
					CellPadding = UDim2.fromScale(0, 0),
					CellSize = UDim2.fromScale(0.2, 0.5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				fishTiles = React.createElement(React.Fragment, nil, children)
			})
		}),
		infoOverlay = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(17, 17, 17),
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.5, 0.987),
			Size = UDim2.fromScale(0.979996, 0.157653)
		}, {
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.323523, 0.34207),
				Size = UDim2.fromScale(0.34922, 0.348615),
				Text = (not v or v3) and "???" or v.Name or "???",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				uIStroke = React.createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			}),
			uICorner = React.createElement("UICorner"),
			uIStroke = React.createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			fade = React.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(102, 187, 216),
				BackgroundTransparency = 0.45,
				Position = UDim2.fromScale(0, -9.08347e-7),
				Size = UDim2.fromScale(0.256597, 1),
				ZIndex = CONSTANTS.LAYER.BASE
			}, {
				uIGradient = React.createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				uICorner = React.createElement("UICorner")
			}),
			icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = typeof(v6.Image) ~= "string" and "" or v6.Image,
				ImageColor3 = v3 and CONSTANTS.COLOR.PALETTE.BLACK or CONSTANTS.COLOR.PALETTE.WHITE,
				ImageRectOffset = v6.ImageRectOffset,
				ImageRectSize = v6.ImageRectSize,
				Position = UDim2.fromScale(0, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.14215, 0.977068),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				uiAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1
				})
			}),
			creator = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.32379, 0.685929),
				Size = UDim2.fromScale(0.349931, 0.3),
				Text = not v2 and "" or `Times Caught: {v2.CaughtCount}` or "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = 0.4,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			bar = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 230, 53),
				BackgroundTransparency = 0.65,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.606203, 0.26714),
				Size = UDim2.fromScale(0.284, 0.16)
			}, {
				innerBar = React.createElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 230, 53),
					BackgroundTransparency = 0.65,
					BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0, 0),
					Size = UDim2.fromScale(1, 1),
					ClipsDescendants = true
				}, {
					progressBar = React.createElement("Frame", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 230, 53),
						BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromScale(not v2 and 0 or v2.HighestWeight / 65535 or 0, 0.5),
						Size = UDim2.fromScale(1, 1)
					}, {
						arrow = React.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://105014044988846",
							Position = UDim2.fromScale(1, 0.5),
							ScaleType = Enum.ScaleType.Fit,
							Size = UDim2.fromScale(0.229, 1.75),
							Visible = v2 ~= nil,
							Rotation = 0.001
						}, {
							highestWeight = React.createElement("TextLabel", {
								AnchorPoint = Vector2.new(0.5, 0),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								Position = UDim2.fromScale(0.5, 1),
								Size = UDim2.fromScale(6, 1.15),
								Text = not v2 and "" or `Heaviest: {FishHelper.FormatTrueWeight(FishHelper.GetTrueWeightRaw(props.CurrentFishIndex, v2.HighestWeight))}` or "",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								Rotation = 0.001
							})
						})
					})
				}),
				highestWeight = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(1.05, 0.485999),
					Size = UDim2.fromScale(0.361257, 2),
					Text = (v3 or not v) and "??" or FishHelper.FormatTrueWeight(FishHelper.GetTrueWeightRaw(
						props.CurrentFishIndex,
						65535
					)) or "??",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				lowestWeight = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(-0.419365, 0.486006),
					Size = UDim2.fromScale(0.358, 2),
					Text = (v3 or not v) and "??" or FishHelper.FormatTrueWeight(FishHelper.GetTrueWeightRaw(
						props.CurrentFishIndex,
						0
					)) or "??",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right
				})
			})
		})
	})
end