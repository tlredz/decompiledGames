local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local remoteEvent = Net:RemoteEvent("AssetStreamService/Request")
local remoteEvent2 = Net:RemoteEvent("AssetStreamService/Ack")
local localPlayer = Players.LocalPlayer
local assetStream = ReplicatorClient.get("AssetStream")
local v = {}
local onAssetCached = Signal.new()
local folder = nil
local AssetStreamController = {
	onAssetCached = onAssetCached
}

local function ensureCategory(p: string)
	local v3 = v[p]

	if not v3 then
		v3 = {}
		v[p] = v3
	end

	return v3
end

local v3 = {}
local v4 = {}
local v5 = {}
local v6 = false
local flag = false

local function cacheKeyOf(p: string, p2: string)
	return p .. "\1" .. p2
end

local function flush()
	v6 = false

	for k, v7 in v4 do
		if #v7 > 0 then
			remoteEvent:FireServer(k, v7)
		end
	end

	for k, v7 in v5 do
		if #v7 > 0 then
			remoteEvent2:FireServer(k, v7)
		end
	end

	table.clear(v4)
	table.clear(v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleFlush()
	if not v6 then
		v6 = true
		task.defer(flush)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queueRequest(p: string, p2: string)
	local v7 = v4[p]

	if not v7 then
		v7 = {}
		v4[p] = v7
	end

	table.insert(v7, p2)
	scheduleFlush() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startRetryLoop()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while next(v3) ~= nil do
			task.wait(3)

			for k, v7 in v3 do
				v7.tries += 1

				if v7.tries > 12 then
					v3[k] = nil
				else
					queueRequest(v7.category, v7.key) -- equivalent call inferred; original call site unknown
				end
			end
		end

		flag = false
	end)
end

local function requestAsset(category: string, p2: string)
	local v7 = v[category]

	if v7 and v7[p2] then
		return
	end

	local v8 = category .. "\1" .. p2

	if v3[v8] then
		return
	end

	v3[v8] = {
		category = category,
		key = p2,
		tries = 0
	}
	queueRequest(category, p2) -- equivalent call inferred; original call site unknown
	startRetryLoop() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ackAsset(c: string, k: string)
	local v7 = v5[c]

	if not v7 then
		v7 = {}
		v5[c] = v7
	end

	table.insert(v7, k)
	scheduleFlush() -- equivalent call inferred; original call site unknown
end

local function realNameFromKey(k: string)
	local v7 = string.find(k, "\1", 1, true)

	if not v7 then
		return k
	end

	while true do
		local v8 = string.find(k, "\1", v7 + 1, true)

		if not v8 then
			break
		end

		v7 = v8
	end

	return (string.sub(k, v7 + 1))
end

local function waitForMeta(folder2)
	local v7

	while true do
		v7 = assetStream:TryIndex({ "assets", folder2.Name })

		if type(v7) == "table" then
			break
		end

		if not folder2.Parent then
			return nil
		end

		task.wait()
	end

	return v7
end

local function onStreamedAsset(folder2)
	local v7 = waitForMeta(folder2)

	if not v7 then
		return
	end

	local c = v7.c
	local k = v7.k

	if type(c) ~= "string" or type(k) ~= "string" then
		return
	end

	local clones = v[c]

	if not clones then
		clones = {}
		v[c] = clones
	end

	if clones[k] then
		return
	end

	local n = v7.n

	if type(n) == "number" and n > 0 then
		while #folder2:GetDescendants() < n do
			if not folder2.Parent then
				return
			end

			task.wait()
		end
	end

	if clones[k] then
		return
	end

	local clone = folder2:Clone()
	clone.Name = realNameFromKey(k)
	clone.Parent = folder
	clones[k] = clone
	v3[c .. "\1" .. k] = nil
	onAssetCached:Fire(c, k)
	ackAsset(c, k) -- equivalent call inferred; original call site unknown
end

local function watchStreamFolder(__AssetStream)
	__AssetStream.ChildAdded:Connect(function(child)
		task.spawn(onStreamedAsset, child)
	end)

	for _, child in __AssetStream:GetChildren() do
		task.spawn(onStreamedAsset, child)
	end
end

function AssetStreamController.requestAssets(category: string, items)
	for _, item in items do
		requestAsset(category, item)
	end
end

function AssetStreamController.waitForAsset(category: string, p2: string, value: number?)
	local v7 = v[category]

	if not v7 then
		v7 = {}
		v[category] = v7
	end

	if v7[p2] then
		return v7[p2]
	end

	requestAsset(category, p2)
	local v8 = os.clock() + (value or 30)

	while os.clock() < v8 do
		task.wait(0.1)

		if v7[p2] then
			return v7[p2]
		end
	end

	return v7[p2]
end

function AssetStreamController.Load(_)
	task.spawn(function()
		local __AssetStream = localPlayer:WaitForChild("PlayerGui"):WaitForChild("__AssetStream", 60)

		if not __AssetStream then
			return
		end

		folder = Instance.new("Folder")
		folder.Name = "AssetCache"
		folder.Parent = script
		watchStreamFolder(__AssetStream)
	end)
end

return AssetStreamController