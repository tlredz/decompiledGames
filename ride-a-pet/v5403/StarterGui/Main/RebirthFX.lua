local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIRewardFX = require(ReplicatedStorage:WaitForChild("UIRewardFX"))
local rebirth = script.Parent:WaitForChild("Rebirth")
local remotes = ReplicatedStorage:WaitForChild("Remotes", 1e999)
local game2 = remotes and remotes:WaitForChild("Game", 1e999)
local rebirth2 = game2 and game2:WaitForChild("Rebirth", 1e999)

if rebirth2 then
	rebirth2.OnClientEvent:Connect(function()
		UIRewardFX.rebirth(rebirth.Visible and rebirth or nil)
	end)
end