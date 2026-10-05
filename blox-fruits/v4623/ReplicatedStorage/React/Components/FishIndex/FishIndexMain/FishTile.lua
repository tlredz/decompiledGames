local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(ReplicatedStorage.Packages.MaterialIconsHD)
local useSprite = require(ReplicatedStorage.React.Hooks.useSprite)
local FishingIndexInventoryData = require(game.ReplicatedStorage.FishReplicated.FishingIndexInventoryData)
require(ReplicatedStorage.React.Components.FishIndex.Types)
local Spritesheets = require(ReplicatedStorage.Spritesheets)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local broken_image = MaterialIconsHD.broken_image
local v = {
	Common = {
		[true] = Spritesheets.MAP["Tile Common Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Common Default"] or broken_image
	},
	Uncommon = {
		[true] = Spritesheets.MAP["Tile Uncommon Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Uncommon Default"] or broken_image
	},
	Rare = {
		[true] = Spritesheets.MAP["Tile Rare Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Rare Default"] or broken_image
	},
	Legendary = {
		[true] = Spritesheets.MAP["Tile Legendary Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Legendary Default"] or broken_image
	},
	Mythical = {
		[true] = Spritesheets.MAP["Tile Mythical Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Mythical Default"] or broken_image
	},
	Premium = {
		[true] = Spritesheets.MAP["Tile Premium Active"] or broken_image,
		[false] = Spritesheets.MAP["Tile Premium Default"] or broken_image
	}
}
local pufferfish1 = Spritesheets.MAP.Pufferfish1 or MaterialIconsHD.broken_image
return function(props)
	local state, setState = React.useState(false)
	local v2 = React.useMemo(function()
		return FishingIndexInventoryData.FishIndex[props.FishId]
	end, { props.FishId })
	local v4

	if v2 then
		v4 = v2.Name .. "1"
	end

	local v5 = useSprite(v4) or pufferfish1
	local v6 = React.useMemo(function()
		local v8 = v[not (v2 and v2.Rarity) and "Common" or RarityUtil.VALUE_TO_TYPE[v2.Rarity]]
		assert(v8, "spriteSet should be defined here")
		return v8[state]
	end, { v2 and v2.Rarity, state })
	return React.createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.184211, -1.24731e-7),
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = props.FishId
	}, {
		click = React.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			ZIndex = 25,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			[React.Event.MouseButton1Click] = function()
				if props.CurrentFish ~= props.FishId then
					props.SetCurrentFish(props.FishId)
				end
			end,
			[React.Event.MouseEnter] = function()
				setState(true)
			end,
			[React.Event.MouseLeave] = function()
				setState(false)
			end
		}),
		uiAspectRatioConstarint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.627
		}),
		tile = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			selectedImg = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "http://www.roblox.com/asset/?id=9810799683",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.new(0.925, 20, 0.925, 20),
				SliceCenter = Rect.new(16, 16, 43, 43),
				Visible = props.CurrentFish == props.FishId,
				ZIndex = 6
			}),
			icon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = typeof(v5.Image) ~= "string" and "" or v5.Image,
				ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ImageRectOffset = v5.ImageRectOffset,
				ImageRectSize = v5.ImageRectSize,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.89, 0.89),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			background = React.createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = typeof(v6.Image) ~= "string" and "" or v6.Image,
				ImageRectOffset = v6.ImageRectOffset,
				ImageRectSize = v6.ImageRectSize,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1)
			}),
			counter = React.createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.2,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-1.18977e-6, 0.0700002),
				Size = UDim2.fromScale(0.59, 0.23),
				Visible = false,
				ZIndex = 10
			}, {
				uIGradient = React.createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.542964, 0.38125),
						NumberSequenceKeypoint.new(0.768369, 0.675),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				shadow = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.15, 0.6),
					Size = UDim2.fromScale(1, 1),
					Text = "x3",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}, {
					textLabel = React.createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						Position = UDim2.fromScale(0.45, 0.425),
						Size = UDim2.fromScale(1, 1),
						Text = "x3",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					}, {
						uIStroke = React.createElement("UIStroke", {
							Thickness = 0.5
						})
					})
				})
			}),
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.98
			}),
			heaviestWeightShadow = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.94, 0.925),
				Size = UDim2.fromScale(0.794, 0.225),
				Text = "21 kg",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.MID,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				Visible = false,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}, {
				textLabel = React.createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.99, 0.92),
					Size = UDim2.fromScale(1, 1),
					Text = "21 kg",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextStrokeTransparency = CONSTANTS.ALPHA.MID,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					ZIndex = CONSTANTS.LAYER.OVERLAY
				}, {
					uIStroke = React.createElement("UIStroke")
				})
			})
		}),
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.529, 0.95),
			Size = UDim2.fromScale(1, 0.288021),
			Text = v2 and v2.Name or "???",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.MID,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			uIStroke = React.createElement("UIStroke"),
			uITextSizeConstraint = React.createElement("UITextSizeConstraint", {
				MaxTextSize = 30
			})
		})
	})
end