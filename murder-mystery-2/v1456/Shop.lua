local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local game2 = script.Parent.Parent.Game
local shop = game2.Shop
local ShopModule = require(game.ReplicatedStorage.Modules.ShopModule)
require(game.ReplicatedStorage.Modules.ItemModule)
ShopModule.GUI.ShopFrame = shop
ShopModule.GUI.Main = shop.Main
ShopModule.GUI.Nav = shop.Nav
ShopModule.GUI.Title = shop.Title
ShopModule.GUI.FeaturedFrame = shop.Main.Featured
ShopModule.GUI.ViewBoxFrame = shop.Main.ViewCrate.Container
ShopModule.GUI.Processing = game2.Processing
ShopModule.GUI.HotItemsContainer = shop.Main.Featured.HotItems.Container
ShopModule.GenerateHotItems()
ShopModule.ConnectNavButtons()
ShopModule.ConnectViewBoxFrame()
ShopModule.ConnectBuyPopup()
ShopModule.ConnectGems()
ShopModule.GenerateShopItems()
local radio = game.Players.LocalPlayer:GetAttribute("Radio")
game2.Shop.Main.Radios.NoRadioCover.Visible = not radio
game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent:connect(function()
	game2.Shop.Main.Radios.NoRadioCover.Visible = false
end)
game2.Shop.Main.Radios.NoRadioCover.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
end)