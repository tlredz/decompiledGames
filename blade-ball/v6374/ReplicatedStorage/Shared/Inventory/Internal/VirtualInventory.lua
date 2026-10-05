local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local isServer = RunService:IsServer()
local v = {
	Emote = "Emotes",
	Explosion = "DataExplosions",
	Ability = "DataAbilities"
}
local v2 = {
	Sword = "Swords",
	Booth = "Booths"
}
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getReplicatedInstances()
	if v3 then
		return v3
	end

	local success, result = pcall(function()
		return require3(ReplicatedStorage2.Shared.ReplicatedInstances)
	end)

	if not success then
		return nil
	end

	v3 = result
	return v3
end

local function getItemNames(p: string)
	local result = {}
	local v4 = v[p]

	if v4 then
		local misc = ReplicatedStorage2:FindFirstChild("Misc")
		local child = misc and misc:FindFirstChild(v4)

		if child then
			for _, child2 in child:GetChildren() do
				table.insert(result, child2.Name)
			end
		end

		return result
	else
		local v5 = v2[p]

		if not v5 then
			return result
		end

		local replicatedInstances = getReplicatedInstances() -- equivalent call inferred; original call site unknown

		if not replicatedInstances then
			return result
		end

		local collection = replicatedInstances.Collections[v5]
		local contents = collection and collection.Contents

		if type(contents) ~= "table" then
			return result
		end

		for k in contents do
			table.insert(result, k)
		end

		return result
	end
end

local function hasCatalog(p: string)
	return v[p] ~= nil or v2[p] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function catalogHas(p: string, p2: string)
	for _, v4 in getItemNames(p) do
		if v4 == p2 then
			return true
		end
	end

	return false
end

local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getFFlagModule()
	if v4 then
		return v4
	end

	local success, result = pcall(function()
		if isServer then
			return require3(ServerScriptService.Game.CoreGameModules.FFlagServer)
		end

		return (require3(ReplicatedStorage2.ClientGameModules.FFlagClient))
	end)

	if not success then
		return nil
	end

	v4 = result
	return v4
end

local function readFlag(p: string)
	local fFlagModule = getFFlagModule() -- equivalent call inferred; original call site unknown

	if not (fFlagModule and fFlagModule:IsDataReady()) then
		return nil
	end

	local success, result = pcall(function()
		return fFlagModule:GetKey(p)
	end)

	if success then
		return result
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveUserId(player)
	if player == nil then
		local localPlayer = Players.LocalPlayer
		return localPlayer and localPlayer.UserId or nil
	end

	if typeof(player) == "Instance" and player:IsA("Player") then
		return player.UserId
	end

	return nil
end

local function getAllowlist()
	local fFlagModule = getFFlagModule() -- equivalent call inferred; original call site unknown
	local result

	if fFlagModule and fFlagModule:IsDataReady() then
		local v5 = "VirtualInventoryUserIds"
		local success
		success, result = pcall(function()
			return fFlagModule:GetKey(v5)
		end)

		if not success then
			result = nil
		end
	end

	if type(result) == "table" then
		local result2 = {}

		for _, v5 in result do
			local v6 = tonumber(v5)

			if v6 then
				table.insert(result2, v6)
			end
		end

		if #result2 > 0 then
			return result2
		end
	end

	return {}
end

local VirtualInventory = {
	IdPrefix = "virtual",
	IsEnabledFor = function(_, player)
		local fFlagModule = getFFlagModule() -- equivalent call inferred; original call site unknown
		local result

		if fFlagModule and fFlagModule:IsDataReady() then
			local v5 = "VirtualInventory"
			local success
			success, result = pcall(function()
				return fFlagModule:GetKey(v5)
			end)

			if not success then
				result = nil
			end
		end

		if result ~= true then
			return false
		end

		local userId = resolveUserId(player) -- equivalent call inferred; original call site unknown

		if userId then
			return table.find(getAllowlist(), userId) ~= nil
		end

		return false
	end
}

local function buildId(p: number, p2: string, p3: string)
	return (`virtual_{p}_{p2}_{p3}`)
end

function VirtualInventory:IsVirtualId(value)
	return type(value) == "string" and string.sub(value, 1, 8) == "virtual_"
end

local function buildItem(p: string, name: string, userId: number)
	local v5 = {
		Name = name,
		Id = `virtual_{userId}_{p}_{name}`,
		CreatedAt = 0,
		TradeLock = {
			Type = "Permanent",
			Value = true
		}
	}

	if p == "Sword" then
		v5.Finisher = true
		v5.Accessory = true
		v5.Kills = 0
	elseif p == "Ability" then
		v5.Upgrade = 1
	end

	return v5
end

function VirtualInventory.BuildInventory(_, player, p: string)
	local userId = resolveUserId(player) -- equivalent call inferred; original call site unknown

	if not userId or v[p] == nil and v2[p] == nil then
		return nil
	end

	local result = {}

	for _, v5 in getItemNames(p) do
		local item = buildItem(p, v5, userId)
		result[item.Id] = item
	end

	return result
end

function VirtualInventory:GetItem(player, p: string, name)
	if type(name) ~= "string" then
		return nil
	end

	local userId = resolveUserId(player) -- equivalent call inferred; original call site unknown

	if not userId or v[p] == nil and v2[p] == nil then
		return nil
	end

	-- equivalent call inferred; original call site unknown
	if catalogHas(p, name) then
		return (buildItem(p, name, userId))
	end

	if not self:IsVirtualId(name) then
		return nil
	end

	local formatted = `virtual_{userId}_{p}_`

	if string.sub(name, 1, #formatted) ~= formatted then
		return nil
	end

	local name2 = string.sub(name, #formatted + 1)

	-- equivalent call inferred; original call site unknown
	if catalogHas(p, name2) then
		return (buildItem(p, name2, userId))
	end

	return nil
end

function VirtualInventory.FindItems(_, player, p: string, value)
	if type(value) ~= "string" then
		return {}
	end

	local userId = resolveUserId(player) -- equivalent call inferred; original call site unknown

	if not userId then
		return {}
	end

	-- equivalent call inferred; original call site unknown
	if catalogHas(p, value) then
		return { (`virtual_{userId}_{p}_{value}`) }
	end

	return {}
end

return VirtualInventory