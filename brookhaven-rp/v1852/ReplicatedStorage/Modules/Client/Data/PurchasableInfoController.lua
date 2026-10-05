local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaClient = require(ReplicatedStorage.Modules.Client.Data.ReplicaClient)
local CountDownLatch = require(ReplicatedStorage.Modules.Shared.Async.CountDownLatch)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local v = nil
local v2 = CountDownLatch.new(1)
local PurchasableInfoController = {
	FrameworkInit = function() end,
	FrameworkStart = function()
		ReplicaClient.OnNew("PurchasableInfo", function(p)
			v = p
			v2:countDown()
		end)
		ReplicaClient.RequestData()
	end
}

local function getInfo(p: number, p2)
	v2:await()
	local v3 = v.Data[tostring(p)]

	if v3 ~= nil then
		return v3
	end

	local v4, v5 = GetProductInfo(p, p2, 0)

	if v4 then
		return v5
	end

	return nil
end

function PurchasableInfoController.GetGamepassInfo(p)
	local id = Gamepasses.GetId(p)
	local gamePass = Enum.InfoType.GamePass
	v2:await()
	local v3 = v.Data[tostring(id)]

	if v3 ~= nil then
		return v3
	end

	local v4, v5 = GetProductInfo(id, gamePass, 0)

	if v4 then
		return v5
	end

	return nil
end

function PurchasableInfoController.GetDevProductInfo(p)
	local id = DevProducts.GetId(p)
	local product = Enum.InfoType.Product
	v2:await()
	local v3 = v.Data[tostring(id)]

	if v3 ~= nil then
		return v3
	end

	local v4, v5 = GetProductInfo(id, product, 0)

	if v4 then
		return v5
	end

	return nil
end

function PurchasableInfoController.GetCountableDevProductInfo(p)
	local id = CountableDevProducts.GetId(p)
	local product = Enum.InfoType.Product
	v2:await()
	local v3 = v.Data[tostring(id)]

	if v3 ~= nil then
		return v3
	end

	local v4, v5 = GetProductInfo(id, product, 0)

	if v4 then
		return v5
	end

	return nil
end

return PurchasableInfoController