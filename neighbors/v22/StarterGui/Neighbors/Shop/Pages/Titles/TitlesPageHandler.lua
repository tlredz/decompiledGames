game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local inspectItemPage = shop.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent = script.Parent
local example = script.Example

if UserInputService.TouchEnabled then
	example.Size = UDim2.new(1, 0, 0, 20)
end

local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local Network = require(ReplicatedStorage.Modules.Network)
local Title = require(ReplicatedStorage.Modules.Title)
local Case = require(ReplicatedStorage.Assets.Data.Case)
local localPlayer = Players.LocalPlayer
local v = {}
local bindableEvent = Instance.new("BindableEvent")

local function GetTitles()
	return Titles
end

local function GetEquippedTitle()
	return localPlayer:GetAttribute("Title")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnTitle(data)
	return Data.Titles:Get(data.Display) ~= nil
end

local v2 = {}

local function UpdateAllCategoryAmounts()
	for k, v3 in pairs(v) do
		local v4 = v2[k] or {}
		local count = 0

		for _, v5 in ipairs(v4) do
			if DoesOwnTitle(v5) then
				count += 1
			end
		end

		v3.Collapsible.Amount.Text = string.format("%d / %d Titles", count, #v4)
	end
end

local function UpdateTitlePreview(data)
	local doesOwnTitle = DoesOwnTitle(data) -- equivalent call inferred; original call site unknown
	inspectItemPage.Visible = true
	local hex = (Case:GetColors()[data.Rarity] or Color3.new(1, 1, 1)):ToHex()
	inspectItem.ItemName.Text = `{data.Display}  (<font color="#{hex}"> <stroke color="#000000">{data.Rarity or "Common"}</stroke></font> )`

	if not data.Rarity then
		inspectItem.ItemName.Text = data.Display
	end

	inspectItem.Description.Text = ""
	inspectItem.Item.ItemImage.Visible = false
	inspectItem.Item.Title.Visible = true
	Title:Construct(localPlayer, inspectItem.Item.Title, data.Display)

	if typeof(data.Description) == "function" then
		inspectItem.Description.Text = data.Description()
	elseif data.Description and data.Description ~= "" then
		inspectItem.Description.Text = data.Description
	else
		inspectItem.Description.Text = `"{data.Display}" Title`
	end

	inspectItem.Price.Text = ""
	local connections = {}

	if doesOwnTitle then
		if localPlayer:GetAttribute("Title") == data.Display then
			inspectItem.Buttons.Unequip.Visible = true
		else
			inspectItem.Buttons.Equip.Visible = true
		end
	end

	table.insert(connections, inspectItem.Buttons.Equip.MouseButton1Click:Connect(function()
		Network:fire("SetActiveTitle", data.Display)
		inspectItemPage.Visible = false
	end))
	table.insert(connections, inspectItem.Buttons.Unequip.MouseButton1Click:Connect(function()
		Network:fire("SetActiveTitle", data.Display)
		inspectItemPage.Visible = false
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

local function CreateTitleCategory(category: string)
	local category2 = UI:CreateCategory(parent, true)
	category2.Collapsible.InfoContainer.Title.Text = category
	category2.List.UIGridLayout:Destroy()
	local clone = script.UIListLayout:Clone()
	clone.Parent = category2.List

	local function GetItemCount()
		local count = 0

		for _, button in category2.List:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		category2.Visible = GetItemCount() > 0
	end

	category2.List.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	category2.List.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return category2
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function CreateTitle(p)
	local clone = example:Clone()
	clone.InfoContainer.Title.Text = p.Display
	local title = clone.ExistContainer.Title
	local v3 = Data.Titles.Owners[p.Display] or 0
	title.Text = `{string.format("%0.0f", v3):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	return clone
end

local function CreateTitleList()
	for k, title in Titles do
		local v3 = v[title.Category]
		v2[title.Category] = v2[title.Category] or {}
		table.insert(v2[title.Category], title)

		if not v3 then
			v3 = CreateTitleCategory(title.Category)
			v3.Parent = parent
			v[title.Category] = v3
		end

		local clone = example:Clone()
		clone.InfoContainer.Title.Text = title.Display
		local title2 = clone.ExistContainer.Title
		local v4 = Data.Titles.Owners[title.Display] or 0
		title2.Text = `{string.format("%0.0f", v4):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
		v3.LayoutOrder = title.Order
		clone.Parent = v3.List
		clone.Name = title.Display:lower():gsub(" ", "_")
		clone.LayoutOrder = title.Order
		clone.InfoContainer.Rarity.BackgroundColor3 = Case:GetColors()[title.Rarity] or Color3.new(1, 1, 1)
		local v5 = k
		local v6 = title

		local function UpdateColor()
			local enabled = localPlayer:GetAttribute("Title") == v5
			local hideIfNotOwned = v6.HideIfNotOwned
			local hidden = clone.Hidden
			hidden.Visible = Data.Titles:Get(v6.Display) == nil
			clone.Parent = enabled and parent or v3.List
			clone.UIGradient.Enabled = enabled
			local title3 = clone.ExistContainer.Title
			local v10 = Data.Titles.Owners[v6.Display] or 0
			title3.Text = `{string.format("%0.0f", v10):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
			clone.UIStroke.Color = Color3.new(0, 0, 0)
			clone.UIStroke.Transparency = 0.65
			clone.Size = UDim2.new(0.49, 0, 0, 20)
			clone.InfoContainer.Title.Text = v6.Display
			local v11 = clone
			local visible

			if hideIfNotOwned then
				visible = DoesOwnTitle(v6)
			else
				visible = true
			end

			v11.Visible = visible

			if enabled then
				clone.LayoutOrder = 2
				clone.UIStroke.Color = Color3.fromRGB(0, 98, 0)
				clone.UIStroke.Transparency = 0
				clone.Size = UDim2.new(1, 0, 0, 20)
				clone.InfoContainer.Title.Text = `<font color="#{Color3.fromRGB(0, 65, 0):ToHex()}"><b>[EQUIPPED]</b></font> {v6.Display}`
			end
		end

		UpdateColor()
		local v8 = clone
		local v9 = title
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local title3 = v8.ExistContainer.Title
			local v10 = Data.Titles.Owners[v9.Display] or 0
			title3.Text = `{string.format("%0.0f", v10):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
			local text = shop.Hotbar.SearchBar.Search.TextBox.Text

			if v9.HideIfNotOwned and Data.Titles:Get(v9.Display) == nil then
				return
			end

			v8.Visible = v9.Display:lower():find(text:lower()) ~= nil
		end)
		local UpdateColor2 = UpdateColor
		bindableEvent.Event:Connect(function()
			return UpdateColor2()
		end)
		local UpdateColor3 = UpdateColor
		localPlayer:GetAttributeChangedSignal("Title"):Connect(function()
			return UpdateColor3()
		end)
		local v10 = title
		clone.MouseButton1Click:Connect(function()
			if inspectItemPage.Visible then
				return
			end

			UpdateTitlePreview(v10)
		end)
		UI:Bind(clone)
		UI:AddShadowOnHover(clone)
	end

	UpdateAllCategoryAmounts()
end

Data.Titles:GetPropertyChangedSignal("Items"):Connect(function()
	bindableEvent:Fire()
end)
Data.Titles:GetPropertyChangedSignal("Owners"):Connect(function()
	bindableEvent:Fire()
end)
bindableEvent.Event:Connect(function()
	UpdateAllCategoryAmounts()
end)
parent.PreviewTitle.Event:Connect(function(p)
	UpdateTitlePreview(p)
end)
CreateTitleList()