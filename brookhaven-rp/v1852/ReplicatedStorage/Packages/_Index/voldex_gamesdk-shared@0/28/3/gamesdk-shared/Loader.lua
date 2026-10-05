local parent = script.Parent.Parent
local Promise = require(parent.Promise)
local Loader = {
	States = {
		Womb = "Womb",
		Boot = "Boot",
		Require = "Require",
		Sort = "Sort",
		Init = "Init",
		Start = "Start",
		Done = "Done"
	}
}
Loader.State = Loader.States.Womb
Loader.LastStateChange = nil
Loader.StartTime = nil
Loader.Timings = {}
Loader._stateChanged = Instance.new("BindableEvent")
Loader.StateChanged = Loader._stateChanged.Event

local function warno(...)
	warn("[GameSdk - Loader]", ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function erroro(formatted)
	error("[GameSdk - Loader] " .. formatted)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setState(state: string)
	local state2 = Loader.State
	Loader.State = state

	if Loader.LastStateChange ~= nil then
		Loader.Timings[state2] = os.clock() - Loader.LastStateChange
	end

	Loader.LastStateChange = os.clock()
	Loader._stateChanged:Fire(state, state2)
end

local function topologicalSort(items)
	local v = {}
	local v2 = {}
	local v3 = {}

	for k, _ in items do
		table.insert(v, k)
		v2[k] = {}
		v3[k] = 0
	end

	for k, item in items do
		local dependsOn = item.DependsOn

		if not (dependsOn ~= nil and type(dependsOn) == "table") then
			continue
		end

		for _, v4 in dependsOn do
			if items[v4] then
				table.insert(v2[v4], k)
				v3[k] += 1
			else
				warno("Module '" .. k .. "' depends on '" .. v4 .. "' which was not found")
			end
		end
	end

	local v4 = {}

	for k, v5 in v3 do
		if v5 == 0 then
			table.insert(v4, k)
		end
	end

	local result = {}
	local count = 0

	while #v4 > 0 do
		local v5 = table.remove(v4, 1)
		table.insert(result, v5)
		count += 1

		for _, v6 in v2[v5] do
			v3[v6] -= 1

			if v3[v6] == 0 then
				table.insert(v4, v6)
			end
		end
	end

	if count == #v then
		return result, nil
	end

	local result2 = {}

	for k, v5 in v3 do
		if v5 > 0 then
			table.insert(result2, k)
		end
	end

	return {}, result2
end

function Loader.Boot(items)
	setState(Loader.States.Womb) -- equivalent call inferred; original call site unknown
	local descendants = {}
	setState(Loader.States.Boot) -- equivalent call inferred; original call site unknown

	for _, folder in items do
		for _, descendant in folder:GetDescendants() do
			if not descendant.ClassName ~= "ModuleScript" then
				table.insert(descendants, descendant)
			end
		end
	end

	setState(Loader.States.Require) -- equivalent call inferred; original call site unknown
	local v = {}
	local v2 = {}

	for _, v3 in descendants do
		local v4 = v3
		local v5 = Promise.new(function(callback, callback2)
			local success, result = pcall(function()
				return require(v4)
			end)

			if not success then
				callback2(result)
				return
			end

			v[v4.Name] = result
			callback()
		end)
		table.insert(v2, v5)
		local v6 = v3
		v5:catch(function(p)
			warno((`{Loader.State}: {v6.Name} failed to require: {tostring(p)}`))
		end)
	end

	Promise.allSettled(v2):await()
	setState(Loader.States.Sort) -- equivalent call inferred; original call site unknown
	local v3, v4 = topologicalSort(v)

	if v4 ~= nil then
		erroro(`{Loader.State}: circular dependencies detected: {table.concat(v4, ", ")}`) -- equivalent call inferred; original call site unknown
	end

	setState(Loader.States.Init) -- equivalent call inferred; original call site unknown

	for _, v5 in v3 do
		local v6 = v[v5]

		if not (v6 and v6.Init) then
			continue
		end

		local success, result = pcall(v6.Init)

		if not success then
			warno((`{Loader.State}: {v5} failed to initialize: {tostring(result)}`))
		end
	end

	setState(Loader.States.Start) -- equivalent call inferred; original call site unknown

	for _, v5 in v3 do
		local v6 = v[v5]

		if not (v6 and v6.Start) then
			continue
		end

		local v7 = v6
		local v8 = v5
		task.defer(function()
			local success, result = pcall(v7.Start)

			if not success then
				warno((`{Loader.State}: {v8} failed to start: {tostring(result)}`))
			end
		end)
	end

	setState(Loader.States.Done) -- equivalent call inferred; original call site unknown
	return true
end

function Loader.GetState()
	return Loader.State
end

function Loader.GetTimings()
	return Loader.Timings
end

return Loader