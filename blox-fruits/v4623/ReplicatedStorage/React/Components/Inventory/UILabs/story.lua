local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
require(game.ReplicatedStorage.PseudoEnum)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local Types = require(script.Parent.Types)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local parentModule = require(script.Parent)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IsOpen = true
	}
}, function(p)
	local state, setState = React.useState(nil)
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
	return createElement(ItemSelection.Provider, {
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
		Inventory = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			IsOpen = p.controls.IsOpen,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Tiles = tiles,
			OnAction = function(p2)
				print("action", p2)
			end,
			OnExit = function()
				print("exit")
			end,
			OnExitComplete = function()
				print("exit complete")
			end
		})
	})
end)