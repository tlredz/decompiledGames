local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))
local dataLoaded = localPlayer:WaitForChild("NoSaveData"):WaitForChild("DataLoaded")

while not dataLoaded.Value do
	dataLoaded.Changed:Wait()
end

while localPlayer:GetAttribute("GameLoaded") ~= true do
	localPlayer:GetAttributeChangedSignal("GameLoaded"):Wait()
end

local hasFinishedTutorial = localPlayer:WaitForChild("SavedData"):WaitForChild("HasFinishedTutorial")

while not hasFinishedTutorial.Value and localPlayer:GetAttribute("TutorialActive") ~= true and not GameSettings.Enabled("SKIPTUTORIALONSTUDIO") do
	task.wait(0.1)
end

task.wait(4.5)
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
character:WaitForChild("HumanoidRootPart")
local Volcano = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Cutscenes"):WaitForChild("Volcano"))
local v, v2 = Volcano.Play({
	StudioPreview = true
})

if not v then
	warn("[VolcanoCutsceneTest] " .. tostring(v2 or "Cancelled"))
end