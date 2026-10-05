local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local Textures = require(game.ReplicatedStorage.Textures)
local Audio = require(game.ReplicatedStorage.Audio)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local IslandTile = require(game.ReplicatedStorage.React.Components.IslandTile)
local Beam = require(game.ReplicatedStorage.React.Components.Beam)
local ParticleEmitter = require(game.ReplicatedStorage.React.Components.ParticleEmitter)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Animation.useKeyFrames)
local useSpringMap = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringMap)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Definitions.Map.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v, v2 = useKeyFrames({
		{
			Duration = 0.5,
			Id = "OffscreenReset"
		},
		{
			Duration = 0.75,
			Id = "OffscreenStart"
		},
		{
			Duration = 3.75,
			Id = "StarAnimation"
		},
		{
			Duration = 2,
			Id = "MedalAscend"
		},
		{
			Duration = 4,
			Id = "Medal"
		},
		{
			Duration = 1.25,
			Id = "MedalReset"
		},
		{
			Duration = 0.75,
			Id = "OffscreenEnd"
		},
		{
			Duration = 0.5,
			Id = "OffscreenReset"
		}
	}, props.IsPlaying, props.IsLooping)
	React.useEffect(function()
		if v ~= "OffscreenStart" then
			return function() end
		end

		local sound = Instance.new("Sound")
		sound.SoundId = Audio.fx.ui["island-completion-build-up.ogg"]
		SoundService:PlayLocalSound(sound)
		return function()
			sound:Destroy()
		end
	end, { v })
	local v3 = useSpringMap("OffscreenReset", v, 0.6, 0.6, {
		OffscreenEnd = 1.5,
		MedalAscend = 0.4,
		Medal = 0.4
	}, 0.5)
	local backgroundTransparency = useSpringMap("OffscreenReset", v, 0.8, 0.35, {
		OffscreenEnd = 1,
		OffscreenReset = 1
	}, 0.4)
	local v5 = useSpringMap("OffscreenReset", v, 0.4, 0.35, {
		Medal = 0.25,
		MedalAscend = 0.25,
		MedalReset = 0.25,
		StarAnimation = 0.4
	}, 0.5)
	local v6 = useSpringMap("OffscreenReset", v, 0.75, 0.85, {
		OffscreenEnd = 0.4,
		StarAnimation = 0.7,
		MedalAscend = 0.65,
		Medal = 0.65,
		MedalReset = 0.5
	}, 0.6) * 0.8
	local v7 = useSpringMap("OffscreenReset", v, 0.75, 0.85, {
		OffscreenStart = 0,
		StarAnimation = 0,
		MedalAscend = 0,
		Medal = 0
	}, 1)
	local v8 = useSpringMap("OffscreenReset", v, 0.75, 0.85, {
		OffscreenStart = 0.2
	}, 1)
	local v9 = useSpringMap("OffscreenReset", v, 0.45, 0.85, {
		OffscreenStart = 0.6,
		StarAnimation = 1,
		MedalAscend = 0.4,
		Medal = 0.4
	}, 0)
	local v10 = useSpringMap("OffscreenReset", v, 0.45, 0.85, {
		MedalAscend = 0.1,
		Medal = 0.1,
		OffscreenEnd = 0.1,
		MedalReset = 0,
		OffscreenReset = 0
	}, 1)
	local numberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v8, 0),
		NumberSequenceKeypoint.new(0.5, v7, 0),
		NumberSequenceKeypoint.new(1, v8, 0)
	})
	local v11 = useSpringMap("OffscreenReset", v, 0.7, 0.85, {
		MedalReset = 0.6,
		MedalAscend = 1,
		Medal = 1
	}, 0)
	local v12 = useSpringMap("OffscreenReset", v, 0.7, 0.85, {
		Medal = 0,
		MedalAscend = 0
	}, 1)
	local v13 = useSpringMap("OffscreenReset", v, 0.9, 0.8, {
		Medal = 1
	}, 0)
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local v19 = {
		Active = true,
		ZIndex = CONSTANTS.LAYER.CONTENT,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = backgroundTransparency
	}
	local v20 = {
		HorizontalBeam = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.27),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.CONTENT,
			ClipsDescendants = true
		}, {
			HorizontalHypeBeam1 = createElement(Beam, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(v10, 0.175 * v9),
				Axis = Enum.Axis.X,
				TextureLength = 0.5,
				TextureSpeed = 2.25,
				TextureMode = Enum.TextureMode.Stretch,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Texture = Textures.fx.beam.lightning["trail-3.png"],
				ZIndex = CONSTANTS.LAYER.CONTENT
			}, {
				UIGradient = createElement("UIGradient", {
					Rotation = 0,
					Transparency = numberSequence,
					Color = ColorSequence.new(Color3.new(1, 0.32549, 0.32549))
				})
			}),
			HorizontalHypeBeam2 = createElement(Beam, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(v10, 0.275 * v9),
				Axis = Enum.Axis.X,
				TextureLength = 0.66,
				TextureSpeed = -1.5,
				TextureMode = Enum.TextureMode.Stretch,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Texture = Textures.fx.beam.lightning["trail-3.png"],
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIGradient = createElement("UIGradient", {
					Rotation = 0,
					Transparency = numberSequence,
					Color = ColorSequence.new(Color3.new(1, 0.784314, 0.784314))
				})
			})
		}),
		VerticalHypeBeam1 = 0
	}
	local verticalHypeBeam

	if v11 > 0 and v12 < 1 then
		verticalHypeBeam = createElement(Beam, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.25 * v11, 0.6),
			Axis = Enum.Axis.Y,
			TextureLength = 0.75,
			TextureSpeed = 3,
			TextureMode = Enum.TextureMode.Stretch,
			Texture = Textures.fx.beam.lightning["trail-3.png"],
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, v12),
					NumberSequenceKeypoint.new(0.6, v12),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	else
		verticalHypeBeam = false
	end

	v20.VerticalHypeBeam1 = verticalHypeBeam
	local v16 = {
		Scrim = createElement("Frame", v19, v20),
		Island = 0,
		Labels = 0
	}
	local island

	if v == "OffscreenReset" then
		island = false
	else
		local v25 = {
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
			Position = 0,
			AnchorPoint = 0,
			Size = 0,
			SizeConstraint = 0,
			Island = 0,
			IconMode = 0,
			IsGlowEnabled = false,
			IsRecommended = false,
			IsLocked = false,
			Level = nil,
			Stars = nil,
			StarsFilled = nil,
			OnClick = nil
		}
		local position

		if v == "OffscreenStart" then
			position = UDim2.fromScale(
				1.5 - TweenService:GetValue(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				v3
			)
		else
			position = UDim2.fromScale(0.5, v3)
		end

		v25.Position = position
		v25.AnchorPoint = Vector2.new(0.5, v5)
		v25.Size = UDim2.fromScale(0.5, v6)
		v25.SizeConstraint = Enum.SizeConstraint.RelativeYY
		v25.Island = props.Island
		v25.IconMode = v == "OffscreenStart" and "Default" or "Completed"
		island = createElement(IslandTile, v25)
	end

	v16.Island = island
	local labels

	if v == "OffscreenReset" then
		labels = false
	else
		local fragment = React.Fragment
		local textGlow

		if v == "OffscreenEnd" or v == "Medal" then
			textGlow = createElement("ImageLabel", {
				Size = UDim2.fromScale(0.95, 0.4),
				Position = UDim2.fromScale(0.5, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = SpriteMap.UI.Shadow.Image,
				ImageRectOffset = SpriteMap.UI.Shadow.ImageRectOffset,
				ImageRectSize = SpriteMap.UI.Shadow.ImageRectSize,
				Active = false,
				ImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ImageTransparency = 1 - v13 * 0.5,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				ParticleEmitter = createElement(ParticleEmitter, {
					Size = UDim2.fromScale(0.8, 0.8),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ParticleTexture = Textures.fx.particles.flame["sparks.png"],
					Lifetime = NumberRange.new(0.75, 1.25),
					Rate = math.ceil(20 * v13),
					Shape = Enum.ParticleEmitterShape.Sphere,
					Enabled = v13 > 0,
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
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				})
			})
		else
			textGlow = false
		end

		labels = createElement(fragment, {}, {
			TextGlow = textGlow,
			IslandLabelContainer = createElement("Frame", {
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.765),
				Size = UDim2.fromScale(0.8, 0.15 * v13),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ClipsDescendants = true
			}, {
				Label = createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.125),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextScaled = true,
					TextTransparency = 1 - v13,
					Text = (props.Island.Display.Name or props.Island.Index.Key):upper(),
					TextSize = 64,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Transparency = 1 - v13,
						Color = CONSTANTS.COLOR.PALETTE.BLACK
					})
				})
			}),
			CompletionContainer = createElement("Frame", {
				ZIndex = 4,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.85),
				Size = UDim2.fromScale(0.75, 0.15 * v13),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ClipsDescendants = true
			}, {
				Label = createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.2),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextTransparency = 1 - v13,
					TextScaled = true,
					Text = "COMPLETED",
					TextSize = 64,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Transparency = 1 - v13,
						Color = CONSTANTS.COLOR.PALETTE.BLACK
					})
				})
			})
		})
	end

	v16.Labels = labels
	return createElement("Frame", mergeFrame, v16)
end