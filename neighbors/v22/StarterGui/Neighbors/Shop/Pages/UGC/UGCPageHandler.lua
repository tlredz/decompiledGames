local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shop = script:FindFirstAncestor("Shop")
local uGCDisclaimer = shop.Parent.Parent:WaitForChild("Prompts"):WaitForChild("UGCDisclaimer")
local parent = script.Parent
local example = script.Example
local UI = require(ReplicatedStorage.Modules.UI)
local Data = require(game.ReplicatedStorage.Modules.Data)
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local UGC = require(ReplicatedStorage.Assets.Data.Store.UGC)
Data.Inventory:WaitFor("Get")

local function CreateItemCategory(text: string)
	local category = UI:CreateCategory(parent)
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

local function CreateUGC(id: number, info)
	local clone = example:Clone()
	local footer = clone.Footer
	clone.ItemName.Title.Text = info.Name
	footer.Credits.Amount.Text = "" .. ` {info.PriceInRobux}`
	clone.Icon.Image = `rbxthumb://type=Asset&id={id}&w=420&h=420`
	clone:SetAttribute("ID", id)
	pcall(function()
		clone.Icon.Hidden.Visible = MarketplaceService:PlayerOwnsAsset(localPlayer, id)

		if clone.Icon.Hidden.Visible then
			clone.LayoutOrder -= 1000
		end
	end)
	return clone
end

local function CreateUGCList()
	local itemCategory = CreateItemCategory("UGC")
	itemCategory.Name = "UGC"
	local v2 = {}

	for _, id in UGC do
		local v4 = id
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(v4)
		end)

		if success and result and result.PriceInRobux then
			table.insert(v2, {
				Id = id,
				Price = result.PriceInRobux,
				Info = result
			})
		end
	end

	table.sort(v2, function(a, b)
		return a.Price < b.Price
	end)

	for _, v3 in v2 do
		local UGC2 = CreateUGC(v3.Id, v3.Info)

		if not UGC2 then
			continue
		end

		UGC2.Parent = itemCategory.List
		local UGC3 = UGC2
		local v6 = v3
		UGC2.MouseButton1Click:Connect(function()
			if UGC3.Icon.Hidden.Visible then
				_G.DisplayError("You already own this UGC!", 3)
				return
			end

			uGCDisclaimer.Icon.Image = `rbxthumb://type=Asset&id={v6.Id}&w=420&h=420`
			uGCDisclaimer.Visible = true
			local mouseButton1ClickConnection = uGCDisclaimer.Buttons.Confirm.Button.MouseButton1Click:Connect(function()
				MarketplaceService:PromptPurchase(localPlayer, v6.Id, true)
				uGCDisclaimer.Visible = false
			end)
			uGCDisclaimer:GetPropertyChangedSignal("Visible"):Once(function()
				mouseButton1ClickConnection:Disconnect()
			end)
		end)
		UI:Bind(UGC2)
		UI:AddShadowOnHover(UGC2)
	end

	MarketplaceService.PromptPurchaseFinished:Connect(function(_, p, p2)
		if p2 then
			for _, child in itemCategory.List:GetChildren() do
				if child:GetAttribute("ID") ~= p then
					continue
				end

				child.Icon.Hidden.Visible = true
				child.LayoutOrder -= 1000
				_G.DisplaySuccess((`You have successfully purchased {child.Footer.ItemName.Text}!`))
				shop.ShopHandler.BuySound:Play()
			end
		end
	end)
	itemCategory.Parent = parent
end

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	local _ = script.Parent.Visible
end)
CreateUGCList()