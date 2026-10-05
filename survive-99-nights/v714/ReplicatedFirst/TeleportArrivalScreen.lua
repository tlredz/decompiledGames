local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local arrivingTeleportGui = TeleportService:GetArrivingTeleportGui()

if arrivingTeleportGui then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	arrivingTeleportGui.Enabled = true
	arrivingTeleportGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	arrivingTeleportGui:Destroy()
end