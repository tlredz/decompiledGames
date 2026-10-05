local ReplicatedStorage = game:GetService("ReplicatedStorage")
local controllers = ReplicatedStorage.Controllers
local controllerRunner = script:WaitForChild("ControllerRunner")
local folder = Instance.new("Folder")
folder.Name = "ControllerRunners"
folder.Parent = script.Parent
local require2 = require
local ControllerIsolator = {}
local v = {}
local requireProxyManifest = script.Parent:FindFirstChild("RequireProxyManifest")
local v2 = nil

if requireProxyManifest then
	local success, result = pcall(require2, requireProxyManifest)

	if success then
		v2 = result
	else
		task.spawn(error, (`RequireProxyManifest failed to load, using the hand-written lists: {result}`))
	end
end

local v3 = {}

if v2 then
	for _, isolatedModule in v2.IsolatedModules do
		v3[isolatedModule] = true
	end
end

local function isController(moduleScript)
	local isA = moduleScript:IsA("ModuleScript")

	if isA then
		if moduleScript.Name:match("Controller") == nil then
			isA = false
		else
			isA = moduleScript:IsDescendantOf(controllers)
		end
	end

	return isA
end

local function isIsolated(moduleScript)
	local v4

	if v3[moduleScript] == true then
		return true
	else
		v4 = moduleScript:IsA("ModuleScript")

		if v4 then
			if moduleScript.Name:match("Controller") == nil then
				return false
			else
				return (moduleScript:IsDescendantOf(controllers))
			end
		end
	end

	return v4
end

local function resolvePath(moduleScript: string, game2)
	local v4

	if moduleScript:sub(1, 6) == "@game/" then
		game2 = game
		v4 = moduleScript:sub(7)
	elseif moduleScript:sub(1, 6) == "@self/" then
		v4 = moduleScript:sub(7)
	else
		return nil
	end

	for childName in v4:gmatch("[^/]+") do
		if childName == "." then
			continue
		end

		if childName == ".." then
			game2 = game2.Parent
		else
			game2 = game2:FindFirstChild(childName)
		end

		if game2 == nil then
			return nil
		end
	end

	if game2 and game2:IsA("ModuleScript") then
		return game2
	end

	return nil
end

local function waitForLoaded(runner)
	local loaded = runner:GetAttribute("Loaded")

	while loaded == nil do
		runner:GetAttributeChangedSignal("Loaded"):Wait()
		loaded = runner:GetAttribute("Loaded")
	end

	return loaded == true
end

local function getRunner(moduleScript)
	local v4

	if v3[moduleScript] == true then
		v4 = true
	else
		v4 = moduleScript:IsA("ModuleScript")

		if v4 then
			if moduleScript.Name:match("Controller") == nil then
				v4 = false
			else
				v4 = moduleScript:IsDescendantOf(controllers)
			end
		end
	end

	assert(v4, (`{moduleScript:GetFullName()} is not a controller or manifest module`))
	local v5 = v[moduleScript]

	if v5 == nil then
		local clone = controllerRunner:Clone()
		clone.Name = moduleScript.Name
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "Target"
		objectValue.Value = moduleScript
		objectValue.Parent = clone
		clone.Parent = folder
		v[moduleScript] = {
			runner = clone
		}
		clone.Enabled = true
		v5 = v[moduleScript]
	end

	local runner = v5.runner

	while runner:GetAttribute("Ready") ~= true do
		runner:GetAttributeChangedSignal("Ready"):Wait()
	end

	if runner:GetAttribute("BeginLoad") ~= true then
		runner:SetAttribute("BeginLoad", true)
	end

	if not waitForLoaded(runner) then
		error(`Failed to require "{moduleScript:GetFullName()}" in isolation:\n{runner:GetAttribute("LoadError")}`, 3)
	end

	return runner
end

function ControllerIsolator.IsController(moduleScript)
	local v4

	if typeof(moduleScript) == "Instance" then
		v4 = moduleScript:IsA("ModuleScript")

		if v4 then
			if moduleScript.Name:match("Controller") == nil then
				return false
			else
				return (moduleScript:IsDescendantOf(controllers))
			end
		end
	else
		return false
	end

	return v4
end

function ControllerIsolator.GetManifest()
	return v2
end

function ControllerIsolator.Require(moduleScript)
	local v4

	if v3[moduleScript] == true then
		v4 = true
	else
		v4 = moduleScript:IsA("ModuleScript")

		if v4 then
			if moduleScript.Name:match("Controller") == nil then
				v4 = false
			else
				v4 = moduleScript:IsDescendantOf(controllers)
			end
		end
	end

	if not v4 then
		return require2(moduleScript)
	end

	getRunner(moduleScript)
	return require2(moduleScript)
end

function ControllerIsolator.CreateRequire(p, callback)
	return function(moduleScript)
		local moduleScript2 = nil

		if typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript") then
			moduleScript2 = moduleScript
		elseif type(moduleScript) == "string" then
			moduleScript2 = resolvePath(moduleScript, p)
		end

		if not moduleScript2 then
			return callback(moduleScript2 or moduleScript)
		end

		local v4

		if v3[moduleScript2] == true then
			v4 = true
		else
			v4 = moduleScript2:IsA("ModuleScript")

			if v4 then
				if moduleScript2.Name:match("Controller") == nil then
					v4 = false
				else
					v4 = moduleScript2:IsDescendantOf(controllers)
				end
			end
		end

		if v4 then
			return ControllerIsolator.Require(moduleScript2)
		end

		return callback(moduleScript2 or moduleScript)
	end
end

function ControllerIsolator.LoadDescendants(folder2, callback)
	local result = {}

	for _, moduleScript in folder2:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local isA = moduleScript:IsA("ModuleScript")

		if isA then
			if moduleScript.Name:match("Controller") == nil then
				isA = false
			else
				isA = moduleScript:IsDescendantOf(controllers)
			end
		end

		if not (isA and (not callback or callback(moduleScript))) then
			continue
		end

		getRunner(moduleScript)
		result[moduleScript] = true
	end

	return result
end

local function invoke(instance, p: string, flag: boolean)
	local invoke2 = getRunner(instance):FindFirstChild("Invoke")
	assert(invoke2 and invoke2:IsA("BindableFunction"), (`Missing Invoke binding for {instance:GetFullName()}`))
	local success, result, v4, v5 = pcall(invoke2.Invoke, invoke2, p, flag)

	if success then
		return result, v4, v5
	end

	return true, false, result
end

function ControllerIsolator.InitAll(items)
	for k in items do
		local v4, v5, v6 = invoke(k, "Init", false)

		if not v4 or v5 then
			continue
		end

		task.spawn(error, (`{k.Name}:Init() - {v6}`))
	end
end

function ControllerIsolator.StartAll(items)
	for k in items do
		local v4, v5, v6 = invoke(k, "Start", true)

		if not v4 or v5 then
			continue
		end

		task.spawn(error, (`{k.Name}:Start() - {v6}`))
	end
end

return ControllerIsolator