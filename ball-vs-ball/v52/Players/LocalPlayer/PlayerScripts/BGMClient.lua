local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BGMPlayer = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("BGMPlayer"))
local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
local client = PlayerData.client
local BGM = ReplicatedStorage:WaitForChild("音效素材"):WaitForChild("大厅BGM")
assert(BGM:IsA("Folder"), "ReplicatedStorage.音效素材.大厅BGM 必须是 Folder")
BGMPlayer.Start(BGM)

if client.settings.musicEnabled() == false then
	BGMPlayer.Pause()
end

client.settings.musicEnabled.Changed(function(flag: boolean)
	if flag then
		BGMPlayer.Resume()
	else
		BGMPlayer.Pause()
	end
end)