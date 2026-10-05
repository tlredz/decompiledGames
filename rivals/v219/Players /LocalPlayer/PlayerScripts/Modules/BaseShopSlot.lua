local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local BaseShopSlot = {}
BaseShopSlot.__index = BaseShopSlot

function BaseShopSlot.new(shopEntry, p)
	local self = setmetatable({}, BaseShopSlot)
	self.ShopEntry = shopEntry
	self.FirstRewardData = self.ShopEntry.Rewards[1]
	self.IsOwned = CosmeticLibrary:OwnsCosmetic(
		PlayerDataController:Get("CosmeticInventory"),
		self.FirstRewardData.Name,
		self.FirstRewardData.Weapon
	)
	local weapon = self.FirstRewardData.Weapon

	if weapon then
		if self.FirstRewardData.Weapon == "IsRandom" or self.FirstRewardData.Weapon == "IsUniversal" then
			weapon = false
		else
			weapon = not PlayerDataController:GetWeaponData(self.FirstRewardData.Weapon)
		end
	end

	self.IsLockedRaw = weapon
	self.IsLocked = p or false
	self:_Init()
	return self
end

function BaseShopSlot.OnClick(_, _)
	assert(false, "Not implemented")
end

function BaseShopSlot:Destroy() end

function BaseShopSlot._SetupBuyButton(data, instance, p)
	local cosmetic = CosmeticLibrary.Cosmetics[data.FirstRewardData.Name]
	local v = CurrencyLibrary.Info[data.ShopEntry.MainCurrency]
	local price = data.ShopEntry.Prices[data.ShopEntry.MainCurrency]

	if p then
		p.Visible = data.IsOwned
	end

	instance.Visible = not data.IsOwned
	instance.Limited.Visible = false
	instance.Locked.Visible = not instance.Limited.Visible and data.IsLocked
	instance.Price.Visible = not (instance.Limited.Visible or data.IsLocked) and data.ShopEntry.MainCurrency and price > 0
	instance.Free.Visible = not (instance.Limited.Visible or data.IsLocked) and data.ShopEntry.MainCurrency and price == 0
	instance.Robux.Visible = not instance.Limited.Visible and not data.IsLocked and data.ShopEntry.ProductID
	instance.Size = cosmetic and UDim2.new(0.5, 0, 0.25, 0) or UDim2.new(0.625, 0, 0.3125, 0)

	if instance.Price.Visible then
		instance.Price.Value.Text = Utility:PrettyNumber(price)
		instance.Price.Value.Icon.Image = v.ImageFlatOutline
		instance.Price.Value.Icon.ImageLabel.Image = v.ImageFlat
		instance.Price.Background.ImageColor3 = v.Color
		instance.Price.Background.UIGradient.Color = v.ColorGradient
	end

	if data.ShopEntry.ProductID then
		MonetizationController:SetRobuxText(instance.Robux.Value, data.ShopEntry.ProductID, Enum.InfoType.Product)
	end

	for _, v2 in pairs({
		"Locked",
		"Price",
		"Free",
		"Robux",
		"Limited"
	}) do
		if not instance[v2].Visible then
			instance[v2]:Destroy()
		end
	end

	if instance:FindFirstChild("Price") then
		local value = instance.Price.Value
		local icon = value.Icon

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			icon.Position = UDim2.new(0.5, value.TextBounds.X / 2, 0.5, 0)
		end

		value:GetPropertyChangedSignal("TextBounds"):Connect(update)
		instance.AncestryChanged:Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

function BaseShopSlot:_Init() end

return BaseShopSlot