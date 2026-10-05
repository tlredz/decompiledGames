local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = {}

local function updateVolume()
	local v2 = localPlayer:GetAttribute("LobbyTraining") and localPlayer.Character and localPlayer.Character.Parent == workspace.Dead

	for _, v3 in v do
		v3.Volume = v2 and 1 or 0
	end
end

localPlayer:GetAttributeChangedSignal("LobbyTraining"):Connect(updateVolume)
task.spawn(updateVolume)
return Observers.observeTag("LobbyTrainingSFX", function(p)
	table.insert(v, p)
	task.spawn(updateVolume)
	return function()
		local index = table.find(v, p)

		if index then
			table.remove(v, index)
		end
	end
end, { workspace })