local localPlayer = game.Players.LocalPlayer
local machine = require(game.ReplicatedStorage.Services.Core.machine)
localPlayer:WaitForChild("PlayerGui")
game.ReplicatedStorage:WaitForChild("ReplicatedAssets")
machine.setup(game.ReplicatedStorage)
machine.runHandlers(localPlayer.PlayerScripts:WaitForChild("Handlers"))