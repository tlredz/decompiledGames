local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
require(game.ReplicatedStorage.Spritesheets)
local _ = React.createElement
local element = React.createElement("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder = Enum.SortOrder.LayoutOrder
})

local function BoxWithHeader(props)
	local textLabel = React.useMemo(function()
		return React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			Size = UDim2.fromScale(1, 1),
			Text = props.headerText or "",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			ZIndex = 2
		}, {
			UIStroke = React.createElement("UIStroke"),
			UIPadding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0.05, 0),
				PaddingRight = UDim.new(0.05, 0)
			})
		})
	end, { props.headerText })
	local headerText = React.useMemo(function()
		return React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 199, 29),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			LayoutOrder = 1
		}, {
			UISizeConstraint = React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(5000, props.headerMaxY or 35 * workspace.CurrentCamera.ViewportSize.Y / 1080)
			}),
			TextLabel = textLabel,
			UIGradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 239, 60)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 239, 60)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 239, 60))
				})
			}),
			UIStroke = React.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})
	end, { textLabel, props.headerMaxY })
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, {
		UIListLayout = element,
		HeaderText = headerText,
		Frame = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.2),
			Size = UDim2.fromScale(1, 1),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2
		}, { React.createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1.2
			}), props.children }),
		UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio or 2
		})
	})
end

return BoxWithHeader