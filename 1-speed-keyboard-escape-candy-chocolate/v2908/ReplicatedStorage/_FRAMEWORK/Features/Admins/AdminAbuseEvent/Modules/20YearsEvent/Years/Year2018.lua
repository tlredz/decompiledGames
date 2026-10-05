local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local Config = require(script.Config)
local CollectedModelVisibility = require(script.Parent.CollectedModelVisibility)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local YearCollectibles = require(script.Parent.YearCollectibles)
require(script.Parent.Parent.Types)
local remo = require(ReplicatedStorage.Packages.remo)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local year2018 = remo.createRemotes({
	year2018 = remo.namespace({
		chestOpened = remo.remote()
	})
}).year2018
local remotes = YearCollectibles.createRemotes("year2018Orbs")

local function checkGameplayReady(map)
	local child = map:FindFirstChild(Config.scriptablesFolderName)
	local child2

	if child then
		child2 = child:FindFirstChild(Config.chestsFolderName)
	end

	local models = {}
	local v = nil

	for _, model in not child2 and {} or child2:GetChildren() do
		if model:IsA("Model") and model.PrimaryPart then
			table.insert(models, model)
		else
			v = model
		end
	end

	if not child2 then
		return false, nil, "20th Anniversary year 2018 is missing its Scriptables.Chests folder"
	end

	if v then
		return
			false,
			nil,
			string.format("20th Anniversary year 2018 chest %s must be a Model with a PrimaryPart", v:GetFullName())
	end

	return true, models, nil
end

local function isWithinReach(player, p)
	local character = player.Character
	return character ~= nil and (character:GetPivot().Position - p.Position).Magnitude <= Config.maxOpenDistanceStuds
end

local function createPrompt(parent, p: number)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = Config.promptName
	proximityPrompt.ActionText = Config.promptActionText
	proximityPrompt.ObjectText = Config.promptObjectText
	proximityPrompt.HoldDuration = Config.promptHoldSeconds
	proximityPrompt.MaxActivationDistance = Config.promptDistanceStuds
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt:SetAttribute(Config.chestIdAttributeName, p)
	proximityPrompt.Parent = parent
	return proximityPrompt
end

local function startChests(items)
	local v = AAEventWinAward.create(Config.chestAward)
	local v2 = {}
	local v3 = {}
	local connections = {}

	for k, item in items do
		local primaryPart = item.PrimaryPart
		v2[k] = {}
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = Config.promptName
		proximityPrompt.ActionText = Config.promptActionText
		proximityPrompt.ObjectText = Config.promptObjectText
		proximityPrompt.HoldDuration = Config.promptHoldSeconds
		proximityPrompt.MaxActivationDistance = Config.promptDistanceStuds
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt:SetAttribute(Config.chestIdAttributeName, k)
		proximityPrompt.Parent = primaryPart
		table.insert(v3, proximityPrompt)
		local v4 = k
		table.insert(connections, proximityPrompt.Triggered:Connect(function(player)
			if v2[v4][player.UserId] then
				year2018.chestOpened:fire(player, v4)
				return
			end

			local v6 = primaryPart
			local character = player.Character
			local v7

			if character == nil then
				v7 = false
			else
				v7 = (character:GetPivot().Position - v6.Position).Magnitude <= Config.maxOpenDistanceStuds
			end

			if v7 then
				v2[v4][player.UserId] = true
				v(player)
				year2018.chestOpened:fire(player, v4)
			end
		end))
	end

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		for _, v4 in v3 do
			v4:Destroy()
		end

		table.clear(v3)
	end
end

local function startOrbs(p)
	local zones = YearCollectibles.findZones(p.map, Config.orbSpawnZoneName)

	if #zones > 0 then
		return YearCollectibles.startServer(p, {
			remotes = remotes,
			zones = zones,
			config = Config.winOrbs,
			award = Config.winOrbAward,
			logger = logger
		})
	end

	logger:warn("20th Anniversary year 2018 has no OrbSpawnZone")
	return p
end

local function startGameplay(loaded)
	local v, v2, v3 = checkGameplayReady(loaded.map)

	if not v then
		logger:warn(v3)
		return startOrbs(loaded)
	end

	local v4 = startChests(v2)
	local cleanup = loaded.cleanup
	return startOrbs({
		map = loaded.map,
		spawn = loaded.spawn,
		cleanup = function()
			v4()
			cleanup()
		end
	})
end

local Year2018 = {}

function Year2018.load(p, _: number)
	local loaded, v = DefaultYearMap.load(p, 2018)

	if loaded then
		return startGameplay(loaded), nil
	end

	return nil, v
end

function Year2018.loadClient(p, _: number)
	local v = {}
	local folder = nil
	local v2 = {}

	local function closeIfOpened(proximityPrompt)
		if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Name == Config.promptName and v[proximityPrompt:GetAttribute(Config.chestIdAttributeName)] then
			local parent = proximityPrompt.Parent

			while parent and parent ~= folder do
				if parent:IsA("Model") and parent.Parent and parent.Parent.Name == Config.chestsFolderName then
					if v2[parent] then
						break
					end

					v2[parent] = CollectedModelVisibility.hide(parent)
					return
				else
					parent = parent.Parent
				end
			end
		end
	end

	local chestOpenedConnection = year2018.chestOpened:connect(function(p2: number)
		v[p2] = true

		if folder then
			for _, descendant in folder:GetDescendants() do
				closeIfOpened(descendant)
			end
		end
	end)
	local v3 = DefaultYearMap.watchMap(p, 2018, function(folder2)
		folder = folder2

		for _, descendant in folder2:GetDescendants() do
			closeIfOpened(descendant)
		end

		local descendantAddedConnection = folder2.DescendantAdded:Connect(closeIfOpened)
		return function()
			descendantAddedConnection:Disconnect()

			for _, v4 in v2 do
				v4()
			end

			table.clear(v2)
			folder = nil
		end
	end)
	local v4 = YearCollectibles.startClient({
		remotes = remotes,
		config = Config.winOrbs,
		logger = logger
	})
	return function()
		v4()
		chestOpenedConnection()
		v3()
	end
end

return Year2018