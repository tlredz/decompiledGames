local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.MarketplaceService)
local localPlayer = Players.LocalPlayer
game:GetService("ContextActionService")
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v5 = require3(ReplicatedStorage2.Shared.Statable)
local v6 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v7 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v8 = require3(ReplicatedStorage2.ServerInfo)
local v9 = require3(script.Parent.Parent)
local v10 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v11 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v12 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v13 = require3(ReplicatedStorage2.Controllers.HalloweenGachaNPCController)
local v14 = require3(ReplicatedStorage2.Shared.UiPresets)
local v15 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local playerGui = localPlayer.PlayerGui
local mobileShop = playerGui:WaitForChild("MobileShop")
local main = mobileShop.Main
local pages = mobileShop:WaitForChild("Pages")
local secretUpgrade = playerGui:WaitForChild("SecretUpgrade")
local v16 = {
	Sword = v5.State(),
	Explosion = v5.State(),
	Ability = v5.State(),
	DevProduct = v5.State(),
	GamePass = v5.State()
}
local state = v5.State("Abilities")
local v17 = {
	Normal = 0,
	Rare = 1,
	Legendary = 2,
	Limited = 3,
	LimitedU = 4,
	Unique = 5,
	Secret = 6
}
local v18 = {
	Normal = Color3.fromRGB(124, 120, 113),
	Limited = Color3.fromRGB(37, 131, 255),
	LimitedU = Color3.fromRGB(37, 131, 255),
	Rare = Color3.fromRGB(218, 59, 59),
	Legendary = Color3.fromRGB(255, 204, 0),
	Unique = Color3.fromRGB(120, 17, 129),
	Secret = Color3.fromRGB(44, 44, 44)
}
local Mobile = {
	PageInfo = {
		Sword = {
			ItemState = v16.Sword,
			Template = mobileShop.Templates.SwordTemplate,
			PageName = "Swords"
		},
		Explosion = {
			ItemState = v16.Explosion,
			Template = mobileShop.Templates.ExplosionTemplate,
			PageName = "Explosions"
		},
		Ability = {
			ItemState = v16.Ability,
			Template = mobileShop.Templates.AbilityTemplate,
			PageName = "Abilities"
		},
		DevProduct = {
			ItemState = v16.DevProduct,
			Template = mobileShop.Templates.DevProductTemplate,
			PageName = "Coins"
		},
		GamePass = {
			ItemState = v16.GamePass,
			Template = mobileShop.Templates.GamePassTemplate,
			PageName = "Passes"
		}
	},
	SetSelectedItems = function(self)
		local v19 = self.DataReplion:Get({ "SwordSkins", "CurrentlySelected" }) or "Base Sword"
		v16.Sword:Set(v9:GetSwordData(v10.Swords[v19]))
		local v20 = self.DataReplion:Get({ "Abilities", "CurrentlySelected" }) or "Dash"
		v16.Ability:Set(v9:GetAbilityData(v10.Abilities[v20]))
		local v21 = self.DataReplion:Get({ "ExplosionSkins", "CurrentlySelected" }) or "Explosion Normal"
		v16.Explosion:Set(v9:GetExplosionData(v10.Explosions[v21]))
	end,
	Open = function(self)
		v2:Open("MobileShop")
		v12:Hide("MobileShop")
		self:SetSelectedItems()
		v6(Enum.CoreGuiType.Chat, false)
	end,
	Close = function(self)
		v2:Close("MobileShop")
		v12:Show("MobileShop")
		v6(Enum.CoreGuiType.Chat, true)
	end
}

local function applyColor(instance, color)
	if typeof(color) == "Color3" then
		instance.TextColor3 = color
		return
	end

	instance.TextColor3 = Color3.new(1, 1, 1);
	(instance:FindFirstChildWhichIsA("UIGradient") or Instance.new("UIGradient", instance)).Color = color
end

function Mobile.SetCurrentPage(_, p: string)
	warn("Setting Page too", p)
	state:Set(p)
end

function Mobile:SelectedAbilityHandler(_)
	local abilities = pages:WaitForChild("Abilities")
	local btns = abilities:WaitForChild("Right"):WaitForChild("Btns")
	local equip = btns:WaitForChild("Equip")
	local upgradeButton = btns:WaitForChild("UpgradeButton")
	local arrowButton = btns:WaitForChild("ArrowButton")
	local upgrades = btns:WaitForChild("Upgrades")
	v5.Computed(function(callback)
		local v19 = callback(v16.Ability)

		if v19 then
			if callback(v19.Owns) then
				equip.Visible = true

				if not v19.ItemInfo.Upgrade.NonUpgradable then
					upgrades.Visible = true
					arrowButton.Visible = true
					upgradeButton.Visible = true
				end

				equip.Frame.Icon.Visible = false
				equip.Frame.Equip.Text = callback(v19.IsEquipped) and "Equipped" or "Equip"
			else
				if v19.ItemInfo.Price then
					equip.Visible = true
					equip.Frame.Icon.Visible = true
					equip.Frame.Equip.Text = v19.ItemInfo.Price
				else
					equip.Visible = false
				end

				upgrades.Visible = false
				upgradeButton.Visible = false
				arrowButton.Visible = false
			end
		end
	end)
	local v19 = v3.new()
	v5.Computed(function(callback)
		v19:Destroy()
		local v20 = callback(v16.Ability)

		if v20 then
			if v20.ItemInfo.Upgrade.NonUpgradable and not v20.ItemInfo.Upgrade.CustomUpgrade then
				upgrades.Visible = false
				upgradeButton.Visible = false
				arrowButton.Visible = false
			end

			if v20.ItemInfo.Upgrade.CustomUpgrade then
				warn("?")
			end

			local v21 = callback(v20.UpgradeLevel) or 0
			local maxUpgrade = v20.ItemInfo.Upgrade.MaxUpgrade

			if v21 == maxUpgrade then
				upgradeButton.UpgradeCost.Text = "Max"
			else
				warn(callback(v20.UpgradePrice))
				upgradeButton.UpgradeCost.Text = callback(v20.UpgradePrice)
			end

			for i = 1, maxUpgrade do
				local clone = v19:Clone(mobileShop.Templates.AbilityUpgradeTemplate)
				clone.LayoutOrder = i

				if i <= v21 then
					clone.Image = "rbxassetid://15645666568"
				end

				clone.Parent = upgrades
			end

			for k, text in v20.ItemInfo.Upgrade.UpgradeInfo do
				local clone = v19:Clone(mobileShop.Templates.AbilityUpgradeInfoTemplate)
				clone.fade.TextLabel.Text = "Upgrade " .. k
				clone.Visible = true
				clone.LayoutOrder = k
				clone.TextLabel.Text = text
				clone.Parent = abilities.Upgrades.ScrollingFrame
			end
		end
	end)
	v14.animateButtonClick(abilities.Upgrades.Close)
	abilities.Upgrades.Close.Activated:Connect(function()
		abilities.Black.Visible = false
		abilities.Upgrades.Visible = false
	end)
	v14.animateButtonClick(arrowButton)
	arrowButton.Activated:Connect(function()
		abilities.Black.Visible = true
		abilities.Upgrades.Visible = true
	end)
	v14.animateButtonClick(equip)
	equip.Activated:Connect(function()
		local v20 = v16.Ability:Get()

		if v20 then
			if v20.Owns:Get() then
				v9:SetEquipped(v20.ItemInfo)
			else
				v9:RequestAbilityPurchase(v20)
			end
		end
	end)
	upgradeButton.Activated:Connect(function()
		local v20 = v16.Ability:Get()

		if v20 then
			local customUpgrade = v20.ItemInfo.Upgrade.CustomUpgrade

			if customUpgrade then
				if customUpgrade == "TimeHole" then
					v13:OpenPhantomUpgrade()
				else
					v2:Open(customUpgrade)
				end
			end

			v9:RequestAbilityUpgrade(v20)
		end
	end)
	v14.animateButtonClick(upgradeButton)
	v14.animateButtonClick(equip)
end

function Mobile:SelectedSwordHandler(instance)
	local right = mobileShop.Pages:WaitForChild("Swords"):WaitForChild("Right")
	local purchaseButton = right:WaitForChild("PurchaseButton")
	local finisherButton = right:WaitForChild("FinisherButton")
	local secretUpgrade2 = right:WaitForChild("SecretUpgrade")
	v5.Computed(function(callback)
		local v19 = callback(v16.Sword)

		if v19 then
			if callback(v19.Owns) then
				purchaseButton.Visible = true
				purchaseButton.Equip.Text = callback(v19.IsEquipped) and "Equipped" or "Equip"
			else
				purchaseButton.Visible = false
			end

			finisherButton.Visible = v19.ItemInfo.HasFinisher
			local v20 = callback(v19.OwnsFinisher)
			finisherButton.Label.Text = v20 and "Equip" or "OBTAIN IN SCI FI SPINS"

			if callback(v19.IsFinisherEquipped) then
				finisherButton.Label.Text = "Unequip"
			end

			secretUpgrade2.Visible = v19.ItemInfo.HasAwaken
		end
	end)
	v14.animateButtonClick(finisherButton)
	finisherButton.Activated:Connect(function()
		local v19 = v16.Sword:Get()

		if v19 then
			if v19.OwnsFinisher:Get() then
				v9:RequestFinisherEquip(v19.ItemInfo)
			else
				v2:Open("SciFiGacha")
			end
		end
	end)
	v14.animateButtonClick(secretUpgrade2)
	secretUpgrade2.Activated:Connect(function()
		local v19 = v16.Sword:Get()

		if v19 then
			secretUpgrade:SetAttribute("ToAwaken", v19.ItemInfo.Name)
			v2:Open(secretUpgrade.Name)
		end
	end)
	v14.animateButtonClick(purchaseButton)
	purchaseButton.Activated:Connect(function()
		local v19 = v16.Sword:Get()

		if v19 then
			v9:SetEquipped(v19.ItemInfo)
		end
	end)
	local itemViewport = right:WaitForChild("ItemViewport")
	v5.Computed(function(callback)
		instance:Destroy()
		local v19 = callback(v16.Sword)

		if v19 and not v19.ItemInfo.Icon then
			local v20 = v4:SetSwordIconAsViewportByName(itemViewport, v19.ItemInfo.Name)
			right.ItemIcon.Visible = false
			right.ItemViewport.Visible = true

			if v20 then
				instance:Add(v20)
			end
		end
	end)
end

function Mobile:SelectedExplosion(_)
	local right = pages:WaitForChild("Explosions"):WaitForChild("Right")
	local itemTitle = right:WaitForChild("ItemTitle")
	local equip = right:WaitForChild("Equip")
	v5.Computed(function(callback)
		local v19 = callback(v16.Explosion)

		if v19 then
			local itemInfo = v19.ItemInfo
			itemTitle.Text = itemInfo.Title.Text
			itemTitle.UIStroke.Color = itemInfo.Title.StrokeColor
			applyColor(itemTitle, itemInfo.Title.Color)
		end
	end)
	v5.Computed(function(callback)
		local v19 = callback(v16.Explosion)

		if v19 then
			if callback(v19.Owns) then
				equip.Visible = true
				equip.Equip.Text = callback(v19.IsEquipped) and "Equipped" or "Equip"
			else
				equip.Visible = false
			end
		end
	end)
	v14.animateButtonClick(equip)
	equip.Activated:Connect(function()
		local v19 = v16.Explosion:Get()

		if v19 then
			v9:SetEquipped(v19.ItemInfo)
		end
	end)
end

function Mobile:GeneralHandler(_, p, childName: string)
	local right = mobileShop.Pages:WaitForChild(childName):WaitForChild("Right")
	local itemTitle = right:WaitForChild("ItemTitle")
	local desc = right:WaitForChild("Desc")

	if p.ItemInfo.Icon then
		local itemIcon = right:WaitForChild("ItemIcon")
		itemIcon.Visible = true
		itemIcon.Image = p.ItemInfo.Attributes and p.ItemInfo.Attributes.AltIcon or p.ItemInfo.Icon
	end

	if p.ItemInfo.Description then
		desc.Text = p.ItemInfo.Description
	end

	itemTitle.Text = p.ItemInfo.DisplayName or p.ItemInfo.Name
end

function Mobile:SetupPageRight()
	local v19 = v3.new()
	local v20 = v3.new()

	for _, v21 in Mobile.PageInfo do
		local pageName = v21.PageName
		local itemState = v21.ItemState
		v5.Computed(function(callback)
			local v24 = callback(itemState)

			if not v24 then
				return nil
			end

			self:GeneralHandler(callback, v24, pageName)
		end)
	end

	self:SelectedAbilityHandler(v20)
	self:SelectedExplosion(v19)
	self:SelectedSwordHandler(v19)
end

function Mobile:RenderSword(data, instance, maid)
	local itemInfo = data.ItemInfo
	instance:WaitForChild("EquipButton")
	local favorite = instance:WaitForChild("Favorite")
	maid:Add(v5.Computed(function(callback)
		local v19 = v17[data.ItemInfo.Rarity]
		local v20 = callback(data.Owns)

		if v20 then
			v19 = math.abs(v19 - 4)
		end

		instance.LayoutOrder = v19 or -1
		instance.LayoutOrder += callback(data.IsFavorited) and -500 or 0
		instance.LayoutOrder += v20 and -100 or 0
	end))
	maid:Add(v5.Computed(function(callback)
		favorite.Visible = callback(data.Owns)
		favorite.Image = callback(data.IsFavorited) and "rbxassetid://15697987058" or "rbxassetid://15697983062"
	end))
	v14.animateButtonClick(favorite)
	favorite.Activated:Connect(function()
		v9:ToggleFavorited(itemInfo)
	end)
	maid:Add(v5.setPropertyComputed(instance, "Visible", function(callback)
		return not itemInfo.Hidden or callback(data.Owns) or itemInfo.AlwaysVisible
	end))

	if itemInfo.Icon then
		instance.ItemIcon.Visible = true
		instance.ItemIcon.Image = itemInfo.Icon
		instance.ViewportFrame.Visible = false
	else
		instance.ViewportFrame.Visible = true
		instance.ItemIcon.Visible = false
		v4:SetSwordIconAsViewportByName(instance.ViewportFrame, data.ItemInfo.Name)
	end

	instance.ItemName.Text = data.ItemInfo.DisplayName
	instance.ImageColor3 = v18[data.ItemInfo.Rarity] or v18.Normal
	instance.Parent = pages.Swords.Items
end

function Mobile:RenderExplosion(p, state2, maid)
	local itemInfo = p.ItemInfo
	state2.ItemTitle.Text = itemInfo.Title.Text
	state2.ItemTitle.UIStroke.Color = itemInfo.Title.StrokeColor
	state2.ItemSubText.Text = itemInfo.SubText.Text
	state2.ItemSubText.UIStroke.Color = itemInfo.SubText.StrokeColor
	applyColor(state2.ItemTitle, itemInfo.Title.Color)
	applyColor(state2.ItemSubText, itemInfo.SubText.Color)
	maid:Add(v5.setPropertyComputed(state2, "LayoutOrder", function(callback)
		if callback(p.Owns) then
			return -100
		end

		return 0
	end))
	maid:Add(v5.setPropertyComputed(state2.ItemTitle, "Position", function(callback)
		return callback(p.Owns) and UDim2.fromScale(0.5, 0.7) or UDim2.fromScale(0.5, 0.9)
	end))
	state2.ItemIcon.Image = v4:GetExplosionIcon(p.ItemInfo.Name)
	state2.Parent = pages.Explosions.Items
end

function Mobile:RenderAbility(data, instance, maid)
	local itemInfo = data.ItemInfo
	local equipButton = instance:WaitForChild("EquipButton")
	local purchaseButton = instance:WaitForChild("PurchaseButton")
	maid:Add(v5.setPropertyComputed(instance.ItemLevel, "Text", function(callback)
		return string.format("Lv. %d", callback(data.UpgradeLevel) or 1)
	end))
	maid:Add(v5.setPropertyComputed(instance.ItemLevel, "Visible", function(callback)
		return callback(data.UpgradeLevel) >= 1
	end))
	maid:Add(v5.setPropertyComputed(instance, "LayoutOrder", function(callback)
		return itemInfo.Order - (callback(data.Owns) and 50 or 0) - (itemInfo.Price and 10 or 0)
	end))
	v5.Computed(function(callback)
		local v19 = callback(data.Owns)

		if v19 or not itemInfo.Price then
			if v19 then
				purchaseButton.Visible = false
				equipButton.Visible = true
			end
		else
			equipButton.Visible = false
			purchaseButton.Visible = true
			purchaseButton.Frame.Equip.Text = itemInfo.Price
		end
	end)
	v14.animateButtonClick(purchaseButton)
	purchaseButton.Activated:Connect(function()
		if not data.Owns:Get() and itemInfo.Price then
			v9:RequestAbilityPurchase(data)
		end
	end)
	applyColor(instance.ItemName, itemInfo.Title.Color)
	instance.ItemName.Text = itemInfo.Title.Text
	instance.ItemName.UIStroke.Color = itemInfo.Title.StrokeColor
	instance.ImageColor3 = v18.Limited
	instance.ItemIcon.Image = itemInfo.Attributes and itemInfo.Attributes.AltIcon or itemInfo.Icon
	instance.Parent = pages.Abilities.Items
end

function Mobile:RenderDevProduct(p, instance, maid)
	local itemInfo = p.ItemInfo
	instance.CoinAmount.Text = itemInfo.CoinReward
	local buyButton = instance:WaitForChild("BuyButton")
	maid:Add(v5.setPropertyComputed(instance.BuyButton.Text, "Text", function(callback)
		local v19 = callback(p.ProductInfo)
		return v19 and string.format(" %d", v19.PriceInRobux) or "PRICE_UNAVALIABLE!"
	end))
	v14.animateButtonClick(buyButton)
	v14.animateButtonClick(instance.GiftButton)
	instance.GiftButton.Activated:Connect(function()
		v11:SetGift(itemInfo.DisplayName)
	end)
	buyButton.Activated:Connect(function()
		v15:PromptPurchase(itemInfo.ProductId, Enum.InfoType.Product)
	end)
	instance.ItemIcon.Image = itemInfo.Icon or v4:GetIcon("DEFAULT_MISSING")
	instance.Parent = pages.Coins.Items
end

function Mobile:RenderGamePass(data, instance, maid)
	local itemInfo = data.ItemInfo
	local buyButton = instance:WaitForChild("BuyButton")
	instance.GamePass.Fade.ItemTitle.Text = itemInfo.DisplayName
	instance.GamePass.Image = itemInfo.Icon
	instance.Desc.Text = itemInfo.Description
	v14.animateButtonClick(buyButton)
	v14.animateButtonClick(instance.GiftButton)
	instance.GiftButton.Activated:Connect(function()
		v11:SetGift(itemInfo.GiftName)
	end)
	maid:Add(v5.setPropertyComputed(instance.BuyButton.Text, "Text", function(callback)
		if callback(data.Owns) then
			return "Purchased"
		end

		local v19 = callback(data.ProductInfo)
		return v19 and string.format(" %d", v19.PriceInRobux) or "PRICE_UNAVALIABLE!"
	end))
	buyButton.Activated:Connect(function()
		if data.Owns:Get() then
			return
		end

		v:PromptGamePassPurchase(Players.LocalPlayer, itemInfo.ProductId)
	end)
	instance.Parent = pages.Passes.Items
end

function Mobile:RenderSlot(data)
	local itemInfo = data.ItemInfo
	local v19 = Mobile.PageInfo[data.ItemInfo.ItemType]
	local maid = v3.new()
	local clone = v19.Template:Clone()
	maid:Add(clone.Activated:Connect(function()
		v16[itemInfo.ItemType]:Set(data)
	end))

	if itemInfo.ItemType == "Sword" or itemInfo.ItemType == "Ability" or itemInfo.ItemType == "Explosion" then
		clone.ImageColor3 = v18.Limited
		local equipButton = clone:WaitForChild("EquipButton")
		local equip = equipButton:WaitForChild("Equip")
		v5.Computed(function(callback)
			if callback(data.Owns) then
				equipButton.Visible = true
				equip.Text = callback(data.IsEquipped) and "Equipped" or "Equip"
			end
		end)
		v14.animateButtonClick(equipButton)
		equipButton.Activated:Connect(function()
			v16[itemInfo.ItemType]:Set(data)
			v9:SetEquipped(itemInfo)
		end)
		v14.animateButtonClick(clone)
		clone.Activated:Connect(function(_, p)
			if p == 1 then
				v16[itemInfo.ItemType]:Set(data)
				v9:SetEquipped(itemInfo)
			end
		end)
	end

	v14.animateButtonHover(clone)
	clone.Visible = true

	if itemInfo.ItemType == "Sword" then
		Mobile:RenderSword(data, clone, maid)
	elseif itemInfo.ItemType == "Explosion" then
		Mobile:RenderExplosion(data, clone, maid)
	elseif itemInfo.ItemType == "Ability" then
		Mobile:RenderAbility(data, clone, maid)
	elseif itemInfo.ItemType == "DevProduct" then
		Mobile:RenderDevProduct(data, clone, maid)
	elseif itemInfo.ItemType == "GamePass" then
		Mobile:RenderGamePass(data, clone, maid)
	end

	return clone, function()
		maid:Destroy()
	end
end

function Mobile.HandlePageChange(_, _: string) end

function Mobile:Start()
	self.DataReplion = client:WaitReplion("Data")
	local tabs = main:WaitForChild("Tabs")
	local money = main:WaitForChild("Money")
	local color = Color3.fromRGB(63, 63, 63)
	local color2 = Color3.fromRGB(26, 126, 21)

	for _, frame in pages:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local name = frame.Name
		local child = tabs:FindFirstChild(name)

		if not child then
			continue
		end

		local name2 = name
		local v20 = child
		local v21 = frame
		v5.Computed(function(callback)
			local visible = callback(state) == name2
			v20.Image = visible and "rbxassetid://15643806432" or "rbxassetid://15643737651"
			v20.HoverImage = visible and "rbxassetid://15643806432" or "rbxassetid://14782685409"
			v20.Text.UIStroke.Color = visible and color2 or color
			v21.Visible = visible
		end)
		local name3 = name
		child.Activated:Connect(function()
			state:Set(name3)
		end)
	end

	v2:OnGuiClose("GiftingUI", function()
		task.wait()
		v2:Open("MobileShop", true)
		v2:Lock("MobileShop", true)
		task.wait()
		v2:Unlock("MobileShop", true)
		v2:Close("MobileShop", true)
		self:Close()
	end)
	v2:OnGuiClose("MobileShop", function()
		task.wait()

		if not v2:IsOpen("GiftingUI") then
			self:Close()
		end
	end)
	money.Text = v7:AddCommas(self.DataReplion:Get("Credits") or 0)
	self.DataReplion:OnChange("Credits", function(p, _)
		money.Text = v7:AddCommas(p)
	end)
	self:SetupPageRight()
	v3.new()
	local itemsList = v9:GetItemsList(function(p)
		return p.ItemType ~= "Ability" or not v8.isElementalServer()
	end)
	local v19 = {}

	for _, v20 in itemsList do
		v19[v20] = self:RenderSlot(v9:GetItemData(v20))
	end

	mobileShop.Close.Activated:Connect(function()
		self:Close()
	end)
end

return Mobile