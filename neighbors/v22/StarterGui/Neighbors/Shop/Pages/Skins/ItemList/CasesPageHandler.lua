game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Title)
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local _ = shop.InspectItemPage.InspectItem
local _ = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
require(ReplicatedStorage.Modules.Network)
require(ReplicatedStorage.Assets.Data.Case)
require(ReplicatedStorage.Assets.Data.Store.Titles)
require(ReplicatedStorage.Assets.Data.Store.Skins)
local specialCurrencySymbol = workspace:GetAttribute("SpecialCurrencySymbol")
local _ = Players.LocalPlayer

local function GetCases()
	local modulesByName = {}

	for _, moduleScript in ReplicatedStorage.Assets.Data.Crates:GetChildren() do
		local name = moduleScript.Name
		local module = require(moduleScript)
		modulesByName[name] = module
	end

	return modulesByName
end

local function IsWithinTimePeriod(p, p2: number)
	return p.Start < p2 and p2 < p.End
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function GetCaseTypeLayoutOrder(p: string)
	for _, child in ReplicatedStorage.Assets.Data.Crates:GetChildren() do
		if child.Name == p then
			return child:GetAttribute("LayoutOrder") or 0
		end
	end

	return 0
end

local function CreateCase(data, text: string, p)
	local clone = (p or example):Clone()
	local footer = clone.Footer
	local v = not data.Special and "$" or specialCurrencySymbol
	clone.ItemName.Title.Text = text
	local amount = footer.Credits.Amount
	local price = data.Price
	amount.Text = `{v}{string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	clone.Icon.Image = data.Icon or "rbxassetid://15989671213"
	return clone
end

local function CreateCaseList()
	local cases = GetCases()

	for childName, v2 in cases do
		for _, v3 in { shop.Pages:FindFirstChild(childName) } do
			local _ = v3.Visible
			local itemList = v3:FindFirstChild("ItemList")
			local frame = itemList:FindFirstChildOfClass("Frame")
			local frame2 = frame and frame.List:FindFirstChildOfClass("Frame")

			for k, v4 in pairs(v2) do
				local v5

				if v3.Name == "Special" then
					v5 = frame2
				else
					v5 = false
				end

				local clone = (v5 or example):Clone()
				local footer = clone.Footer
				local v6 = not v4.Special and "$" or specialCurrencySymbol
				clone.ItemName.Title.Text = k
				local amount = footer.Credits.Amount
				local price = v4.Price
				amount.Text = `{v6}{string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
				clone.Icon.Image = v4.Icon or "rbxassetid://15989671213"
				clone.Parent = itemList
				clone.Name = k:lower():gsub(" ", "_")
				clone.ItemName.Visible = false
				clone.Icon.ImageRectOffset = Vector2.new()
				clone.Icon.ImageRectSize = Vector2.new()
				clone.Icon.ScaleType = Enum.ScaleType.Stretch
				clone.LayoutOrder = v4.Price
				clone.Icon.BackgroundColor3 = v4.Color
				local total = 0

				for k2, item in v4.Items do
					if k2 ~= "Collectible" then
						total += #item
					end
				end

				local v7 = v4
				local v8 = v3

				local function GetVisibility()
					local offsale = v7.Offsale
					local v9 = total > 0
					local special = v7.Special

					if offsale or not v9 or special and v8.Name ~= "Special" then
						return false
					end

					if special or v8.Name ~= "Special" then
						return true
					end

					return false
				end

				local offsale = v4.Offsale
				local v9 = total > 0
				local special = v4.Special
				clone.Visible = not (offsale or not v9) and (not special or v3.Name == "Special") and ((special or v3.Name ~= "Special") and true or false)
				local v11 = childName
				local v12 = k
				clone.MouseButton1Click:Connect(function()
					if v11 == "Skins" then
						shop.ItemSkinsPage.Preview:Fire(v12)
					else
						shop.ItemTitlesPage.Preview:Fire(v12)
					end
				end)

				if childName == "Skins" then
					-- equivalent calls inferred from this helper; original call sites unknown
					local v13 = clone
					local v14 = k

					local function UpdateHidden()
						v13.Icon.Hidden.Visible = not Data.Inventory:Get(v14)
					end

					local UpdateHidden2 = UpdateHidden
					Data.Inventory:GetPropertyChangedSignal("Items"):Connect(function()
						return UpdateHidden2()
					end)
					UpdateHidden() -- equivalent call inferred; original call site unknown
				end

				UI:Bind(clone)
				UI:AddShadowOnHover(clone)
			end
		end
	end
end

task.wait(1)
CreateCaseList()