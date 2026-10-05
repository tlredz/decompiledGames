local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage4:WaitForChild("Remotes"):WaitForChild("Inventory")
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage5:WaitForChild("Remotes"):WaitForChild("Shop")
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local newShop = require(ReplicatedStorage6:WaitForChild("Database"):WaitForChild("Sync")).NewShop
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
local EventInfoService = require(ReplicatedStorage7:WaitForChild("SharedServices"):WaitForChild("EventInfoService"))
local localPlayer = game.Players.LocalPlayer
local small = script.Parent.Parent:WaitForChild("Small")
local main = small:WaitForChild("Container"):WaitForChild("Main")
local container = small:WaitForChild("Container"):WaitForChild("Title"):WaitForChild("Container")
local processing = small:WaitForChild("Processing")
local container2 = main:WaitForChild("Featured"):WaitForChild("Nav"):WaitForChild("Container")
local container3 = main:WaitForChild("Featured"):WaitForChild("Container")
local radioCover = main:WaitForChild("Items"):WaitForChild("Container"):WaitForChild("RadioCover")
local viewContents = main:WaitForChild("ViewContents")
local itemContainer = viewContents:WaitForChild("Container"):WaitForChild("Main"):WaitForChild("BoxFrame"):WaitForChild("ItemContainer")
local scrollingFrame = viewContents:WaitForChild("Container"):WaitForChild("Main"):WaitForChild("BoxContents"):WaitForChild("Container"):WaitForChild("ScrollingFrame")
local buyFrame = viewContents:WaitForChild("Container"):WaitForChild("BuyFrame")
local buyPopup = main:WaitForChild("BuyPopup")
local itemContainer2 = buyPopup:WaitForChild("Container"):WaitForChild("Left"):WaitForChild("ItemFrame"):WaitForChild("ItemContainer")
local textLabel = buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("Description"):WaitForChild("TextLabel")
local priceFrame = buyPopup:WaitForChild("Container"):WaitForChild("Right"):WaitForChild("PriceFrame")
local scrollFrame = main:WaitForChild("Items"):WaitForChild("Container"):WaitForChild("ScrollFrame")
local itemGridLayout = scrollFrame:WaitForChild("ItemGridLayout")
local newItem = scrollFrame:WaitForChild("NewItem")
local v = { "Featured" }

local function GoToPage(main2, p: string)
	local back = container:WaitForChild("Back")
	back.Visible = p ~= "Featured"
	local title = container:WaitForChild("Title")
	title.Visible = p == "Featured"

	for _, guiObject in main2:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == p
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GoBack()
	table.remove(v)
	GoToPage(main, v[#v])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewBoxContents(p: string, p2: string)
	ShopService:ViewBoxContents(itemContainer, scrollingFrame, buyFrame, p, p2)
	table.insert(v, "ViewContents")
	GoToPage(main, "ViewContents")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewBuyPopup(p: string, _: string)
	ShopService:ViewBuyPopup(itemContainer2, textLabel, priceFrame, p)
	table.insert(v, "BuyPopup")
	GoToPage(main, "BuyPopup")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupScreenSize()
	if newItem.AbsoluteSize.Y < 160 then
		itemGridLayout.CellSize = UDim2.new(0.333, -4, 1, 0)
	end

	newItem:Destroy()
end

local function setupNavigation()
	for _, button in container2:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v2 = button
		button.Activated:Connect(function()
			table.insert(v, "Items")
			GoToPage(main, "Items")
			ShopService:SetVisibleItems(scrollFrame, v2.Name)

			if v2.Name ~= "Radios" then
				radioCover.Visible = false
				return
			end

			radioCover.Visible = not localPlayer:GetAttribute("Radio")
		end)
	end
end

local function onItemPurchaseRequested(p: string, p2: string)
	local type = newShop[p].Type

	if processing.Visible == true then
		return
	end

	if type == "MysteryBox" or type == "Eggs" then
		processing.Visible = true

		if type == "MysteryBox" then
			local unbox = ShopService:RequestUnbox(p, p2, 1)
			processing.Visible = false

			if unbox then
				small.Visible = false
			end
		elseif type == "Eggs" then
			local v2 = shop.OpenCrate:InvokeServer(p, "Eggs", p2)
			processing.Visible = false

			if v2 then
				small.Visible = false
				shop.EggController:Fire(p, v2)
			end
		end

		ItemPopupService.ItemClaimsComplete.Event:Once(function()
			small.Visible = true
		end)
	else
		processing.Visible = true

		if shop.BuyItemNew:InvokeServer(p, p2) then
			GoBack() -- equivalent call inferred; original call site unknown
			small.Visible = false
			ItemPopupService.ItemClaimsComplete.Event:Once(function()
				small.Visible = true
			end)
		end

		processing.Visible = false
	end
end

local function onItemClicked(p: string, p2: string)
	if p2 == "Event" then
		WindowService:ViewFrame("CurrentEvent")
	elseif p2 == "MysteryBox" or p2 == "Eggs" then
		viewBoxContents(p, p2) -- equivalent call inferred; original call site unknown
	else
		viewBuyPopup(p) -- equivalent call inferred; original call site unknown
	end
end

local function onCurrencyUpdated()
	local coins = ProfileData.Materials.Owned.Coins or 0
	local gems = ProfileData.Materials.Owned.Gems or 0
	local amount = container:WaitForChild("Gems"):WaitForChild("Container"):WaitForChild("Amount")
	amount.Text = ShopService.CommaValue(gems)
	local amount_2 = container:WaitForChild("Coins"):WaitForChild("Container"):WaitForChild("Amount")
	amount_2.Text = ShopService.CommaValue(coins)
end

local function onInitialize()
	setupScreenSize() -- equivalent call inferred; original call site unknown
	setupNavigation()
	ShopService:GenerateShopItems(scrollFrame)
	ShopService:ConnectPurchaseCurrency(main:WaitForChild("PurchaseCurrency"))
	ShopService:GenerateFeaturedItems(container3, ShopService.FeaturedItems.Mobile)
	container:WaitForChild("Gems"):WaitForChild("GetMore"):WaitForChild("Button").Activated:Connect(function()
		table.insert(v, "PurchaseCurrency")
		GoToPage(main, "PurchaseCurrency")
	end)
	GoToPage(main, "Featured")
	container:WaitForChild("Back").Activated:Connect(GoBack)
	WindowService:RegisterFrame(small, "Shop", function(p)
		if not p then
			return
		end

		local targetFrame = p.TargetFrame

		if not targetFrame then
			return
		end

		if targetFrame == "ViewContents" then
			local targetItem = p.TargetItem

			if not targetItem then
				return
			end

			viewBoxContents(targetItem, "MysteryBox") -- equivalent call inferred; original call site unknown
		elseif p.TargetItem then
			local targetItem = p.TargetItem
			local _ = newShop[p.TargetItem].Type
			viewBuyPopup(targetItem) -- equivalent call inferred; original call site unknown
		end
	end)
	onCurrencyUpdated()
	inventory.InventoryDataChanged.Event:Connect(function(_, p, _)
		if p == "Gems" or p == "Coins" then
			onCurrencyUpdated()
		end
	end)
	localPlayer:GetAttributeChangedSignal("Radio"):Connect(function()
		if localPlayer:GetAttribute("Radio") then
			radioCover.Visible = false
		end
	end)
	radioCover:WaitForChild("Container"):WaitForChild("BuyFrame"):WaitForChild("Buy").Activated:Connect(function()
		shop.GetRadio:FireServer()
	end)
	ShopService.PurchaseGemsRequested.Event:Connect(function()
		table.insert(v, "PurchaseCurrency")
		GoToPage(main, "PurchaseCurrency")
	end)
	ShopService.ItemClicked.Event:Connect(onItemClicked)
	ShopService.ItemPurchaseRequested.Event:Connect(onItemPurchaseRequested)
	EventInfoService:OnEventStarted(function(p)
		if p.EventStartInfo.FeaturedItems then
			ShopService:GenerateFeaturedItems(container3, p.EventStartInfo.FeaturedItems.Mobile)
		end

		if p.EventStartInfo.ShopData then
			ShopService:GenerateShopItems(scrollFrame)
		end
	end)
end

onInitialize()