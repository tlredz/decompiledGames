local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Level = UILabs.Slider(700, 0, 700, 25),
		Attempt = UILabs.Slider(1, 1, 99, 1),
		IsOpen = true,
		IsDebug = true
	}
}, function(p)
	useMockStateWriter("Level", p.controls.Level)
	local v = {
		[`Attempt{p.controls.Attempt}`] = createElement(parentModule, {
			IsOpen = p.controls.IsOpen,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			OnSelect = function(p2)
				print((`teleport requested: {p2.Display.Name or p2.Index.Key}`))
			end,
			OnPuzzleComplete = function()
				print((`puzzle complete on attempt {p.controls.Attempt}`))
			end,
			OnCelebrationComplete = function()
				print((`celebration complete on attempt {p.controls.Attempt}`))
			end
		})
	}
	return createElement(React.Fragment, {}, v)
end)