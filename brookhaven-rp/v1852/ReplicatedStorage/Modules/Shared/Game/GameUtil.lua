local GameUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
local v2 = nil
local privateServerOwnerId = nil

local function dictionaryFindValue(items, p)
	for _, item in items do
		if item == p then
			return true
		end
	end

	return false
end

GameUtil.DEBUG_FORCE_PRIVATE_SERVER = game.GameId == GameConstants.GameIds.Dev.BrookhavenCCTesting

function GameUtil.isDevPlace()
	local dev = GameConstants.PlaceIds.Dev
	local placeId = game.PlaceId

	for _, v3 in dev do
		if v3 == placeId then
			return true
		end
	end

	return false
end

function GameUtil.isQAPlace()
	local QA = GameConstants.PlaceIds.QA
	local placeId = game.PlaceId

	for _, v3 in QA do
		if v3 == placeId then
			return true
		end
	end

	return false
end

function GameUtil.isQAInternalPlace()
	return GameConstants.PlaceIds.Dev.Internal == game.PlaceId or GameConstants.PlaceIds.Dev.Internal2 == game.PlaceId
end

function GameUtil.isHouseTestingPlace()
	return game.PlaceId == GameConstants.PlaceIds.Dev.HouseTesting
end

function GameUtil.isPublicTestPlace()
	local publicTesting = GameConstants.PlaceIds.PublicTesting
	local placeId = game.PlaceId

	for _, v3 in publicTesting do
		if v3 == placeId then
			return true
		end
	end

	return false
end

function GameUtil.isLivePlace()
	local live = GameConstants.PlaceIds.Live
	local placeId = game.PlaceId

	for _, v3 in live do
		if v3 == placeId then
			return true
		end
	end

	return false
end

function GameUtil.isStagingPlace()
	return game.PlaceId == GameConstants.PlaceIds.Live.PreRelease or game.PlaceId == GameConstants.PlaceIds.Staging.Staging
end

function GameUtil.isPrivateTestingPlace()
	local privateTesting = GameConstants.PlaceIds.PrivateTesting
	local placeId = game.PlaceId

	for _, v3 in privateTesting do
		if v3 == placeId then
			return true
		end
	end

	return false
end

function GameUtil.IsFranchise()
	return game.PlaceId == GameConstants.PlaceIds.Dev.Filming1 or game.PlaceId == GameConstants.PlaceIds.Dev.Filming2
end

function GameUtil.isLiveGame()
	local live = GameConstants.GameIds.Live
	local gameId = game.GameId

	for _, v3 in live do
		if v3 == gameId then
			return true
		end
	end

	return false
end

function GameUtil.givesUnrestrictedGamepassAccess()
	if game.GameId == GameConstants.GameIds.Live.Main then
		return false
	end

	local unrestrictedGamepassAccessGameIds = GameConstants.UnrestrictedGamepassAccessGameIds
	local gameId = game.GameId

	for _, unrestrictedGamepassAccessGameId in unrestrictedGamepassAccessGameIds do
		if unrestrictedGamepassAccessGameId == gameId then
			return true
		end
	end

	return false
end

function GameUtil.IsPrivateServer()
	if GameUtil.DEBUG_FORCE_PRIVATE_SERVER then
		return true
	end

	if RunService:IsServer() then
		return game.PrivateServerId ~= ""
	end

	return workspace:GetAttribute("IsPrivateServer")
end

function GameUtil.IsPrivateServerOwner(p)
	if GameUtil.DEBUG_FORCE_PRIVATE_SERVER then
		return true
	end

	if p ~= nil then
		return p.UserId == GameUtil.GetPrivateServerOwner()
	end

	if RunService:IsServer() then
		if v == nil then
			local ServerScriptService = game:GetService("ServerScriptService")
			local PrivateServerService = require(ServerScriptService.Modules.PrivateServer.PrivateServerService)
			v = PrivateServerService
		end

		return v.IsPrivateServerOwner(p)
	else
		if v2 == nil then
			v2 = Remotes.invokeServer("IsPrivateServerOwner")
		end

		return v2
	end
end

function GameUtil.GetPrivateServerOwner()
	if RunService:IsServer() then
		if privateServerOwnerId == nil then
			privateServerOwnerId = game.PrivateServerOwnerId
		end
	elseif privateServerOwnerId == nil then
		privateServerOwnerId = Remotes.invokeServer("GetPrivateServerOwner")
	end

	return privateServerOwnerId
end

return GameUtil