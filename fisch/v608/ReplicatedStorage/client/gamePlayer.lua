local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local luauSignal = require(ReplicatedStorage.packages.luauSignal)
require(ReplicatedStorage.packages.Replion)
require(ReplicatedStorage.shared.utils.result)
local GamePlayer = {
	replionLoaded = luauSignal(),
	playerAdded = luauSignal(),
	playerRemoving = luauSignal()
}

function GamePlayer.init()
	for _, v in Players:GetPlayers() do
		GamePlayer._playerAddedConnection(v)
	end

	Players.PlayerAdded:Connect(GamePlayer._playerAddedConnection)
	Players.PlayerRemoving:Connect(GamePlayer._playerRemovingConnection)
end

function GamePlayer._playerAddedConnection(p)
	GamePlayer.playerAdded:fire(p)
end

function GamePlayer._playerRemovingConnection(p)
	GamePlayer.playerRemoving:fire(p)
end

return GamePlayer