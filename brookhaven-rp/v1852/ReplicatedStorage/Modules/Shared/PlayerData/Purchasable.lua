local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Purchasable = {}
local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class2:GetInfoClient()
	local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
	return PurchasableInfoController.GetGamepassInfo(self.gamepass)
end

function class2.GetInfoServer(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PurchasableInfoService = require(ServerScriptService.Modules.Products.PurchasableInfoService)
	return PurchasableInfoService.GetInfo(Gamepasses.GetId(p.gamepass), Enum.InfoType.GamePass)
end

function class2:IsOwnedClient()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	return GamepassController.IsPermanentlyOwned(self.gamepass)
end

function class2.IsOwnedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)
	return GamepassService.IsOwned(p2, p.gamepass)
end

function class2.GetPriceAsync(p)
	local v, v2 = GetProductInfo(Gamepasses.GetId(p.gamepass), Enum.InfoType.GamePass, 0)

	if v then
		return v2.PriceInRobux
	end

	return nil
end

function class2.GetId(p)
	return Gamepasses.GetId(p.gamepass)
end

function class2.GetGiftId(p)
	return Gamepasses.GetGiftId(p.gamepass)
end

function class2.GetName(p)
	return Gamepasses.GetName(p.gamepass)
end

function class2.GetSmallIcon(p)
	local GamepassIcon = require(ReplicatedStorage.Modules.Client.Item.GamepassIcon)
	return GamepassIcon.GetSmallIcon(p.gamepass)
end

function class2:ToGamepass()
	return self.gamepass
end

function class2.ToDevProduct(_)
	return nil
end

function class2:Equals(p2)
	return p2 ~= nil and p2.gamepass == self.gamepass
end

function class:GetInfoClient()
	local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
	return PurchasableInfoController.GetDevProductInfo(self.devProduct)
end

function class.GetInfoServer(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	local PurchasableInfoService = require(ServerScriptService.Modules.Products.PurchasableInfoService)
	return PurchasableInfoService.GetInfo(DevProducts.GetId(p.devProduct), Enum.InfoType.Product)
end

function class:IsOwnedClient()
	local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
	return DevProductController.IsOwned(self.devProduct)
end

function class.IsOwnedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local DevProductService = require(ServerScriptService.Modules.Products.DevProductService)
	return DevProductService.IsOwned(p2, p.devProduct)
end

function class.GetPriceAsync(p)
	local v, v2 = GetProductInfo(DevProducts.GetId(p.devProduct), Enum.InfoType.Product, 0)

	if v then
		return v2.PriceInRobux
	end

	return nil
end

function class.GetId(p)
	return DevProducts.GetId(p.devProduct)
end

function class.GetGiftId(p)
	return DevProducts.GetGiftId(p.devProduct)
end

function class:ToGamepass()
	return nil
end

function class.ToDevProduct(p)
	return p.devProduct
end

function class:Equals(p2)
	return p2 ~= nil and p2.devProduct == self.devProduct
end

function class.GetName(p)
	return DevProducts.GetName(p.devProduct)
end

function class:GetSmallIcon()
	local infoClient = self:GetInfoClient()

	if infoClient then
		return "rbxassetid://" .. infoClient.IconImageAssetId
	end

	return nil
end

function Purchasable.isOwnedClient(object)
	return object:IsOwnedClient()
end

function Purchasable.equals(p, object)
	if p == nil and object == nil then
		return true
	end

	if object == nil then
		return false
	end

	return object:Equals(p)
end

function Purchasable.getTelemetryIds(object)
	if object == nil then
		return nil, nil
	end

	local gamepass = object:ToGamepass()

	if gamepass == nil then
		return nil, object:GetId()
	end

	return Gamepasses.GetId(gamepass), nil
end

function Purchasable:ofGamepass()
	local v

	if self == nil then
		v = false
	else
		v = self.__GAMEPASS
	end

	assert(v, "argument is not a gamepass")
	return (setmetatable({
		gamepass = self
	}, class2))
end

function Purchasable:ofDevProduct()
	local v

	if self == nil then
		v = false
	else
		v = self.__DEV_PRODUCT
	end

	assert(v, "argument is not a dev product")
	return (setmetatable({
		devProduct = self
	}, class))
end

return Purchasable