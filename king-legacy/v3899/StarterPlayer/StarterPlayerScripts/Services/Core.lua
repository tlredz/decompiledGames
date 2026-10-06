local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("SoundService")
game:GetService("TweenService")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local Streaming = require(ReplicatedStorage.Chest.Assets.Modules.Streaming)
local EntityClient = require(ReplicatedStorage.Chest.Assets.Modules.EntityClient)
local EntityAtlas = require(ReplicatedStorage.Chest.Assets.Modules.EntityAtlas)
require(ReplicatedStorage.Chest.Assets.Modules.ProfileManager)
local Optimization = require(ReplicatedStorage.Chest.Assets.Modules.Optimization)
require(ReplicatedStorage.Chest.Assets.Modules.EntityAnimation)
local Allies = require(ReplicatedStorage.Chest.Assets.Modules.Features.Allies)
require(ReplicatedStorage.Chest.Assets.Modules.Features.StickController)
Streaming:Setup()
EntityClient:Setup()
task.spawn(function()
	Optimization:Setup()
end)
EntityAtlas:Setup()
RunService.Heartbeat:Connect(function(dt)
	Streaming:Step(dt)
	EntityClient:Step(dt)
	Allies:Step(dt)
end)
ReplicatedStorage.Chest.Remotes.Events.EtcEvent.OnClientEvent:Connect(function(p, p2)
	if p == "StopAnimation" then
		local lists = p2.Lists
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
			if lists[v.Name] then
				v:Stop()
			end
		end
	end
end)