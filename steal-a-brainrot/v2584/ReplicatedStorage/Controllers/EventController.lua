local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
require(ReplicatedStorage.Shared.EventTypes)
local eventManifests = ReplicatorClient.get("EventManifests")
local v = nil
local moduleScriptsByName = {}
local v2 = {}
local EventController = {
	Events = {}
}

local function restoreEventAssets(p: string, parent, items)
	local clones = {}

	for _, childName in items do
		if type(childName) ~= "string" or parent:FindFirstChild(childName) then
			continue
		end

		local eventAsset = BrainrotAssets.getEventAsset(p, childName)

		if not eventAsset or parent:FindFirstChild(childName) then
			continue
		end

		local clone = eventAsset:Clone()
		clone.Name = childName
		clone.Parent = parent
		table.insert(clones, clone)
	end

	return clones
end

function EventController:GetActiveEvents()
	if v then
		return v:Get("ActiveEvents") or {}
	end

	return {}
end

function EventController:GetActiveEventData(p: string)
	for k, v3 in EventController:GetActiveEvents() do
		if v3.eventName == p then
			return v3, k
		end
	end

	return nil, nil
end

function EventController.IsActive(_, p: string)
	local activeEventData, v3 = EventController:GetActiveEventData(p)
	return activeEventData ~= nil, v3
end

function EventController:Execute(p: string, _: number?)
	local event = EventController.Events[p]

	if not event or event.Active then
		return false
	end

	event.Active = true
	local parent = moduleScriptsByName[p]
	local v4 = parent and eventManifests:TryIndex({ "manifests", p })

	if type(v4) == "table" then
		task.spawn(function()
			local v5 = restoreEventAssets(p, parent, v4)

			if event.Active then
				v2[p] = v5
				event.__started = true

				if type(event.OnStart) == "function" then
					event:OnStart()
				end
			else
				for _, v6 in v5 do
					v6:Destroy()
				end
			end
		end)
	else
		event.__started = true

		if type(event.OnStart) == "function" then
			event:OnStart()
		end
	end

	return true
end

function EventController:Cancel(p: string)
	local event = EventController.Events[p]

	if not (event and event.Active) then
		return false
	end

	event.Active = false

	if event.__started then
		event.__started = false

		if type(event.OnStop) == "function" then
			event:OnStop()
		end
	end

	local v3 = v2[p]

	if v3 then
		for _, v4 in v3 do
			v4:Destroy()
		end

		v2[p] = nil
	end

	return true
end

function EventController.Load(_)
	task.spawn(function()
		while not ReplicatedStorage:GetAttribute("EventsLoaded") do
			task.wait()
		end

		for _, moduleScript in script.Events:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v3, v4 = coroutine.resume(coroutine.create(require), moduleScript)

			if v3 and type(v4) == "table" then
				if type(v4.OnLoad) == "function" then
					local v5, v6 = coroutine.resume(coroutine.create(v4.OnLoad), v4)

					if not v5 then
						warn((`Event {moduleScript:GetFullName()} failed to call Load function:\n{v6 == nil and "yielded (possibly)" or v6}`))
						continue
					end
				end

				moduleScriptsByName[moduleScript.Name] = moduleScript
				EventController.Events[moduleScript.Name] = v4
			else
				warn((`Event {moduleScript:GetFullName()} failed to load:\n{v4 == nil and "yielded (possibly)" or v4}`))
			end
		end
	end)
end

function EventController.Start(_)
	eventManifests:WaitForLoaded()
	v = Synchronizer:Wait("Events")
	v:OnArrayInserted("ActiveEvents", function(p)
		EventController:Execute(p.eventName)
	end)
	v:OnArrayRemoved("ActiveEvents", function(p)
		EventController:Cancel(p.eventName)
	end)

	for _, v3 in EventController:GetActiveEvents() do
		local v4 = v3
		task.spawn(function()
			EventController:Execute(v4.eventName)
		end)
	end
end

return EventController