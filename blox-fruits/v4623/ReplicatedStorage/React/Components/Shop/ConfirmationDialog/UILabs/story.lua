local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local IdMap = require(game.ReplicatedStorage.IdMap)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Product = UILabs.Choose(TableUtil.keys(IdMap.Redeemable), 1)
	}
}, function(p)
	return createElement(parentModule, {
		ItemId = IdMap.Redeemable[p.controls.Product],
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = CONSTANTS.LAYER.RAISED,
		OnBuy = function()
			print("buy")
		end,
		OnGift = function()
			print("gift")
		end,
		OnCancel = function()
			print("cancel")
		end
	})
end)