local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local PlayerStat = require(script.PlayerStat)
local ShowcaseItem = require(script.ShowcaseItem)
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local Inventory = require(ReplicatedStorage.React.Components.Inventory)
require(ReplicatedStorage.React.Components.Inventory.Types)
local PseudoEnum = require(ReplicatedStorage.PseudoEnum)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
local useGuiServiceSelect = require(ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local use = require(ReplicatedStorage.React.Hooks.UID.use)
local Config = require(ReplicatedStorage.React.Contexts.Inventory.Config)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local useConfig = require(ReplicatedStorage.React.Hooks.Inventory.useConfig)
local ItemSelection = require(ReplicatedStorage.React.Contexts.ItemSelection)
local ItemReplicationService = require(ReplicatedStorage.ItemReplicationService)
local ItemReplicationOverrideProvider = require(ReplicatedStorage.React.Components.ItemReplicationOverrideProvider)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local v = {}
local selectItem = PseudoEnum.InventoryAction.SelectItem
local createElement = React.createElement

local function getClientItemQuantity(itemId: number)
	while ItemReplicationService.IsInitialized ~= true do
		task.wait()
	end

	assert(ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT, "bad ItemReplicationService")

	if not ItemReplicationService.IsInitialized then
		return 0
	end

	local items = ItemReplicationService:GetItems(ItemReplicationService.KEYS.QUANTITY)

	if items == nil then
		return 0
	end

	for _, item in items do
		if item.ItemId == itemId then
			return item.Value or 0
		end
	end

	return 0
end

if not GlobalUtil.FFlags.IsUnitTest then
	task.spawn(function()
		v = ReplicatedStorage.Remotes.GetPlayerStatDisplayNames:InvokeServer()
	end)
end

function inventoryPopUp(props)
	local state, setState = React.useState(nil)
	return createElement(ItemSelection.Provider, {
		value = {
			Selection = state,
			SetSelection = function(itemId, networkedUID)
				if itemId == nil then
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
		InventoryContainer = createElement("ScreenGui", {
			ResetOnSpawn = false,
			DisplayOrder = 30,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			Inventory = createElement(Inventory, {
				IsOpen = props.SelectingItemForSlot ~= nil,
				OnAction = function(p)
					if p == selectItem then
						props.OnItemSelected(props.SelectingItemForSlot, state)
					end
				end,
				OnExit = function()
					props.SetSelectingItemForSlot(nil)
					props.OnItemSelected(props.SelectingItemForSlot, nil)
				end,
				OnExitComplete = function() end,
				Tiles = props.Items
			})
		})
	})
end

return function(props)
	local state, setState = React.useState(nil)
	local v2 = use("ProfileShowcase")
	useGuiServiceSelect(v2, state == nil)
	local state2, setState2 = React.useState({})
	local v3 = {}

	for i = 1, 4 do
		local stat = props.LoadedPlayer.ProfileData["Stat" .. i]
		local formatted = `Stat{i}`
		local v7 = {
			Stat = stat,
			Variant = stat ~= nil and "Default" or props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode and "Add" or "Empty",
			Name = 0,
			StatSelectionVisible = 0,
			SetStatSelectionVisible = 0,
			StatNumber = 0,
			SetSelectedStatSlotId = 0,
			LoadedPlayer = 0
		}
		local name

		if stat then
			name = v[stat.StatId + 1]
		else
			name = "Stat " .. i
		end

		v7.Name = name
		v7.StatSelectionVisible = props.StatSelectionVisible
		v7.SetStatSelectionVisible = props.SetStatSelectionVisible
		v7.StatNumber = i
		v7.SetSelectedStatSlotId = props.SetSelectedStatSlotId
		v7.LoadedPlayer = props.LoadedPlayer
		v3[formatted] = createElement(PlayerStat, v7)
	end

	local children = {}

	for i = 1, 6 do
		local v4 = props.LoadedPlayer.ProfileData[`ShowcaseSlot{i}Id`]
		local v5 = i
		local v6 = i
		children[`Item{i}`] = createElement(ShowcaseItem, {
			Tile = state2[i],
			Quantity = props.LoadedPlayer.ProfileData[`ShowcaseSlot{i}Quantity`],
			Variant = v4 ~= 0 and "Default" or props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode and "Add" or "Empty",
			OnClick = props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode and state == nil and function()
				setState(v5)
				print("Selecting item for slot", v5)
			end or nil,
			OnCloseClick = props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode and function()
				local v7, v8 = ReplicatedStorage.Remotes.UpdatePlayerProfileValue:InvokeServer("Showcase", v6, 0)

				if not v7 then
					print("Failed to set Showcase item because", v8)
					return
				end

				props.PatchProfileData({
					[`ShowcaseSlot{v6}Id`] = 0,
					[`ShowcaseSlot{v6}Rarity`] = 0,
					[`ShowcaseSlot{v6}Quantity`] = 0
				})
			end or nil
		})
	end

	React.useEffect(function()
		local v4 = {}

		for i = 1, 6 do
			local itemId = props.LoadedPlayer.ProfileData[`ShowcaseSlot{i}Id`]

			if itemId ~= nil and itemId ~= 0 then
				v4[i] = {
					ItemId = itemId,
					NetworkedUID = nil
				}
			end
		end

		setState2(v4)
	end, { props.LoadedPlayer })
	local v4 = useConfig()
	local v5 = React.useMemo(function()
		local copy = TableUtil.deepCopy(v4)
		copy.Title = "Showcase"
		copy.Actions = { PseudoEnum.InventoryAction.SelectItem }
		local v6 = copy.Layout[PseudoEnum.InventoryItemGroup.Wardrobe]

		if v6 and not table.find(v6.Brackets, PseudoEnum.InventoryItemBracket.Titles) then
			table.insert(v6.Brackets, PseudoEnum.InventoryItemBracket.Titles)
		end

		if v6 and not table.find(v6.Brackets, PseudoEnum.InventoryItemBracket.Backgrounds) then
			table.insert(v6.Brackets, PseudoEnum.InventoryItemBracket.Backgrounds)
		end

		copy.Layout[PseudoEnum.InventoryItemGroup.Build] = nil
		copy.ShowInvisibleTiles = true
		copy.FavoritingEnabled = false
		copy.NewCountEnabled = false
		TableUtil.deepFreeze(copy)
		return copy
	end, { v4 })
	local override = React.useMemo(function()
		local result = {}

		for _, inventoryItem in props.InventoryItems do
			if not ItemReplicationService.IsInitialized then
				continue
			end

			table.insert(result, {
				ItemId = inventoryItem.ItemId,
				NetworkedUID = inventoryItem.NetworkedUID,
				Key = ItemReplicationService.KEYS.IS_FAVORITED,
				Value = false
			})
			table.insert(result, {
				ItemId = inventoryItem.ItemId,
				NetworkedUID = inventoryItem.NetworkedUID,
				Key = ItemReplicationService.KEYS.NEW_COUNT,
				Value = 0
			})
		end

		return result
	end, { props.InventoryItems })
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		LayoutOrder = 3,
		Position = UDim2.fromScale(-2.48234e-8, 0.408137),
		Size = UDim2.fromScale(0.975688, 0.584612),
		Visible = CONSTANTS.isPermissionLevelMet(
			props.LoadedPlayer.UserId,
			props.LoadedPlayer.ProfileData.Settings.ShowcaseVisible
		),
		[React.Tag] = v2
	}, {
		inventoryConfigProvider = createElement(Config.Provider, {
			value = v5
		}, {
			ItemReplicationOverride = createElement(ItemReplicationOverrideProvider, {
				Override = override
			}, {
				inventory = createElement(inventoryPopUp, {
					SelectingItemForSlot = state,
					SetSelectingItemForSlot = setState,
					OnItemSelected = function(p: number, p2)
						print("Selected item for slot", p, p2)

						if p2 == nil then
							return
						end

						local itemId = p2.ItemId
						local v9 = itemId ~= 0 and {
							ItemId = itemId
						} or nil
						local clone = table.clone(state2)
						clone[p] = v9
						setState2(clone)
						setState(nil)
						local v10, v11 = ReplicatedStorage.Remotes.UpdatePlayerProfileValue:InvokeServer(
							"Showcase",
							p,
							itemId
						)

						if not v10 then
							print("Failed to set Showcase item because", v11)
							return
						end

						local v12 = {
							[`ShowcaseSlot{p}Id`] = itemId,
							[`ShowcaseSlot{p}Quantity`] = itemId == 0 and 0 or getClientItemQuantity(itemId)
						}

						if itemId ~= 0 then
							for i = 1, 6 do
								if not (i ~= p and props.LoadedPlayer.ProfileData[`ShowcaseSlot{i}Id`] == itemId) then
									continue
								end

								v12[`ShowcaseSlot{i}Id`] = 0
								v12[`ShowcaseSlot{i}Rarity`] = 0
								v12[`ShowcaseSlot{i}Quantity`] = 0
							end
						end

						props.PatchProfileData(v12)
					end,
					Items = props.InventoryItems
				})
			})
		}),
		headerTextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0, -2.52211e-7),
			Size = UDim2.fromScale(0.781, 0.114502),
			Text = "Profile Showcase",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke"),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 0.4),
				Size = UDim2.fromScale(1, 1),
				Text = "Profile Showcase",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke")
			})
		}),
		items = createElement("Frame", {
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = 4,
			Position = UDim2.fromScale(0, 0.145),
			Size = UDim2.fromScale(1, 0.330579)
		}, {
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				Padding = UDim.new(0.022, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			uIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0.002, 0)
			}),
			showcaseItems = createElement(React.Fragment, nil, children)
		}),
		statistics = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			LayoutOrder = 10,
			Position = UDim2.fromScale(0, 1.045),
			Size = UDim2.fromScale(1, 0.491736)
		}, {
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				Padding = CONSTANTS2.SPACING.PADDING.SCALE.XXS,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = true
			}),
			uIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0.002, 0)
			}),
			stats = createElement(React.Fragment, nil, v3)
		})
	})
end