local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Observers = require(packages.Observers)
require(packages.State)
local TableUtil = require(packages.TableUtil)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedTimeFlowPuzzle)
local module = require("@self/ObserverStates")
require("@self/Types")
local TimeFlowPuzzleController = {}

function TimeFlowPuzzleController.Start()
	TimeFlowPuzzleController.BootObservers()
	DataController.PlayerDataReplicator:Observe({ "TimeFlowPuzzle" }, TimeFlowPuzzleController.DataUpdateProcessor)
end

function TimeFlowPuzzleController.GetCompletionStateObject(p)
	local v = nil

	for _, v3 in module do
		local completionStateObjects = v3.CompletionStateObjects

		if not completionStateObjects then
			continue
		end

		local flag = false

		for k, completionStateObject in completionStateObjects do
			if k ~= p then
				continue
			end

			v = completionStateObject
			flag = true
		end

		if flag then
			break
		end
	end

	return v
end

function TimeFlowPuzzleController.ClearGeodeBlocker(p: string)
	local clearedDebrisUIDs = module.Debris.CompletionStateObjects.ClearedDebrisUIDs
	local v = clearedDebrisUIDs:get()
	local copy = TableUtil.Copy(v)
	table.insert(copy, p)
	clearedDebrisUIDs:set(copy)
end

function TimeFlowPuzzleController.BootObservers()
	for _, v in module do
		Observers.observeTag(v.Tag, v.ObserverCallback)
	end
end

function TimeFlowPuzzleController.DataUpdateProcessor(p)
	if not p then
		return
	end

	if p.Generic.CartStoneCollected then
		module.Minecart.CompletionStateObjects.GemCollected:set(true)
	end

	if p.Generic.CartStopped then
		module.Minecart.CompletionStateObjects.CartStopped:set(true)
	end

	if p.Generic.TimeSharedCollected then
		module.TimeShard.CompletionStateObjects.Collected:set(true)
	end

	if p.Generic.SwimmingStoneCollected then
		module.Debris.CompletionStateObjects.CollectedReward:set(true)
	end

	if p.Placements.Cut then
		module.Placements.CompletionStateObjects.Cut:set(true)
	end

	if p.Placements.Radiant then
		module.Placements.CompletionStateObjects.Radiant:set(true)
	end

	if p.Placements.Rough then
		module.Placements.CompletionStateObjects.Rough:set(true)
	end
end

return TimeFlowPuzzleController