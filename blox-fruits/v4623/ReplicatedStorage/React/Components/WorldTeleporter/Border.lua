local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useOscillation = require(game.ReplicatedStorage.React.Hooks.Animation.useOscillation)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim.new(0, 0)
local uDim2 = UDim.new(-0.015, 0)
local uDim3 = UDim.new(-0.03, 0)
local uDim4 = UDim.new(-0.045, 0)
local createElement = React.createElement

local function lerpUDim(udim: UDim, udim2: UDim, p: number)
	return UDim.new(udim.Scale + (udim2.Scale - udim.Scale) * p, udim.Offset + (udim2.Offset - udim.Offset) * p)
end

return function(_)
	local v = useTheme()
	local transparency = usePeriod(true, 1)
	local v3 = useOscillation(true, 1)

	local function lerp(p: number, p2: number)
		return p + (p2 - p) * transparency
	end

	local fragment = React.Fragment
	local v5 = {
		Outer = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Color = v.Secondary,
			Thickness = 0.00375,
			BorderOffset = uDim
		}),
		Inner0 = 0,
		Inner1 = 0,
		Inner2 = 0,
		ShadowContainer = 0
	}
	local v7 = {
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Color = v.Secondary,
		Thickness = 0.00375 + -0.00225 * transparency,
		BorderOffset = 0
	}
	local udim = uDim
	local udim2 = uDim2
	v7.BorderOffset = UDim.new(
		udim.Scale + (udim2.Scale - udim.Scale) * transparency,
		udim.Offset + (udim2.Offset - udim.Offset) * transparency
	)
	v5.Inner0 = createElement("UIStroke", v7)
	local v9 = {
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Color = v.Secondary,
		Thickness = 0.0015 + -0.0011250000000000001 * transparency,
		BorderOffset = 0
	}
	local udim3 = uDim2
	local udim4 = uDim3
	v9.BorderOffset = UDim.new(
		udim3.Scale + (udim4.Scale - udim3.Scale) * transparency,
		udim3.Offset + (udim4.Offset - udim3.Offset) * transparency
	)
	v5.Inner1 = createElement("UIStroke", v9)
	local v11 = {
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Color = v.Secondary,
		Thickness = 0.000375 + -0.000375 * transparency,
		BorderOffset = 0,
		Transparency = 0
	}
	local udim5 = uDim3
	local udim6 = uDim4
	v11.BorderOffset = UDim.new(
		udim5.Scale + (udim6.Scale - udim5.Scale) * transparency,
		udim5.Offset + (udim6.Offset - udim5.Offset) * transparency
	)
	v11.Transparency = transparency
	v5.Inner2 = createElement("UIStroke", v11)
	v5.ShadowContainer = createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Size = UDim2.fromScale(0.99 + 0.002 * v3, 0.99 + 0.002 * v3),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5)
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Glow = createElement("UIShadow", {
			Color = v.Background,
			BlurRadius = UDim.new(0.1, 0),
			Transparency = CONSTANTS.ALPHA.OPAQUE
		})
	})
	return createElement(fragment, {}, v5)
end