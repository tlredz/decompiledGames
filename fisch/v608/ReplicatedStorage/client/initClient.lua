local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
RunService:IsStudio()
require(ReplicatedStorage.client.localCharacter)
require(ReplicatedStorage.client.moduleLoader)
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
require(ReplicatedStorage.client.ui)
require(ReplicatedStorage.client.gamePlayer)
local logger = require(ReplicatedStorage.shared.utils.logger)
local environment = require(ReplicatedStorage.shared.environment)
require(ReplicatedStorage.packages.emit)
require(ReplicatedStorage.packages.Loader)
require(ReplicatedStorage.shared.modules.CustomTweens)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local components = ReplicatedStorage.client.components
local TextChatService = game:GetService("TextChatService")

-- equivalent calls inferred from this helper; original call sites unknown
local function initDumb(p, doStart, doInit)
	local clone = script.inittemp:Clone()
	clone.target.Value = p
	clone:SetAttribute("doInit", doInit)
	clone:SetAttribute("doStart", doStart)
	clone.Name = p.Name
	clone.Parent = script
	clone.Enabled = true
end

local function addComponent(p)
	return initDumb(p, false, false)
end

local function Validate(object)
	local success, result = pcall(function()
		return object:GetRankInGroupAsync(7381705) >= 60
	end)

	if success then
		return result
	end

	return false
end

task.spawn(function()
	local localPlayer = Players.LocalPlayer
	local success, result = pcall(function()
		return localPlayer:GetRankInGroupAsync(7381705) >= 60
	end)

	if not success then
		result = false
	end

	if not result then
		for _, textChatCommand in ipairs(TextChatService:GetDescendants()) do
			if textChatCommand:IsA("TextChatCommand") and textChatCommand:GetAttribute("TesterCommand") then
				textChatCommand:Destroy()
			end
		end
	end
end)
TextChatService.DescendantAdded:Connect(function(textChatCommand)
	if textChatCommand:IsA("TextChatCommand") and textChatCommand:GetAttribute("TesterCommand") then
		local localPlayer = Players.LocalPlayer
		local success, result = pcall(function()
			return localPlayer:GetRankInGroupAsync(7381705) >= 60
		end)

		if not success then
			result = false
		end

		if not result then
			textChatCommand:Destroy()
		end
	end
end)

local function startController(instance)
	if instance:GetAttribute("Disabled") or instance:HasTag("disable") then
		return
	else
		return initDumb(instance, true, false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldLoadController(moduleScript)
	return moduleScript:IsA("ModuleScript") and not moduleScript:GetAttribute("LoaderIgnore")
end

local function legacyStartupStep()
	for _, moduleScript in ipairs(legacyControllers:GetDescendants()) do
		if moduleScript:FindFirstAncestorWhichIsA("ModuleScript") or not shouldLoadController(moduleScript) then
			continue
		end

		task.spawn(startController, moduleScript)
	end

	legacyControllers.DescendantAdded:Connect(function(moduleScript)
		if moduleScript.Parent and not moduleScript:FindFirstAncestorWhichIsA("ModuleScript") and shouldLoadController(moduleScript) then
			task.spawn(startController, moduleScript)
		end
	end)

	for _, moduleScript in components:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			task.spawn(addComponent, moduleScript)
		end
	end

	components.DescendantAdded:Connect(addComponent)
	task.defer(function()
		workspace:SetAttribute("ServerReady", true)
	end)
	Players.LocalPlayer:SetAttribute("ControllersLoaded", true)
end

local moduleLoaderDumb

moduleLoaderDumb = function(instance)
	for _, folder in instance:GetChildren() do
		if folder:HasTag("disable") then
			continue
		end

		if folder:IsA("Folder") then
			moduleLoaderDumb(folder)
		else
			initDumb(folder, false, true) -- equivalent call inferred; original call site unknown
		end
	end
end

local function startClient()
	local now = os.clock()
	require(ReplicatedStorage.shared.modules.DeferredSignalHackaround)
	legacyUiLoader.init()
	legacyStartupStep()
	initDumb(ReplicatedStorage.packages.emit, false, true) -- equivalent call inferred; original call site unknown
	initDumb(ReplicatedStorage.shared.modules.CustomTweens, false, true) -- equivalent call inferred; original call site unknown
	moduleLoaderDumb(ReplicatedStorage.client.modules)

	for _, descendant in ReplicatedStorage.shared.Observers:GetDescendants() do
		initDumb(descendant, false, false) -- equivalent call inferred; original call site unknown
	end

	initDumb(ReplicatedStorage.client.gamePlayer, false, true) -- equivalent call inferred; original call site unknown
	initDumb(ReplicatedStorage.client.ui, false, true) -- equivalent call inferred; original call site unknown
	environment.loadContent(script.Parent.content)
	local now2 = os.clock()
	logger.printLive((`client loaded in {string.format("%.2f", (now2 - now) * 1000)}ms`))
end

startClient()