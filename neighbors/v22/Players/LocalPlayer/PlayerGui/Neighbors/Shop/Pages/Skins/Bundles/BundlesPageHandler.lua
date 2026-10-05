game:GetService("MarketplaceService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
require(ReplicatedStorage.Modules.Title)
local shop = script:FindFirstAncestor("Shop")
local parent = shop.Parent.Parent
local inspectItemPage = shop.InspectItemPage
local _ = inspectItemPage.InspectItem
local parent2 = script.Parent
local clone = script.Example:Clone()
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local Network = require(ReplicatedStorage.Modules.Network)
local GiftUtil = require(ReplicatedStorage.Modules.GiftUtil)
require(ReplicatedStorage.Assets.Data.Store.Titles)
require(ReplicatedStorage.Assets.Data.Store.Skins)
local Bundles = require(ReplicatedStorage.Assets.Data.Store.Bundles)
local localPlayer = Players.LocalPlayer
local itemSkinsPage = shop.ItemSkinsPage
local frame = itemSkinsPage.Frame
local purchase = itemSkinsPage.Frame.Purchase
local gift = itemSkinsPage.Frame.Gift
local cancel = itemSkinsPage.Frame.Cancel
local starterPackImageFrame = script.StarterPackImageFrame
local v = {}

local function GetBundles()
	return Bundles
end

local function IsWithinTimePeriod(p, p2: number)
	return p.Start < p2 and p2 < p.End
end

local function CommaValue(p: number)
	return string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function GetBundleTypeLayoutOrder(p: string)
	for _, child in ReplicatedStorage.Assets.Data.Crates:GetChildren() do
		if child.Name == p then
			return child:GetAttribute("LayoutOrder") or 0
		end
	end

	return 0
end

local function CreateBundleCategory(text: string)
	local category = UI:CreateCategory(parent2)
	category.Collapsible.InfoContainer.Title.Text = text

	local function GetItemCount()
		local count = 0

		for _, frame2 in category.List:GetChildren() do
			if frame2:IsA("Frame") and frame2.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		category.Visible = GetItemCount() > 0
	end

	category.List.ChildAdded:Connect(function(frame2)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if frame2:IsA("Frame") then
			frame2:GetPropertyChangedSignal("Visible"):Connect(function()
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

local function CreateBundle(data, name: string)
	local clone2 = clone:Clone()
	local footer = clone2.Footer

	while not data.Ready do
		task.wait()
	end

	clone2.ItemName.Title.Text = name
	local title = footer.Buy.Title
	local price = tonumber(data.Price) or -1
	title.Text = ` {string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	clone2.Icon.Image = data.Icon or "rbxassetid://15989671213"
	return clone2
end

local function PromptBundle(data, flag: boolean?)
	local name = data.Name
	local price = data.Price
	purchase:SetAttribute("ProductId", data.ProductId)
	inspectItemPage.InspectItem.ItemName.Text = name
	FullClose = flag or false
	frame.NeedOwnHint.Visible = #(data.Skins or {}) > 0
	frame.BundlePrice.Visible = true
	frame.ItemName.Text = name
	local bundlePrice = frame.BundlePrice
	local v2 = tonumber(price) or -1
	bundlePrice.Text = `Price:  {string.format("%0.0f", v2):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`
	purchase.Visible = true
	gift.Visible = true
	cancel.Visible = false
	itemSkinsPage.Sidebar.Visible = false
	itemSkinsPage.Preview:Fire(name)
end

local function CreateBundleList()
	local bundleCategory = CreateBundleCategory("Bundles")
	bundleCategory.Parent = shop.Pages.Skins.ItemList
	bundleCategory.Name = "Bundles"
	bundleCategory.LayoutOrder = -1000

	for _, v4 in Bundles do
		if not v4.LimitedTime then
			continue
		end

		local limitedTime = v4.LimitedTime
		local now = os.time()
		local v5

		if limitedTime.Start < now then
			v5 = now < limitedTime.End
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		local name = v4.Name
		local bundle = CreateBundle(v4, name)
		bundle.Parent = bundleCategory.List
		bundle.Name = name:lower():gsub(" ", "_")
		bundle.Visible = #(v4.Skins or {}) + #(v4.Items or {}) + #(v4.Titles or {}) + #(v4.Emotes or {}) + #(v4.Backgrounds or {}) + #(v4.Banners or {}) + #(v4.Avatars or {}) + (v4.Credits and 1 or 0) > 0
		local v7 = v4
		bundle.MouseButton1Click:Connect(function()
			PromptBundle(v7)
		end)
		-- equivalent calls inferred from this helper; original call sites unknown
		local v9 = v4

		local function UpdateHidden()
			bundle.Icon.Hidden.Visible = localPlayer:GetAttribute((`P{v9.ProductId}`))
		end

		local UpdateHidden2 = UpdateHidden
		localPlayer:GetAttributeChangedSignal((`P{v4.ProductId}`)):Connect(function()
			return UpdateHidden2()
		end)
		UpdateHidden() -- equivalent call inferred; original call site unknown
		UI:Bind(bundle)
		UI:AddShadowOnHover(bundle)
		v[name] = v4
	end
end

ProximityPromptService.PromptTriggered:Connect(function(player)
	if player:GetAttribute("isBundle") then
		shop:SetAttribute("Visible", true)
		shop.Visible = true
		local v2 = nil

		for _, bundle in Bundles do
			if bundle.Name ~= player:GetAttribute("Bundle") then
				continue
			end

			v2 = bundle
			break
		end

		PromptBundle(v2, true)
	end
end)
frame.Purchase.MouseButton1Click:Connect(function()
	local productId = frame.Purchase:GetAttribute("ProductId")

	if productId and frame.Parent.Visible then
		if localPlayer:GetAttribute((`P{productId}`)) then
			_G.DisplayError("You already own the bundle!", 5)
		elseif localPlayer:GetAttribute("Special") then
			Network:fire("BuyBundleSpecialUser", productId)
		else
			local MarketplaceService = game:GetService("MarketplaceService")
			MarketplaceService:PromptProductPurchase(localPlayer, productId)
		end
	end
end)
frame.Gift.MouseButton1Click:Connect(function()
	GiftUtil:PromptGift(frame.Purchase:GetAttribute("ProductId"))
end)
frame.Cancel.MouseButton1Click:Connect(function()
	frame.Cancel.Visible = false
	frame.Gift.Visible = true
	frame.Purchase.Visible = true
end)
frame.Close.MouseButton1Click:Connect(function()
	itemSkinsPage.Sidebar.Visible = true

	if FullClose then
		shop.Visible = false
		FullClose = false
	end

	itemSkinsPage.Frame.BundlePrice.Visible = false
	itemSkinsPage.Frame.NeedOwnHint.Visible = false
	frame.Cancel.Visible = false
	frame.Gift.Visible = false
	frame.Purchase.Visible = false
end)

local function getStarterPackBundle()
	for _, bundle in Bundles do
		if not (bundle.StarterPack and bundle.LimitedTime) then
			continue
		end

		local limitedTime = bundle.LimitedTime
		local now = os.time()
		local v2

		if limitedTime.Start < now then
			v2 = now < limitedTime.End
		else
			v2 = false
		end

		if v2 then
			return bundle
		end
	end

	return nil
end

local function setupStarterPackIcon(parent3, starterPackBundle)
	local child = parent3:FindFirstChild(starterPackImageFrame.Name)

	if child then
		child:Destroy()
	end

	local clone2 = starterPackImageFrame:Clone()
	local starterPackImage = clone2.StarterPackImage
	local ray = clone2.Ray
	starterPackImage.Image = starterPackBundle.Icon
	local uIScale = clone2:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Parent = clone2
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local v2 = nil
	TweenService:Create(ray, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Rotation = 360
	}):Play()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startTilt()
		starterPackImage.Rotation = -6
		v2 = TweenService:Create(starterPackImage, tweenInfo2, {
			Rotation = 6
		})
		v2:Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopTilt()
		if v2 then
			v2:Cancel()
			v2 = nil
		end
	end

	starterPackImage.MouseEnter:Connect(function()
		stopTilt() -- equivalent call inferred; original call site unknown
		TweenService:Create(starterPackImage, tweenInfo, {
			Rotation = 0
		}):Play()
		TweenService:Create(uIScale, tweenInfo, {
			Scale = 1.15
		}):Play()
	end)
	starterPackImage.MouseLeave:Connect(function()
		TweenService:Create(uIScale, tweenInfo, {
			Scale = 1
		}):Play()
		startTilt() -- equivalent call inferred; original call site unknown
	end)
	startTilt() -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		clone2.Visible = not localPlayer:GetAttribute((`P{starterPackBundle.ProductId}`))
	end

	localPlayer:GetAttributeChangedSignal((`P{starterPackBundle.ProductId}`)):Connect(updateVisibility)
	updateVisibility() -- equivalent call inferred; original call site unknown
	starterPackImage.MouseButton1Click:Connect(function()
		shop:SetAttribute("Visible", true)
		shop.Visible = true
		PromptBundle(starterPackBundle, true)
	end)
	UI:Bind(starterPackImage)
	clone2.Parent = parent3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupStarterPackIcons(instance)
	local starterPackBundle = getStarterPackBundle()

	if not starterPackBundle then
		return
	end

	setupStarterPackIcon(instance:WaitForChild("Menu"), starterPackBundle)
	setupStarterPackIcon(instance:WaitForChild("Connecting"), starterPackBundle)
end

task.spawn(function()
	setupStarterPackIcons(parent:WaitForChild("MainMenu")) -- equivalent call inferred; original call site unknown
end)
parent.ChildAdded:Connect(function(child)
	if child.Name == "MainMenu" then
		setupStarterPackIcons(child) -- equivalent call inferred; original call site unknown
	end
end)

function _G.ShowBundle(p)
	shop:SetAttribute("Visible", true)
	shop.Visible = true
	local v2 = nil

	for _, bundle in Bundles do
		if bundle.Name ~= p then
			continue
		end

		v2 = bundle
		break
	end

	PromptBundle(v2)
end

task.wait(1)
CreateBundleList()