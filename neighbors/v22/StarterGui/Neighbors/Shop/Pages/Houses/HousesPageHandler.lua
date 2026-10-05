local ContentProvider = game:GetService("ContentProvider")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("UserInputService")
local parent = script.Parent.Parent.Parent
local _ = parent.Parent.Parent
local inspectItemPage = parent.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent2 = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local Network = require(ReplicatedStorage.Modules.Network)
local HouseSkins = require(ReplicatedStorage.Assets.Data.Store.HouseSkins)
local bindableEvent = Instance.new("BindableEvent")
local localPlayer = Players.LocalPlayer

local function GetSkins()
	return HouseSkins
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnSkin(p: string)
	return Data.HouseSkins:Get(p) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsSkinEquipped(p: string)
	if DoesOwnSkin(p) then
		return Data.HouseSkins:Get(p).Equipped
	end

	return false
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function CreateSkinCategory(text: string)
	local category = UI:CreateCategory(parent2)
	category.Collapsible.InfoContainer.Title.Text = text
	category.List.UIGridLayout.CellSize = UDim2.new(0, 146, 0, 87)
	category.List.UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	category.List.UIGridLayout.FillDirectionMaxCells = 4
	category.List.UIGridLayout.UIAspectRatioConstraint.AspectRatio = 1.678

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

local function CreateSkin(data, _: string)
	local clone = example:Clone()
	local footer = clone.Footer
	clone.ItemName.Title.Text = data.Display
	local amount = footer.Credits.Amount
	local price = data.Price
	amount.Text = `${string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	footer.Credits.Visible = data.Price > 0
	clone.Icon.Image = data.Thumbnails[1] or "rbxassetid://15989671213"
	return clone
end

local function SetupSlideshow(thumbnails)
	inspectItem.Item.ItemImage.Visible = false
	inspectItem.Item.Slideshow.Visible = true

	for _, image in inspectItem.Item.Slideshow:GetChildren() do
		if image:IsA("ImageLabel") and image.Visible then
			image:Destroy()
		end
	end

	for _, item in thumbnails do
		local clone = inspectItem.Item.Slideshow.ItemImage:Clone()
		clone.Image = item
		clone.Visible = true
		clone.Parent = inspectItem.Item.Slideshow
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(thumbnails)
	end)
end

local function UpdateItemPreview(data)
	inspectItemPage.Visible = true
	SetupSlideshow(data.Thumbnails)
	inspectItem.Description.Text = data.Description
	inspectItem.Item.ItemImage.Visible = true
	inspectItem.Item.Title.Visible = false
	inspectItem.ItemName.Text = data.Display
	local doesOwnSkin = DoesOwnSkin(data.Name) -- equivalent call inferred; original call site unknown
	local visible = IsSkinEquipped(data.Name) -- equivalent call inferred; original call site unknown

	if doesOwnSkin then
		inspectItem.Buttons.Equip.Visible = not visible
		inspectItem.Buttons.Unequip.Visible = visible
		inspectItem.ViewDesigns.Visible = localPlayer:GetAttribute("HouseEditor") and true or false
		inspectItem.Price.Visible = false
	else
		inspectItem.Buttons.Purchase.Visible = true
		inspectItem.Price.Visible = true
	end

	if data.Price == 0 then
		inspectItem.Price.Text = "FREE"
	elseif data.Price == 1e999 then
		inspectItem.Price.Text = ""
	else
		local price = inspectItem.Price
		local price2 = data.Price
		price.Text = "" .. string.format("%0.0f", price2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	local connections = {}
	table.insert(connections, inspectItem.Buttons.Equip.MouseButton1Click:Connect(function()
		if doesOwnSkin then
			Network:fire("EquipHouseSkin", data.Name)
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Unequip.MouseButton1Click:Connect(function()
		if doesOwnSkin then
			Network:fire("EquipHouseSkin", data.Name)
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:Connect(function()
		Network:fire("EquipHouseSkin", data.Name)
		inspectItemPage.Visible = false
	end))
	table.insert(connections, inspectItem.ViewDesigns.MouseButton1Click:Connect(function()
		local houses = localPlayer.PlayerGui.Prompts.Houses
		houses:SetAttribute("ActiveHouse", data.Name)
		houses.Visible = true
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		inspectItem.Item.ItemImage.Visible = true
		inspectItem.Item.Slideshow.Visible = false

		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

_G.InspectHouse = UpdateItemPreview

local function CreateSkinList()
	local skinCategory = CreateSkinCategory("Owned")
	skinCategory.Parent = parent2
	local skinCategory2 = CreateSkinCategory("For Sale")
	skinCategory2.Parent = parent2

	for k, v4 in HouseSkins do
		local name = v4.Name
		local skin = CreateSkin(v4, name)
		skin.Parent = skinCategory2.List
		skin.Name = name:lower():gsub(" ", "_")
		skin.LayoutOrder = k
		local v6 = v4

		local function UpdateVisibility()
			local text = parent.Hotbar.SearchBar.Search.TextBox.Text
			local v9 = not v6.Offsale

			if not v9 then
				v9 = DoesOwnSkin(name)
			end

			skin.Visible = v9 and name:lower():find(text:lower()) ~= nil and true or false
		end

		local skin2 = skin
		local name2 = name

		local function UpdateColor()
			local hidden = skin2.Icon.Hidden
			local visible = IsSkinEquipped(name2) -- equivalent call inferred; original call site unknown
			hidden.Visible = visible

			if skin2.Footer.Credits.Visible then
				skin2.Icon.Size = UDim2.new(1, 0, 1, -19)
				skin2.ItemName.Position = UDim2.new(0.5, 0, 1, -19)
			else
				skin2.Icon.Size = UDim2.new(1, 0, 1, 0)
				skin2.ItemName.Position = UDim2.new(0.5, 0, 1, 0)
			end
		end

		UpdateColor()
		UpdateVisibility()
		local skin3 = skin
		local name3 = name
		parent.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = parent.Hotbar.SearchBar.Search.TextBox.Text
			skin3.Visible = name3:lower():find(text:lower()) ~= nil
		end)
		local UpdateVisibility2 = UpdateVisibility
		local name4 = name
		local skin4 = skin
		local UpdateColor2 = UpdateColor
		bindableEvent.Event:Connect(function()
			UpdateVisibility2()
			local doesOwnSkin = DoesOwnSkin(name4) -- equivalent call inferred; original call site unknown
			skin4.Footer.Credits.Visible = not doesOwnSkin

			if doesOwnSkin then
				skin4.Parent = skinCategory.List
			else
				skin4.Parent = skinCategory2.List
			end

			UpdateColor2()
		end)
		local v15 = v4
		skin.MouseButton1Click:Connect(function()
			UpdateItemPreview(v15)
		end)
		UI:Bind(skin)
		UI:AddShadowOnHover(skin)
	end
end

Data.HouseSkins:GetPropertyChangedSignal("Items"):Connect(function()
	bindableEvent:Fire()
end)
CreateSkinList()