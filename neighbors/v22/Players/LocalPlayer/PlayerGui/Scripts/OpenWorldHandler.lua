local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Server = require(game.ReplicatedStorage.Modules.Server)

if Server:IsOpenWorld() then
	local mainMenu = playerGui:WaitForChild("MainMenu")
	mainMenu.Enabled = false
	local partyMembers = playerGui:WaitForChild("Neighbors"):WaitForChild("PartyMembers")
	partyMembers.Visible = false
end