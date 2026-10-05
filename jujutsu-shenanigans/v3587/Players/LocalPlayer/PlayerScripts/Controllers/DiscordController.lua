local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local _ = game.ReplicatedStorage
require(script.DiscordClient)
local controller = Knit.CreateController({
	Name = "DiscordController"
})

function controller.KnitStart(_) end

function controller.KnitInit(_) end

return controller