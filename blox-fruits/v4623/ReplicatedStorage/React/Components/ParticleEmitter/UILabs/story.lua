local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Textures = require(game.ReplicatedStorage.Textures)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	["Flame Main"] = Textures.fx.particles.flame["main.png"],
	["Flame Crescent"] = Textures.fx.particles.flame["crescent.png"],
	["Flame Flare"] = Textures.fx.particles.flame["flare.png"],
	["Flame Shards"] = Textures.fx.particles.flame["shards.png"],
	["Flame Sparks"] = Textures.fx.particles.flame["sparks.png"],
	["Flame Specs"] = Textures.fx.particles.flame["specs.png"],
	["Lightning Dots"] = Textures.fx.particles.lightning["dots.png"],
	["Lightning Dust"] = Textures.fx.particles.lightning["dust.png"]
}
local v2 = {
	Box = Enum.ParticleEmitterShape.Box,
	Sphere = Enum.ParticleEmitterShape.Sphere,
	Cylinder = Enum.ParticleEmitterShape.Cylinder,
	Disc = Enum.ParticleEmitterShape.Disc
}
local v3 = {
	Volume = Enum.ParticleEmitterShapeStyle.Volume,
	Surface = Enum.ParticleEmitterShapeStyle.Surface
}
local v4 = {
	Outward = Enum.ParticleEmitterShapeInOut.Outward,
	Inward = Enum.ParticleEmitterShapeInOut.Inward,
	InAndOut = Enum.ParticleEmitterShapeInOut.InAndOut
}
local v5 = {
	Top = Enum.NormalId.Top,
	Bottom = Enum.NormalId.Bottom,
	Left = Enum.NormalId.Left,
	Right = Enum.NormalId.Right,
	Front = Enum.NormalId.Front,
	Back = Enum.NormalId.Back
}
local v6 = {
	FacingCamera = Enum.ParticleOrientation.FacingCamera,
	FacingCameraWorldUp = Enum.ParticleOrientation.FacingCameraWorldUp,
	VelocityParallel = Enum.ParticleOrientation.VelocityParallel,
	VelocityPerpendicular = Enum.ParticleOrientation.VelocityPerpendicular
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Enabled = true,
		ParticleTexture = UILabs.EnumList(v, "Flame Main"),
		Rate = UILabs.Slider(30, 0, 200, 1),
		LifetimeMin = UILabs.Slider(1, 0.1, 8, 0.1),
		LifetimeMax = UILabs.Slider(2, 0.1, 8, 0.1),
		SpeedMin = UILabs.Slider(0.3, 0, 3, 0.05),
		SpeedMax = UILabs.Slider(0.6, 0, 3, 0.05),
		SpreadAngle = UILabs.Slider(25, 0, 180, 5),
		SizeStart = UILabs.Slider(0.12, 0, 1, 0.01),
		SizeFinish = UILabs.Slider(0, 0, 1, 0.01),
		RotSpeed = UILabs.Slider(60, 0, 720, 15),
		Squash = UILabs.Slider(0, -2, 2, 0.1),
		Drag = UILabs.Slider(0.5, 0, 10, 0.1),
		AccelerationY = UILabs.Slider(-0.4, -4, 4, 0.1),
		TimeScale = UILabs.Slider(1, 0, 3, 0.1),
		ShapePartial = UILabs.Slider(0, 0, 1, 0.05),
		Shape = UILabs.EnumList(v2, "Box"),
		ShapeStyle = UILabs.EnumList(v3, "Volume"),
		ShapeInOut = UILabs.EnumList(v4, "Outward"),
		EmissionDirection = UILabs.EnumList(v5, "Top"),
		Orientation = UILabs.EnumList(v6, "FacingCamera")
	}
}, function(p)
	local controls = p.controls
	return createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(18, 18, 24),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.4, 0.4),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		Emitter = createElement(parentModule, {
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ParticleTexture = controls.ParticleTexture,
			ParticleSize = NumberSequence.new({
				NumberSequenceKeypoint.new(0, controls.SizeStart),
				NumberSequenceKeypoint.new(1, controls.SizeFinish)
			}),
			ParticleTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.15, 0),
				NumberSequenceKeypoint.new(0.7, 0.2),
				NumberSequenceKeypoint.new(1, 1)
			}),
			ParticleColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 236, 150)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 122, 51)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(122, 27, 27))
			}),
			Enabled = controls.Enabled,
			Rate = controls.Rate,
			Lifetime = NumberRange.new(
				math.min(controls.LifetimeMin, controls.LifetimeMax),
				(math.max(controls.LifetimeMin, controls.LifetimeMax))
			),
			Speed = NumberRange.new(
				math.min(controls.SpeedMin, controls.SpeedMax),
				(math.max(controls.SpeedMin, controls.SpeedMax))
			),
			SpreadAngle = NumberRange.new(-controls.SpreadAngle, controls.SpreadAngle),
			ParticleRotation = NumberRange.new(-180, 180),
			RotSpeed = NumberRange.new(-controls.RotSpeed, controls.RotSpeed),
			Squash = controls.Squash,
			Drag = controls.Drag,
			Acceleration = Vector2.new(0, controls.AccelerationY),
			TimeScale = controls.TimeScale,
			ShapePartial = controls.ShapePartial,
			Shape = controls.Shape,
			ShapeStyle = controls.ShapeStyle,
			ShapeInOut = controls.ShapeInOut,
			EmissionDirection = controls.EmissionDirection,
			Orientation = controls.Orientation
		})
	})
end)