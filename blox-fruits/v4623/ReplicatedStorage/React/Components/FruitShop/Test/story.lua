local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
require(script.Parent.Types)
local createElement = React.createElement

function shop(p)
	local fruits = p.Fruits
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(table.freeze({}))
	local state3, _ = React.useState(table.freeze({}))
	return createElement(parentModule, {
		Size = UDim2.fromScale(1, 1),
		IsControllerActive = true,
		IsVisible = true,
		Fruits = fruits,
		Owned = state2,
		Equipped = state,
		Locked = state3,
		InputType = "Gamepad",
		OnExitClick = function()
			print("exit click")
		end,
		OnMutationClick = function() end,
		OnDragonSwapClick = function()
			print("swap click")
		end,
		OnCardClick = function(_, flag: boolean)
			print("card click", flag)
		end,
		OnPermPurchaseClick = function(p2)
			print((`permanently purchased {p2.Name}`))

			if table.find(state2, p2) then
				setState(p2)
				return
			end

			local clone = table.clone(state2)
			table.insert(clone, p2)
			table.freeze(clone)
			setState2(clone)
		end,
		OnTempPurchaseClick = function(p2)
			setState(p2)
			print((`temp purchased {p2.Name}`))
		end,
		OnGiftClick = function(p2)
			print((`on gift click purchased {p2.Name}`))
		end,
		OnEggClick = function()
			print("egg click")
		end,
		FruitReleaseDate = DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp + 31536000)
	}, {})
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	local thread = task.spawn(function()
		local Data = require(game.ReplicatedStorage.Controllers.UI.FruitShop.Data)
		local fruits = {}

		for _, v2 in Data do
			table.insert(fruits, v2)
		end

		root:render((ReactRoblox.createPortal(createElement(shop, {
			Fruits = fruits
		}), p)))
	end)
	return function()
		print("Shop clean up")
		root:unmount()
		task.cancel(thread)
	end
end