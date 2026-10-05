local React = require(game.ReplicatedStorage.Packages.React)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local IdMap = require(game.ReplicatedStorage.IdMap)
local Inventory = require(game.ReplicatedStorage.React.Components.Inventory)
local Config = require(game.ReplicatedStorage.React.Contexts.Inventory.Config)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local useScreenSize = require(game.ReplicatedStorage.React.Hooks.useScreenSize)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useData)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
local useOscillation = require(game.ReplicatedStorage.React.Hooks.Animation.useOscillation)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local ItemReplicationOverrideProvider = require(game.ReplicatedStorage.React.Components.ItemReplicationOverrideProvider)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("UI"):tag("React"):traceback():display():build()
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v2 = { IdMap.Skin.YETISKINfiend, IdMap.Skin.TIGERSKINwerewolf }
local createElement = React.createElement

function getMods(p: string, p2: number?)
	local result = {}

	if p == "FruitSkin" or p == "FruitMutation" then
		if p2 then
			for _, v3 in ItemConfig.map(Modification.getAllModifications(p2, "Mutation")) do
				table.insert(result, v3)
			end
		end

		for _, v3 in ItemConfig.Query.select({
			Variant = {
				VariantOf = p2,
				Mutation = {
					Operation = "NEQ",
					Value = nil
				}
			}
		}) do
			local mutation = v3.Variant and v3.Variant.Mutation

			if mutation then
				table.insert(result, ItemConfig.match(mutation):unwrap())
			end
		end
	end

	if p == "FruitSkin" or p == "SwordSkin" or p == "AuraSkin" then
		for _, v3 in ItemConfig.Query.select(p == "FruitSkin" and {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Type = "Fruit",
				Adornee = p2
			}
		} or p == "SwordSkin" and {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Type = "Sword",
				Adornee = p2
			}
		} or p == "AuraSkin" and {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Type = "Aura",
				Adornee = p2
			}
		} or {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Adornee = p2
			}
		}) do
			table.insert(result, v3)
		end
	end

	return result
end

function scrim(p)
	local v3 = useScreenSize()
	local v4 = useSpring(0, p.IsOpen and 1 or 0, 0.8, 1.2)
	local v5 = useSpring(0, p.IsOpen and 1 or 0, 0.6, 0.5)
	local v6 = useSpring(0, p.IsOpen and 1 or 0, 1, 3)
	local v7 = useOscillation(v5 > 0.05, 3)
	return createElement("Frame", {
		BackgroundTransparency = 1 - v4 * 0.7,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(v3.X * 2, v3.Y * 2),
		ZIndex = p.ZIndex
	}, {
		Glow = createElement("ImageLabel", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.525),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://111285502935012",
			ImageColor3 = Color3.fromRGB(255, 200, 0),
			ImageTransparency = 1 - v5 * 0.3 - v7 * 0.05,
			Position = UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, 1.25), 1 - v6),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(0.45, 0.35),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			SliceCenter = Rect.new(62, 62, 62, 62),
			SliceScale = 6
		})
	})
end

return function(props)
	local v3 = useViewportSize()
	local v4 = use("ModificationsMenu")
	useGuiServiceSelect(v4, props.IsOpen)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if props.IsOpen ~= false or not state then
			return function() end
		end

		local thread = task.spawn(function()
			setState(nil)
		end)
		return function()
			return task.cancel(thread)
		end
	end, { props.IsOpen, state })
	local state2, setState2 = React.useState({
		Type = "Adornee"
	})
	local type = state2.Type
	local useMemo = React.useMemo

	local function fn()
		if state2.Type ~= "Modifications" or not state2.AdorneeId then
			return nil
		end

		local itemIds = { state2.AdorneeId }

		for _, v5 in ItemConfig.Query.select({
			Variant = {
				VariantOf = state2.AdorneeId
			}
		}) do
			table.insert(itemIds, v5.Index.ItemId)
		end

		return itemIds
	end

	local v6

	if state2.Type == "Modifications" then
		v6 = state2.AdorneeId
	end

	local v7 = useMemo(fn, { v6 })
	local menuType = props.MenuType
	React.useEffect(function()
		v.trace((`initial mod / adornee update: (menuType={menuType}, initialAdorneeId={props.InitialAdorneeId}, initialModificationId={props.InitialModificationId})`))
		local thread = task.spawn(function()
			if props.InitialModificationId then
				setState2({
					Type = "Modifications",
					AdorneeId = Modification.matchAdornee(props.InitialModificationId):unwrap(),
					ExitOnBack = true
				})
				setState({
					ItemId = props.InitialModificationId
				})
			elseif props.InitialAdorneeId then
				setState2({
					Type = "Modifications",
					AdorneeId = props.InitialAdorneeId,
					ExitOnBack = true
				})
			else
				setState2({
					Type = "Adornee"
				})
			end
		end)
		return function()
			task.cancel(thread)
		end
	end, { menuType, props.InitialAdorneeId, props.InitialModificationId })
	local v8 = React.useMemo(function()
		local itemIds = {}

		if v7 then
			for _, v9 in v7 do
				for _, v10 in getMods(menuType, v9) do
					table.insert(itemIds, v10.Index.ItemId)
				end
			end
		else
			for _, v9 in getMods(menuType) do
				table.insert(itemIds, v9.Index.ItemId)
			end
		end

		table.sort(itemIds)
		table.freeze(itemIds)
		v.trace(function()
			return `allPossibleMods for menuType="{menuType}", mode="{type}"`, ItemConfig.mapDebug(itemIds)
		end)
		return itemIds
	end, { menuType, type, v7 })
	local v9 = React.useMemo(function()
		v.trace(function()
			local v10 = {}

			for _, v11 in ItemConfig.map(props.Modifications) do
				table.insert(v10, v11.Index.DebugLabel)
			end

			return "props.Modifications", ItemConfig.mapDebug(props.Modifications)
		end)
		local modifications = {}

		for _, modification in props.Modifications do
			if table.find(v2, modification) or not table.find(v8, modification) then
				continue
			end

			table.insert(modifications, modification)
		end

		table.sort(modifications)
		v.trace(function()
			return "modifications out", ItemConfig.mapDebug(modifications)
		end)
		table.freeze(modifications)
		return modifications
	end, { v8, props.Modifications })
	local v10 = React.useMemo(function()
		local v11 = {}

		for _, v12 in v9 do
			local unwrapped = ItemConfig.match(v12):unwrap()
			local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
			v11[unwrapped2] = v11[unwrapped2] or 0
			v11[unwrapped2] += 1
		end

		local keys = TableUtil.keys(v11)
		table.sort(keys)
		table.freeze(keys)
		v.trace(function()
			return "adornees", ItemConfig.mapDebug(keys)
		end)
		return keys
	end, { menuType, v9 })
	React.useEffect(function()
		v.trace(function()
			return "props.Equipped", ItemConfig.mapDebug(props.Equipped)
		end)
	end, { props.Equipped })
	local tiles = React.useMemo(function()
		local result = {}

		for _, physical in v10 do
			local unwrapped = ItemConfig.match(physical):unwrap()

			if unwrapped.Moveset and unwrapped.Moveset.Type == "Fruit" and unwrapped.Moveset.Physical then
				if menuType == "FruitMutation" and unwrapped.Variant and unwrapped.Variant.IsFoundation ~= true then
					continue
				else
					physical = unwrapped.Moveset.Physical
				end
			end

			local v12 = {
				ItemId = physical
			}
			table.freeze(v12)
			table.insert(result, v12)
		end

		table.freeze(result)
		return result
	end, { v10 })
	local v12 = React.useMemo(function()
		local result = {}

		for _, itemId in v9 do
			local v14 = {
				ItemId = itemId
			}
			table.freeze(v14)
			table.insert(result, v14)
		end

		table.freeze(result)
		return result
	end, { v9 })

	local function fn2()
		if state2.Type == "Modifications" then
			local unwrapped = ItemConfig.match(state2.AdorneeId):unwrap()
			local stackDisplayName = unwrapped.Inventory.StackDisplayName or unwrapped.Display.Title or unwrapped.Display.Name or unwrapped.Index.StorageKey

			if menuType == "AuraSkin" then
				return "Aura Skins"
			elseif menuType == "FruitMutation" then
				return (`{stackDisplayName} Configurator`)
			elseif menuType == "FruitSkin" then
				return (`{stackDisplayName} Configurator`)
			elseif menuType == "SwordSkin" then
				return (`{stackDisplayName} Configurator`)
			end

			return "Modifications"
		else
			if menuType == "AuraSkin" then
				return "Aura Skins"
			elseif menuType == "FruitMutation" then
				return "Fruit Configurator"
			elseif menuType == "FruitSkin" then
				return "Fruit Configurator"
			elseif menuType == "SwordSkin" then
				return "Sword Configurator"
			end

			return "Modifications"
		end
	end

	local title = React.useMemo(fn2, { state2.Type, state2.Type == "Modifications" and state2.AdorneeId, menuType })
	local v16 = useAdorneeData()
	local v17 = useData()
	local useMemo3 = React.useMemo

	local function fn3()
		local v18 = {}
		local v19 = 0

		if type == "Adornee" then
			v19 = #tiles

			for _, v20 in tiles do
				local unwrapped = ItemConfig.match(v20.ItemId):unwrap()

				for _, group in unwrapped.Inventory.Groups do
					v18[group] = v18[group] or {
						Brackets = {},
						SortingTypes = { PseudoEnum.InventorySortType.Rarity }
					}

					for _, bracket in unwrapped.Inventory.Brackets do
						if not table.find(v18[group].Brackets, bracket) then
							table.insert(v18[group].Brackets, bracket)
						end
					end
				end
			end
		elseif type == "Modifications" then
			v19 = #v12

			for _, v20 in v12 do
				local unwrapped = ItemConfig.match(v20.ItemId):unwrap()

				for _, group in unwrapped.Inventory.Groups do
					v18[group] = v18[group] or {
						Brackets = {},
						SortingTypes = { PseudoEnum.InventorySortType.Rarity }
					}

					for _, bracket in unwrapped.Inventory.Brackets do
						if not table.find(v18[group].Brackets, bracket) then
							table.insert(v18[group].Brackets, bracket)
						end
					end
				end
			end
		end

		local purchaseTiles

		if props.Purchasable and props.OnPurchase then
			purchaseTiles = {}
			assert(purchaseTiles, "bad purchase tiles")

			for _, itemId in props.Purchasable do
				table.insert(purchaseTiles, {
					ItemId = itemId
				})
			end

			TableUtil.deepFreeze(purchaseTiles)
		end

		local v21 = false
		local v22, v23, v24, v25

		if state then
			v22 = Modification.getIfEquipped(state.ItemId, v17, v16)
			v23 = Modification.getIfCanUnequip(state.ItemId, v17, v16)
			v24 = Modification.getIfCanEquip(state.ItemId, v17, v16)
			v25 = Modification.getIfUnlocked(state.ItemId, v17, v16)
			v21 = props.Previewable and table.find(props.Previewable, state.ItemId) and true or false

			if v25 then
				v21 = false
			end
		else
			v22 = false
			v23 = false
			v24 = false
			v25 = false
		end

		local actions = {}

		if type ~= "Adornee" then
			if v21 then
				table.insert(actions, PseudoEnum.InventoryAction.Preview)
			end

			if not v22 and v25 or v22 and v23 or not v22 and v24 then
				table.insert(actions, PseudoEnum.InventoryAction.EquipItem)
			end
		end

		local v27 = {
			Title = title,
			Scale = 0.8,
			PurchaseTiles = 0,
			HideEmptyScreen = 0,
			TileCategoryIconOverride = nil,
			TileStackingDisabled = 0,
			ForceSolidOutline = true,
			ShowInvisibleTiles = true,
			HideToolBar = true,
			Actions = 0,
			Layout = 0
		}

		if v21 then
			purchaseTiles = nil
		end

		v27.PurchaseTiles = purchaseTiles
		v27.HideEmptyScreen = v19 > 0
		v27.TileStackingDisabled = type ~= "Adornee"
		v27.Actions = actions
		v27.Layout = v19 == 0 and {
			Wardrobe = {
				Brackets = { PseudoEnum.InventoryItemBracket.Configurables },
				SortingTypes = { PseudoEnum.InventorySortType.Rarity }
			}
		} or v18
		return v27
	end

	local purchasable = props.Purchasable
	local isOpen = props.IsOpen
	local v19

	if props.Previewable then
		v19 = table.concat(props.Previewable, "_") or nil
	end

	local v20 = useMemo3(fn3, {
		type,
		menuType,
		v10,
		v9,
		purchasable,
		title,
		state,
		isOpen,
		v19
	})
	local override = React.useMemo(function()
		local v22 = {}
		local v23 = {}

		local function addItem(itemId: number)
			if v23[itemId] or not ItemReplicationService.IsInitialized then
				return
			end

			v23[itemId] = true
			table.insert(v22, {
				ItemId = itemId,
				Key = ItemReplicationService.KEYS.QUANTITY,
				Value = 1
			})
			table.insert(v22, {
				ItemId = itemId,
				Key = ItemReplicationService.KEYS.IS_EQUIPPED,
				Value = table.find(props.Equipped, itemId) ~= nil
			})
			table.insert(v22, {
				ItemId = itemId,
				Key = ItemReplicationService.KEYS.IS_NEW,
				Value = false
			})
			table.insert(v22, {
				ItemId = itemId,
				Key = ItemReplicationService.KEYS.NEW_COUNT,
				Value = nil
			})
		end

		for _, v24 in v8 do
			addItem(v24)
		end

		for _, v24 in v10 do
			addItem(v24)
		end

		return v22
	end, {
		v9,
		v8,
		props.Equipped,
		ItemReplicationService.IsInitialized
	})
	local v25 = RobloxTypes.mergeFrame({
		[React.Tag] = v4,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromOffset(v3.X, v3.Y),
		SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
		SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
		SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
		SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
		SelectionGroup = true
	}, props)
	local v26 = {
		Scrim = createElement(scrim, {
			IsOpen = props.IsOpen,
			ZIndex = -10
		}),
		ItemReplicationOverride = 0
	}
	local provider = Config.Provider
	local provider2 = ItemSelection.Provider
	local v39 = {
		IsOpen = props.IsOpen,
		OnAction = type ~= "Adornee" and #v9 ~= 0 and function(p)
			if p == PseudoEnum.InventoryAction.EquipItem and state then
				props.OnEquip(state.ItemId, table.find(props.Equipped, state.ItemId) == nil)
			elseif p == PseudoEnum.InventoryAction.Preview and state then
				if props.OnPreview then
					props.OnPreview(state.ItemId)
				end
			elseif p == PseudoEnum.InventoryAction.Purchase and state and props.OnPurchase then
				local unwrapped = ItemConfig.match(state.ItemId):unwrap()
				local purchaseWith = unwrapped.Economy and unwrapped.Economy.PurchaseWith

				if purchaseWith then
					props.OnPurchase(purchaseWith)
				else
					v.error((`no purchasable config found for "{unwrapped.Index.DebugLabel}"`))
				end
			end
		end or nil,
		OnExit = function()
			setState(nil)

			if state2.Type ~= "Modifications" then
				props.OnExit()
			elseif state2.ExitOnBack then
				props.OnExit()
			else
				setState2({
					Type = "Adornee"
				})
			end
		end,
		OnExitComplete = function() end,
		Tiles = 0
	}

	if type ~= "Adornee" then
		tiles = type ~= "Modifications" and {} or v12
	end

	v39.Tiles = tiles
	v26.ItemReplicationOverride = createElement(ItemReplicationOverrideProvider, {
		Override = override
	}, {
		InventoryConfigContext = createElement(provider, {
			value = v20
		}, {
			ItemSelectionContext = createElement(provider2, {
				value = {
					Selection = state,
					SetSelection = function(itemId, networkedUID)
						if itemId and type == "Adornee" then
							if ItemConfig.match(itemId):unwrap().Index.IdType == "PhysicalMoveset" then
								local nullable = ItemConfig.Query.selectOne({
									Index = {
										IdType = "Moveset"
									},
									Moveset = {
										Physical = itemId
									}
								}):asNullable()

								if nullable then
									itemId = nullable.Index.ItemId
								else
									itemId = nil
								end
							end

							if itemId then
								setState2({
									Type = "Modifications",
									AdorneeId = itemId,
									ExitOnBack = false
								})
							end
						elseif itemId == nil then
							setState(nil)
						else
							setState({
								ItemId = itemId,
								NetworkedUID = networkedUID
							})
						end
					end
				}
			}, {
				Inventory = createElement(Inventory, v39)
			})
		})
	})
	return createElement("Frame", v25, v26)
end