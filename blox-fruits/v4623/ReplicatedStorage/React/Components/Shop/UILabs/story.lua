local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		GiftCount = UILabs.Slider(0, 0, 99, 1)
	}
}, function(p)
	useMockStateWriter("GiftCount", p.controls.GiftCount)
	local state, setState = React.useState(nil)
	return createElement(parentModule, {
		SelectedItemId = state,
		OnInteraction = function(p2)
			print(`Received "{p2.Type}" interaction`, p2)

			if p2.Type == "Select" or p2.Type == "GiftProduct" or p2.Type == "PurchaseProduct" then
				setState(p2.ItemId)
			else
				setState(nil)
			end
		end
	})
end)