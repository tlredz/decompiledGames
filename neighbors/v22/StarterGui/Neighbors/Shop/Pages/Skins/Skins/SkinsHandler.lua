game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("UserInputService")
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local _ = shop.InspectItemPage.InspectItem
local parent = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local ShopUtil = require(ReplicatedStorage.Modules.ShopUtil)
local Case = require(ReplicatedStorage.Assets.Data.Case)
local Network = require(ReplicatedStorage.Modules.Network)
local bindableEvent = Instance.new("BindableEvent")
local _ = Players.LocalPlayer

local function GetCaseFromName(k: string)
	for k2, skin in ShopUtil.Cases.Skins do
		for _, list in pairs(skin.Items) do
			if table.find(list, k) then
				return k2, skin
			end
		end
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnSkin(p: string)
	return Data.Skins:Get(p) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsSkinEquipped(p: string)
	if DoesOwnSkin(p) then
		return Data.Skins:Get(p).Equipped
	end

	return false
end

local function CreateSkinCategory(text: string)
	local category = UI:CreateCategory(parent, true)
	category.Collapsible.InfoContainer.Title.Text = text

	local function GetItemCount()
		local count = 0

		for _, button in category.List:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		category.Visible = GetItemCount() > 0
	end

	category.List.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	category.List.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return category
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateSkin(skin, _: string)
	local clone = example:Clone()
	clone.ItemName.Title.Text = skin.Display
	clone.Icon.Image = skin.Icon or "rbxassetid://15989671213"
	return clone
end

local function CreateSkinList()
	local skins = ShopUtil.Skins
	local skinCategory = CreateSkinCategory("Equipped")
	skinCategory.Parent = parent
	local v2 = {}

	for k, skin in skins do
		local itemNameFromSkin = ShopUtil:GetItemNameFromSkin(k)

		if not itemNameFromSkin then
			continue
		end

		local item = ShopUtil:GetItem(itemNameFromSkin)

		if not item then
			continue
		end

		local count = 0
		local _, v3 = GetCaseFromName(k)

		if v3 then
			for k2, item2 in v3.Items do
				for _, _ in item2 do
					if k2 ~= "Collectible" then
						count += 1
					end
				end
			end
		end

		if count == 0 then
			continue
		end

		local v4 = v2[item.Display]

		if not v4 then
			v4 = CreateSkinCategory(item.Display)
			v4.Parent = parent
			v4.Name = item.Display:lower():gsub(" ", "_")
			v2[item.Display] = v4
			-- equivalent calls inferred from this helper; original call sites unknown
			local v5 = item

			local function UpdateCategoryText()
				local itemSkinsCount = ShopUtil:GetItemSkinsCount(v5.Name)
				v4.Collapsible.InfoContainer.Title.Text = v5.Display
				v4.Collapsible.InfoContainer.Badge.Text = `[{itemSkinsCount.Owned}/{itemSkinsCount.Total}]`
				v4.Collapsible.InfoContainer.Badge.Visible = true
			end

			UpdateCategoryText() -- equivalent call inferred; original call site unknown
			bindableEvent.Event:Connect(UpdateCategoryText)
		end

		local skin2 = CreateSkin(skin) -- equivalent call inferred; original call site unknown
		skin2.Parent = v4.List
		skin2.Name = k:lower():gsub(" ", "_")
		skin2.LayoutOrder = Case:GetRarityIndex(skin.Rarity)
		skin2.Visible = DoesOwnSkin(k)
		local v8 = k
		local v9 = Case:GetColors()[skin.Rarity]
		local v10 = skin

		local function UpdateColor()
			local skin3 = skin2
			local skinEquipped = IsSkinEquipped(v8) -- equivalent call inferred; original call site unknown
			skin3.Parent = skinEquipped and skinCategory.List or v4.List
			local hidden = skin2.Icon.Hidden
			local visible = IsSkinEquipped(v8) -- equivalent call inferred; original call site unknown
			hidden.Visible = visible
			local icon = skin2.Icon
			icon.BackgroundColor3 = DoesOwnSkin(v8) and v9 or v9:Lerp(Color3.new(0, 0, 0), 0.85)
			skin2.Rarity.BackgroundColor3 = Case:GetColors()[v10.Rarity] or Color3.new(1, 1, 1)
			local icon2 = skin2.Icon
			icon2.ImageColor3 = DoesOwnSkin(v8) and Color3.new(1, 1, 1) or Color3.new(0.25, 0.25, 0.25)
		end

		UpdateColor()
		local v11 = k
		local skin4 = skin2
		local v13 = itemNameFromSkin
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if Data.Skins:Get(v11) == nil then
				return
			end

			local text = shop.Hotbar.SearchBar.Search.TextBox.Text
			skin4.Visible = v11:lower():find(text:lower()) ~= nil or v13:lower():find(text:lower()) ~= nil
		end)
		local skin5 = skin2
		local v15 = k
		local UpdateColor2 = UpdateColor
		bindableEvent.Event:Connect(function()
			skin5.Visible = DoesOwnSkin(v15)
			UpdateColor2()
		end)
		local v16 = k
		skin2.MouseButton1Click:Connect(function()
			Network:fire("EquipSkin", v16)
		end)
		UI:Bind(skin2)
	end
end

Data.Skins:GetPropertyChangedSignal("Items"):Connect(function()
	bindableEvent:Fire()
end)
CreateSkinList()