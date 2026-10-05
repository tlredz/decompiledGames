local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local EffectReload = require(script:WaitForChild("EffectReload"))
local Metadata = require(script.Metadata)
local Payload = require(script.Payload)
require(script.Types)
local isRunning = RunService:IsRunning()
local v = RunService:IsClient() and isRunning
local FX = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FX")
local simulatedFX = script:WaitForChild("SimulatedFX")
local bindable = script:WaitForChild("Bindable")
local Effect = {}
Effect.__index = Effect
require(ReplicatedStorage:WaitForChild("Util").MasterClock)
task.spawn(function()
	require(ReplicatedStorage.Util.tasklib)
end)

local function findFirstAncestorSatisfying(toolCallerFromStack, fn)
	assert(fn, "A predicate function is required")
	local parent = toolCallerFromStack.Parent

	while parent do
		if parent == workspace or parent.Parent == game then
			return nil
		end

		if fn(parent) then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function findToolCallerFromStack(value: number?)
	local v2 = assert(value or 3)
	local v3 = {}

	while true do
		local v4 = debug.info(v2, "f")

		if v4 == nil or v2 > 200 then
			break
		end

		if type(v4) == "function" then
			local v5 = getfenv(v4)
			local script2 = v5 and v5.script

			if typeof(script2) == "Instance" and script2:IsA("LuaSourceContainer") and not v3[script2] then
				local parent = script2.Parent

				if parent and parent:IsA("Tool") then
					return script2, parent
				else
					v3[script2] = true
				end
			end
		end

		v2 += 1
	end

	return nil, nil
end

local function fn()
	if RunService:IsClient() then
		return nil
	end

	local toolCallerFromStack = findToolCallerFromStack(4)

	if not toolCallerFromStack then
		return nil
	end

	local firstAncestorSatisfying = findFirstAncestorSatisfying(toolCallerFromStack, function(p)
		return p.Parent ~= nil and p.Parent == workspace:WaitForChild("Characters")
	end)
	local playerFromCharacter = firstAncestorSatisfying and Players:GetPlayerFromCharacter(firstAncestorSatisfying)
	return playerFromCharacter or nil
end

local function noopMethod() end

local object = setmetatable({}, {
	__index = function()
		return noopMethod
	end
})

local function fromServerRunClientModule(value: string?)
	local v2 = isRunning and not v

	if v2 then
		if type(value) == "string" then
			return string.sub(value, -7) == ".Client" or string.find(value, ".Client.", 1, true) ~= nil or string.sub(
				value,
				-14
			) == ".ClientRuntime" or string.find(value, ".ClientRuntime.", 1, true) ~= nil
		else
			return false
		end
	end

	return v2
end

Effect.findModule = Metadata.findModule
Effect.getModule = Metadata.getModule

function Effect.new(value, async: boolean?)
	if fromServerRunClientModule(debug.info(2, "s")) then
		return object
	end

	local implementation = nil
	local name = nil
	local module

	if typeof(value) == "Instance" then
		name = Metadata.getName(value)
		module = value
	elseif type(value) == "string" then
		module = Effect.getModule(value)
		name = value
	else
		module = Metadata.fromImplementation(value)

		if module then
			name = Metadata.getName(module)
		end

		implementation = value
	end

	assert(module or implementation ~= nil, "Effect not found!: " .. tostring(value))
	return (setmetatable({
		Name = name,
		Module = module,
		Implementation = implementation,
		Id = math.random(99999999),
		Async = async,
		Sender = fn()
	}, {
		__index = Effect
	}))
end

function Effect.preload(p)
	EffectReload.getEffectImpl(Effect.getModule(p))
end

local function forPlayersExcept(p, callback, p2, p3)
	for _, v2 in Players:GetPlayers() do
		if v2 ~= p3 then
			callback(p, p2, v2)
		end
	end
end

function Effect.replicateExcept(p, p2, p3)
	forPlayersExcept(p, p.replicate, p2, p3)
end

function Effect.playExcept(p, p2, p3)
	forPlayersExcept(p, p.play, p2, p3)
end

local function getEffectTime()
	if isRunning then
		return (workspace:GetServerTimeNow())
	end

	return (os.clock())
end

local Mouse, mouse

if v and Players.LocalPlayer then
	Mouse = require(ReplicatedStorage:WaitForChild("Mouse"))
	mouse = Players.LocalPlayer:GetMouse()
else
	Mouse = nil
	mouse = nil
end

local function playLocal(data, mouses)
	if data.Async then
		local implementation

		if data.Implementation == nil then
			implementation = EffectReload.getEffectImpl(data.Module)
		else
			implementation = data.Implementation
		end

		if type(implementation) == "function" then
			implementation(mouses, data)
		else
			implementation.new(mouses):Run()
		end
	else
		for k, item in pairs(mouses) do
			if item == Mouse then
				mouses[k] = mouse
			elseif type(item) == "table" and rawget(item, "SourcePlayer") then
				Payload.hydrateSourcePlayerProxy(item)
			end
		end

		bindable:Fire("spawn", data.Module or data.Implementation, mouses, data)
	end
end

local function fireEffectRemote(player, effectTime: number, p, encoded)
	if not isRunning then
		simulatedFX:Fire(effectTime, p, encoded)
	elseif player then
		FX:FireClient(player, effectTime, p, encoded)
	else
		FX:FireAllClients(effectTime, p, encoded)
	end
end

local function reportFxNameUsed(name: string?)
	if isRunning and name then
		local RobloxAnalytics = require(game.ServerScriptService.Services.RobloxAnalytics)
		RobloxAnalytics.Tools:ReportFxNameUsed(name)
	end
end

local function replicate(spawn2, p, p2, value)
	if v and value == nil then
		playLocal(p, p2)
		return
	end

	local effectTime = getEffectTime()
	local resolved = Metadata.resolve(p)
	local resolvedServer = resolved and resolved:FindFirstChild("Server")

	if resolvedServer then
		task.spawn(function()
			local module = require(resolvedServer)
			module(p2, p)
		end)
	end

	local encoded = Payload.encode(p2)
	local v2 = Metadata.forRemote(p)

	if value == nil or typeof(value) == "Instance" and value.ClassName == "Player" then
		if value == nil then
			value = nil
		end

		spawn2(function()
			fireEffectRemote(value, effectTime, v2, encoded)
		end)
		reportFxNameUsed(v2.Name)
	elseif typeof(value) == "table" then
		spawn2(function()
			for _, item in value do
				fireEffectRemote(item, effectTime, v2, encoded)
			end

			reportFxNameUsed(v2.Name)
		end)
	end
end

function Effect.replicate(p, p2, p3)
	replicate(spawn, p, p2, p3)
end

function Effect.play(p, p2, p3)
	replicate(task.spawn, p, p2, p3)
end

for _, moduleScript in ReplicatedStorage.EffectContainer:GetDescendants() do
	if moduleScript:IsA("ModuleScript") and moduleScript:GetAttribute("Preload") then
		task.spawn(require, moduleScript)
	end
end

require(ReplicatedStorage.Global)

if v and Players.LocalPlayer or not isRunning then
	require(ReplicatedStorage.Util.FakeHumanoidRootPart)
	local Receiver = require(script.Receiver)
	local v2

	if isRunning then
		v2 = FX.OnClientEvent
	else
		v2 = simulatedFX.Event
	end

	Receiver.new(v2, getEffectTime):start()
end

return Effect