local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Network = require(game.ReplicatedStorage.Modules.Network)
local Server = require(game.ReplicatedStorage.Modules.Server)

if not Server:IsCustomServer() then
	return
end

Network:listen("CustomServerAnnouncement", function(text: string, p, flag: boolean?)
	local clone = script.Message:Clone()
	clone.Parent = Players.LocalPlayer.PlayerGui
	clone.Title.Text = `{flag and "Private Message" or "Message"} from {p.Name}`
	clone.Message.Text = text
	Debris:AddItem(clone, 5)
end)