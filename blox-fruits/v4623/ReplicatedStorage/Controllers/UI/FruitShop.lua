local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Data = require(script.Data)
local GiftWindow = require(game.ReplicatedStorage.Controllers.UI.GiftWindow)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Shop = require(game.ReplicatedStorage.Shop)
local PriceService = require(game.ReplicatedStorage.PriceService)
local AnalyticsClient = require(game.ReplicatedStorage.Controllers.AnalyticsClient)
local StateUtil = require(script.StateUtil)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
require(game.ReplicatedStorage.Modules.Util.Trove)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local ColorPalette = require(game.ReplicatedStorage.Util.RichText.ColorPalette)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local Notification = require(game.ReplicatedStorage.Notification)
local ModificationsMenu = require(game.ReplicatedStorage.Controllers.UI.ModificationsMenu)
local Modification = require(game.ReplicatedStorage.Util.Modification)
require(script.Types)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("UI"):tag("Controller"):tag("FruitShop"):display():traceback():build()
local FruitShop = require(game.ReplicatedStorage.React.Components.FruitShop)
require(game.ReplicatedStorage.React.Components.FruitShop.Types)
local DragonSelectionMenu = require(game.ReplicatedStorage.React.Components.DragonSelectionMenu)
local ConfirmationDialog = require(game.ReplicatedStorage.React.Components.ConfirmationDialog)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local v2 = {}

for k, v3 in pairs(Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.ALL)) do
	if v3.subtype == "Fruit" then
		v2[k] = v3
	end
end

table.freeze(v2)
local unwrapped = Shop.match("Discounted Permanent Dragon"):unwrap()
local v3 = nil
local commRemoteFunc = StateUtil.CommRemoteFunc
local devilFruit = Players.LocalPlayer:WaitForChild("Data"):WaitForChild("DevilFruit")
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local createElement = React.createElement

function getRestockDatetime(p)
	local v4 = p == "AdvancedFruitDealer" and 7200 or 14400
	local unixTimestamp = DateTime.now().UnixTimestamp
	local v5 = unixTimestamp % v4
	return DateTime.fromUnixTimestamp(unixTimestamp - v5 + v4)
end

function getFruitsAsync(p)
	local extended = v.extend("getFruitsAsync")
	extended.info((`called fn (context={p})`))
	local v4 = commRemoteFunc:InvokeServer("GetFruits", p == "AdvancedFruitDealer")
	assert(typeof(v4) == "table", (`bad result: {v4}`))
	extended.trace(function()
		local names = {}

		for _, v5 in v4 do
			table.insert(names, v5.Name)
		end

		return "names: ", names
	end)
	return v4
end

function getEquippedFruit()
	local extended = v.extend("getEquippedFruit", nil, "INFO")
	extended.info("called fn ()")
	local value = devilFruit.Value

	for k, v4 in pairs(Data) do
		if k ~= value then
			continue
		end

		local v5 = k
		local v6 = v4
		extended.trace(function()
			return `returning fruit "{v5}": `, v6
		end)
		return v4
	end

	if value:len() == 0 or value == " " then
		extended.trace((`returning nil from "{value}"`))
		return nil
	else
		extended.trace((`unsupported fruit name: "{value}"`))
	end
end

function getOwnedFruitAsync(p)
	local extended = v.extend("getOwnedFruitAsync")
	extended.info((`called fn (context="{p}")`))
	local result = {}
	local names = {}

	for _, v4 in ipairs(getFruitsAsync(p)) do
		if not v4.HasPermanent then
			continue
		end

		local v5 = Data[v4.Name]

		if not v5 then
			continue
		end

		table.insert(result, v5)
		table.insert(names, v4.Name)
	end

	table.freeze(result)
	extended.trace(function()
		return "names", names
	end)
	return result
end

function getLockedFruitAsync(p)
	local extended = v.extend("getLockedFruitAsync")
	extended.info((`called fn (context="{p}")`))
	local result = {}
	local names = {}

	for _, v4 in ipairs(getFruitsAsync(p)) do
		if v4.OnSale then
			continue
		end

		local v5 = Data[v4.Name]

		if not v5 then
			continue
		end

		table.insert(result, v5)
		table.insert(names, v4.Name)
	end

	table.freeze(result)
	extended.trace(function()
		return "names", names
	end)
	return result
end

function getBeli()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return 0
	end

	local data = localPlayer:FindFirstChild("Data")
	local beli = data and data:FindFirstChild("Beli")

	if beli then
		assert(beli:IsA("IntValue"), "Invalid beli value")
		return beli.Value
	end

	return 0
end

function promptInvokePermanentPurchaseAsync(p, p2, flag: boolean)
	if flag and p.Name == "Dragon-Dragon" then
		commRemoteFunc:InvokeServer("ClassicDragonGui1", nil)
	else
		commRemoteFunc:InvokeServer("buyRobuxShop", {
			StorageName = "Permanent " .. p.Name,
			PurchaseLocation = p2 == "ShopGui" and "FruitShop" or "FruitDealer",
			FunnelId = p2 == "ShopGui" and "Shop" or nil
		})
	end
end

function newDebounce(p: number)
	local v4 = 0
	return function()
		local now = tick()

		if p < now - v4 then
			v4 = now
			return true
		else
			return false
		end
	end
end

local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v3 == self then
		v3 = nil
	end

	self._OnContextChange:Destroy()
	self._OnOpen:Destroy()
	self._OnOpenAtFruitChange:Destroy()
	self.OnClose:Destroy()
	self._Root:Destroy()
	setmetatable(self, nil)
	table.clear(self)
end

function class:GetIfInitialized()
	if v3 then
		return v3._IsAlive
	end

	return false
end

function class:Open(shopContext, openAtFruit: string?)
	if self.IsOpen then
		return
	end

	local v4 = self.ShopContext ~= shopContext
	self.ShopContext = shopContext

	if v4 then
		self._OnContextChange:Fire(shopContext)
	end

	self._OpenAtFruit = openAtFruit
	self._OnOpenAtFruitChange:Fire(openAtFruit)
	self.IsOpen = true
	task.spawn(AttributeCounter.add, Players.LocalPlayer, "NPC_INTERACTION_LOCK")
	self.OnClose:Once(function()
		task.spawn(AttributeCounter.remove, Players.LocalPlayer, "NPC_INTERACTION_LOCK")
	end)
	self._OnOpen:Fire()

	if not self._UID then
		self:_Open()
	end
end

function class:_Open()
	assert(class:GetIfInitialized(), "FruitShop not initialized")
	local GUID = HttpService:GenerateGUID(false)
	self._UID = GUID
	local root = ReactRoblox.createRoot(self._Root)
	local v4 = nil
	local flag = true

	local function cleanUp()
		if not flag then
			return
		end

		flag = false
		self.OnClose:Fire(self.ShopContext)

		if GUID == self._UID then
			self.IsOpen = false
			self._UID = nil
			self._CleanUp = nil
		end

		if v4 then
			v4:Destroy()
		end

		root:unmount()
	end

	local v5 = newDebounce(1)
	local extended = v.extend("react")

	local function shopComponent(_)
		local state2, setState = React.useState({})
		local state3, setState2 = React.useState(self.IsOpen)
		local state4, setState3 = React.useState(self.ShopContext)
		local state5, setState4 = React.useState(false)
		local state6, setState5 = React.useState(getEquippedFruit())
		local state7, setState6 = React.useState(table.freeze({}))
		local state8, setState7 = React.useState(table.freeze({}))
		local state9, setState8 = React.useState(getRestockDatetime(state4))
		local state10, setState9 = React.useState(false)
		local state11, setState10 = React.useState(false)
		local state12, setState11 = React.useState(false)
		local state13, setState12 = React.useState(nil)
		local state14, setState13 = React.useState(false)
		local state15, setState14 = React.useState(false)
		local state16, setState15 = React.useState(self._OpenAtFruit)
		local state17, setState16 = React.useState("West")
		local state18, setState17 = React.useState(nil)
		local state19, setState18 = React.useState(Players.LocalPlayer:HasTag("DiscountedDragonEnabled"))
		local state20, setState19 = React.useState(nil)
		local v6 = useLastInput()
		React.useEffect(function()
			if not self._IsAlive then
				return function() end
			end

			local connection = self._OnOpenAtFruitChange:Connect(function(p: string?)
				setState15(p)
			end)
			return function()
				connection:Disconnect()
			end
		end, { self._IsAlive })
		React.useEffect(function()
			local price = PriceService.getPrice(unwrapped.ItemId)

			if price ~= state20 then
				setState19(price)
			end

			return function() end
		end, { PriceService:GetIfInitialized() })
		local fruits = React.useMemo(function()
			local result = {}

			for _, v8 in pairs(state2) do
				if v8.Name == "Dragon-Dragon" and state19 then
					local clone = table.clone(v8)

					if state20 then
						clone.PermanentRobuxPrice = state20
					end

					table.freeze(clone)
					table.insert(result, clone)
				else
					table.insert(result, v8)
				end
			end

			extended.trace(function()
				local permanentRobuxPrices = {}

				for k, v8 in result do
					permanentRobuxPrices[k] = v8.PermanentRobuxPrice
				end

				return "modifiedFruits", permanentRobuxPrices
			end)
			return result
		end, { state19, state2, state20 })
		state8 = React.useMemo(function()
			local v8 = nil

			for _, v10 in ipairs(fruits) do
				if v10.Name ~= "Dragon-Dragon" then
					continue
				end

				v8 = v10
				break
			end

			state8 = table.clone(state8)

			if v8 then
				for i, v10 in ipairs(state8) do
					if v10.Name ~= "Dragon-Dragon" then
						continue
					end

					state8[i] = v8
					break
				end
			end

			table.freeze(state8)
			extended.trace(function()
				return "owned", state8
			end)
			return state8
		end, { state8, fruits })
		state7 = React.useMemo(function()
			local v8 = nil

			for _, v10 in ipairs(fruits) do
				if v10.Name ~= "Dragon-Dragon" then
					continue
				end

				v8 = v10
				break
			end

			state7 = table.clone(state7)

			if v8 then
				for i, v10 in ipairs(state7) do
					if v10.Name ~= "Dragon-Dragon" then
						continue
					end

					state7[i] = v8
					break
				end
			end

			extended.trace(function()
				local names = {}

				for _, v10 in state7 do
					table.insert(names, v10.Name)
				end

				return "locked", names
			end)
			table.freeze(state7)
			return state7
		end, { state7, fruits })
		state6 = React.useMemo(function()
			if not state6 then
				return
			end

			for _, v8 in ipairs(state8) do
				if v8.Name ~= state6.Name then
					continue
				end

				extended.trace((`equipped: {v8.Name}`))
				return v8
			end

			extended.trace(function()
				return "equipped fallback", state6 and state6.Name
			end)
			return state6
		end, { state6, state8 })
		local v8

		if state6 then
			v8 = table.find(state8, state6) == nil
		else
			v8 = false
		end

		React.useEffect(function()
			local connection = CollectionService:GetInstanceAddedSignal("DiscountedDragonEnabled"):Connect(function(p)
				if p == Players.LocalPlayer then
					setState18(Players.LocalPlayer:HasTag("DiscountedDragonEnabled"))
				end
			end)
			setState18(Players.LocalPlayer:HasTag("DiscountedDragonEnabled"))
			return function()
				connection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			if not self._IsAlive then
				return function() end
			end

			local connection = self._OnContextChange:Connect(function(p)
				setState3(p)
			end)
			return function()
				connection:Disconnect()
			end
		end, { self._IsAlive })
		React.useEffect(function()
			if not self._IsAlive then
				return function() end
			end

			local connection = self._OnOpen:Connect(function()
				setState2(true)
			end)
			return function()
				connection:Disconnect()
			end
		end, { self._IsAlive })
		React.useEffect(function()
			if not self._IsAlive then
				return function() end
			end

			local onCloseConnection = self.OnClose:Connect(function()
				setState2(false)
			end)
			return function()
				onCloseConnection:Disconnect()
			end
		end, { self._IsAlive })
		React.useEffect(function()
			local thread = task.spawn(function()
				if state3 then
					local fruitsAsync = getFruitsAsync(state4)
					local v9 = {}

					for _, v10 in pairs(fruitsAsync) do
						for k, v12 in pairs(Data) do
							if k ~= v10.Name then
								continue
							end

							table.insert(v9, v12)
							break
						end
					end

					task.spawn(function()
						local lockedFruitAsync = getLockedFruitAsync(state4)

						if self._IsAlive then
							setState6(lockedFruitAsync)
						end
					end)
					task.spawn(function()
						local ownedFruitAsync = getOwnedFruitAsync(state4)

						if self._IsAlive then
							setState7(ownedFruitAsync)
						end
					end)
					task.spawn(function()
						if self._IsAlive then
							setState(v9)
						end
					end)
					task.spawn(function()
						local dragonTypeAsync = StateUtil.getDragonTypeAsync()

						if self._IsAlive then
							setState16(dragonTypeAsync)
						end
					end)
				end
			end)
			return function()
				task.cancel(thread)
			end
		end, { state3, state4 })
		React.useEffect(function()
			local onCloseConnection = nil
			local thread = task.spawn(function()
				GuiService.TouchControlsEnabled = LastInput:Get() == "Touch" and not state3

				if state3 then
					onCloseConnection = self.OnClose:Connect(function()
						GuiService.TouchControlsEnabled = LastInput:Get() == "Touch"
					end)
				end
			end)
			return function()
				if onCloseConnection then
					onCloseConnection:Disconnect()
				end

				task.cancel(thread)
			end
		end, { state3, v6 })
		React.useEffect(function()
			local onClientEventConnection = StateUtil.CommRemoteEvent.OnClientEvent:Connect(function(p: string, ...)
				if p == "ItemChanged" or p == "ItemRemoved" then
					setState7(getOwnedFruitAsync(state4))
				end
			end)
			return function()
				onClientEventConnection:Disconnect()
			end
		end, {})
		React.useEffect(function()
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				if state9.UnixTimestampMillis - DateTime.now().UnixTimestampMillis <= 0 then
					setState6(getLockedFruitAsync(state4))
					setState8(getRestockDatetime(state4))
				end
			end)
			return function()
				heartbeatConnection:Disconnect()
			end
		end, { state9 })
		React.useEffect(function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local dragonType = devilFruit:GetAttribute("DragonType")

				if (dragonType == "East" or dragonType == "West") and dragonType ~= state17 then
					setState16(dragonType)
				end
			end

			local dragonTypeChangedConnection = devilFruit:GetAttributeChangedSignal("DragonType"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
			return function()
				dragonTypeChangedConnection:Disconnect()
			end
		end, { devilFruit:GetAttribute("DragonType") })
		React.useEffect(function()
			local function update()
				local equippedFruit = getEquippedFruit()

				if state6 ~= equippedFruit then
					setState5(equippedFruit)
				end

				local ownedFruitAsync = getOwnedFruitAsync(state4)

				if not table.isfrozen(ownedFruitAsync) then
					table.freeze(ownedFruitAsync)
				end

				setState7(ownedFruitAsync)
			end

			local valueChangedConnection = devilFruit:GetPropertyChangedSignal("Value"):Connect(update)
			task.spawn(update)
			return function()
				valueChangedConnection:Disconnect()
			end
		end, { devilFruit.Value })
		local fragment = React.Fragment
		local warningDialog

		if state13 then
			local upper = ColorPalette.Red:ToHex():upper()
			local equipped

			if state13.Equipped then
				equipped = state13.Equipped
			end

			local upper2 = ColorPalette.Green:ToHex():upper()
			local v17

			if state13.Selection then
				v17 = state13.Selection
			end

			warningDialog = createElement(ConfirmationDialog, {
				Title = "WARNING",
				Body = `This will replace your current <font color="#{upper}">&lt;{equipped}&gt;</font> Blox Fruit for <font color="#{upper2}">&lt;{v17}&gt;</font>.\n \nAre you sure you want to continue?`,
				ConfirmText = "Continue",
				CancelText = "Cancel",
				OnCloseComplete = function()
					print("complete dialog close")
					setState12(nil)
				end,
				OnResponse = function(flag2: boolean)
					print("responded", flag2)

					if flag2 then
						state13.Method()
					end
				end
			})
		end

		local dragonSelectionMenu

		if state10 or state14 then
			dragonSelectionMenu = createElement(DragonSelectionMenu, {
				IsOpen = state10,
				IsQuick = false,
				IsEastEnabled = true,
				IsWestEnabled = true,
				IsControllerActive = state10 or state14,
				OnSelectionClick = function(p: string?)
					if p then
						print((`click {p}`))

						if state15 then
							if not StateUtil.tryInvokeTemporaryPurchaseAsync("Dragon-Dragon", state4) then
								StateUtil.notifyError("Can't afford fruit")
							end
						else
							local v14, v15 = StateUtil.tryEquipFruit("Dragon-Dragon", p)

							if not v14 then
								StateUtil.notifyError(v15 or "Failed to equip permanent fruit")
							end
						end
					end

					setState9(false)
					setState13(true)
				end,
				OnCloseComplete = function()
					print("Closed")
					setState13(false)
				end
			})
		end

		local v16 = {
			Size = UDim2.fromScale(1, 1),
			IsVisible = state3,
			IsHidden = state12,
			Fruits = fruits,
			Owned = state8,
			Equipped = state6,
			Locked = state7,
			OpenAtFruit = state16,
			IsControllerActive = not (state10 or state14 or state13 or state11 or state12),
			OnEggClick = nil,
			OnCardClick = function(p, flag2: boolean)
				if flag2 then
					setState17(p)
				elseif state18.Name == p.Name then
					setState17(nil)
				end

				if flag2 and not state5 then
					setState4(true)
					AnalyticsClient:ReportShoppingStep({
						funnelId = "Shop",
						purchaseLocation = "FruitShop",
						storageName = p.Name,
						step = 2
					})
				end
			end,
			CurrentDragonSwapType = state17,
			OnExitClick = function()
				if not flag then
					return
				end

				flag = false
				self.OnClose:Fire(self.ShopContext)

				if GUID == self._UID then
					self.IsOpen = false
					self._UID = nil
					self._CleanUp = nil
				end

				if v4 then
					v4:Destroy()
				end

				root:unmount()
			end,
			OnPermPurchaseClick = function(p)
				if not v5() then
					return
				end

				if table.find(state8, p) then
					-- equivalent calls inferred from this helper; original call sites unknown
					local function equip()
						if p.Name == "Dragon-Dragon" then
							setState14(false)
							setState9(true)
						else
							local v17, v18 = StateUtil.tryEquipFruit(p.Name)

							if not v17 then
								StateUtil.notifyError(v18 or "Failed to equip permanent fruit")
							end
						end
					end

					if v8 then
						setState12(table.freeze({
							Method = equip,
							Equipped = state6 and state6.DisplayName or nil,
							Selection = p.DisplayName
						}))
						return
					end

					equip() -- equivalent call inferred; original call site unknown
				else
					local function purchase()
						local ownedFruitAsync = getOwnedFruitAsync(state4)

						if not table.isfrozen(ownedFruitAsync) then
							table.freeze(ownedFruitAsync)
						end

						setState7(ownedFruitAsync)

						for _, v17 in ipairs(ownedFruitAsync) do
							if v17.Name == p.Name then
								return
							end
						end

						promptInvokePermanentPurchaseAsync(p, state4, state19)
					end

					if v8 and (not state6 or state6 and state6.Name ~= p.Name) then
						setState12(table.freeze({
							Method = purchase,
							Equipped = state6 and state6.DisplayName or nil,
							Selection = p.DisplayName
						}))
					else
						purchase()
					end
				end
			end,
			OnTempPurchaseClick = state4 ~= "ShopGui" and function(data)
				if not v5() then
					return
				end

				local function purchase()
					if data.Name == "Dragon-Dragon" then
						if data.Price > getBeli() then
							StateUtil.notifyError("Can't afford fruit")
							return
						end

						setState14(true)
						setState9(true)
					elseif not StateUtil.tryInvokeTemporaryPurchaseAsync(data.Name, state4) then
						StateUtil.notifyError("Can't afford fruit")
					end
				end

				print("setting post dialog callback", v8, state13)

				if v8 then
					setState12(table.freeze({
						Method = purchase,
						Equipped = state6 and state6.DisplayName or nil,
						Selection = data.DisplayName
					}))
				else
					purchase()
				end
			end or nil,
			OnDragonSwapClick = function()
				local character = Players.LocalPlayer.Character

				if character and StateUtil.getIfTransformed(character) then
					Notification.new("You can't swap fruits while transformed", 5):Display()
					return
				end

				if not v5() then
					return
				end

				local v17 = StateUtil.getDragonTypeAsync() == "East" and "West" or "East"

				if v17 ~= state17 and StateUtil.tryEquipFruit("Dragon-Dragon", v17) then
					setState16(StateUtil.getDragonTypeAsync() or v17)
				end
			end,
			OnMutationClick = function(p)
				if not v5() then
					return
				end

				assert(ModificationsMenu.IsInitialized, "bad ModificationsMenu")

				if ModificationsMenu:IsOpen() then
					return
				end

				print((`on mutation click purchased {p.Name}`))
				local unwrapped2 = ItemConfig.Query.selectOne({
					Index = {
						StorageKey = p.Name,
						IdType = "Moveset"
					},
					Variant = {
						Mutation = {
							Operation = "NEQ",
							Value = nil
						}
					}
				}):unwrap()
				local allModifications = Modification.getAllModifications(unwrapped2.Index.ItemId, "Mutation")

				if not (#allModifications > 0) then
					StateUtil.notifyError("Invalid mutation")
					return
				end

				setState11(true)
				ModificationsMenu.OnClosed:Once(function()
					setState11(false)
				end)
				ModificationsMenu:Open({
					Type = "MovesetMutation",
					MovesetType = "Fruit",
					AdorneeId = unwrapped2.Index.ItemId,
					AvailableModifications = allModifications,
					PurchaseEnabled = true
				})
			end,
			OnGiftClick = function(p)
				if not v5() then
					return
				end

				print((`on gift click purchased {p.Name}`))
				setState10(true)

				if v4 then
					v4:Destroy()
				end

				local shopData = v2[p.Name]

				if shopData then
					v4 = GiftWindow:Open({
						onClose = function()
							setState10(false)

							if v4 then
								v4:Destroy()
							end
						end,
						shopData = shopData,
						purchaseLocation = state4 == "ShopGui" and "FruitShop" or "FruitDealer"
					})
				else
					StateUtil.notifyError("Invalid gift")
				end
			end,
			FruitReleaseDate = 0
		}

		if state4 == "ShopGui" then
			state9 = nil
		end

		v16.FruitReleaseDate = state9
		return createElement(fragment, {}, {
			WarningDialog = warningDialog,
			DragonSelectionMenu = dragonSelectionMenu,
			Shop = createElement(FruitShop, v16, {})
		})
	end

	root:render(createElement(shopComponent, {}, {}))
	self._CleanUp = cleanUp
end

function class:_Close()
	if self._CleanUp then
		self._CleanUp()
		self._CleanUp = nil
	end
end

function class:Close(flag: boolean?)
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	self.OnClose:Fire(self.ShopContext, flag)
end

function class.init()
	class:GetIfInitialized()
	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "FruitShopAndDealer"
	screenGui.DisplayOrder = 4
	screenGui.Parent = playerGui
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = LastInput:Get() == "Touch"
	screenGui.ClipToDeviceSafeArea = true
	local object = setmetatable({
		_Root = screenGui,
		_CleanUp = nil,
		_UID = nil,
		_OpenAtFruit = nil,
		_IsAlive = true,
		IsOpen = false,
		_OnOpenAtFruitChange = Signal.new(),
		_OnContextChange = Signal.new(),
		_OnOpen = Signal.new(),
		OnClose = Signal.new(),
		ShopContext = "ShopGui"
	}, class)
	local v4 = v3
	v3 = object

	if v4 then
		v4:Destroy()
	end

	object:_Open()
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("FruitShop", function(...)
			return object:Open(...)
		end, function(...)
			return object:Close(...)
		end, function()
			return object.IsOpen
		end)
	end)
	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v3 or class
end)