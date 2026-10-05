local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local FFlags = require(ReplicatedStorage.Packages.FFlags)

while not FFlags:Get("PlayWave/Enabled", false) do
	task.wait(1)
end

Synchronizer:Wait(Players.LocalPlayer)
task.wait(1)
local playWaveEvents = ReplicatedStorage:WaitForChild("PlayWaveEvents", 1e999)
local playWaveClientReady = playWaveEvents and playWaveEvents:WaitForChild("PlayWaveClientReady", 1e999)

if playWaveClientReady then
	playWaveClientReady:FireServer("813f7f84-8e4c-4772-b57b-6a7c6cc7c704")
else
	warn("[PlayWave] PlayWaveClientReady event not found.")
end

local playWaveBenefit = playWaveEvents and playWaveEvents:WaitForChild("PlayWaveBenefit", 30)

if playWaveBenefit then
	playWaveBenefit.OnClientEvent:Connect(function(p) end)
end