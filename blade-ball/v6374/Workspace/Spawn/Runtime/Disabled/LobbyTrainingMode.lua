local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)

if not UseNewLobby then
	return
end

local Replion = require(ReplicatedStorage.Packages.Replion)
local v = Replion.Client:WaitReplion("Data")
workspace:WaitForChild("Spawn", 1000000)
local lobby_Ball_Training = script.Parent.Parent.Parent:WaitForChild("Lobby_Ball_Training")

local function updateTrainingState()
	local v2 = v:Get("TotalStats.Kills") or 0

	if (v:Get("TotalStats.Wins") or 0) < 1 or v2 < 5 then
		lobby_Ball_Training.Parent = nil
	else
		lobby_Ball_Training.Parent = script.Parent.Parent.Parent
	end
end

lobby_Ball_Training:Destroy()
lobby_Ball_Training = nil