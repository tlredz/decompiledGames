local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedABTests = require(ReplicatedStorage.UserGenerated.ABTests.SharedABTests)
local DeepFreezeUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepFreezeUnsafe)
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local localPlayer = Players.LocalPlayer
local flag = false
local loaded = Bindable.new()

local function IsLoaded()
	return flag
end

local v2 = nil

local function GetAssignmentsAsync(player, flag2: boolean)
	local v3

	if typeof(player) == "Instance" then
		v3 = player:IsA("Player")
	else
		v3 = false
	end

	assert(v3)
	assert(type(flag2) == "boolean")

	if player ~= localPlayer then
		return nil
	end

	local v4

	while true do
		v4 = v2

		if v4 then
			break
		end

		if not (flag2 and player.Parent) then
			return nil
		end

		task.wait()
	end

	return v4
end

local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function GetAttributes(player)
	if player == localPlayer then
		return v3
	end

	local v4

	if typeof(player) == "Instance" then
		v4 = player:IsA("Player")
	else
		v4 = false
	end

	assert(v4)
	return nil
end

local function GetAttribute(player, value: string, p)
	assert(type(value) == "string")
	local attributes = GetAttributes(player) -- equivalent call inferred; original call site unknown
	local selected = attributes and attributes[value]

	if selected == nil then
		return p, false
	end

	return selected, true
end

local function GetAttributeAsync(localPlayer2, value: string, p)
	assert(type(value) == "string")

	if GetAssignmentsAsync(localPlayer2, true) then
		return GetAttribute(localPlayer2, value, p)
	end

	return p, false
end

local function GetJobAttributes()
	local player = localPlayer

	if player == localPlayer then
		return v3
	end

	local v4

	if typeof(player) == "Instance" then
		v4 = player:IsA("Player")
	else
		v4 = false
	end

	assert(v4)
	return nil
end

local function GetJobAssignments()
	return v2
end

local playerUpdated = Bindable.new()
local jobUpdated = Bindable.new()
SharedABTests.UpdateRemote.OnClientEvent:Connect(function(p, p2)
	DeepFreezeUnsafe(p)
	DeepFreezeUnsafe(p2)
	v3 = p
	v2 = p2
	flag = true
	loaded:Fire()
	playerUpdated:Fire(localPlayer)
	jobUpdated:Fire()
end)
return table.freeze({
	GetAttributes = GetAttributes,
	GetAttribute = GetAttribute,
	GetAttributeAsync = GetAttributeAsync,
	GetAssignmentsAsync = GetAssignmentsAsync,
	GetJobAttributes = GetJobAttributes,
	GetJobAttribute = function(p: string, p2)
		return GetAttribute(localPlayer, p, p2)
	end,
	GetJobAttributeAsync = function(p: string, p2)
		return GetAttributeAsync(localPlayer, p, p2)
	end,
	GetJobAssignments = GetJobAssignments,
	GetJobAssignmentsAsync = function(flag2: boolean)
		return GetAssignmentsAsync(localPlayer, flag2)
	end,
	IsLoaded = IsLoaded,
	Loaded = loaded,
	PlayerUpdated = playerUpdated,
	JobUpdated = jobUpdated
})