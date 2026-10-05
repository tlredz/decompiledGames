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
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local enumItems = PseudoEnum.getEnumItems("InventoryItemGroup")
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		WidthPx = UILabs.Slider(420, 160, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(36, 12, 120, 1),
		Group = UILabs.Choose(enumItems, 1),
		IsMoving = false
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
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
				local v4 = {
					ItemId = v3.Index.ItemId
				}
				TableUtil.deepFreeze(v4)
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
		Panel = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(widthPx, (math.round(heightPx * 5)))
		}, {
			ToolBar = createElement(parentModule, {
				AnchorPoint = Vector2.new(0.5, 0),
				IsMoving = p.controls.IsMoving,
				Position = UDim2.fromScale(0.5, 0),
				SearchText = state,
				Size = UDim2.new(1, 0, 0, heightPx),
				Tiles = tiles,
				OnSearch = function(p2: string?)
					setState(p2)
				end,
				OnSearchFocusChanged = function(flag: boolean)
					print("search focus", flag)
				end
			})
		})
	})
end)