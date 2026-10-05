local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local child = ReplicatedStorage.PlayerData:FindFirstChild((tostring(localPlayer.UserId)))
local RunService = game:GetService("RunService")
local parent = script.Parent

while not child do
	task.wait(1)
	child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(localPlayer.UserId)))
end

if not (child and child:WaitForChild("HighlightToggle").Value) then
	return
end

parent.Enabled = true
local heartbeatConnection = nil
local imageLabel = parent.Frame.ImageLabel
heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	if parent and parent.Parent and parent.Enabled then
		imageLabel.Rotation = (imageLabel.Rotation + dt * 180) % 360
		return
	end

	heartbeatConnection:Disconnect()
	heartbeatConnection = nil
end)