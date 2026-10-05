local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("ItemService"))
game:GetService("ContextActionService")
local ShopService = require(script.Parent:WaitForChild("ShopService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local newShop = require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync")).NewShop
local GuiService = game:GetService("GuiService")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage4:WaitForChild("Remotes"):WaitForChild("Shop")
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage5:WaitForChild("Remotes"):WaitForChild("Inventory")
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage6:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage7:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage8:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local console = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext"):WaitForChild("Console")
local shop2 = console:WaitForChild("Shop")
local large = script.Parent.Parent:WaitForChild("Large")
local main = large:WaitForChild("Main")
local container = main:WaitForChild("Container")
local title = large:WaitForChild("Title")
local nav = title:WaitForChild("Nav")
local info = main:WaitForChild("Info")
local processing = main:WaitForChild("Processing")
local bottomBar = large:WaitForChild("BottomBar")
local buyPopup = container:WaitForChild("BuyPopup")
local container2 = buyPopup:WaitForChild("Container")
local itemFrame = container2:WaitForChild("Left"):WaitForChild("ItemContainer"):WaitForChild("ItemFrame")
local priceFrame = container2:WaitForChild("Right"):WaitForChild("PriceFrame")
local textLabel = container2:WaitForChild("Right"):WaitForChild("Description"):WaitForChild("TextLabel")
local scrollingFrame = container:WaitForChild("PurchaseCurrency"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
local scrollingFrame2 = container:WaitForChild("ViewContents"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
local buyFrame = info:WaitForChild("BuyFrame")
local scrollingFrame3 = container:WaitForChild("Featured"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
local largeShopItemFrame = scrollingFrame3:WaitForChild("LargeShopItemFrame")
local scrollingFrame4 = main:WaitForChild("Container"):WaitForChild("Items"):WaitForChild("Items"):WaitForChild("ScrollingFrame")
local largeBoxContentItem = scrollingFrame2:WaitForChild("LargeBoxContentItem")
local v = {
	"Featured",
	"PurchaseCurrency",
	"Weapons",
	"Effects",
	"Perks",
	"Emotes",
	"Pets"
}
local index = 1
local v2 = "Featured"
local v3 = "Featured"
local v4 = nil

local function GoToPage(p: string)
	for _, frame in container:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Visible = frame.Name == p

		if frame.Name == p then
			GuiService:Select(frame)
		end
	end

	v3 = p
end

local function GoToTab(text: string)
	if text == "PurchaseCurrency" then
		title.Title.Text = "Get Gems"
		GoToPage("PurchaseCurrency")
	elseif text == "Featured" then
		title.Title.Text = "Featured"
		GoToPage("Featured")
	else
		title.Title.Text = text
		ShopService:SetVisibleItems(scrollingFrame4, text)
		GoToPage("Items")
		GuiService:Select(scrollingFrame4)
	end

	for _, button in nav:GetChildren() do
		if button:IsA("TextButton") then
			button.Style = button.Name == text and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		end
	end

	index = table.find(v, text)
	v2 = text
end

local function ConnectPurchaseCurrency()
	for _, frame in scrollingFrame:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v5 = frame
		frame.Container.ActionButton.Activated:Connect(function()
			shop.PurchaseProduct:FireServer(v5.Name, "Gems")
		end)
		local v6 = frame
		frame.Container.ActionButton.SelectionGained:Connect(function()
			info.ItemContainer.ItemFrame.Container.Icon.Image = v6.Container.Icon.Image
			info.ItemContainer.ItemFrame.ItemName.TextLabel.Text = v6.ItemName.TextLabel.Text
			info.ItemContainer.ItemFrame.ItemName.BackgroundColor3 = v6.ItemName.BackgroundColor3
		end)
	end
end

local function viewBoxContents(p: string, p2: string)
	ShopService:ViewBoxContents(info.ItemContainer.ItemFrame, scrollingFrame2, buyFrame, p, p2)
	info.BuyFrame.Visible = true
	GoToPage("ViewContents")
	GuiService:Select(info.BuyFrame)
	v4 = p
end

local function viewBuyPopup(p: string, p2: string)
	ShopService:ViewBuyPopup(itemFrame, textLabel, priceFrame, p, p2)
	buyPopup.Visible = true
	GuiService:Select(priceFrame)
	v4 = p
end

local function onItemSelected(p: string, p2: string)
	ShopService:DisplayItem(info.ItemContainer.ItemFrame, p, p2)
	info.BuyFrame.Visible = false
end

local function onItemClicked(p: string, p2: string)
	if p2 == "Event" then
		shop2.Enabled = false
		WindowService:ViewFrame("CurrentEvent")
		console.Event.Enabled = true
	else
		if p2 == "MysteryBox" or p2 == "Eggs" then
			ShopService:ViewBoxContents(info.ItemContainer.ItemFrame, scrollingFrame2, buyFrame, p, p2)
			info.BuyFrame.Visible = true
			GoToPage("ViewContents")
			GuiService:Select(info.BuyFrame)
		else
			ShopService:ViewBuyPopup(itemFrame, textLabel, priceFrame, p, p2)
			buyPopup.Visible = true
			GuiService:Select(priceFrame)
		end

		v4 = p
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeShop()
	shop2.Enabled = false
	large.Visible = false
	GuiService.SelectedObject = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function navigateShop(p: number)
	index += p

	if index > #v then
		index = 1
	end

	if index <= 0 then
		index = #v
	end

	GoToTab(v[index])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onShopOpened()
	GoToTab("Featured")
end

local function onItemPurchaseRequested(p: string, p2: string)
	local type = newShop[p].Type

	if processing.Visible == true then
		return
	end

	if type == "MysteryBox" or type == "Eggs" then
		processing.Visible = true

		if type == "MysteryBox" then
			if ShopService:RequestUnbox(p, p2, 1) then
				closeShop() -- equivalent call inferred; original call site unknown
			end
		else
			local v5 = type == "Eggs" and shop.OpenCrate:InvokeServer(p, type, p2)

			if v5 then
				closeShop() -- equivalent call inferred; original call site unknown
				shop.EggController:Fire(p, v5)
			end
		end

		processing.Visible = false
	else
		processing.Visible = true
		local v5 = shop.BuyItemNew:InvokeServer(p, p2)
		processing.Visible = false

		if v5 then
			buyPopup.Visible = false
			large.Visible = false
			shop2.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectLastViewedItem()
	GuiService:Select(container:FindFirstChild(v3).Items.ScrollingFrame:FindFirstChild(v4))
end

local function onShopBackPressed()
	if v3 == "ViewContents" then
		GoToTab(v2)
		selectLastViewedItem() -- equivalent call inferred; original call site unknown
	elseif buyPopup.Visible then
		buyPopup.Visible = false
		selectLastViewedItem() -- equivalent call inferred; original call site unknown
	else
		closeShop() -- equivalent call inferred; original call site unknown
	end
end

local function onCurrencyUpdated()
	local coins = ProfileData.Materials.Owned.Coins or 0
	local gems = ProfileData.Materials.Owned.Gems or 0
	local amount = bottomBar:WaitForChild("Gems"):WaitForChild("Amount")
	amount.Text = ShopService.CommaValue(gems)
	local amount_2 = bottomBar:WaitForChild("Coins"):WaitForChild("Amount")
	amount_2.Text = ShopService.CommaValue(coins)
end

local function onInitialize()
	ShopService.ShopItemFrame = largeShopItemFrame
	ShopService.FeaturedItemFrame = largeShopItemFrame
	ShopService.BoxContentItemFrame = largeBoxContentItem
	ShopService.ShopItemCurrencyFrame = largeShopItemFrame:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("LargeCurrencyFrame")
	ShopService.ShopItemCurrencyFrame.Parent = script
	ShopService.CurrencyPriceFrame = priceFrame:WaitForChild("Gems")
	ShopService.CurrencyPriceFrame.Parent = script
	largeShopItemFrame:WaitForChild("Container"):WaitForChild("Prices"):WaitForChild("Gems"):Destroy()
	largeShopItemFrame.Parent = script
	largeBoxContentItem.Parent = script
	ShopService:GenerateFeaturedItems(scrollingFrame3, ShopService.FeaturedItems.Console)
	ShopService:GenerateShopItems(scrollingFrame4)
	shop2:WaitForChild("Back").Pressed:Connect(onShopBackPressed)
	shop2:WaitForChild("NavigateLeft").Pressed:Connect(function()
		navigateShop(-1) -- equivalent call inferred; original call site unknown
	end)
	shop2:WaitForChild("NavigateRight").Pressed:Connect(function()
		navigateShop(1) -- equivalent call inferred; original call site unknown
	end)
	console:WaitForChild("Event"):WaitForChild("Back").Pressed:Connect(function()
		WindowService:Back()
		console.Event.Enabled = false
		GuiService.SelectedObject = nil
	end)
	ConnectPurchaseCurrency()
	onCurrencyUpdated()
	inventory.InventoryDataChanged.Event:Connect(function(_, p, _)
		if p == "Gems" or p == "Coins" then
			onCurrencyUpdated()
		end
	end)
	ShopService.PurchaseGemsRequested.Event:Connect(function()
		GoToTab("PurchaseCurrency")
	end)
	ShopService.ItemPurchaseRequested.Event:Connect(onItemPurchaseRequested)
	ShopService.ItemSelectionGained.Event:Connect(onItemSelected)
	ShopService.ItemClicked.Event:Connect(onItemClicked)
	WindowService:RegisterFrame(large, "Shop", onShopOpened)
	large.Visible = false
	onShopOpened() -- equivalent call inferred; original call site unknown
	EventInfoService:OnEventStarted(function(p)
		if p.EventStartInfo.FeaturedItems then
			ShopService:GenerateFeaturedItems(scrollingFrame3, p.EventStartInfo.FeaturedItems.Console)
		end

		if p.EventStartInfo.ShopData then
			ShopService:GenerateShopItems(scrollingFrame4)
		end
	end)
end

onInitialize()