local Global = require(game.ReplicatedFirst.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local ReactRoblox = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("ReactRoblox"))
local UILabs = require(ReplicatedFirst:WaitForChild("DevPackages"):WaitForChild("UILabs"))
local parentModule = require(script.Parent)
local TEXTURES = require(script.Parent.Parent.Parent.TEXTURES)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IconKey = UILabs.Choose({ "SAIL_BOAT_1", "SAIL_BOAT_2", "SAIL_BOAT_3" }),
		BobMax = UILabs.Number(0.1, 0, 0.5, nil, true),
		BobPeriod = UILabs.Number(1, 0.5, 20, 0.5, true),
		DriftMax = UILabs.Number(0.1, 0, 0.5, nil, true),
		DriftPeriod = UILabs.Number(1, 0.5, 20, 0.5, true),
		TiltMax = UILabs.Number(15, 0, 45, 0.5, true),
		TiltPeriod = UILabs.Number(1, 0.5, 20, 0.5, true)
	}
}, function(p)
	return createElement(parentModule, {
		Image = TEXTURES.IMAGES[p.controls.IconKey],
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
		DriftPeriod = p.controls.DriftPeriod,
		MaxDrift = p.controls.DriftMax,
		BobPeriod = p.controls.BobPeriod,
		MaxBob = p.controls.BobMax,
		TiltPeriod = p.controls.TiltPeriod,
		MaxTilt = p.controls.TiltMax
	})
end)