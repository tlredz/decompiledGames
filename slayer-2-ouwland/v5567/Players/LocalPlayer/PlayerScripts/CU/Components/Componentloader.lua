local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local layout = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Misc"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.None
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local screenGui2 = Instance.new("ScreenGui")
screenGui2.Name = "ComponentsHolder"
screenGui2.Parent = playerGui
screenGui2.ResetOnSpawn = false
screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local DialogueComponent = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent)
local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
local modules = {}
local maid = nil
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function add(module)
	if maid == nil then
		return
	end

	maid:Add(module(screenGui2))
end

local function update(_)
	if v ~= nil then
		local current = Dialogue.CurrentDialogue.Current
		local v2 = current ~= nil and Dialogue.Diagloues[current] or nil

		if v2 == nil or v2.SurviveRespawn ~= true then
			game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Dialogue.Value = false
			v()
			v = nil
		end
	end

	if maid ~= nil then
		maid:Destroy()
		maid = nil
	end

	maid = cleanit.new()

	for _, v2 in modules do
		maid:Add(v2(screenGui2))
	end
end

for _, moduleScript in layout.ResetOnSpawn:GetChildren(), nil, nil do
	if moduleScript:IsA("ModuleScript") then
		table.insert(modules, require(moduleScript))
	end
end

layout.ResetOnSpawn.ChildAdded:Connect(function(moduleScript)
	if not moduleScript:IsA("ModuleScript") then
		return
	end

	local module = require(moduleScript)
	add(module) -- equivalent call inferred; original call site unknown
	table.insert(modules, module)
end)

if localPlayer.Character ~= nil then
	update()
end

localPlayer.CharacterAdded:Connect(update)
game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Dialogue.Value = false
local ProximityPromptService = game:GetService("ProximityPromptService")

local function openDialogue(current: string?, p)
	if current == nil then
		return
	end

	if v == nil then
		Dialogue.CurrentDialogue.Current = current
		v = DialogueComponent(screenGui2, current, p)

		if v ~= nil then
			game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Dialogue.Value = true
		end
	else
		Dialogue.AttemptDialogue:Fire(current)
	end
end

ProximityPromptService.PromptTriggered:Connect(function(player, _)
	if not game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Prompts.Value then
		return
	end

	if player:HasTag("Dialogue") then
		openDialogue(player:GetAttribute("DialogueName") or player.ObjectText, player)
	end
end)
Dialogue.OpenDialogue:Connect(openDialogue)
local v2 = nil

local function checkPendingDialogue()
	local pendingDialogue = localPlayer:GetAttribute("PendingDialogue")

	if pendingDialogue == nil or pendingDialogue == "" or pendingDialogue == v2 then
		return
	end

	v2 = pendingDialogue
	openDialogue(pendingDialogue)
end

localPlayer:GetAttributeChangedSignal("PendingDialogue"):Connect(checkPendingDialogue)
local pendingDialogue = localPlayer:GetAttribute("PendingDialogue")

if pendingDialogue ~= nil and pendingDialogue ~= "" and pendingDialogue ~= v2 then
	v2 = pendingDialogue
	openDialogue(pendingDialogue)
end

Dialogue.CurrentDialogue.Cancel:Connect(function()
	game.ReplicatedStorage.CAM.Client.Components.Layout.Visibility.Dialogue.Value = false

	if v ~= nil then
		v()
		v = nil
	end
end)

for _, moduleScript in layout.NoneResetting:GetChildren(), nil, nil do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	module(screenGui2)
end

layout.NoneResetting.ChildAdded:Connect(function(moduleScript)
	if not moduleScript:IsA("ModuleScript") then
		return
	end

	local module = require(moduleScript)
	module(screenGui2)
end)