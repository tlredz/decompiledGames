local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.FishIndex.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
return function(props)
	return React.createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.184211, -1.24731e-7),
		Size = UDim2.fromOffset(1, 1),
		LayoutOrder = props.FishId,
		Visible = props.Visible
	}, {
		uiAspectRatioConstarint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.627
		}),
		click = React.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			ZIndex = 25,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			[React.Event.MouseButton1Click] = function()
				if props.CurrentFish ~= props.FishId then
					props.SetCurrentFish(props.FishId)
				end
			end
		}),
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.529, 0.95),
			Size = UDim2.fromScale(1, 0.288021),
			Text = "???",
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
		}),
		undiscoveredState = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			LayoutOrder = -1,
			Position = UDim2.fromScale(0.5, 0.01),
			Size = UDim2.fromScale(1, 1)
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
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
			uICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0.08, 0)
			}),
			uIStroke = React.createElement("UIStroke", {
				Color = CONSTANTS.COLOR.DIVIDER.BORDER,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			fishIcon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://98130889923069",
				ImageColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.4, 0.4)
			}),
			fishNumber = React.createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.07, 0.05),
				Size = UDim2.fromScale(0.673, 0.25),
				Text = string.format("%.2d", props.LayoutIndex),
				TextColor3 = Color3.fromRGB(103, 103, 103),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS.LAYER.RAISED
			})
		})
	})
end