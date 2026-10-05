local Framework = {}
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local InstanceLoadingUtil = require(ReplicatedStorage.Modules.Shared.Utils.InstanceLoadingUtil)
Framework.States = {
	Womb = "Womb",
	Boot = "Boot",
	Require = "Require",
	Init = "Init",
	Start = "Start",
	Done = "Done"
}
Framework.CurrentState = Framework.States.Womb
Framework.StateChanged = Signal.new()
Framework.Constants = {
	ServerBootedAttribute = "ServerFrameworkBooted",
	ClientBootedAttribute = "ClientFrameworkBooted",
	SharedDirectories = { ReplicatedStorage.Modules.Shared },
	SharedBlacklistDirectories = {},
	DisabledAttribute = "Disabled"
}
local nowsByCurrentState = {}
local count = 0
local v = false

local function warno(...)
	count += 1

	if not (count > 40) then
		warn(`[{RunService:IsServer() and "SERVER" or "CLIENT"} FRAMEWORK]`, ...)
	elseif not v then
		warn("Too many warnings have been spammed. Further warnings will be suppressed.")
		v = true
	end
end

local function informSlow(...)
	warno(...)
end

local v2 = {
	Function = function(moduleScript)
		return moduleScript:IsA("ModuleScript")
	end,
	Id = "ModuleScript"
}

function Framework.writeModuleScriptTotals(items, p: number)
	local v3 = {}

	for _, item in pairs(items) do
		table.insert(v3, InstanceLoadingUtil.waitForDescendantsToLoad(item, p))
	end

	Promise.all(v3):await()

	for _, item in pairs(items) do
		InstanceLoadingUtil.writeDescendantTotal(item, v2, true)
	end
end

function Framework.promiseWaitForModuleScriptTotals(items)
	local v3 = {}

	for _, item in pairs(items) do
		table.insert(v3, InstanceLoadingUtil.waitForDescendantTotalToMatch(item, v2, 1))
	end

	return Promise.all(v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setState(currentState: string)
	Framework.CurrentState = currentState
	nowsByCurrentState[currentState] = tick()
	Framework.StateChanged:Fire(currentState)
end

local lastTime = nil
local v3 = ""
local v4 = {}

local function logBoot(...)
	if not lastTime then
		lastTime = tick()
	end

	for _, v5 in pairs({ ... }) do
		v3 ..= "\n" .. ("%.3f"):format(tick() - lastTime) .. "," .. v5
	end
end

function Framework.getBootLog()
	return v3
end

function Framework.getModulesHasNotLoadedYet()
	return v4
end

function Framework.getBootTimes()
	if RunService:IsServer() then
		while not ReplicatedStorage:GetAttribute(Framework.Constants.ServerBootedAttribute) do
			task.wait()
		end

		return {
			Server = ReplicatedStorage:GetAttribute(Framework.Constants.ServerBootedAttribute),
			Client = -1
		}
	else
		while not (ReplicatedStorage:GetAttribute(Framework.Constants.ServerBootedAttribute) and ReplicatedStorage:GetAttribute(Framework.Constants.ClientBootedAttribute)) do
			task.wait()
		end

		return {
			Server = ReplicatedStorage:GetAttribute(Framework.Constants.ServerBootedAttribute),
			Client = ReplicatedStorage:GetAttribute(Framework.Constants.ClientBootedAttribute)
		}
	end
end

function Framework.boot(items, options)
	local v5 = options or {}

	if Framework.CurrentState ~= Framework.States.Womb then
		error("Framework is already booting")
	end

	if RunService:IsClient() then
		repeat
			task.wait(0.1)
		until ReplicatedStorage:GetAttribute(Framework.Constants.ServerBootedAttribute)
	end

	setState(Framework.States.Boot) -- equivalent call inferred; original call site unknown
	logBoot("Grabbing all ModuleScripts...")
	local descendants = {}

	for _, folder in pairs(items) do
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant.ClassName ~= "ModuleScript" then
				continue
			end

			local v6 = false

			for _, ancestor in pairs(v5) do
				if not (descendant:IsDescendantOf(ancestor) or descendant == ancestor) then
					continue
				end

				v6 = true
				break
			end

			if not (v6 or descendant:GetAttribute(Framework.Constants.DisabledAttribute)) then
				table.insert(descendants, descendant)
			end
		end
	end

	logBoot((`Grabbed {#descendants} ModuleScripts`))
	setState(Framework.States.Require) -- equivalent call inferred; original call site unknown
	local lastTime2 = tick()
	local lastTime3 = tick()
	logBoot("Requiring all ModuleScripts...")
	local v6 = {}
	local count2 = 0
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local flag = false
	local __loadOrders = {}
	local v10 = {}
	local v11 = {}

	for _, v12 in pairs(descendants) do
		local v13 = v12
		local v14 = Promise.new(function(callback)
			local lastTime4 = tick()
			local now = nil
			task.delay(5, function()
				if not RunService:IsStudio() or now then
					return
				end

				while not now do
					informSlow((`boot: {v13.Name} has taken {("%.3f"):format(tick() - lastTime4)}s to require so far..`))
					task.wait(4)
				end
			end)
			v4[v13.Name] = true
			local success, result = pcall(function()
				return require(v13)
			end)
			now = tick()
			v4[v13.Name] = nil
			local v15 = tick() - lastTime3

			if v15 > 2 then
				informSlow((`boot: {v13.Name} took {("%.3f"):format(v15)}s to require`))
			end

			lastTime3 = tick()

			if success then
				v6[v13] = {
					Module = type(result) == "table" and result,
					Function = type(result) == "function" and result,
					RequireTimeSeconds = tick() - lastTime2
				}
				local v21 = v6[v13]
				local requireTimeSeconds = v6[v13].RequireTimeSeconds
				logBoot((`🟩 Required {v13.Name} in {requireTimeSeconds > 2 and "🟥" or "🟩"}{("%.3f"):format(requireTimeSeconds)}s`))

				if requireTimeSeconds > 2 then
					count2 += 1
					v7[v13.Name] = (v7[v13.Name] or 0) + 1
					v8[v13.Name] = 1
					v9[v13.Name] = v13
					local dependencies = v13:GetAttribute("Dependencies")

					if dependencies then
						flag = true
						local jSONDecode = HttpService:JSONDecode(dependencies)

						for k, v22 in pairs(jSONDecode) do
							v7[v22] = (v7[v22] or 0) + 1
						end

						v8[v13.Name] = #jSONDecode
					end
				end

				if v21.Module then
					__loadOrders[result] = result.__loadOrder or 0
				end

				v10[result] = v13
				callback(true, v13)
			else
				v6[v13] = {
					Error = tostring(result)
				}
				logBoot((`🟥 Failed to require {v13.Name}: {tostring(result)}`))
				callback(false, v13)
			end
		end)
		table.insert(v11, v14)
		local v15 = v12
		v14:catch(function(p)
			warno((`boot: {v15.Name} failed to require: {tostring(p)}`))
		end)
	end

	Promise.allSettled(v11):await()
	logBoot((`Required all ModuleScripts in {("%.3f"):format(tick() - lastTime2)}s`))
	local v12 = {}
	local modules = {}

	for _, v13 in pairs(v11) do
		local expect, v14 = v13:expect()
		local v15 = v6[v14]

		if v15 then
			if v15.Error then
				warno((`boot: {v14:GetFullName()} encountered error "{v15.Error}". Will not be booted.`))
			elseif expect then
				if v15.RequireTimeSeconds > 2 then
					informSlow((`boot: {v14:GetFullName()} took {("%.3f"):format(v15.RequireTimeSeconds)}s to require`))
				end

				if v15.Module and not v12[v15.Module] then
					if not table.find(modules, v15.Module) then
						table.insert(modules, v15.Module)
					end

					v12[v15.Module] = true
				end
			else
				warno((`boot: {v14:GetFullName()} failed to require. Will not be booted.`))
			end
		else
			warno((`boot: Missing require data for {v14:GetFullName()}. Will not be booted.`))
		end
	end

	setState(Framework.States.Init) -- equivalent call inferred; original call site unknown
	logBoot((`Sorting {#modules} modules based on '__loadOrder'..`))
	table.sort(modules, function(a, b)
		local v13 = __loadOrders[a]
		local v14 = __loadOrders[b]

		if v13 ~= v14 then
			return v13 < v14
		end

		local v15 = v10[a]
		local v16 = v10[b]

		if v15.Name == v16.Name then
			return v15:GetFullName() < v16:GetFullName()
		end

		return v15.Name < v16.Name
	end)
	logBoot((`Sorted {#modules} modules.`))
	logBoot("Initialising modules synchronously...")
	local lastTime4 = tick()
	local count3 = 0

	for _, v13 in pairs(modules) do
		if not v13.FrameworkInit then
			continue
		end

		local lastTime5 = tick()
		local now = nil
		local name = v10[v13].Name
		task.delay(5, function()
			if now then
				return
			end

			while not now do
				informSlow((`boot: {name} has taken {("%.3f"):format(tick() - lastTime5)}s to init so far..`))
				task.wait(4)
			end
		end)
		local v16 = v13
		table.sort({ 1, 2 }, function(a, b)
			v16.FrameworkInit()
			return a < b
		end)
		now = tick()
		local v17 = tick() - lastTime4

		if v17 > 2 then
			informSlow((`boot: {name} took {("%.3f"):format(v17)}s to init`))
		end

		lastTime4 = tick()
		local v18 = now - lastTime5
		logBoot((`[{__loadOrders[v13]}] Initialised {name} in {v18 > 2 and "🟥" or "🟩"}{("%.3f"):format(tick() - lastTime5)}s`))
		count3 += 1
	end

	logBoot((`Initialised {count3} modules.`))
	setState(Framework.States.Start) -- equivalent call inferred; original call site unknown
	logBoot("Starting modules asynchronously...")
	local count4 = 0

	for _, v13 in pairs(modules) do
		if not v13.FrameworkStart then
			continue
		end

		logBoot((`Starting {v10[v13].Name}...`))
		task.defer(v13.FrameworkStart)
		count4 += 1
	end

	logBoot((`Started {count4} modules.`))
	setState(Framework.States.Done) -- equivalent call inferred; original call site unknown
	logBoot("Framework is done booting.\n")

	if count2 > 0 then
		if flag then
			logBoot((`We found {count2} modules with long require times, here are the most common dependencies also with long load times..:`))
			local v13 = {}

			for k, count5 in pairs(v7) do
				if v8[k] then
					table.insert(v13, {
						Dependency = k,
						Count = count5
					})
				end
			end

			table.sort(v13, function(a, b)
				return a.Count > b.Count
			end)

			for _, v14 in pairs(v13) do
				local v15 = v14.Count / count2 * 100
				logBoot((`  {v14.Dependency} - Freq: {v14.Count} ({("%.2f"):format(v15)}%)`))
				local v16 = v9[v14.Dependency]

				if not v16 then
					continue
				end

				local dependencies = v16:GetAttribute("Dependencies")

				if not dependencies then
					continue
				end

				local jSONDecode = HttpService:JSONDecode(dependencies)
				local v17 = {}

				for _, v18 in pairs(jSONDecode) do
					if v8[v18] then
						table.insert(v17, v18)
					end
				end

				logBoot((`    {#v17} slow dependencies ({table.concat(v17, ", ")})`))
			end
		else
			logBoot((`We found {count2} modules with long require times - run the "WriteDependencies" macro to get more information`))
		end
	end

	if RunService:IsServer() then
		ReplicatedStorage:SetAttribute(
			Framework.Constants.ServerBootedAttribute,
			tick() - nowsByCurrentState[Framework.States.Boot]
		)
	else
		ReplicatedStorage:SetAttribute(
			Framework.Constants.ClientBootedAttribute,
			tick() - nowsByCurrentState[Framework.States.Boot]
		)
	end
end

function Framework.promiseFrameworkDoneBooting()
	return Promise.new(function(callback)
		if Framework.CurrentState == Framework.States.Done then
			callback()
			return
		end

		local stateChangedConnection = nil
		stateChangedConnection = Framework.StateChanged:Connect(function(p: string)
			if p == Framework.States.Done then
				stateChangedConnection:Disconnect()
				callback()
			end
		end)
	end)
end

return Framework