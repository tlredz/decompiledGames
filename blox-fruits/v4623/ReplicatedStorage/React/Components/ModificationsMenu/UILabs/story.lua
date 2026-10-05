local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IsOpen = true,
		MenuType = UILabs.Choose({
			"AuraSkin",
			"FruitSkin",
			"FruitMutation",
			"SwordSkin"
		}, 2),
		PercentPurchasable = UILabs.Slider(50, 0, 100, 1),
		InitialAdorneeId = "",
		InitialModificationId = ""
	}
}, function(p)
	local menuType = p.controls.MenuType
	local modifications = React.useMemo(function()
		local itemIds = {}

		for _, v2 in ItemConfig.Query.join({
			Index = {
				IdType = "Skin"
			}
		}, {
			Index = {
				IdType = "Mutation"
			}
		}) do
			table.insert(itemIds, v2.Index.ItemId)
		end

		table.sort(itemIds)
		return itemIds
	end, {})
	local purchasable = React.useMemo(function()
		local random = Random.new(123)
		local result = {}

		for _, v3 in modifications do
			if random:NextNumber() <= p.controls.PercentPurchasable / 100 then
				table.insert(result, v3)
			end
		end

		return result
	end, { modifications, p.controls.PercentPurchasable })
	return createElement(React.Fragment, {}, {
		{
			Menu = createElement(parentModule, {
				IsOpen = p.controls.IsOpen,
				Modifications = modifications,
				Equipped = {},
				Purchasable = purchasable,
				InitialAdorneeId = tonumber(p.controls.InitialAdorneeId),
				InitialModificationId = tonumber(p.controls.InitialModificationId),
				MenuType = menuType,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				OnPurchase = function(p2: number)
					print((`onPurchase: {p2}`))
				end,
				OnEquip = function(p2: number, flag: boolean)
					print("onAction", p2, flag)
				end,
				OnExit = function()
					print("exit")
				end
			})
		}
	})
end)