local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShopController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local shopEntryBuyButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ShopEntryBuyButton")
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(name)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.InspectCurrencyPage = Signal.new()
	self.Title = self.PromptFrame:WaitForChild("Title")
	self.LimitedFrame = self.PromptFrame:WaitForChild("Limited")
	self.Container = self.PromptFrame:WaitForChild("Container")
	self.LockedText = self.PromptFrame:WaitForChild("Locked")
	self.DisabledText = self.PromptFrame:WaitForChild("Disabled")
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ViewContentsButton = self.PromptFrame:WaitForChild("ViewContents")
	self.ButtonsFrame = self.PromptFrame:WaitForChild("Buttons")
	self.BuyRobuxButton = self.ButtonsFrame:WaitForChild("BuyRobux")
	self.BuyRobuxButtonText = self.BuyRobuxButton:WaitForChild("Value")
	self.BuyRobuxTripleButton = self.ButtonsFrame:WaitForChild("BuyRobuxTriple")
	self.BuyRobuxTripleButtonText = self.BuyRobuxTripleButton:WaitForChild("Value")
	self.AreYouSureTitle = self.ButtonsFrame:WaitForChild("AreYouSure")
	self.Name = name
	self.ShopEntry = ShopController:GetShopEntry(name)
	self._close_on_purchase = self.ShopEntry.EntryType == "Daily"
	self._reward_slots = {}
	self._update_text_bounds = {}
	self:_Init()
	return self
end

function object:Destroy()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	self.InspectCurrencyPage:Destroy()
	Prompt.Destroy(self)
end

function object:_Update()
	local cosmeticInventory = PlayerDataController:Get("CosmeticInventory")
	local reward = self.ShopEntry.Rewards[1]
	local cosmetic = CosmeticLibrary.Cosmetics[reward.Name]
	local v = cosmetic and CosmeticLibrary.Types[cosmetic.Type]
	local reward2 = CosmeticLibrary.Rewards[reward.Name]
	local ownsCosmetic = CosmeticLibrary:OwnsCosmetic(cosmeticInventory, reward.Name, reward.Weapon)
	local weapon = reward.Weapon

	if weapon then
		if reward.Weapon == "IsRandom" or reward.Weapon == "IsUniversal" then
			weapon = false
		else
			weapon = not PlayerDataController:GetWeaponData(reward.Weapon)
		end
	end

	local title = self.Title
	local type

	if v and v.IsWeaponCosmetic then
		type = (reward.Weapon == "IsRandom" and "Random" or reward.Weapon == "IsUniversal" and "Universal" or reward.Weapon) .. " " .. cosmetic.Type
	elseif cosmetic then
		type = cosmetic.Type
	else
		type = reward.Name
	end

	title.Text = type
	self.LockedText.Visible = ownsCosmetic or weapon
	self.LockedText.Text = ownsCosmetic and "Unavailable\nYou already own this" or not weapon and "" or "Unavailable\nYou don't own " .. (reward.Weapon or "") or ""
	local disabledText = self.DisabledText
	local visible = not self.LockedText.Visible

	if visible then
		if reward2 then
			if reward2.Type == "Lootbox" then
				visible = ComplianceController:ArePaidRandomItemsRestricted()
			else
				visible = false
			end
		else
			visible = reward2
		end
	end

	disabledText.Visible = visible
	self.ViewContentsButton.Visible = reward2 and reward2.Type == "Lootbox" and true or v and v.IsWeaponCosmetic and reward.Weapon == "IsRandom"
	self.ButtonsFrame.Visible = not (self.DisabledText.Visible or self.LockedText.Visible)
	self.BuyRobuxButton.Visible = not ownsCosmetic and not weapon and self.ShopEntry.ProductID ~= nil
	self.BuyRobuxTripleButton.Visible = not ownsCosmetic and not weapon and self.ShopEntry.ProductIDTriple ~= nil
	self.AreYouSureTitle.Visible = false

	if self.ShopEntry.ProductID then
		MonetizationController:SetRobuxText(self.BuyRobuxButtonText, self.ShopEntry.ProductID, Enum.InfoType.Product)
	end

	if self.ShopEntry.ProductIDTriple then
		MonetizationController:SetRobuxText(
			self.BuyRobuxTripleButtonText,
			self.ShopEntry.ProductIDTriple,
			Enum.InfoType.Product
		)
	end
end

function object:_Setup()
	self.LimitedFrame.Visible = self.ShopEntry.IsLimited

	for k, price in pairs(self.ShopEntry.Prices) do
		local v = CurrencyLibrary.Info[k]

		if v.OnlyDisplayBuyButtonAboveZeroBalance and PlayerDataController:Get(k) <= 0 then
			continue
		end

		local clone = shopEntryBuyButton:Clone()
		clone.LayoutOrder = v.OrderIndex
		clone.Free.Visible = price == 0
		clone.Price.Visible = price > 0
		clone.Price.Value.Text = Utility:PrettyNumber(price)
		clone.Price.Value.Icon.Image = v.ImageFlatOutline
		clone.Price.Value.Icon.ImageLabel.Image = v.ImageFlat
		clone.Price.Background.ImageColor3 = v.Color
		clone.Price.Background.UIGradient.Color = v.ColorGradient
		clone.Parent = self.ButtonsFrame
		ButtonEffect:Add(clone)
		local v2 = v
		local v3 = price
		local v4 = k
		clone.MouseButton1Click:Connect(function()
			if PlayerDataController:Get(v2.DataName) < v3 then
				if not MonetizationController:PromptCurrencyBundlePurchase(v3, v4) then
					Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
					return
				end

				self.InspectCurrencyPage:Fire()
				self:CloseRequest()
			elseif v2.NeedsAreYouSurePrompt and not self.AreYouSureTitle.Visible then
				for i, guiBase2d in pairs(self.ButtonsFrame:GetChildren()) do
					if guiBase2d:IsA("GuiBase2d") then
						guiBase2d.Visible = false
					end
				end

				clone.Visible = true
				self.AreYouSureTitle.Visible = true
			else
				Utility:CreateSound("rbxassetid://18210861148", 1, 1, script, true, 5)
				ShopController:PurchaseShopEntry(self.Name, v4)
				self:_Update()

				if self._close_on_purchase then
					self:CloseRequest()
				end
			end
		end)
		local value = clone.Price.Value
		-- equivalent calls inferred from this helper; original call sites unknown
		local icon = value.Icon

		local function update()
			icon.Position = UDim2.new(0.5, value.TextBounds.X / 2, 0.5, 0)
		end

		value:GetPropertyChangedSignal("TextBounds"):Connect(update)
		clone.AncestryChanged:Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	for k, reward in pairs(self.ShopEntry.Rewards) do
		local v = RewardSlot.new(reward)
		v.Frame.LayoutOrder = k
		v:SetParent(self.Container)
		table.insert(self._reward_slots, v)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.BuyRobuxButton.MouseButton1Click:Connect(function()
		if self._close_on_purchase then
			self:CloseRequest()
		end

		ShopController:PurchaseShopEntry(self.Name)
	end)
	self.BuyRobuxTripleButton.MouseButton1Click:Connect(function()
		if self._close_on_purchase then
			self:CloseRequest()
		end

		ShopController:PurchaseShopEntry(self.Name, nil, true)
	end)
	self.ViewContentsButton.MouseButton1Click:Connect(function()
		self.OpenPrompt:Fire(
			"InspectLootbox",
			self.ShopEntry.Rewards[1].Name,
			self.ShopEntry.Rewards[1].Weapon,
			"InspectShopEntry",
			self.Name
		)
	end)
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_Update()
	end))
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ViewContentsButton)
	ButtonEffect:Add(self.BuyRobuxButton)
	ButtonEffect:Add(self.BuyRobuxTripleButton)
end

return object