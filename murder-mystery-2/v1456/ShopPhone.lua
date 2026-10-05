local parent = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local screens = parent:WaitForChild("Lobby"):WaitForChild("Screens")
parent:WaitForChild("Game")
local shop = screens:WaitForChild("Shop")
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)
require(game.ReplicatedStorage.Modules.ItemModule)
local shopModule = game.ReplicatedStorage.Modules.ShopModule
ShopModule.GUI.ShopFrame = shop
ShopModule.GUI.Main = shop.Main
ShopModule.GUI.Nav = shop.Main.Featured.Nav
ShopModule.GUI.Title = shop.Title
ShopModule.GUI.FeaturedFrame = shop.Main.Featured
ShopModule.GUI.ViewBoxFrame = shop.Main.ViewCrate.Container
ShopModule.GUI.Processing = screens.Processing
ShopModule.GUI.HotItemsContainer = shop.Main.Featured.HotItems.ScrollingFrame.Container
ShopModule.GUI.HotItemLayout = shopModule.HotItems.Phone.HotItemLayout
ShopModule.GUI.NewHotItem = shopModule.HotItems.Phone.HotItem
ShopModule.GUI.BoxContentsLayout = shopModule.ViewBoxContents.Phone.BoxContentsLayout
ShopModule.GUI.NewBoxContent = shopModule.ViewBoxContents.Phone.NewItem
ShopModule.GUI.ShopItemLayout = shopModule.ShopTabs.Phone.ItemGridLayout
ShopModule.GenerateHotItems()
ShopModule.ConnectNavButtonsPhone()
ShopModule.ConnectViewBoxFrame(true)
ShopModule.ConnectBuyPopup()
ShopModule.ConnectGems()
ShopModule.GenerateShopItems()
shop.Title.Back.MouseButton1Click:connect(function()
	shop.Title.Back.Visible = false
	shop.Title.Title.Visible = true

	for _, child in pairs(shop.Main:GetChildren()) do
		child.Visible = child.Name == "Featured"
	end
end)

function comma_value(value)
	repeat
		local v
		value, v = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1,%2")
		k = v
	until k == 0

	return value
end

function UpdateCash()
	local coins = ProfileData.Materials.Owned.Coins or 0
	local gems = ProfileData.Materials.Owned.Gems or 0
	shop.Title.Coins.Container.Amount.Text = comma_value((math.floor(coins)))
	shop.Title.Gems.Container.Amount.Text = comma_value(gems)
end

remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(_, p, _)
	if p == "Coins" or p == "Gems" then
		UpdateCash()
	end
end)
UpdateCash()