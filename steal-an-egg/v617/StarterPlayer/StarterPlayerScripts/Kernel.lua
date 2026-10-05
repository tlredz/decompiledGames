local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lastTime = os.clock()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local OnboardingTiming = require(ReplicatedStorage.Shared.Util.OnboardingTiming)
OnboardingTiming.Mark("GameLoaded", nil, os.clock() - lastTime)
task.spawn(function()
	require(script.Parent:WaitForChild("PlayerModule"))
end)
require(ReplicatedStorage.Shared.Flags.GameFlags)
local Log = require(ReplicatedStorage.Packages.Log)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local v = { controllers:WaitForChild("GUI"), controllers:WaitForChild("Game") }
local v2 = {
	ReplicatedStorage.Client.PlatformController,
	ReplicatedStorage.Client.HiddenUIHandler,
	ReplicatedStorage.Client.ForbiddenIslandController,
	ReplicatedStorage.Client.DecorationScale,
	ReplicatedStorage.Client.UIEffects,
	ReplicatedStorage.Client.MusicDirector,
	ReplicatedStorage.Client.Notifications,
	ReplicatedStorage.Client.PlotState,
	ReplicatedStorage.Client.FuseMachineMotion,
	ReplicatedStorage.Client.ShrineFusionController,
	ReplicatedStorage.Client.SystemChat,
	ReplicatedStorage.Client.ChatDecorations,
	ReplicatedStorage.Shared.Save
}
local v3 = Log.new()
local localPlayer = Players.LocalPlayer
local collectControllers

collectControllers = function(instance, children)
	for _, child in instance:GetChildren() do
		if child:IsA("Folder") then
			collectControllers(child, children)
		elseif child:IsA("ModuleScript") and not child:GetAttribute("SkipAutoload") then
			table.insert(children, child)
		end
	end

	return children
end

local function byFullName(instance, instance2)
	return instance:GetFullName() < instance2:GetFullName()
end

local function runStage(instance, p: string, callback)
	local lastTime2 = os.clock()
	local success, result = pcall(callback)

	if success and (instance.Name == "GuardAreasController" or instance.Name == "AreaEggsController") then
		OnboardingTiming.Mark(instance.Name .. "." .. p, nil, os.clock() - lastTime2)
	end

	if not success then
		v3:AtError():Log((`[Kernel] {instance:GetFullName()} failed in {p}: {result}`))
	end

	return success
end

local function bootController(instance)
	local lastTime2 = os.clock()
	local success, result = pcall(require, instance)

	if not success then
		v3:AtError():Log((`[Kernel] {instance:GetFullName()} failed while loading: {result}`))
		return
	end

	local v4 = os.clock() - lastTime2

	if RunService:IsStudio() and v4 > 0.04 then
		v3:AtWarning():Log((`[Kernel] {instance.Name} took {string.format("%.0f", v4 * 1000)} ms to load`))
	end

	if type(result) ~= "table" then
		v3:AtWarning():Log((`[Kernel] {instance:GetFullName()} did not return a controller table; tag it SkipAutoload if it is a library`))
		return
	end

	local init = result.Init
	local start = result.Start

	if type(init) ~= "function" and type(start) ~= "function" then
		v3:AtWarning():Log((`[Kernel] {instance:GetFullName()} exposes neither Init nor Start; tag it SkipAutoload if it is a library`))
		return
	end

	if type(init) == "function" and not runStage(instance, "Init", init) then
		return
	end

	if type(start) == "function" then
		runStage(instance, "Start", start)
	end
end

for _, v4 in v2 do
	local v5 = v4
	task.spawn(function()
		local success, result = pcall(require, v5)

		if not success then
			v3:AtError():Log((`[Kernel] client startup module {v5:GetFullName()} failed: {result}`))
		end
	end)
end

localPlayer:WaitForChild("PlayerGui")
local v4 = {}

for _, v5 in v do
	collectControllers(v5, v4)
end

table.sort(v4, byFullName)

for _, v5 in v4 do
	task.spawn(bootController, v5)
end

v3:AtInfo():Log((`[Kernel] launched {#v4} controllers`))