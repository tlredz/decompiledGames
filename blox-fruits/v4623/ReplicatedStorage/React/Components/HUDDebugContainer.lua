local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local PRESETS = require(script.PRESETS)
local createElement = React.createElement
return function(props)
	local v = PRESETS[props.PresetKey]
	useMockStateWriter("LastInput", not v and "MouseKeyboard" or v.InputType or "MouseKeyboard")

	if not v then
		return
	end

	local v5 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ClipsDescendants = true,
		BackgroundColor3 = Color3.new(1, 0, 0),
		BackgroundTransparency = 1,
		Size = props.ClipToScreen and UDim2.fromOffset(v.Resolution.X, v.Resolution.Y) or UDim2.fromOffset(
			v.Resolution.X / v.Size.X.Scale,
			v.Resolution.Y / v.Size.Y.Scale
		)
	}
	local v9 = {
		AnchorPoint = props.ClipToScreen and Vector2.new(v.Offset.X.Scale, v.Offset.Y.Scale) or Vector2.new(0, 0),
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromOffset(v.Resolution.X / v.Size.X.Scale, v.Resolution.Y / v.Size.Y.Scale),
		BackgroundTransparency = 1,
		ImageTransparency = props.BackgroundTransparency,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Image = v.Image,
		ZIndex = 1
	}
	local v13 = {
		Position = v.Offset,
		Size = v.Size,
		BackgroundColor3 = Color3.new(1, 0, 0),
		BackgroundTransparency = props.VisualizeSafeZone and 0.5 or 1
	}
	local textLabel

	if props.HideLabel == true then
		textLabel = false
	else
		textLabel = createElement("TextLabel", {
			ZIndex = 2,
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(),
			TextColor3 = Color3.new(1, 1, 1),
			Text = `{props.PresetKey}`,
			TextScaled = true,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0, 0.075),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0)
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0.05, 0),
				PaddingRight = UDim.new(0.05, 0),
				PaddingTop = UDim.new(0.025, 0),
				PaddingBottom = UDim.new(0.025, 0)
			})
		})
	end

	return createElement("Frame", v5, {
		Screenshot = createElement("ImageLabel", v9, {
			Window = createElement("Frame", v13, {
				TextLabel = textLabel,
				SafeZone = createElement("Frame", {
					Position = v.SafeZoneOffset or UDim2.fromScale(0, 0),
					Size = (v.SafeZoneSize or UDim2.fromScale(1, 1)) - v.SafeZoneOffset,
					BackgroundColor3 = Color3.new(0, 1, 0),
					BackgroundTransparency = props.VisualizeSafeZone and 0.5 or 1
				}, props.children)
			})
		})
	})
end