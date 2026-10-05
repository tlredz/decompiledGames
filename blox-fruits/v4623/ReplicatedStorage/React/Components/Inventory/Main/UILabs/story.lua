local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local Types = require(game.ReplicatedStorage.React.Components.Inventory.Types)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
local parentModule = require(script.Parent)
local enumItems = PseudoEnum.getEnumItems("InventoryItemGroup")
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		TileCount = UILabs.Slider(150, 0, 500, 1),
		Group = UILabs.Choose(enumItems, 1)
	}
}, function(p)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(p.controls.Group)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(PseudoEnum.InventorySortType.Rarity)
	React.useEffect(function()
		setState2(p.controls.Group)
	end, { p.controls.Group })
	local tiles = React.useMemo(function()
		local result = {}

		for _, idType in ItemId.getTypes():unwrap() do
			for _, v3 in ItemConfig.Query.select({
				Index = {
					IdType = idType
				}
			}) do
				local itemId = v3.Index.ItemId

				if ItemId.getDataFromId(itemId):isErr() then
					continue
				end

				local v4 = {
					ItemId = itemId
				}
				TableUtil.deepFreeze(v4)
				assert(Types.Types.Tile.check(v4))
				table.insert(result, v4)
			end
		end

		table.freeze(result)
		return result
	end, {})
	return createElement(Navigation.Provider, {
		value = {
			Group = state2,
			Bracket = state3,
			SortType = state4,
			InitialSelection = nil,
			SetNavigation = function(p2, p3, p4, _)
				if state2 ~= p2 then
					setState2(p2)
				end

				if state3 ~= p3 then
					setState3(p3)
				end

				if state4 ~= p4 then
					setState4(p4)
				end
			end
		}
	}, {
		ItemSelection = createElement(ItemSelection.Provider, {
			value = {
				Selection = state,
				SetSelection = function(itemId: number?, networkedUID: string?)
					if itemId == nil then
						setState(nil)
					else
						setState((table.freeze({
							ItemId = itemId,
							NetworkedUID = networkedUID
						})))
					end
				end
			}
		}, {
			Main = createElement(parentModule, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Tiles = tiles,
				OnExit = function()
					print("exit")
				end,
				OnStashPurchaseClick = function()
					print("stash purchase")
				end
			})
		})
	})
end)