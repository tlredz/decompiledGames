local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Premium = require(game.ReplicatedStorage.React.Components.Gacha.Windows.MagnetEvent26.Premium)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Visible = UILabs.Boolean(true),
		HeaderHidden = UILabs.Boolean(false)
	}
}, function(p)
	local state, setState = React.useState(nil)
	return createElement(Premium, {
		Size = UDim2.fromScale(1, 1),
		Selected = state,
		HeaderHidden = p.controls.HeaderHidden,
		Visible = p.controls.Visible,
		PreviewFrameEffect = function(p2: number)
			print("PreviewFrameEffect", p2)
		end,
		OnPurchase = function(p2: number)
			print((`OnPurchase={p2}`))
		end,
		OnClose = function()
			print("close")
		end,
		SelectItem = function(p2: number)
			setState(p2)
			print("select", p2)
		end
	})
end)