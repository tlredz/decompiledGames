local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.Utils)
local packages = ReplicatedStorage2.Packages
local v2 = require3(packages.Promise)
local v3 = require3(packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.TimedCache)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local MarketplaceService2 = {}
local v5

if RunService:IsClient() then
	v5 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
else
	v5 = require3(game.ServerScriptService.Game.CoreGameModules.FFlagServer)
end

function MarketplaceService2.__index(_, p)
	local v6 = MarketplaceService[p]

	if type(v6) == "function" then
		return function(_, ...)
			return v6(MarketplaceService, ...)
		end
	end

	return v6
end

setmetatable(MarketplaceService2, MarketplaceService2)
local v6 = { 5001998742, 5295074138 }
MarketplaceService2.Prompted = v.Signal.new()
local maid = v.Maid.new()
local v7 = nil

local function EnableDefault()
	if v7 == "Default" then
		return
	end

	v7 = "Default"

	if RunService:IsClient() then
		maid.PromptGamePassPurchase = v3:RemoteEvent("PromptGamePassPurchase").OnClientEvent:Connect(function(p: number, ...)
			task.defer(_G.AddPendingPurchase, p, true)
			MarketplaceService2:PromptGamePassPurchase(localPlayer, ...)
		end)
		maid.PromptProductPurchase = v3:RemoteEvent("PromptProductPurchase").OnClientEvent:Connect(function(p: number, ...)
			task.defer(_G.AddPendingPurchase, p, true)
			MarketplaceService2:PromptProductPurchase(localPlayer, p, ...)
		end)

		function MarketplaceService2:PromptGamePassPurchase(p, p2)
			task.defer(_G.AddPendingPurchase, p2, true)
			MarketplaceService2.Prompted:Fire()
			MarketplaceService:PromptGamePassPurchase(p, p2)
		end

		function MarketplaceService2:PromptProductPurchase(p, p2)
			if table.find(v.FFlag.TimeoutFFlag("DisabledProducts", 10, {}), tonumber(p2) or 0) or table.find(
				v.FFlag.TimeoutFFlag("DisabledProductsIgnoringGifts", 10, {}),
				tonumber(p2) or 0
			) then
				if _G.SendNotification then
					task.defer(_G.SendNotification, "This product is disabled!")
				end

				return false
			else
				task.defer(_G.AddPendingPurchase, p2, true)
				MarketplaceService2.Prompted:Fire()
				MarketplaceService:PromptProductPurchase(p, p2)
			end
		end
	else
		local remoteEvent = v3:RemoteEvent("PromptGamePassPurchase")
		local remoteEvent2 = v3:RemoteEvent("PromptProductPurchase")

		function MarketplaceService2:PromptGamePassPurchase(player, ...)
			remoteEvent:FireClient(player, ...)
		end

		function MarketplaceService2:PromptProductPurchase(player, ...)
			remoteEvent2:FireClient(player, ...)
		end
	end
end

local function Enable1Robux()
	if v7 == "1Robux" then
		return
	end

	v7 = "1Robux"
	local RunService2 = game:GetService("RunService")

	if RunService2:IsClient() then
		maid.PromptGamePassPurchase = v3:RemoteEvent("PromptGamePassPurchase").OnClientEvent:Connect(function(p: number, ...)
			task.defer(_G.AddPendingPurchase, p, true)
			MarketplaceService2:PromptGamePassPurchase(localPlayer, p, ...)
		end)
		maid.PromptProductPurchase = v3:RemoteEvent("PromptProductPurchase").OnClientEvent:Connect(function(p, ...)
			task.defer(_G.AddPendingPurchase, p, true)
			MarketplaceService2:PromptProductPurchase(localPlayer, p, ...)
		end)

		function MarketplaceService2:PromptProductPurchase(_, p)
			if table.find(v.FFlag.TimeoutFFlag("DisabledProducts", 10, {}), tonumber(p) or 0) or table.find(
				v.FFlag.TimeoutFFlag("DisabledProductsIgnoringGifts", 10, {}),
				tonumber(p) or 0
			) then
				if _G.SendNotification then
					task.defer(_G.SendNotification, "This product is disabled!")
				end

				return false
			else
				local v8 = tonumber(p)

				if not v8 then
					warn((`Failed to turn Product Id {p} to number`))
					return
				end

				task.defer(_G.AddPendingPurchase, v8, true)
				MarketplaceService2.Prompted:Fire()
				v3:RemoteEvent("PromptTestPurchase"):FireServer("Product", v8)
			end
		end

		function MarketplaceService2:PromptGamePassPurchase(_, p)
			local v8 = tonumber(p)

			if not v8 then
				warn((`Failed to turn Product Id {p} to number`))
				return
			end

			task.defer(_G.AddPendingPurchase, v8, true)
			MarketplaceService2.Prompted:Fire()
			v3:RemoteEvent("PromptTestPurchase"):FireServer("GamePass", v8)
		end
	else
		v3:RemoteEvent("PromptTestPurchase").OnServerEvent:Connect(function(p, productType, p3)
			local productId = tonumber(p3)

			if productId ~= productId then
				return warn((`PromptTestPurchase returned a NaN for type: "{productType}", id: "{p3}"`))
			end

			local playerMaid = v.PlayerMaids:GetPlayerMaid(p)

			if playerMaid then
				playerMaid.LastPromptedProduct = {
					ProductType = productType,
					ProductId = productId
				}
				MarketplaceService:PromptProductPurchase(p, v.Settings.TEST_PLACE_PRODUCT)
			end
		end)
		local remoteEvent = v3:RemoteEvent("PromptGamePassPurchase")
		local remoteEvent2 = v3:RemoteEvent("PromptProductPurchase")

		function MarketplaceService2:PromptGamePassPurchase(player, ...)
			remoteEvent:FireClient(player, ...)
		end

		function MarketplaceService2:PromptProductPurchase(player, ...)
			remoteEvent2:FireClient(player, ...)
		end
	end
end

function MarketplaceService2.IsTestPurchaseEnabled(_)
	if table.find(v6, game.GameId) and v5:IsDataReady() and v5:GetKey("Enable1RobuxProducts") then
		return true
	end

	return false
end

local promisify = v2.promisify(function(p: number, p2)
	return MarketplaceService:GetProductInfo(p, p2)
end)
local v8 = {}

function MarketplaceService2:GetProductInfoAsync(p: number, p2)
	local v9 = p2 or Enum.InfoType.Asset
	local v10 = v8[v9]

	if not v10 then
		v10 = {}
		v8[v9] = v10
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v11 = v10[p]

	if v11 and v11.Data and unixTimestamp <= v11.Expiration then
		return v2.resolve(v11.Data)
	end

	local v12 = v11 and 2 or 4
	return v2.retryWithDelay(promisify, v12, 3, p, v9):andThen(function(p3)
		v10[p] = {
			Data = p3,
			Expiration = unixTimestamp + 120
		}
		return p3
	end):catch(function(...)
		v11 = v10[p]

		if v11 and v11.Data then
			return v2.resolve(v11.Data)
		end

		return v2.reject(...)
	end)
end

function MarketplaceService2:GetProductInfo(p: number, p2)
	return self:GetProductInfoAsync(p, p2):expect()
end

local remoteFunction = v3:RemoteFunction("Marketplace/GetProductInfo")
local v9 = v4.new()
local v10 = {}

function MarketplaceService2:GetServerProductInfo(p: number, p2)
	if RunService:IsServer() then
		return self:GetProductInfo(p, p2)
	end

	if v10[p] then
		return v2.resolve(v10[p])
	end

	return v2.new(function(callback, callback2, callback3)
		local v11, v12 = remoteFunction:InvokeServer(p, p2)

		if not v11 then
			callback2()
			return
		end

		v10[p] = v12

		if callback3() then
			return
		end

		callback(v12)
	end)
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, value, p2)
		if type(value) ~= "number" or value ~= value or value < 0 or v9:Get(p) then
			return false
		end

		v9:Set(p, true, 1)
		return MarketplaceService2:GetProductInfoAsync(value, p2):await()
	end
end

if table.find(v6, game.GameId) then
	local function bindLoading(p)
		local fn

		fn = function(...)
			task.spawn(function(...)
				while not v5:IsDataReady() or MarketplaceService2[p] == fn do
					task.wait()
				end

				MarketplaceService2[p](...)
			end, ...)
		end

		MarketplaceService2[p] = fn
	end

	local v11 = "PromptGamePassPurchase"
	local fn

	fn = function(...)
		task.spawn(function(...)
			while not v5:IsDataReady() or MarketplaceService2[v11] == fn do
				task.wait()
			end

			MarketplaceService2[v11](...)
		end, ...)
	end

	MarketplaceService2.PromptGamePassPurchase = fn
	local v12 = "PromptProductPurchase"
	local fn2

	fn2 = function(...)
		task.spawn(function(...)
			while not v5:IsDataReady() or MarketplaceService2[v12] == fn2 do
				task.wait()
			end

			MarketplaceService2[v12](...)
		end, ...)
	end

	MarketplaceService2.PromptProductPurchase = fn2

	local function Check()
		if v5:GetKey("Enable1RobuxProducts") then
			Enable1Robux()
		else
			EnableDefault()
		end
	end

	task.spawn(Check)
	v5.DataUpdatedEvent:Connect(Check)
else
	EnableDefault()
end

return MarketplaceService2