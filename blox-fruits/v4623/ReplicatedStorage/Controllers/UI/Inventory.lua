local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Option = require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Future)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
require(game.ReplicatedStorage.Packages.OptionTable)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RemoteUtil = require(script.RemoteUtil)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.Modules.FishHelper)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local FruitShop = require(game.ReplicatedStorage.Controllers.UI.FruitShop)
local ModificationsMenu = require(game.ReplicatedStorage.Controllers.UI.ModificationsMenu)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local ItemReplication = require(game.ReplicatedStorage.Util.ItemReplication)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local IdMap = require(game.ReplicatedStorage.IdMap)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Controller"):tag("UI"):tag("Inventory"):display():traceback():build()
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Inventory = require(game.ReplicatedStorage.React.Components.Inventory)
local useIsEquipped = require(game.ReplicatedStorage.React.Hooks.Item.useIsEquipped)
local v2 = nil
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local createElement = React.createElement
local getUID = RemoteUtil.getUID

function setInventoryBadgeCount(totalNewItems: number)
	Players.LocalPlayer:SetAttribute("TotalNewItems", totalNewItems)
end

function clearGroup(p)
	if not (p ~= PseudoEnum.InventoryItemGroup.Build and ItemReplicationService.IsInitialized) then
		return
	end

	assert(ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT, "bad item replication service")
	RemoteUtil.clearNewCountAsync(p)
end

local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v2 == self then
		v2 = nil
	end

	for _, _Connection in self._Connections do
		local connection = _Connection
		pcall(function()
			connection:Disconnect()
		end)
	end

	for _, callback in self._CleanUpCallbacks do
		pcall(callback)
	end

	setmetatable(self, nil)
	table.clear(self)
end

function class:GetIfInitialized()
	if v2 then
		return v2._IsAlive
	end

	return false
end

function class:HasTile(value, p, p2: string?)
	assert(self:GetIfInitialized(), "InventoryController is not initialized")
	local v3 = nil

	if typeof(value) == "number" then
		v3 = value
	elseif typeof(value) == "string" then
		v3 = ItemId.getId(value, p):unwrap()
	else
		error((`Invalid argument type for storageKeyOrItemId, got type '{typeof(value)}'`))
	end

	for _, _InventoryItem in self._InventoryItems do
		if _InventoryItem.ItemId ~= v3 then
			continue
		end

		if not (p2 and _InventoryItem.UID ~= p2) then
			return true
		end
	end

	return false
end

function class:GetTiles()
	assert(self:GetIfInitialized(), "InventoryController is not initialized")
	assert(RunService:IsClient(), "InventoryController can only be used on the client")
	local _Tiles = {}

	for _, _Tile in self._Tiles do
		table.insert(_Tiles, _Tile)
	end

	table.freeze(_Tiles)
	return _Tiles
end

function class:Open(p: number?, p2: string?)
	local extended = v.extend(":Open")
	extended.info((`calling fn: (itemId={p},networkedUID={p2})`))
	assert(self:GetIfInitialized(), "InventoryController is not initialized")
	assert(RunService:IsClient(), "InventoryController can only be used on the client")

	if self.IsOpen then
		extended.info("already open")
		return
	end

	task.spawn(function()
		Modification.Data.refreshAsync()
	end)
	self.IsOpen = true
	self.OnInventoryOpen:Fire(p, p2)
end

function class:_LogFirstClick(p, p2)
	v.extend(":_LogFirstClick").info((`calling fn: (itemId={p},networkedUID={p2})`))
	assert(self:GetIfInitialized(), "InventoryController is not initialized")
	assert(RunService:IsClient(), "InventoryController can only be used on the client")
	local UID = getUID(p, p2)
	local _Tile = self._Tiles[UID]

	if not _Tile then
		return false
	end

	ItemReplication.HasClicked.writeClient(_Tile.ItemId, _Tile.NetworkedUID, true)
	ItemReplication.IsNew.writeClient(_Tile.ItemId, _Tile.NetworkedUID, false)
	return true
end

function class:Close()
	local extended = v.extend(":Close")
	extended.info("calling fn: ()")
	assert(self:GetIfInitialized(), "InventoryController is not initialized")
	assert(RunService:IsClient(), "InventoryController can only be used on the client")

	if not self.IsOpen then
		extended.trace("already closed")
		return
	end

	self.IsOpen = false
	self.OnInventoryClose:Fire()
end

function class.init()
	assert(RunService:IsClient(), "InventoryController can only be used on the client")
	v.info("Initializing")
	local onInventoryClose = Signal.new()
	local onInventoryOpen = Signal.new()
	local onTileRemoved = Signal.new()
	local onTileAdded = Signal.new()
	local flag = false
	local v7 = false
	local object = setmetatable({
		_IsAlive = true,
		IsOpen = false,
		_CleanUpCallbacks = { function()
				onInventoryClose:Destroy()
				onInventoryOpen:Destroy()
				onTileRemoved:Destroy()
				onTileAdded:Destroy()
			end },
		_Tiles = {},
		_Connections = {},
		_ScheduleBadgeUpdate = function()
			flag = true
		end,
		_ScheduleRefresh = function()
			v7 = true
		end,
		OnInventoryClose = onInventoryClose,
		OnInventoryOpen = onInventoryOpen,
		OnTileRemoved = onTileRemoved,
		OnTileAdded = onTileAdded
	}, class)
	local candyEgg = IdMap.Material["Candy Egg"]
	table.insert(object._Connections, RunService.Heartbeat:Connect(function()
		if flag then
			flag = false
			local count = 0

			for _, _Tile in object._Tiles do
				if not (_Tile.ItemId ~= candyEgg and ItemReplication.NewCount.readClient(
					_Tile.ItemId,
					_Tile.NetworkedUID
				)) then
					continue
				end

				count += 1
			end

			setInventoryBadgeCount(count)
		end
	end))

	local function tryChange(p)
		local UID = getUID(p.ItemId, p.NetworkedUID)

		if object._Tiles[UID] then
			return false
		end

		object._Tiles[getUID(p.ItemId, p.NetworkedUID)] = p
		onTileAdded:Fire(p)
		return true
	end

	local v8 = false
	local v9 = false
	local lastTime = tick()

	local function fn()
		v.trace("Updating inventory")
		RemoteUtil.getTiles():timeout(10):inspect(function(items)
			for k, _Tile in object._Tiles do
				if items[k] ~= nil then
					continue
				end

				local UID = getUID(_Tile.ItemId)

				if not (not items[UID] or UID == k) then
					continue
				end

				local v10 = _Tile
				v.trace(function()
					return (`couldn't find tile {ItemConfig.match(v10.ItemId):unwrap().Index.DebugLabel} after update, removing`)
				end)
				object._Tiles[k] = nil
				onTileRemoved:Fire(_Tile)
			end

			for k, item in items do
				v8 = true
				local UID = getUID(item.ItemId)

				if UID ~= k and object._Tiles[UID] then
					local v10 = item
					v.trace(function()
						return (`uid changed for {ItemConfig.match(v10.ItemId):unwrap().Index.DebugLabel} between updates, removing`)
					end)
					local _Tile = object._Tiles[UID]
					object._Tiles[UID] = nil
					onTileRemoved:Fire(_Tile)
				end

				if object._Tiles[k] ~= nil then
					continue
				end

				local UID2 = getUID(item.ItemId, item.NetworkedUID)

				if object._Tiles[UID2] then
					continue
				end

				object._Tiles[getUID(item.ItemId, item.NetworkedUID)] = item
				onTileAdded:Fire(item)
			end
		end):inspectErr(v.warn)
	end

	table.insert(object._Connections, RunService.Heartbeat:Connect(function()
		if tick() - lastTime < 1 then
			return
		end

		lastTime = tick()

		if v7 and not v9 then
			v9 = true
			v7 = false
			local success, result = pcall(function()
				fn()
			end)

			if not success then
				v.warn("Failed to refresh inventory:", result)
			end

			v9 = false
		end
	end))
	local thread = task.spawn(function()
		repeat
			v.trace("Refreshing inventory items")
			fn()
			task.wait(v8 and 20 or 5)
		until not object._IsAlive
	end)
	table.insert(object._CleanUpCallbacks, function()
		task.cancel(thread)
	end)
	table.insert(object._CleanUpCallbacks, RemoteUtil.connectOnTileUpdate(function(p, p2)
		v.trace((`tile updated, event={p2}, itemId={p.ItemId}, uid={p.NetworkedUID}`))

		if p2 == "Removed" then
			object._Tiles[getUID(p.ItemId, p.NetworkedUID)] = nil
			onTileRemoved:Fire(p)
		else
			local UID = getUID(p.ItemId, p.NetworkedUID)

			if not object._Tiles[UID] then
				object._Tiles[getUID(p.ItemId, p.NetworkedUID)] = p
				onTileAdded:Fire(p)
			end
		end

		object._ScheduleBadgeUpdate()
	end))

	local function rootComponent(p)
		local state, setState = React.useState((table.clone(object._Tiles)))
		local state2, setState2 = React.useState(nil)
		local state3, setState3 = React.useState(object.IsOpen)
		local tiles = React.useMemo(function()
			local v11 = {}

			for k, _ in state do
				table.insert(v11, k)
			end

			table.sort(v11)
			local result = {}

			for _, v12 in v11 do
				local v13 = state[v12]

				if v13 then
					table.insert(result, v13)
				end
			end

			table.freeze(result)
			return result
		end, { state })
		local state4, setState4 = React.useState(false)
		React.useEffect(function()
			if not ModificationsMenu.IsInitialized then
				return function() end
			end

			assert(ModificationsMenu.IsInitialized, "bad mod menu")
			local onClosedConnection = ModificationsMenu.OnClosed:Connect(function()
				setState4(false)
			end)
			return function()
				onClosedConnection:Disconnect()
			end
		end, { ModificationsMenu.IsInitialized })
		React.useEffect(function()
			local extended = v.extend("React Effect", nil, nil, { "React" })
			extended.info("hook init")

			if not object._IsAlive then
				extended.trace("not alive")
				return function() end
			end

			local connection = onTileAdded:Connect(function(p2)
				extended.trace("item added:", ItemConfig.match(p2.ItemId):unwrap().Index.DebugLabel)
				extended.trace("Refreshing items")
				setState(table.clone(object._Tiles))
			end)
			local connection2 = onTileRemoved:Connect(function(p2)
				extended.trace("item removed:", ItemConfig.match(p2.ItemId):unwrap().Index.DebugLabel)
				extended.trace("Refreshing items")
				setState(table.clone(object._Tiles))
			end)
			extended.trace("Refreshing items")
			setState(table.clone(object._Tiles))
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end, {})
		React.useEffect(function()
			local onInventoryCloseConnection = object.OnInventoryClose:Connect(function()
				setState2(nil)
				setState3(false)
			end)
			local onInventoryOpenConnection = object.OnInventoryOpen:Connect(function(itemId2: number?, networkedUID: string?)
				if itemId2 == nil then
					setState2(nil)
				else
					v.trace("Selected tile:", itemId2)
					object:_LogFirstClick(itemId2, networkedUID)
					flag = true
					object._ScheduleBadgeUpdate()
					setState2((table.freeze({
						ItemId = itemId2,
						NetworkedUID = networkedUID
					})))
				end

				p.Root.Enabled = true
				setState3(true)
			end)
			return function()
				onInventoryCloseConnection:Disconnect()
				onInventoryOpenConnection:Disconnect()
			end
		end, {})
		local itemId

		if state2 then
			itemId = state2.ItemId
		end

		local v12

		if state2 then
			v12 = state2.NetworkedUID
		end

		local v13 = useIsEquipped(itemId, v12)
		return createElement(ItemSelection.Provider, {
			value = {
				Selection = state2,
				SetSelection = function(itemId2: number?, networkedUID: string?)
					if itemId2 == nil then
						setState2(nil)
						return
					end

					clearGroup(PseudoEnum.InventoryItemGroup.Backpack)
					v.info("Selected tile:", itemId2)
					object:_LogFirstClick(itemId2, networkedUID)
					flag = true
					setState2((table.freeze({
						ItemId = itemId2,
						NetworkedUID = networkedUID
					})))
				end
			}
		}, {
			{
				DrawContextProvider = createElement(DrawContextProvider, {
					Context = state4 and "Background" or "Default"
				}, {
					Inventory = createElement(Inventory, {
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutomaticSize = Enum.AutomaticSize.None,
						Size = UDim2.fromScale(1, 1),
						OnTabChange = function(p2)
							assert(
								ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT,
								"bad item rep service"
							)

							for _, v14 in ItemReplicationService:GetItems(ItemReplicationService.KEYS.NEW_COUNT) do
								if not (type(v14.Value) == "number" and v14.Value > 0) then
									continue
								end

								local unwrapped = ItemConfig.match(v14.ItemId):unwrap()

								if not table.find(unwrapped.Inventory.Groups, p2) then
									continue
								end

								setState2((table.freeze({
									ItemId = v14.ItemId,
									NetworkedUID = v14.NetworkedUID
								})))
								break
							end

							clearGroup(p2)
							object._ScheduleBadgeUpdate()
						end,
						IsOpen = state3,
						OnAction = function(value)
							assert(state2, "bad selection")
							local extended = v.extend("React OnAction")
							extended.info("Action on tile:", state2.ItemId, "with action:", value)

							if value == PseudoEnum.InventoryAction.OpenFruitShopFromBuildMenu then
								local unwrapped = ItemConfig.match(state2.ItemId):unwrap()
								object:Close()
								FruitShop:Open("ShopGui", unwrapped.Index.StorageKey)
							else
								if value:find("Equip") and not v13 then
									setState2(nil)
								elseif value == PseudoEnum.InventoryAction.OpenBox or value == PseudoEnum.InventoryAction.RedeemStoredGamepass or value == PseudoEnum.InventoryAction.RedeemPhysicalDragonToken then
									object:Close()
								end

								if Modification.getIfModification(state2.ItemId) and value == PseudoEnum.InventoryAction.ViewMoreFruitAccessories then
									setState4(true)
								end

								local v14 = RemoteUtil.invokeAction(value, state2.ItemId, state2.NetworkedUID, v13):await()
								v14:inspectErr(function(p2)
									extended.warn("Failed to invoke action on tile", state2.ItemId, ":", p2)
								end)

								if v14:isOk() and (value == PseudoEnum.InventoryAction.BuildCampfire or value == PseudoEnum.InventoryAction.OpenBox) then
									object:Close()
								end

								extended.trace(function()
									return "Action result for tile:", state2.ItemId, ":", v14
								end)
							end
						end,
						OnExitComplete = function()
							object:Close()
						end,
						OnExit = function()
							setState3(false)
						end,
						Tiles = tiles
					})
				})
			}
		})
	end

	local none = Option.none()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanGui()
		none:inspect(function(callback)
			callback()
		end)
		none = Option.none()
	end

	local function bootGui()
		none:inspect(function(callback)
			callback()
		end)
		local v10 = true
		local screenGui = Instance.new("ScreenGui")
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.ScreenInsets = Enum.ScreenInsets.None
		screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		screenGui.IgnoreGuiInset = true
		screenGui.Name = "Inventory"
		screenGui.Parent = playerGui
		screenGui.Enabled = object.IsOpen
		screenGui.ResetOnSpawn = false
		local root = ReactRoblox.createRoot(screenGui)
		local thread2 = task.spawn(function()
			root:render((ReactRoblox.createPortal(createElement(rootComponent, {
				Root = screenGui
			}), screenGui)))
		end)
		none = Option.some(function()
			if not v10 then
				return
			end

			v10 = false
			root:unmount()
			screenGui:Destroy()
			task.cancel(thread2)
		end)
	end

	table.insert(object._CleanUpCallbacks, function()
		cleanGui() -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		if object._IsAlive then
			bootGui()
		end
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Inventory", function(...)
			return object:Open(...)
		end, function()
			return object:Close()
		end, function()
			return object.IsOpen
		end)
	end)
	local v10 = v2
	v2 = object

	if v10 then
		v10:Destroy()
	end

	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v2 or class
end)