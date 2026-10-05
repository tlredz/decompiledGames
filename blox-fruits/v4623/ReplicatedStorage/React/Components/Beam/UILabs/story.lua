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
	["Flame Wind"] = Textures.fx.beam.flame["wind.png"],
	["Lightning Main"] = Textures.fx.beam.lightning["main-1.png"],
	["Lightning Main Alt"] = Textures.fx.beam.lightning["main-2.png"],
	["Lightning Trail"] = Textures.fx.beam.lightning["trail-1.png"],
	["Lightning Trail Alt"] = Textures.fx.beam.lightning["trail-2.png"],
	["Flame Detail"] = Textures.fx.particles.flame["detail.png"],
	["Flame Lines"] = Textures.fx.particles.flame["lines.png"]
}
local v2 = {
	Stretch = Enum.TextureMode.Stretch,
	Wrap = Enum.TextureMode.Wrap,
	Static = Enum.TextureMode.Static
}
local v3 = {
	Vertical = Enum.Axis.Y,
	Horizontal = Enum.Axis.X
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Texture = UILabs.EnumList(v, "Flame Wind"),
		Axis = UILabs.EnumList(v3, "Vertical"),
		TextureMode = UILabs.EnumList(v2, "Stretch"),
		TextureLength = UILabs.Slider(2, 0.25, 12, 0.25),
		TextureSpeed = UILabs.Slider(2, -8, 8, 0.25),
		Width = UILabs.Slider(0.3, 0.02, 1, 0.02),
		Length = UILabs.Slider(1, 0.1, 1, 0.05),
		Rotation = UILabs.Slider(0, -180, 180, 5)
	}
}, function(p)
	local controls = p.controls
	local uDim

	if controls.Axis == Enum.Axis.X then
		uDim = UDim2.fromScale(controls.Length, controls.Width)
	else
		uDim = UDim2.fromScale(controls.Width, controls.Length)
	end

	return createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(18, 18, 24),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}, {
		Bounds = controls.ShowBounds and createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(38, 38, 48),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = uDim,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Rotation = controls.Rotation,
			ZIndex = CONSTANTS.LAYER.BASE
		}),
		Beam = createElement(parentModule, {
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = uDim,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Rotation = controls.Rotation,
			ZIndex = CONSTANTS.LAYER.CONTENT,
			Axis = controls.Axis,
			Texture = controls.Texture,
			TextureMode = controls.TextureMode,
			TextureLength = controls.TextureLength,
			TextureSpeed = controls.TextureSpeed
		})
	})
end)