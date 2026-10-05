local PropsLimitClient = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local PUBLIC_SERVER_PROP_LIMIT = CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT
local PRIVATE_SERVER_PROP_LIMIT = CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT
local localPlayer = Players.LocalPlayer

function PropsLimitClient.GetPublicLimit(flag: boolean)
	local count = CountableDevProductController.GetCount(PUBLIC_SERVER_PROP_LIMIT)
	return PropsUtil.ComputePublicLimit(count, flag)
end

function PropsLimitClient.GetPropLimit(flag: boolean)
	local debugPropLimitOverride = PropsUtil.GetDebugPropLimitOverride()

	if debugPropLimitOverride ~= nil then
		return debugPropLimitOverride
	end

	if not GameUtil.IsPrivateServer() then
		return PropsLimitClient.GetPublicLimit(flag)
	end

	if GameUtil.IsPrivateServerOwner(localPlayer) then
		return PrivateServerPropLimits.ResolveLimit(CountableDevProductController.GetCount(PRIVATE_SERVER_PROP_LIMIT))
	end

	return PrivateServerPropLimits.GetLimits()
end

function PropsLimitClient.IsAtPublicMax()
	local max = CountableDevProducts.GetMax(PUBLIC_SERVER_PROP_LIMIT)
	return max ~= nil and max <= CountableDevProductController.GetCount(PUBLIC_SERVER_PROP_LIMIT)
end

function PropsLimitClient.IsAtPrivateServerMax()
	local max = CountableDevProducts.GetMax(PRIVATE_SERVER_PROP_LIMIT)

	if max == nil then
		return false
	end

	if GameUtil.IsPrivateServerOwner(localPlayer) then
		return max <= CountableDevProductController.GetCount(PRIVATE_SERVER_PROP_LIMIT)
	end

	return PrivateServerPropLimits.GetLimits() >= PrivateServerPropLimits.MAX_LIMIT
end

return PropsLimitClient