local React = require(game.ReplicatedStorage.Packages.React)
local Textures = require(game.ReplicatedStorage.Textures)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Beam = require(game.ReplicatedStorage.React.Components.Beam)
local ParticleEmitter = require(game.ReplicatedStorage.React.Components.ParticleEmitter)
local Dance = require(script.Dance)
local Medal = require(script.Medal)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Animation.useKeyFrames)
local useSpringMap = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringMap)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local PULSE = CONSTANTS2.CELEBRATION.PULSE
local PALETTE = CONSTANTS.COLOR.PALETTE
local v = {
	{
		Duration = 0.05,
		Id = "Idle"
	},
	{
		Duration = 0.45,
		Id = "Slash"
	},
	{
		Duration = 0.55,
		Id = "Title"
	},
	{
		Duration = 0.6,
		Id = "Subtitle"
	},
	{
		Duration = CONSTANTS2.CELEBRATION.HOLD_DURATION,
		Id = "Hold"
	},
	{
		Duration = 600,
		Id = "Done"
	}
}
local v2 = {
	Slash = 0.8,
	Title = 0.6,
	Subtitle = 0.45,
	Hold = 0.4,
	Done = 0.4
}
local v3 = {
	Slash = 1.3,
	Title = 1.05,
	Subtitle = 1,
	Hold = 1,
	Done = 1
}
local v4 = {
	Slash = 1,
	Title = 1,
	Subtitle = 0.7,
	Hold = 0.55,
	Done = 0.55
}
local v5 = {
	Title = 1,
	Subtitle = 1,
	Hold = 0.85,
	Done = 0.85
}
local v6 = {
	Title = 1,
	Subtitle = 1,
	Hold = 1,
	Done = 1
}
local v7 = {
	Title = 1,
	Subtitle = 1,
	Hold = 1,
	Done = 1
}
local v8 = {
	Title = 0,
	Subtitle = 0,
	Hold = 0,
	Done = 0
}
local v9 = {
	Subtitle = 1,
	Hold = 1,
	Done = 1
}
local v10 = {
	Subtitle = 1,
	Hold = 1,
	Done = 1
}
local trail3png = Textures.fx.beam.lightning["trail-3.png"]
local sparkspng = Textures.fx.particles.flame["sparks.png"]
local createElement = React.createElement

local function spaceOut(value: string)
	return table.concat(value:split(""), " ")
end

local function useMotion(p: string)
	return {
		BeamWidth = useSpringMap("Idle", p, 0.55, 1.4, v2, 0),
		BeamLength = useSpringMap("Idle", p, 0.7, 1.2, v3, 0),
		VerticalBeam = useSpringMap("Idle", p, 0.7, 1.1, v4, 0),
		GlowAlpha = useSpringMap("Idle", p, 0.8, 1, v5, 0),
		TitleAlpha = useSpringMap("Idle", p, 0.9, 1.6, v6, 0),
		TitleScale = useSpringMap("Idle", p, 0.45, 1.6, v7, 1.9),
		TitleRotation = useSpringMap("Idle", p, 0.55, 1.3, v8, -7),
		SubtitleAlpha = useSpringMap("Idle", p, 0.85, 1.2, v9, 0),
		MedalAlpha = useSpringMap("Idle", p, 0.5, 1.3, v10, 0)
	}
end

local function beam(p, p2: number, textureLength: number, textureSpeed: number, color: Color3, zIndex: number)
	local v11 = 1 - math.clamp(p.BeamWidth, 0, 1) * 0.85
	return createElement(Beam, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(p.BeamLength, p2 * p.BeamWidth),
		Axis = Enum.Axis.X,
		TextureLength = textureLength,
		TextureSpeed = textureSpeed,
		TextureMode = Enum.TextureMode.Stretch,
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Texture = trail3png,
		ZIndex = zIndex
	}, {
		UIGradient = createElement("UIGradient", {
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, v11),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, v11)
			}),
			Color = ColorSequence.new(color)
		})
	})
end

return function(props)
	local v11 = useTheme()
	local v12, v13 = useKeyFrames(v, props.IsPlaying)
	local v14 = useMotion(v12)
	local pulse = props.Pulse
	local v15 = v12 ~= "Title" and 0 or (1 - v13) ^ 2
	local collapse = props.Collapse or 0
	local onHoldComplete = props.OnHoldComplete
	React.useEffect(function()
		if v12 == "Done" and onHoldComplete then
			onHoldComplete()
		end
	end, { v12 == "Done" })

	if not props.IsPlaying then
		return nil
	end

	local mergeCanvasGroup = RobloxTypes.mergeCanvasGroup({
		ref = props.GroupRef,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		Rotation = (props.Rotation or 0) + CONSTANTS2.COLLAPSE.SPIN * collapse
	}, props)
	local children = {
		UIScale = createElement("UIScale", {
			Scale = math.max(1 - collapse, 0)
		}),
		Flash = v15 > 0 and createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = PALETTE.WHITE,
			BackgroundTransparency = 1 - v15,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ZIndex = CONSTANTS.LAYER.OVERLAY + 1
		}),
		Beams = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ClipsDescendants = true,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			Back = beam(v14, 0.405, 0.5, 2.5, v11.Secondary, CONSTANTS.LAYER.CONTENT),
			Front = beam(v14, 0.243, 0.66, -1.75, PALETTE.WHITE, CONSTANTS.LAYER.RAISED)
		}),
		Dance = createElement(Dance, {
			IsPlaying = props.IsPlaying == true,
			Pulse = pulse,
			Islands = props.Islands,
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Medal = v14.MedalAlpha > 0 and createElement(Medal, {
			Alpha = v14.MedalAlpha,
			Pulse = pulse,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.225, 0.225),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}),
		Shadow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.47),
			Size = UDim2.fromScale(1.5, 0.75),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = SpriteMap.UI.Shadow.Image,
			ImageRectOffset = SpriteMap.UI.Shadow.ImageRectOffset,
			ImageRectSize = SpriteMap.UI.Shadow.ImageRectSize,
			ImageColor3 = PALETTE.WHITE,
			ImageTransparency = 1 - v14.GlowAlpha * (0.45 + 0.4 * pulse),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Active = false,
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Sparks = createElement(ParticleEmitter, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.24),
			ParticleTexture = sparkspng,
			Lifetime = NumberRange.new(0.6, 1.2),
			Rate = math.round(v14.TitleAlpha * (25 + PULSE.SPARK_RATE * pulse)),
			Shape = Enum.ParticleEmitterShape.Sphere,
			Enabled = v14.TitleAlpha > 0,
			ParticleColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PALETTE.WHITE),
				ColorSequenceKeypoint.new(1, v11.Secondary)
			}),
			ParticleSize = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.1, 0.25),
				NumberSequenceKeypoint.new(1, 0)
			}),
			ParticleTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.1, 0),
				NumberSequenceKeypoint.new(1, 1)
			}),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}),
		Title = 0,
		Subtitle = 0
	}
	local v21 = {
		AnchorPoint = Vector2.new(0.5, v14.SubtitleAlpha * 0.5 + 0.5),
		Position = UDim2.fromScale(0.5, 0.5 - v14.SubtitleAlpha * 0.1),
		Size = UDim2.fromScale(0.9, 0.24),
		Rotation = v14.TitleRotation,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}
	local v22 = {
		UIScale = createElement("UIScale", {
			Scale = v14.TitleScale * (1 + PULSE.TITLE_SCALE * pulse)
		}),
		Label = 0
	}
	local v24 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Text = 0,
		TextScaled = true,
		TextColor3 = 0,
		TextTransparency = 0,
		ZIndex = 0
	}
	local title = props.Title
	v24.Text = table.concat(title:split(""), " ")
	v24.TextColor3 = PALETTE.WHITE
	v24.TextTransparency = 1 - v14.TitleAlpha
	v24.ZIndex = CONSTANTS.LAYER.OVERLAY
	v22.Label = createElement("TextLabel", v24, {
		UIStroke = createElement("UIStroke", {
			Thickness = 6,
			Color = PALETTE.BLACK,
			Transparency = 1 - v14.TitleAlpha
		}),
		UIGradient = createElement("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PALETTE.WHITE),
				ColorSequenceKeypoint.new(0.55, PALETTE.WHITE),
				ColorSequenceKeypoint.new(1, PALETTE.GOLD_400)
			})
		})
	})
	children.Title = createElement("Frame", v21, v22)
	local v26 = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.575),
		Size = UDim2.fromScale(1, v14.SubtitleAlpha * 0.2),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}
	local v27 = {
		UIScale = createElement("UIScale", {
			Scale = v14.TitleScale * (1 + PULSE.TITLE_SCALE * pulse)
		}),
		Label = 0
	}
	local v29 = {
		Size = UDim2.fromScale(1, 0.3),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Text = 0,
		TextScaled = true,
		TextColor3 = 0,
		TextTransparency = 0
	}
	local subtitle = props.Subtitle
	v29.Text = table.concat(subtitle:split(""), " ")
	v29.TextColor3 = PALETTE.WHITE
	v29.TextTransparency = 1 - v14.SubtitleAlpha
	v27.Label = createElement("TextLabel", v29, {
		UIStroke = createElement("UIStroke", {
			Thickness = 6,
			Color = PALETTE.BLACK,
			Transparency = 1 - v14.SubtitleAlpha
		})
	})
	children.Subtitle = createElement("Frame", v26, v27)
	return createElement("CanvasGroup", mergeCanvasGroup, children)
end