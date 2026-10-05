local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Signal = require(packages.Signal)
local patch = require(packages.patch)
local modules = ReplicatedStorage.client.modules
local ReplicatorClient = require(modules.ReplicatorClient)
local playerData = ReplicatorClient.get("PlayerData")
local playerStorage = ReplicatorClient.get("PlayerStorage")
local playerInventory = ReplicatorClient.get("PlayerInventory")
local playerBestiary = ReplicatorClient.get("PlayerBestiary")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local DataController = {
	PlayerDataReplicator = playerData,
	StorageReplicator = playerStorage,
	InventoryReplicator = playerInventory,
	BestiaryReplicator = playerBestiary,
	DataChanged = Signal.new()
}
local v = {}
local v2 = {}
local deepCopy

deepCopy = function(p)
	if type(p) ~= "table" then
		return p
	end

	local clone = table.clone(p)

	for k, v3 in clone do
		clone[k] = deepCopy(v3)
	end

	return clone
end

local function wrap(p)
	return {
		value = p
	}
end

local function resumeWaiting(k: string, p)
	local v3 = v[k]

	if not v3 then
		return
	end

	for _, callback in v3 do
		if coroutine.status(callback) == "suspended" then
			task.spawn(callback, p)
		end
	end

	table.clear(v3)
end

local function sanitizeInventoryPatch(value)
	if type(value) ~= "table" then
		return
	end

	local inventory = v2.Inventory

	if not inventory then
		return
	end

	for k, item in value do
		if not (type(item) == "table" and type(item.sub) == "table" and inventory[k]) then
			continue
		end

		item.sub.Favourited = nil
	end
end

local function handleReplication(data, data2)
	if type(data) ~= "table" then
		return
	end

	local v3 = {}

	for k in data2 or data do
		v3[k] = true
	end

	for k in v3 do
		local v4 = v2[k]
		local v5 = data[k]
		local diff = patch.diff({
			value = v4
		}, {
			value = v5
		})
		local value = diff.value

		if value == nil then
			continue
		end

		if k == "Inventory" and v2.Inventory then
			sanitizeInventoryPatch(value)
		end

		local v7 = deepCopy(patch.apply({
			value = v4
		}, diff).value)
		v2[k] = v7
		DataController.DataChanged:Fire(k, v7, value)
		resumeWaiting(k, v7)
	end
end

function DataController.Start(_)
	ReplicatorClient.init()
	playerData:ListenRaw(handleReplication)

	if playerData.Data then
		handleReplication(playerData.Data, playerData.Data)
	end

	playerStorage:ListenRaw(handleReplication)

	if playerStorage.Data then
		handleReplication(playerStorage.Data, playerStorage.Data)
	end
end

function DataController.observe(p: string, callback)
	local formatted = `Please use ":Observe(\{ "{p}" })" on DataController.PlayerDataReplicator (or the Storage/Inventory versions) for new work! (Observing: {p})`

	if p == "Inventory" or p == "Storage" then
		error(formatted)
	else
		warn(formatted)
	end

	local v3 = v2[p]

	if v3 then
		task.spawn(callback, v3, v3)
	end

	return DataController.DataChanged:Connect(function(p2, p3, p4)
		if p2 == p then
			callback(p3, p4)
		end
	end)
end

function DataController.watch(p: string, callback)
	local formatted = `Please use ":Listen(\{ "{p}" })" on DataController.PlayerDataReplicator (or the Storage/Inventory versions) for new work! (Watching: {p})`

	if p == "Inventory" or p == "Storage" then
		error(formatted)
	else
		warn(formatted)
	end

	return DataController.DataChanged:Connect(function(p2, p3, p4)
		if p2 == p then
			callback(p3, p4)
		end
	end)
end

function DataController.fetch(p: string)
	local formatted = `Please use ":Index(\{ "{p}" })" on DataController.PlayerDataReplicator (or the Storage/Inventory versions) for new work! (Fetching: {p})`

	if p == "Inventory" or p == "Storage" then
		error(formatted)
	else
		warn(formatted)
	end

	local v3 = v2[p]

	if v3 then
		return v3
	end

	if not v[p] then
		v[p] = {}
	end

	table.insert(v[p], coroutine.running())
	return coroutine.yield()
end

function DataController.getItemFromLink(tool)
	local v3 = playerInventory:TryIndex({ "Inventory" })

	if type(tool) == "string" then
		if v3 then
			return v3[tool]
		end

		return nil
	else
		if not (tool and tool.Parent) then
			return
		end

		local v4

		if typeof(tool) == "Instance" then
			v4 = tool:IsA("Tool")
		else
			v4 = false
		end

		assert(v4, "getItemFromLink expected a tool or itemId")
		local playerFromCharacter = nil

		if tool.Parent:IsA("Model") then
			playerFromCharacter = Players:GetPlayerFromCharacter(tool.Parent)
		else
			local parent = tool.Parent.Parent

			if parent and parent:IsA("Player") then
				playerFromCharacter = parent
			end
		end

		if not playerFromCharacter then
			return
		end

		local link = tool:FindFirstChild("link")

		if not link then
			return
		end

		local value = link.Value

		if v3 then
			return v3[value], value
		end

		return nil, value
	end
end

function DataController.HasItem(p: string, items, flag: boolean?)
	DataController.InventoryReplicator:WaitForLoaded()
	local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)

	local function hasSubValues(p2)
		if not items then
			return true
		end

		for k, item in items do
			if k == "WeightClass" and fish[p] then
				if item ~= FischUtils.GetWeightClass(p, p2.sub.Weight) then
					return false
				end
			elseif not p2.sub[k] or p2.sub[k] ~= item then
				return false
			end
		end

		return true
	end

	for k, v3 in DataController.InventoryReplicator:Index({ "Inventory" }) do
		if v3.name == p and hasSubValues(v3) then
			return true, v3, k
		end
	end

	if flag then
		return false, nil, nil
	end

	DataController.StorageReplicator:WaitForLoaded()

	for k, v3 in DataController.StorageReplicator:Index({ "Storage" }) do
		if v3.name == p and hasSubValues(v3) then
			return true, v3, k
		end
	end

	return false, nil, nil
end

function DataController.CountItem(p: string?, items, p2: number?, flag: boolean?)
	DataController.InventoryReplicator:WaitForLoaded()
	local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)

	local function hasSubValues(p3)
		if not items then
			return true
		end

		for k, item in items do
			if k == "WeightClass" and fish[p] then
				if item ~= FischUtils.GetWeightClass(p, p3.sub.Weight) then
					return false
				end
			elseif not p3.sub[k] or p3.sub[k] ~= item then
				return false
			end
		end

		return true
	end

	local total = 0

	for _, v3 in DataController.InventoryReplicator:Index({ "Inventory" }) do
		if not ((not p or v3.name == p) and hasSubValues(v3)) then
			continue
		end

		total += v3.sub and v3.sub.Stack or 1

		if p2 and p2 <= total then
			return total
		end
	end

	if flag then
		return total
	end

	DataController.StorageReplicator:WaitForLoaded()

	for _, v3 in DataController.StorageReplicator:Index({ "Storage" }) do
		if not ((not p or v3.name == p) and hasSubValues(v3)) then
			continue
		end

		total += v3.sub and v3.sub.Stack or 1

		if p2 and p2 <= total then
			return total
		end
	end

	return total
end

function DataController.getItem(p: string)
	DataController.InventoryReplicator:WaitForLoaded()
	local v3 = DataController.InventoryReplicator:TryIndex({ "Inventory", p })

	if v3 then
		return v3
	end

	DataController.StorageReplicator:WaitForLoaded()
	return DataController.StorageReplicator:TryIndex({ "Storage", p })
end

return DataController