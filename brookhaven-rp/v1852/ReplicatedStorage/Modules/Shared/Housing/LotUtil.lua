local LotUtil = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local LotConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.LotConfig)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
local models = nil

local function populateIdToLotRefMap()
	if models ~= nil then
		return
	end

	models = {}

	for _, model in workspace:FindFirstChild("001_Lots"):GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local number = model:FindFirstChild("Number")

		if number == nil or number:FindFirstChild("Number") == nil then
			error("Lot " .. model:GetFullName() .. " has no number instance")
		else
			if models[number.Number.Value] ~= nil then
				error("Duplicate lot id " .. number.Number.Value .. " for " .. model:GetFullName())
			end

			models[number.Number.Value] = model
		end
	end
end

function LotUtil.GetPlayerOwnedLotNumber(p)
	for k, _ in models do
		local owner = LotUtil.GetOwner(k)

		if owner and owner == p then
			return k
		end
	end

	return nil
end

function LotUtil.GetById(p: number)
	populateIdToLotRefMap()
	return models[p]
end

function LotUtil.GetAllLots()
	populateIdToLotRefMap()
	return models
end

function LotUtil.GetLotRoot(p: number)
	local v = LotUtil.GetById(p)

	if v == nil then
		return nil
	end

	return ComponentUtil.GetComponentFromInstance(v, LotRoot)
end

function LotUtil.GetConfig(p: number)
	local config = LotConfig.GetConfig()
	local v = "Lot_" .. p

	if config == nil or config[v] == nil then
		return nil
	end

	return config[v]
end

function LotUtil.GetLotType(p: number)
	local config = LotUtil.GetConfig(p)

	if config == nil then
		return nil
	end

	return config.PlaceableType
end

function LotUtil.GetRequiredGamepasses(p: number)
	local config = LotUtil.GetConfig(p)

	if config == nil then
		return nil
	end

	return config.Gamepasses
end

function LotUtil.GetOwner(p: number)
	local lotRoot = LotUtil.GetLotRoot(p)

	if lotRoot == nil then
		return nil
	end

	return lotRoot:GetOwner()
end

function LotUtil:IsClaimed()
	local lotRoot = LotUtil.GetLotRoot(self)

	if lotRoot == nil then
		return false
	end

	return lotRoot:IsClaimed()
end

function LotUtil.GetProperty(p: number)
	local v = LotUtil.GetById(p)

	if v == nil then
		return nil
	end

	local housePickedByPlayer = v:FindFirstChild("HousePickedByPlayer")

	if housePickedByPlayer == nil then
		return nil
	end

	return housePickedByPlayer:FindFirstChild("HouseModel")
end

function LotUtil.GetBannedBlock(p: number)
	local v = LotUtil.GetById(p)

	if v == nil then
		return nil
	end

	local housePickedByPlayer = v:FindFirstChild("HousePickedByPlayer")
	local bannedLots = game.ReplicatedStorage.BannedLots

	if housePickedByPlayer == nil then
		return game.ReplicatedStorage.BannedLots:FindFirstChild("BannedBlock" .. tostring(p))
	end

	local houseModel = housePickedByPlayer:FindFirstChild("HouseModel")

	if houseModel ~= nil and houseModel:HasTag("PropertyXL") then
		local child = bannedLots:FindFirstChild("BannedBlock" .. tostring(p) .. "XL")

		if child ~= nil then
			return child
		end
	end

	return game.ReplicatedStorage.BannedLots:FindFirstChild("BannedBlock" .. tostring(p))
end

function LotUtil.GetClearRegionParts(p: number)
	local config = LotUtil.GetConfig(p)
	local clearRegions = { "House" .. p }

	if config ~= nil and config.ClearRegions ~= nil then
		clearRegions = config.ClearRegions
	end

	local result = {}
	local houseBanRegions = ServerStorage:FindFirstChild("HouseBanRegions")

	if houseBanRegions ~= nil then
		for _, childName in clearRegions do
			local part = houseBanRegions:FindFirstChild(childName)

			if part == nil or not part:IsA("BasePart") then
				warn("Invalid region defined: " .. childName .. " for lot " .. p)
			else
				table.insert(result, part)
			end
		end
	end

	if #result == 0 then
		local bannedBlock = LotUtil.GetBannedBlock(p)

		if bannedBlock ~= nil then
			table.insert(result, bannedBlock)
		end
	end

	return result
end

function LotUtil.GetPropertyRoot(p: number)
	local property = LotUtil.GetProperty(p)

	if property == nil then
		return nil
	end

	return ComponentUtil.GetComponentFromInstance(property, PropertyRoot)
end

function LotUtil.GetPropertyPermissions(p: number)
	local property = LotUtil.GetProperty(p)

	if property == nil then
		return nil
	end

	local PropertyPermissions

	if RunService:IsServer() then
		local ServerScriptService = game:GetService("ServerScriptService")
		PropertyPermissions = require(ServerScriptService.Modules.Components.Housing.PropertyPermissions)
	else
		PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
	end

	return ComponentUtil.GetComponentFromInstance(property, PropertyPermissions)
end

function LotUtil.CleanLotName(value: string)
	return (tonumber(value:match("%d+")))
end

function LotUtil.FrameworkStart()
	populateIdToLotRefMap()
end

return LotUtil