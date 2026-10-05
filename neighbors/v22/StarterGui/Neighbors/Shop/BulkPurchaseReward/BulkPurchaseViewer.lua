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
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local Skins = require(ReplicatedStorage.Assets.Data.Store.Skins)
local template = script.Template
local skinTemplate = script.SkinTemplate
local frame = script.Parent.Frame
local _ = frame.ItemName
local close = frame.Close
local skinList = frame.SkinList

local function DoesOwnItem(p: string)
	return Data.Titles:Get(p) ~= nil
end

local function CreateCaseItem(name: string, p: string)
	local clone = template:Clone()
	Title:Construct(localPlayer, clone.Title, name)
	clone.Name = name
	clone.BackgroundColor3 = Case:GetColors()[p]
	clone.LayoutOrder = Case:GetRarityIndex(p)
	clone.Owned.Visible = false
	return clone
end

local function CreateSkin(skin, item: string)
	local clone = skinTemplate:Clone()
	local footer = clone.Footer
	footer.ItemName.Text = skin.Display
	footer.Price.Text = ""
	clone.Icon.Image = skin.Icon or "rbxassetid://15989671213"
	clone.BackgroundColor3 = Case:GetColors()[skin.Rarity]
	clone.LayoutOrder = Case:GetRarityIndex(skin.Rarity)
	clone.Button.MouseButton1Click:Connect(function()
		Network:fire("EquipSkin", item)
	end)
	return clone
end

local function GetTitleFromName(p: string)
	return Titles[p]
end

local function GetSkinFromName(p: string)
	return Skins[p]
end

local function ClearPage()
	for _, child in skinList:GetChildren() do
		if child:IsA(template.ClassName) then
			child:Destroy()
		end
	end
end

local function UpdatePage(items, p: number, p2: number, p3: string)
	ClearPage()
	script.Parent.Frame.RefundInfo.Text = `You rolled {p} duplicates, you were refunded ${Money(p2, true)}`

	for _, item in items do
		if p3 == "Titles" then
			local rarity = Titles[item].Rarity
			local clone = template:Clone()
			Title:Construct(localPlayer, clone.Title, item)
			clone.Name = item
			clone.BackgroundColor3 = Case:GetColors()[rarity]
			clone.LayoutOrder = Case:GetRarityIndex(rarity)
			clone.Owned.Visible = false
			clone.Visible = true
			clone.Parent = skinList
		else
			local skin = CreateSkin(Skins[item], item)
			skin.Visible = true
			skin.Parent = skinList
		end
	end

	script.Parent.Visible = true
end

Network:listen("BulkPurchaseDisplay", function(p, p2: number, p3: number, p4: string)
	UpdatePage(p, p2, p3, p4)
end)
close.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
end)
UI:RegisterScrollingFrame(skinList, { script.Parent.Parent.UIScale, script.Parent.Parent.Parent.UIScale })
UI:Bind(close)