local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = require(ReplicatedStorage.Modules:WaitForChild("StateReplicator"):WaitForChild("Client"))
local localPlayer = game.Players.LocalPlayer
return {
	Data = Client.WaitForTable((`Stats_{localPlayer.Name}`)),
	Changed = Client.GetIndexChangedSignal({ (`Stats_{localPlayer.Name}`) })
}