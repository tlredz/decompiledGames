local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local GiftWindow = require(game.ReplicatedStorage.Controllers.UI.GiftWindow)
local GiftClaimWindow = require(game.ReplicatedStorage.Controllers.UI.GiftClaimWindow)
local Shop = require(game.ReplicatedStorage.Shop)
require(game.ReplicatedStorage.Modules.Util.Trove)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local AnalyticsClient = require(game.ReplicatedStorage.Controllers.AnalyticsClient)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local Shop2 = require(game.ReplicatedStorage.React.Components.Shop)
local Scrim = require(game.ReplicatedStorage.React.Components.Shop.Scrim)
local ConfirmationDialog = require(game.ReplicatedStorage.React.Components.Shop.ConfirmationDialog)
local Global = require(game.ReplicatedStorage.Global)
local commF_ = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local playerGui

if RunService:IsRunning() then
	local Players2 = game:GetService("Players")
	playerGui = Players2.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game:GetService("CoreGui")
end

local createElement = React.createElement
local v = nil
local class = {}
class.__index = class

function class:BuyAsync(value)
	local v2

	if type(value) == "number" then
		v2 = ItemConfig.match(value):asNullable()
	else
		v2 = ItemConfig.match(value, "Redeemable"):asNullable()
	end

	if not v2 then
		warn((`Attempted to buy item with invalid product reference: "{value}"`))
		return
	end

	self._OnSelect:Fire(v2.Index.ItemId)
	self._OnItemSelectionLost:Wait()
	self:Close()
end

function class:GiftAsync(value)
	local v2

	if type(value) == "number" then
		v2 = ItemConfig.match(value):asNullable()
	else
		v2 = ItemConfig.match(value, "Redeemable"):asNullable()
	end

	if not v2 then
		warn((`Attempted to buy item with invalid product reference: "{value}"`))
		return
	end

	self._OnSelect:Fire(v2.Index.ItemId)
	self._OnItemSelectionLost:Wait()
	self:Close()
end

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v == self then
		v = nil
	end

	for _, _Connection in self._Connections do
		_Connection:Disconnect()
	end

	for _, callback in self._Callbacks do
		pcall(callback)
	end

	setmetatable(self, nil)
	table.clear(self)
end

function class:Open(value)
	if self.IsOpen then
		return
	end

	AnalyticsClient:ReportShoppingStep({
		funnelId = "Shop",
		step = 1
	})
	Players.LocalPlayer:SetAttribute("NewGiftCount", nil)
	self.IsOpen = true
	local v2

	if type(value) == "number" then
		v2 = ItemConfig.match(value):asNullable()
	elseif type(value) == "string" then
		v2 = ItemConfig.match(value, "Redeemable"):asNullable()
	end

	local _OnOpen = self._OnOpen
	local v3

	if v2 then
		v3 = v2.Index.ItemId
	end

	_OnOpen:Fire(v3)
end

function class:Close(p: string?)
	if not self.IsOpen then
		return
	end

	self.IsOpen = false
	self._OnClose:Fire()
	self.OnClosed:Fire(p)
end

function class:GetIfInitialized()
	if v == self and v and v._IsAlive then
		return true
	end

	return false
end

function class.init()
	local v2 = v

	if v2 and v2:GetIfInitialized() then
		return function()
			v2:Destroy()
		end
	end

	local object = setmetatable({
		_IsAlive = true,
		_Connections = {},
		_Callbacks = {},
		IsOpen = false,
		_OnItemSelectionLost = Signal.new(),
		OnClosed = Signal.new(),
		_OnOpen = Signal.new(),
		_OnSelect = Signal.new(),
		_OnClose = Signal.new()
	}, class)

	function Global.hookBuy(p, p2)
		if p2 == "Buy" or p2 == nil then
			object:BuyAsync(p)
		else
			object:GiftAsync(p)
		end
	end

	local v3 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBadge(giftCount: number?)
		local v4 = giftCount or 0
		assert(v4, "bad gift Count")
		local v5 = v4 - v3
		v3 = v4
		local newGiftCount = Players.LocalPlayer:GetAttribute("NewGiftCount")
		Players.LocalPlayer:SetAttribute(
			"NewGiftCount",
			(math.max(0, (type(newGiftCount) ~= "number" and 0 or newGiftCount) + v5))
		)
	end

	table.insert(object._Connections, Players.LocalPlayer:GetAttributeChangedSignal("GiftCount"):Connect(function()
		local giftCount = Players.LocalPlayer:GetAttribute("GiftCount")

		if type(giftCount) == "number" then
			updateBadge(giftCount) -- equivalent call inferred; original call site unknown
		else
			updateBadge(nil) -- equivalent call inferred; original call site unknown
		end
	end))
	task.spawn(function()
		local giftCount = Players.LocalPlayer:GetAttribute("GiftCount")

		if type(giftCount) ~= "number" then
			return
		end

		updateBadge(giftCount) -- equivalent call inferred; original call site unknown
	end)

	local function component(_)
		local ref = React.useRef(nil)
		local state, setState = React.useState(object.IsOpen)
		local state2, setState2 = React.useState(false)
		local state3, setState3 = React.useState(nil)
		React.useEffect(function()
			if not state3 then
				object._OnItemSelectionLost:Fire()
			end
		end, { state3 })

		local function onInteraction(p)
			print((`Shop interaction: {p}`))

			if p.Type == "Select" then
				setState3(p.ItemId)
			elseif p.Type == "Exit" then
				setState3(nil)
				object:Close("ExitButton")
			elseif p.Type == "GiftBanner" then
				print("Open Gift Shop clicked")
				object:Close()
				GiftClaimWindow:Open()
			elseif p.Type == "FruitShop" then
				local FruitShop = require(game.ReplicatedStorage.Controllers.UI.FruitShop)
				print("Open Fruit Shop clicked")
				object:Close()
				FruitShop:Open("ShopGui")
				local _, v4 = FruitShop.OnClose:Wait()

				if v4 ~= false then
					object:Open()
				end
			elseif p.Type == "GiftProduct" then
				local itemId = p.ItemId
				local unwrapped = Shop.match(itemId):unwrap()
				local current = ref.current

				if current then
					current:Destroy()
				end

				current = GiftWindow:Open({
					onClose = function()
						setState3(nil)

						if current then
							current:Destroy()
						end
					end,
					shopData = unwrapped:ToLegacy():unwrap(),
					purchaseLocation = "Shop"
				})
				ref.current = current
			elseif p.Type == "Premium" then
				commF_:InvokeServer("buyPremium")
			elseif p.Type == "PurchaseProduct" then
				setState3(nil)
				local itemId = p.ItemId
				local unwrapped = ItemConfig.match(itemId):unwrap()
				AnalyticsClient:ReportShoppingStep({
					funnelId = "Shop",
					purchaseLocation = "Shop",
					storageName = unwrapped.Index.StorageKey,
					step = 2
				})
				commF_:InvokeServer("buyRobuxShop", {
					StorageName = unwrapped.Index.StorageKey,
					PurchaseLocation = "Shop",
					FunnelId = "Shop"
				})
			elseif p.Type == "ChromaticBanner" then
				print("ChromaticGacha clicked")
				local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)
				GachaWindow:Open("PremiumChromaticMagnetGacha26", nil, setState2)
			end
		end

		React.useEffect(function()
			local connection = object._OnSelect:Connect(function(itemId: number?)
				if not itemId then
					setState3(itemId)
					return
				end

				local unwrapped = ItemConfig.match(itemId):unwrap()
				assert(unwrapped.Economy, "tried to buy item without economy config")

				if unwrapped.Economy.IsGiftable then
					setState3(itemId)
				else
					onInteraction({
						Type = "PurchaseProduct",
						ItemId = itemId
					})
				end
			end)
			local connection2 = object._OnOpen:Connect(function(itemId: number?)
				setState(true)

				if itemId then
					local unwrapped = ItemConfig.match(itemId):unwrap()
					assert(unwrapped.Economy, "tried to buy item without economy config")

					if unwrapped.Economy.IsGiftable then
						setState3(itemId)
					else
						onInteraction({
							Type = "PurchaseProduct",
							ItemId = itemId
						})
					end
				end
			end)
			local connection3 = object._OnClose:Connect(function()
				setState(false)
				setState3(nil)
			end)
			return function()
				connection:Disconnect()
				connection2:Disconnect()
				connection3:Disconnect()
			end
		end, {})
		local v6 = {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = not state2
		}
		local confirmationDialogGui

		if state3 and not state then
			confirmationDialogGui = ReactRoblox.createPortal(createElement("ScreenGui", {
				DisplayOrder = 8,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ScreenInsets = Enum.ScreenInsets.None,
				SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
				IgnoreGuiInset = true,
				ResetOnSpawn = false
			}, {
				Scrim = createElement(Scrim, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 40, 1, 40),
					ZIndex = 3
				}, {
					ConfirmationDialog = createElement(ConfirmationDialog, {
						ItemId = state3,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.55),
						ZIndex = 4,
						OnBuy = function()
							onInteraction({
								Type = "PurchaseProduct",
								ItemId = state3
							})
						end,
						OnGift = function()
							onInteraction({
								Type = "GiftProduct",
								ItemId = state3
							})
						end,
						OnCancel = function()
							onInteraction({
								Type = "Select"
							})
						end
					})
				})
			}), playerGui)
		end

		return createElement("Frame", v6, {
			ConfirmationDialogGui = confirmationDialogGui,
			Shop = createElement(Shop2, {
				IsOpen = state,
				SelectedItemId = state3,
				OnInteraction = onInteraction,
				[React.Change.AbsoluteSize] = function(p)
					object._AbsoluteArea = Rect.new(p.AbsolutePosition, p.AbsolutePosition + p.AbsoluteSize)
				end,
				[React.Change.AbsolutePosition] = function(p)
					object._AbsoluteArea = Rect.new(p.AbsolutePosition, p.AbsolutePosition + p.AbsoluteSize)
				end
			})
		})
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "ShopMenuRoot"
	screenGui.Parent = playerGui
	screenGui.DisplayOrder = 2
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(React.createElement(component, {}), screenGui)))
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Shop", function(...)
			return object:Open(...)
		end, function(...)
			return object:Close(...)
		end, function()
			return object.IsOpen
		end)
	end)

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	v = object
	return function()
		object:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)