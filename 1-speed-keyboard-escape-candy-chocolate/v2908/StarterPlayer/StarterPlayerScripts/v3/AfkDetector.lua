local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerAfkStatus = ReplicatedStorage:WaitForChild("PlayerAfkStatus", 10)

if playerAfkStatus then
	localPlayer.Idled:Connect(function()
		playerAfkStatus:FireServer(os.time())
	end)
else
	warn("[AfkDetector] PlayerAfkStatus remote introuvable")
end