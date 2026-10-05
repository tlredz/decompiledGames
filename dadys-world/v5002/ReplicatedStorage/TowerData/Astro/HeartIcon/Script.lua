local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(localPlayer.UserId)))
local child

repeat
	task.wait(1)
	child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(localPlayer.UserId)))
until child

if child and child:WaitForChild("HighlightToggle").Value == true then
	parent.Enabled = true
end