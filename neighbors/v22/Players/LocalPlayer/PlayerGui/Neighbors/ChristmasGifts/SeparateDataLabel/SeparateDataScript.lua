local Server = require(game.ReplicatedStorage.Modules.Server)

if Server:IsAdultServer() then
	script.Parent.Visible = true
end