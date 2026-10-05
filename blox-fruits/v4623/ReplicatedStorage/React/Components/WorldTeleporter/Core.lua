local React = require(game.ReplicatedStorage.Packages.React)
local Textures = require(game.ReplicatedStorage.Textures)
require(game.ReplicatedStorage.React.RobloxTypes)
local ParticleEmitter = require(game.ReplicatedStorage.React.Components.ParticleEmitter)
local ArcText = require(game.ReplicatedStorage.React.Components.WorldTeleporter.ArcText)
local MagicCircle = require(game.ReplicatedStorage.React.Components.WorldTeleporter.MagicCircle)
local useTransitionAlpha = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTransitionAlpha)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local PULSE = CONSTANTS2.CELEBRATION.PULSE
local createElement = React.createElement

local function getNameLines(p)
	if not p then
		return nil, nil, nil
	end

	local name = p.Display.Name or p.Index.Key

	if not name:find(" ") then
		return name, nil, nil
	end

	local parts = name:split(" ")
	return nil, parts[1], parts[2]
end

return function(props)
	local v = useTheme()
	local hasDoubleRing = props.HasDoubleRing
	local v2 = useTransitionAlpha(props.OnClick ~= nil or props.IsActive == true)
	local v3 = useTransitionAlpha(props.IsSolved == true)
	local v4 = (hasDoubleRing and 1 or 1.7) + v2 * 1.35 * (1 / (1 + v3))
	local state, setState = React.useState(Enum.GuiState.Idle)

	if props.OnClick == nil then
		state = Enum.GuiState.Idle
	end

	local v5 = state == Enum.GuiState.Hover or state == Enum.GuiState.Press
	local selectedIsland = props.SelectedIsland
	local name, v6, v7

	if selectedIsland then
		name = selectedIsland.Display.Name or selectedIsland.Index.Key

		if name:find(" ") then
			local parts = name:split(" ")
			v6 = parts[1]
			v7 = parts[2]
			name = nil
		end
	end

	local v8 = (props.Pulse or 0) * v3
	local v9 = 0.145 * v4 * (1 + PULSE.CIRCLE_SCALE * v8)
	local uDim = UDim2.fromScale(((hasDoubleRing and 0.15 or 0) + 0.95) * 5, ((hasDoubleRing and 0.15 or 0) + 0.95) * 5)
	local uDim2 = UDim2.fromScale(0.012, (0.07500000000000001 - (hasDoubleRing and 0.25 or 0)) / 5)
	local uDim3 = UDim.new(((hasDoubleRing and 0.07 or 0) + 0.15) / 5, 0)

	local function textRing(text: string, p: number)
		return createElement(ArcText, {
			IsIslandSelected = props.SelectedIsland ~= nil and props.IsNameVisible ~= false,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = uDim,
			InitialRotation = hasDoubleRing and -25 or -32.5,
			Text = text,
			Repeats = 1,
			FlipText = true,
			GlowColor3 = v.Primary,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Radius = UDim.new(p, 0),
			Padding = uDim3,
			CharacterSize = uDim2,
			RotateCounterClockwise = true,
			HasDoubleRing = hasDoubleRing,
			RotationPeriod = 20,
			ZIndex = 19
		})
	end

	local fragment = React.Fragment
	local v12 = {
		TeleportText = name and textRing(name, 0.22000000000000003),
		TopText = v6 and textRing(v6, 0.18500000000000003),
		BottomText = v7 and textRing(v7, 0.255),
		CoreButton = 0,
		CenterGlowContainer = 0,
		SecondaryCenterGlowContainer = 0,
		SecondaryParticles = 0,
		MagicCircle = 0,
		MagicCircle2 = 0,
		MagicCircle3 = 0
	}
	local onClick = props.OnClick

	if onClick then
		if v2 == 1 then
			onClick = createElement("ImageButton", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.14 * v4, 0.14 * v4),
				ZIndex = 20,
				[React.Change.GuiState] = function(p)
					setState(p.GuiState)
				end,
				[React.Event.Activated] = function(_)
					if props.OnClick then
						props.OnClick()
					end
				end
			})
		else
			onClick = false
		end
	end

	v12.CoreButton = onClick
	local v15 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(0.11 * v4, 0.11 * v4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = CONSTANTS.LAYER.OVERLAY,
		Active = false
	}
	local v16 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Glow = 0
	}
	local color

	if v5 then
		color = v.Text
	else
		color = v.Primary
	end

	v16.Glow = createElement("UIShadow", {
		Color = color,
		BlurRadius = UDim.new(0.5, 0),
		Transparency = state == Enum.GuiState.Hover and 0.35 or state == Enum.GuiState.Press and 0.45 or 0.5 * v2
	})
	v12.CenterGlowContainer = createElement("Frame", v15, v16)
	v12.SecondaryCenterGlowContainer = createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(0.2 * v4 + 0.2 * v2, 0.2 * v4 + 0.2 * v2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Active = false,
		ZIndex = 4
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Glow = createElement("UIShadow", {
			Color = v.Secondary,
			BlurRadius = UDim.new(0.5, 0),
			Transparency = 0.35 + 0.3 * v2
		})
	})
	local v23 = {
		Size = UDim2.fromScale(0.15 * v4, 0.15 * v4),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ParticleTexture = Textures.fx.particles.flame["sparks.png"],
		Lifetime = NumberRange.new(0.75, 1.25),
		Rate = math.round(40 * v2),
		Active = false,
		TimeScale = 0.6,
		Shape = Enum.ParticleEmitterShape.Sphere,
		Enabled = props.IsSolved ~= true,
		ParticleColor = 0,
		ParticleSize = 0,
		ParticleTransparency = 0,
		ZIndex = 0
	}
	local particleColor

	if v5 then
		particleColor = ColorSequence.new(v.Text)
	else
		particleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v.Primary),
			ColorSequenceKeypoint.new(1, v.Secondary)
		})
	end

	v23.ParticleColor = particleColor
	v23.ParticleSize = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2 / v4, 0.5 / v4),
		NumberSequenceKeypoint.new(1, 0)
	})
	v23.ParticleTransparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	v23.ZIndex = CONSTANTS.LAYER.OVERLAY
	v12.SecondaryParticles = createElement(ParticleEmitter, v23)
	v12.MagicCircle = v2 > 0 and createElement(MagicCircle, {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(v9, v9),
		Active = false,
		CornerRadius = UDim.new(0.25, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ImageTransparency = 1 - v2,
		Thickness = 0.01 * (1 + PULSE.CIRCLE_THICKNESS * v8),
		RotationPeriod = 12 - 6 * v3,
		NoGlow = true,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	})
	v12.MagicCircle2 = v2 > 0 and createElement(MagicCircle, {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(v9, v9),
		CornerRadius = UDim.new(0.25, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ImageColor3 = v.Secondary,
		Active = false,
		ImageTransparency = 1 - v2 * 0.7,
		Thickness = 0.01 * (1 + PULSE.CIRCLE_THICKNESS * v8),
		RotationPeriod = 14 - 7 * v3,
		NoGlow = true,
		RotateCounterClockwise = true,
		ZIndex = 6
	})
	local magicCircle

	if v3 > 0 then
		magicCircle = createElement(MagicCircle, {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(v9 * 1.8, v9 * 1.8),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Active = false,
			ImageTransparency = 1 - v3 * (0.35 + 0.45 * v8),
			Thickness = 0.006 * (1 + PULSE.CIRCLE_THICKNESS * v8),
			EdgeThickness = 0.0025,
			BorderOffset = UDim.new(0.05 + 0.03 * v8, 0),
			RotationPeriod = 18,
			NoGlow = true,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		})
	else
		magicCircle = false
	end

	v12.MagicCircle3 = magicCircle
	return createElement(fragment, {}, v12)
end