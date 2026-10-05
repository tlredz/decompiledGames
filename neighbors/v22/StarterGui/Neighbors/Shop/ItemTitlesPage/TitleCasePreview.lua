local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Case = require(ReplicatedStorage.Assets.Data.Case)
local Title = require(ReplicatedStorage.Modules.Title)
local UI = require(ReplicatedStorage.Modules.UI)
local Money = require(ReplicatedStorage.Modules.Money)
local Network = require(ReplicatedStorage.Modules.Network)
local Data = require(ReplicatedStorage.Modules.Data)
local ShopUtil = require(ReplicatedStorage.Modules.ShopUtil)
local template = script.Template
local preview = script.Parent.Preview
local frame = script.Parent.Frame
local itemName = frame.ItemName
local close = frame.Close
local skinList = frame.SkinList
local shop = script:FindFirstAncestor("Shop")
local sidebar = script.Parent.Sidebar
local rarities = sidebar.Rarities
local description = sidebar.Bottom.Description
local _ = sidebar.Price
local purchase = sidebar.Bottom.Purchase
local purchase10 = sidebar.Bottom.Purchase10
local v = nil
local v2 = 1
local v3 = { "Unique", "???", "Collectible" }

local function UpdateSidebarRarities(p)
	for _, frame2 in rarities:GetChildren() do
		if not frame2:IsA("Frame") then
			continue
		end

		local v4 = p[frame2.Name] or 0
		frame2.Label.Text = Case:GetRarityDisplay(frame2.Name)
		frame2.Value.TextColor3 = Case:GetColors()[frame2.Name]
		frame2.Value.Text = `{v4}%`
		frame2.Visible = v4 > 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnItem(name: string)
	return Data.Titles:Get(name) ~= nil
end

local function GetCases()
	local modulesByName = {}

	for _, moduleScript in ReplicatedStorage.Assets.Data.Crates:GetChildren() do
		local name = moduleScript.Name
		local module = require(moduleScript)
		modulesByName[name] = module
	end

	return modulesByName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCaseInfoFromCaseName(p: string)
	return GetCases().Titles[p]
end

local function CreateCaseItem(name: string, k: string, itemChances)
	local clone = template:Clone()
	local doesOwnItem = DoesOwnItem(name) -- equivalent call inferred; original call site unknown
	local title = ShopUtil:GetTitle(name)
	Title:Construct(localPlayer, clone.Title, name)

	if not table.find(v3, title.Rarity) and title.Price and title.Price ~= 1e999 then
		clone.BuyTitle.Visible = not doesOwnItem
		clone.BuyTitle.Label.Text = `{Money(title.Price)}`
		clone.Button.MouseEnter:Connect(function()
			clone.BuyTitle.Label.Text = "Buy"
		end)
		clone.Button.MouseLeave:Connect(function()
			clone.BuyTitle.Label.Text = `{Money(title.Price)}`
		end)
	end

	local v5 = itemChances[name] or 0
	clone.Header.Badge.Text = `{v5}%`
	clone.Header.Visible = v5 > 0
	clone.Name = name
	clone.BackgroundColor3 = Case:GetColors()[k]
	clone.LayoutOrder = Case:GetRarityIndex(k)
	clone.Owned.Visible = not doesOwnItem
	clone.Equipped.Visible = doesOwnItem and localPlayer:GetAttribute("Title") == name
	clone.Button.Activated:Connect(function()
		if doesOwnItem then
			Network:fire("SetActiveTitle", name)
		elseif clone.BuyTitle.Visible then
			localPlayer.PlayerGui.Prompts.ShopPrompt:SetAttribute("ItemName", title.Display)
			localPlayer.PlayerGui.Prompts.ShopPrompt.Visible = true
		end
	end)
	UI:AddShadowOnHover(clone)
	UI:Bind(clone.Button)
	return clone
end

local function UpdatePrice(p)
	local caseInfoFromCaseName = GetCaseInfoFromCaseName(p) -- equivalent call inferred; original call site unknown
	local v5 = not caseInfoFromCaseName.Special and "$" or workspace:GetAttribute("SpecialCurrencySymbol")
	purchase.Content.Text = `Buy 1 ({v5}{Money(caseInfoFromCaseName.Price, true)})`
	purchase10.Content.Text = `Buy 10 ({v5}{Money(caseInfoFromCaseName.Price * 10, true)})`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateQuantity()
	UpdatePrice(v)
end

local function ClearPage()
	v2 = 1
	UpdateQuantity() -- equivalent call inferred; original call site unknown

	for _, child in skinList:GetChildren() do
		if child:IsA(template.ClassName) then
			child:Destroy()
		end
	end
end

local function UpdatePage(p)
	local caseInfoFromCaseName = GetCaseInfoFromCaseName(p) -- equivalent call inferred; original call site unknown
	local canvasPosition

	if v == p then
		canvasPosition = skinList.CanvasPosition
	end

	ClearPage()
	local itemChances, v5 = Case:GetItemChances(caseInfoFromCaseName)
	UpdateSidebarRarities(v5)
	local count = 0
	local count2 = 0

	for k, item in caseInfoFromCaseName.Items do
		if k == "Collectible" then
			continue
		end

		for _, v6 in item do
			local caseItem = CreateCaseItem(v6, k, itemChances)

			if not caseItem.Owned.Visible then
				count2 += 1
			end

			count += 1
			caseItem.Parent = skinList
		end
	end

	itemName.Text = `{p} ({count2} / {count})`
	UpdatePrice(p)
	description.Text = caseInfoFromCaseName.Description

	if canvasPosition then
		skinList.CanvasPosition = canvasPosition
	end

	purchase.Blocked.Visible = _G.Policy.ArePaidRandomItemsRestricted and true or false
	script.Parent.Visible = true
end

preview.Event:Connect(function(p: string)
	v = p
	return UpdatePage(p)
end)
purchase.MouseButton1Click:Connect(function()
	if _G.Policy.ArePaidRandomItemsRestricted then
		return _G.DisplayError("Due to country regulations, you are unable to open random cases.", 5)
	end

	Network:fire("BuyCase", v, 1)
end)
purchase10.MouseButton1Click:Connect(function()
	if _G.Policy.ArePaidRandomItemsRestricted then
		return _G.DisplayError("Due to country regulations, you are unable to open random cases.", 5)
	end

	Network:fire("BuyCase", v, 10)
end)
close.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
end)
Data.Titles:GetPropertyChangedSignal("Items"):Connect(function()
	if script.Parent.Visible and v then
		return UpdatePage(v)
	end
end)
localPlayer:GetAttributeChangedSignal("Title"):Connect(function()
	if script.Parent.Visible and v then
		return UpdatePage(v)
	end
end)
script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	for _, v4 in shop:QueryDescendants("GuiButton") do
		if not (v4.Name ~= "Close" and (v4:FindFirstAncestor("Tabs") or v4:FindFirstAncestor("Hotbar") or v4.Parent.Name == "Header")) then
			continue
		end

		v4.Active = not script.Parent.Visible
	end
end)
Network:listen("BulkPurchaseDisplay", function()
	script.Parent.Visible = false
end)
sidebar.Quantity.Decrease.MouseButton1Click:Connect(function()
	v2 = math.max(v2 - 1, 1)
	UpdateQuantity() -- equivalent call inferred; original call site unknown
end)
sidebar.Quantity.Increase.MouseButton1Click:Connect(function()
	v2 += 1
	UpdateQuantity() -- equivalent call inferred; original call site unknown
end)
UI:RegisterScrollingFrame(skinList, { script.Parent.Parent.UIScale, script.Parent.Parent.Parent.UIScale })
UI:Bind(close)
UI:Bind(purchase)
UI:Bind(purchase10)