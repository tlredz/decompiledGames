local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local ItemRarityGradient = require(ReplicatedStorage.Utilities.ItemRarityGradient)
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
require(script.Parent.Types)
local isClient = RunService:IsClient()
local ClientState

if isClient then
	ClientState = require(ReplicatedStorage.ClientState)
else
	ClientState = nil
end

local NotificationSystem

if isClient then
	NotificationSystem = require(ReplicatedStorage.NotificationSystem)
else
	NotificationSystem = nil
end

local SoundManager

if isClient then
	SoundManager = require(ReplicatedStorage.SoundManager)
else
	SoundManager = nil
end

local PlayerUpgradesInventoryUI

if isClient then
	PlayerUpgradesInventoryUI = require(ReplicatedStorage.UISystems.PlayerUpgradesInventoryUI)
else
	PlayerUpgradesInventoryUI = nil
end

local color = Color3.fromRGB(255, 70, 70)
local color2 = Color3.fromRGB(100, 255, 100)
local v = {
	InvalidSlot = "Invalid item",
	OutOfStock = "Out of stock",
	NoData = "Please try again",
	GrantFailed = "Please try again",
	NoPriceConfig = "Unavailable",
	NotEnoughCurrency = "Not enough currency",
	ShopInactive = "This shop is not active on this server"
}

local function clearGuiChildren(instance)
	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local function fillStars(layoutContainer, tier: number)
	clearGuiChildren(layoutContainer)

	for _ = 1, tier do
		local clone = ReplicatedStorage.Templates.EmphasizedStar:Clone()
		clone.Visible = true
		clone.Parent = layoutContainer
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setButtonText(button, text: string)
	local title = button:FindFirstChild("Title") or button:FindFirstChild("Price")

	if title and title:IsA("TextLabel") then
		title.Text = text
	end
end

local ShopView = {}
ShopView.__index = ShopView

function ShopView.new(definition, actions)
	return (setmetatable({
		definition = definition,
		actions = actions,
		payload = nil,
		hasOpened = false,
		insideZone = false
	}, ShopView))
end

function ShopView:getModal()
	local playerGui = Players.LocalPlayer.PlayerGui

	for _, v2 in CollectionService:GetTagged(self.definition.ui.modalTag) do
		if v2:IsDescendantOf(playerGui) then
			return v2
		end
	end

	return nil
end

function ShopView:isOpen()
	local modal = self:getModal()
	return modal ~= nil and ClientState.ActiveModal == modal
end

function ShopView:toggle()
	local modal = self:getModal()

	if modal then
		self.hasOpened = true
		modal:SetAttribute("ModalVisibleY", self.definition.ui.modalVisibleY)
		ClientState:ToggleModal(modal, self)
		self.actions.requestState()
		self:render()
	end
end

function ShopView:open()
	if not self:isOpen() then
		self:toggle()
	end
end

function ShopView:close()
	if self:isOpen() then
		ClientState:CloseCurrentModal()
	end
end

function ShopView:createCard(parent, name: string, data)
	local definition = self.definition
	local v2 = Items.ITEMS[data.itemKey]
	local robuxProducts = definition.robuxProducts
	local v3

	if robuxProducts then
		v3 = robuxProducts[data.rarity]
	end

	local visible = data.remaining == nil or data.remaining > 0
	local clone = ReplicatedStorage.Templates[definition.ui.cardTemplate]:Clone()
	clone.Name = name
	clone.LayoutOrder = Items.RARITY_PRIORITY[data.rarity] * 10 - data.tier
	local container = clone.Container
	container.SpotFrame.Icon.Image = v2.icon
	ItemRarityGradient.apply(container.SpotFrame, data.rarity)
	local info = container.Info
	info.NameLabel.Text = v2.name
	info.Bonus.Text = string.format("+%d%%", Items.EntryBonusPercent(Items.Entry(data.itemKey, data.tier)))
	info.Rarity.Text = data.rarity

	if data.stock ~= nil then
		info.Amount.Current.Text = tostring(data.remaining)
		info.Amount.Max.Text = tostring(data.stock)
	end

	fillStars(container.TierFrame.LayoutContainer, data.tier)
	local buttons = container.Buttons
	local button = buttons[definition.ui.currencyButton]
	buttons.Owned.Visible = false
	button.Visible = visible
	buttons.BuyRobux.Visible = visible and v3 ~= nil
	buttons.BuyGift.Visible = visible and definition.giftable

	if data.price then
		setButtonText(button, Numbers.formatNumber(data.price)) -- equivalent call inferred; original call site unknown
	end

	if v3 then
		PlayerUpgradesInventoryUI.setRobuxPrice(buttons.BuyRobux, v3, Enum.InfoType.Product)
	end

	if visible then
		button.MouseButton1Down:Connect(function()
			self.actions.buyWithCurrency(name)
		end)
		buttons.BuyRobux.MouseButton1Down:Connect(function()
			self.actions.buyWithRobux(name)
		end)
		buttons.BuyGift.MouseButton1Down:Connect(function()
			PlayerUpgradesInventoryUI.openGiftModal(data.itemKey, {
				Source = definition.id,
				SlotId = name,
				Tier = data.tier
			})
		end)
	end

	clone.Parent = parent
end

function ShopView:updateRestockLabel(p2)
	local restockLabel = self.definition.ui.restockLabel
	local payload = self.payload

	if restockLabel and payload and payload.nextRestockTime then
		local v2 = math.max(0, (math.floor(payload.nextRestockTime - workspace:GetServerTimeNow())))
		p2.RestockFrame.TextLabel.Text = string.format(restockLabel, v2 // 60, v2 % 60)
	end
end

function ShopView:render()
	local modal = self:getModal()

	if modal and ClientState.ActiveModal == modal then
		local ownedItemsFrame = modal.ShopItemsFrame.OwnedItemsFrame
		clearGuiChildren(ownedItemsFrame)

		if self.payload then
			for k, slot in self.payload.slots do
				self:createCard(ownedItemsFrame, k, slot)
			end
		end

		self:updateRestockLabel(modal)
	end
end

function ShopView:showNotice(data)
	local ui = self.definition.ui

	if data.sound then
		SoundManager:Play(data.sound)
	end

	if data.error then
		NotificationSystem:ShowGeneralNotification(ui.errors[data.error] or v[data.error] or data.error, color)
	end

	if data.restock and ui.restockNotice then
		NotificationSystem:ShowGeneralNotification(ui.restockNotice, color2)
	end

	if data.itemAdded and ui.itemAddedNotice then
		local itemAdded = data.itemAdded
		local v2 = not (itemAdded.tier > 0) and "" or string.format(" (T%d)", itemAdded.tier)
		local v3 = Items.ITEMS[itemAdded.itemKey].name .. v2
		NotificationSystem:ShowGeneralNotification(string.format(ui.itemAddedNotice, v3), color2)
	end
end

function ShopView:receive(payload, p)
	if payload then
		self.payload = payload
		self:render()
	end

	if p and self.hasOpened then
		self:showNotice(p)
	end
end

function ShopView:update()
	if self.definition.ui.restockLabel then
		local modal = self:getModal()

		if modal and ClientState.ActiveModal == modal then
			self:updateRestockLabel(modal)
		end
	end
end

function ShopView:onZoneTouched(instance)
	local character = Players.LocalPlayer.Character

	if not self.insideZone and character and instance:IsDescendantOf(character) then
		self.insideZone = true
		self:open()
	end
end

function ShopView:onZoneTouchEnded(p, instance)
	local character = Players.LocalPlayer.Character

	if character and instance:IsDescendantOf(character) then
		task.delay(0.15, function()
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { character }
			overlapParams.FilterType = Enum.RaycastFilterType.Include

			if #workspace:GetPartsInPart(p, overlapParams) == 0 then
				self.insideZone = false
				self:close()
			end
		end)
	end
end

function ShopView:bindZone(part)
	if part:IsA("BasePart") then
		part.Touched:Connect(function(otherPart)
			self:onZoneTouched(otherPart)
		end)
		part.TouchEnded:Connect(function(otherPart)
			self:onZoneTouchEnded(part, otherPart)
		end)
	end
end

function ShopView:resetZone()
	self.insideZone = false
end

return ShopView