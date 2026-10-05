local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
require(script.Types)
local v = {}
local v2 = {}
local v3 = {}
local v4 = false
local flag = false
local flag2 = false
local v5 = nil
local IslandController = {
	NearestLandLocation = nil,
	_Maid = Maid.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function rejectModule(instance, formatted: string)
	v3[instance] = true
	warn((`[IslandController] Ignoring {instance:GetFullName()}: {formatted}`))
end

local function loadIslandModule(instance)
	local v6 = v2[instance]

	if v6 then
		return v6
	end

	if v3[instance] then
		return nil
	end

	local success, result = pcall(require, instance)

	if success then
		if typeof(result) == "table" then
			if typeof(result.LoadForLocations) == "table" and #result.LoadForLocations ~= 0 then
				for k, loadForLocation in result.LoadForLocations do
					if not (typeof(k) ~= "number" or k % 1 ~= 0 or k < 1 or typeof(loadForLocation) ~= "string") then
						continue
					end

					v3[instance] = true
					warn((`[IslandController] Ignoring {instance:GetFullName()}: LoadForLocations must be an array of strings`))
					return nil
				end

				if Maid.isMaid(result.Maid) then
					if typeof(result.RegionEntered) == "function" then
						if typeof(result.RegionLeaving) == "function" then
							v2[instance] = result
							return v2[instance]
						end

						v3[instance] = true
						warn((`[IslandController] Ignoring {instance:GetFullName()}: module must define RegionLeaving`))
					else
						v3[instance] = true
						warn((`[IslandController] Ignoring {instance:GetFullName()}: module must define RegionEntered`))
					end
				else
					v3[instance] = true
					warn((`[IslandController] Ignoring {instance:GetFullName()}: module must contain a Maid created by ReplicatedStorage.Util.Maid`))
				end
			else
				v3[instance] = true
				warn((`[IslandController] Ignoring {instance:GetFullName()}: module must define a non-empty LoadForLocations list`))
			end
		else
			v3[instance] = true
			warn((`[IslandController] Ignoring {instance:GetFullName()}: module must return a table`))
		end

		return nil
	else
		rejectModule(instance, `require failed: {tostring(result)}`) -- equivalent call inferred; original call site unknown
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadsForLocation(p, p2: string)
	return table.find(p.LoadForLocations, p2) ~= nil
end

local function callLifecycle(p, p2: string)
	local v6 = p.Module[p2]
	local success, result = pcall(v6, p.Module)

	if not success then
		warn((`[IslandController] {p.Source:GetFullName()}.{p2} failed: {tostring(result)}`))
	end

	return success
end

local function leaveCurrentIsland()
	for i = #v, 1, -1 do
		local v6 = v[i]
		local maid = v6.Module.Maid
		local regionLeaving = v6.Module.RegionLeaving
		local success, result = pcall(regionLeaving, v6.Module)

		if not success then
			warn((`[IslandController] {v6.Source:GetFullName()}.RegionLeaving failed: {tostring(result)}`))
		end

		maid:DoCleaning()
	end

	table.clear(v)
end

local function enterIsland(nearestLandLocation: string)
	local moduleScripts = {}

	for _, moduleScript in script:GetChildren() do
		if moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "Types" then
			table.insert(moduleScripts, moduleScript)
		end
	end

	table.sort(moduleScripts, function(a, b)
		return a.Name < b.Name
	end)

	for _, source in moduleScripts do
		local module = loadIslandModule(source)

		if not (module and loadsForLocation(module, nearestLandLocation)) then
			continue
		end

		module.Maid:DoCleaning()
		local v8 = {
			Source = source,
			Module = module
		}
		local regionEntered = v8.Module.RegionEntered
		local success, result = pcall(regionEntered, v8.Module)

		if not success then
			warn((`[IslandController] {v8.Source:GetFullName()}.RegionEntered failed: {tostring(result)}`))
		end

		if success then
			table.insert(v, v8)
		else
			local regionLeaving = v8.Module.RegionLeaving
			local success2, result2 = pcall(regionLeaving, v8.Module)

			if not success2 then
				warn((`[IslandController] {v8.Source:GetFullName()}.RegionLeaving failed: {tostring(result2)}`))
			end

			module.Maid:DoCleaning()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function transitionTo(nearestLandLocation: string?)
	if nearestLandLocation == IslandController.NearestLandLocation then
		return
	end

	leaveCurrentIsland()
	IslandController.NearestLandLocation = nearestLandLocation

	if nearestLandLocation then
		enterIsland(nearestLandLocation)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queueTransition(nearestLandLocation: string?)
	v5 = nearestLandLocation
	flag2 = true

	if flag then
		return
	end

	flag = true

	while flag2 do
		flag2 = false
		transitionTo(v5) -- equivalent call inferred; original call site unknown
	end

	flag = false
end

local function readNearestLandLocation(instance)
	local nearestLandLocation = instance:GetAttribute("NearestLandLocation")

	if nearestLandLocation == nil then
		return nil
	end

	if typeof(nearestLandLocation) == "string" then
		return nearestLandLocation
	end

	warn((`[IslandController] NearestLandLocation must be a string, got {typeof(nearestLandLocation)}`))
	return nil
end

function IslandController.GetNearestLandLocation()
	return IslandController.NearestLandLocation
end

function IslandController.OnStart()
	if not RunService:IsClient() or v4 then
		return
	end

	v4 = true
	local v6 = assert(Players.LocalPlayer, "IslandController requires a LocalPlayer")
	IslandController._Maid:GiveTask(v6:GetAttributeChangedSignal("NearestLandLocation"):Connect(function()
		local nearestLandLocation = v6:GetAttribute("NearestLandLocation")

		if nearestLandLocation == nil then
			nearestLandLocation = nil
		elseif typeof(nearestLandLocation) ~= "string" then
			warn((`[IslandController] NearestLandLocation must be a string, got {typeof(nearestLandLocation)}`))
			nearestLandLocation = nil
		end

		queueTransition(nearestLandLocation) -- equivalent call inferred; original call site unknown
	end))
	local nearestLandLocation = v6:GetAttribute("NearestLandLocation")

	if nearestLandLocation == nil then
		nearestLandLocation = nil
	elseif typeof(nearestLandLocation) ~= "string" then
		warn((`[IslandController] NearestLandLocation must be a string, got {typeof(nearestLandLocation)}`))
		nearestLandLocation = nil
	end

	queueTransition(nearestLandLocation) -- equivalent call inferred; original call site unknown
end

return IslandController