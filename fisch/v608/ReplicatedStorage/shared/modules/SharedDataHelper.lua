local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = nil
local legacyPlayerData = nil
local DataController = nil
local legacyLocalPlayerData = nil
local isServer = RunService:IsServer()

if isServer then
	DataService = require(ServerScriptService.server.legacyServices.DataService)
	legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
else
	DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
	legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
end

local function resolvePath(value)
	if typeof(value) == "string" then
		return value:split(".")
	end

	return value
end

local function readPath(child, value)
	if typeof(value) == "string" then
		value = value:split(".")
	end

	for _, childName in value do
		if typeof(child) == "Instance" then
			child = child:FindFirstChild(childName)
		elseif typeof(child) == "table" then
			child = child[childName]
		else
			return child
		end
	end

	return child
end

local SharedDataHelper = {}

function SharedDataHelper.fetchNewFormat(p)
	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if typeof(p) == "table" then
		return p.NewFormat
	end

	if not coroutine.isyieldable() then
		return SharedDataHelper.getNewFormatNow(p)
	end

	if isServer then
		local v2 = DataService:WaitProfile(v)
		return v2 and v2.Data.NewFormat
	end

	DataController.PlayerDataReplicator:WaitForLoaded()
	DataController.InventoryReplicator:WaitForLoaded()
	DataController.StorageReplicator:WaitForLoaded()
	DataController.BestiaryReplicator:WaitForLoaded()
	local clone = table.clone(assert(DataController.PlayerDataReplicator.Data))
	clone.Inventory = assert(DataController.InventoryReplicator.Data).Inventory
	clone.Storage = assert(DataController.StorageReplicator.Data).Storage
	clone.Bestiary = assert(DataController.BestiaryReplicator.Data).Bestiary
	return clone
end

function SharedDataHelper.fetchNewFormatLocal()
	return assert(SharedDataHelper.fetchNewFormat(Players.LocalPlayer))
end

function SharedDataHelper.getNewFormatNow(p)
	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if typeof(p) == "table" then
		return p.NewFormat
	end

	if isServer then
		local profile = DataService:GetProfile(v)
		return profile and profile.Data.NewFormat
	end

	if not DataController.PlayerDataReplicator.Data then
		return nil
	end

	local clone = table.clone(DataController.PlayerDataReplicator.Data)
	clone.Inventory = DataController.InventoryReplicator.Data and DataController.InventoryReplicator.Data.Inventory or {}
	clone.Storage = DataController.StorageReplicator.Data and DataController.StorageReplicator.Data.Storage or {}
	clone.Bestiary = DataController.BestiaryReplicator.Data and DataController.BestiaryReplicator.Data.Bestiary or {}
	return clone
end

function SharedDataHelper.fetchLegacy(p)
	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if not coroutine.isyieldable() then
		return SharedDataHelper.getLegacyNow(p)
	end

	if isServer then
		return (legacyPlayerData.forPlayerSafe(v))
	end

	return legacyLocalPlayerData.fetch()
end

function SharedDataHelper.fetchLegacyLocal()
	return assert(SharedDataHelper.fetchLegacy(Players.LocalPlayer))
end

function SharedDataHelper.getLegacyNow(p)
	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if isServer then
		return (legacyPlayerData.forPlayerNow(v))
	end

	return legacyLocalPlayerData.folder
end

function SharedDataHelper.fetchBoth(p)
	if typeof(p) == "table" then
		return nil, p.NewFormat
	end

	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if not coroutine.isyieldable() then
		return SharedDataHelper.getBothNow(p)
	end

	if not isServer then
		return SharedDataHelper.fetchLegacyLocal(), SharedDataHelper.fetchNewFormatLocal()
	end

	local v2, v3 = legacyPlayerData.forPlayerSafe(v)
	return v2, v3 and v3.Data.NewFormat
end

function SharedDataHelper.fetchBothLocal()
	local both, v = SharedDataHelper.fetchBoth(Players.LocalPlayer)
	return assert(both), assert(v)
end

function SharedDataHelper.getBothNow(p)
	local v = assert(p or Players.LocalPlayer, "Expected a player")

	if not isServer then
		return legacyLocalPlayerData.folder, SharedDataHelper.getNewFormatNow()
	end

	local v2, v3 = legacyPlayerData.forPlayerNow(v)
	return v2, v3 and v3.Data.NewFormat
end

function SharedDataHelper.indexNewFormat(p, p2)
	return (readPath(SharedDataHelper.fetchNewFormat(p), p2))
end

function SharedDataHelper.indexNewFormatNow(p, p2)
	return (readPath(SharedDataHelper.getNewFormatNow(p), p2))
end

function SharedDataHelper.readLegacyPath(p, p2)
	return (readPath(SharedDataHelper.fetchLegacy(p), p2))
end

function SharedDataHelper.readLegacyPathNow(p, p2)
	return (readPath(SharedDataHelper.getLegacyNow(p), p2))
end

function SharedDataHelper.readLegacyPathValue(p, value)
	if typeof(p) ~= "table" then
		local v = readPath(SharedDataHelper.fetchLegacy(p), value)
		return v and v.Value
	end

	if typeof(value) == "string" then
		value = value:split(".")
	end

	if #value < 2 then
		return nil
	end

	local v = value[1]
	local v2 = value[#value - 1]
	local v3 = value[#value]
	local v4 = p[v] and p[v][v3 .. v2]

	if v4 then
		return v4[1]
	end

	return nil
end

function SharedDataHelper.readLegacyPathValueNow(p, value)
	if typeof(p) ~= "table" then
		local v = readPath(SharedDataHelper.getLegacyNow(p), value)
		return v and v.Value
	end

	if typeof(value) == "string" then
		value = value:split(".")
	end

	if #value < 2 then
		return nil
	end

	local v = value[1]
	local v2 = value[#value - 1]
	local v3 = value[#value]
	local v4 = p[v] and p[v][v3 .. v2]

	if v4 then
		return v4[1]
	end

	return nil
end

return SharedDataHelper