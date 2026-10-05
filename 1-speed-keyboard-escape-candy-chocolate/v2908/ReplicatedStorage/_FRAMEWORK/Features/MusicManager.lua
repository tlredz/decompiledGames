local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local PlayerReady = require(ReplicatedStorage._FRAMEWORK.Features.PlayerReady)
local remo = require(ReplicatedStorage.Packages.remo)
local isServer = RunService:IsServer()
local MusicManager = {}
local v = {}
local MusicManager2

if isServer then
	MusicManager2 = nil
else
	MusicManager2 = require(ReplicatedStorage._FRAMEWORK.Libraries.MusicManager)
end

MusicManager.remotes = remo.createRemotes({
	sync = remo.remote()
})

local function checkServer()
	return isServer, "MusicManager state can only be changed or read on the server"
end

local function checkPlayArguments(p, p2: string, p3: number)
	if tostring(p) == "" then
		return false, "MusicManager.play requires a non-empty assetId"
	end

	if p2 == "" then
		return false, "MusicManager.play requires a non-empty name"
	end

	if p3 == p3 and math.abs(p3) ~= 1e999 then
		return true, ""
	end

	return false, "MusicManager.play requires a finite priority"
end

local function createSnapshot()
	local clones = {}

	for _, v2 in v do
		table.insert(clones, table.clone(v2))
	end

	table.sort(clones, function(a, b)
		return a.priority > b.priority
	end)
	return clones
end

-- equivalent calls inferred from this helper; original call sites unknown
local function broadcastSnapshot()
	MusicManager.remotes.sync:fireAll((createSnapshot()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeMatchingTracks(p: string, p2: number)
	for k, v2 in v do
		if k == p or v2.priority == p2 then
			v[k] = nil
		end
	end
end

local function reconcileClientTracks(items)
	local v2 = MusicManager2

	if v2 then
		local v3 = {}

		for _, item in items do
			v3[item.name] = item
		end

		for _, v4 in v2.getAllPlaying() do
			local v5 = v3[v4.name]

			if v5 == nil or tostring(v5.assetId) ~= tostring(v4.assetId) or v5.priority ~= v4.priority then
				v2.stop(v4.name)
			else
				v3[v4.name] = nil
			end
		end

		local v4 = {}

		for _, v5 in v3 do
			table.insert(v4, v5)
		end

		table.sort(v4, function(a, b)
			return a.priority < b.priority
		end)

		for _, v5 in v4 do
			v2.play(v5.assetId, v5.name, v5.priority)
		end
	end
end

function MusicManager.play(assetId, name: string, priority: number)
	local v2 = isServer
	local v3 = "MusicManager state can only be changed or read on the server"
	local v4, v5

	if tostring(assetId) == "" then
		v4 = false
		v5 = "MusicManager.play requires a non-empty assetId"
	elseif name == "" then
		v4 = false
		v5 = "MusicManager.play requires a non-empty name"
	elseif priority == priority and math.abs(priority) ~= 1e999 then
		v4 = true
		v5 = ""
	else
		v4 = false
		v5 = "MusicManager.play requires a finite priority"
	end

	if v2 and v4 then
		removeMatchingTracks(name, priority) -- equivalent call inferred; original call site unknown
		local v6 = {
			assetId = assetId,
			name = name,
			priority = priority
		}
		v[name] = v6
		broadcastSnapshot() -- equivalent call inferred; original call site unknown
		return table.clone(v6)
	else
		if not v2 then
			v5 = v3
		end

		error(v5)
	end
end

function MusicManager.stop(p: string)
	local v2 = "MusicManager state can only be changed or read on the server"

	if isServer then
		if v[p] then
			v[p] = nil
			broadcastSnapshot() -- equivalent call inferred; original call site unknown
		end
	else
		error(v2)
	end
end

function MusicManager.getAllPlaying()
	if isServer then
		return (createSnapshot())
	end

	error("MusicManager state can only be changed or read on the server")
end

function MusicManager.stopAll()
	local v2 = "MusicManager state can only be changed or read on the server"

	if isServer then
		if next(v) ~= nil then
			table.clear(v)
			broadcastSnapshot() -- equivalent call inferred; original call site unknown
		end
	else
		error(v2)
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			PlayerReady.onPlayerReady:Connect(function(p)
				MusicManager.remotes.sync:fire(p, (createSnapshot()))
			end)
		else
			MusicManager.remotes.sync:connect(reconcileClientTracks)
		end
	end
})
return MusicManager