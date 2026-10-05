local createVector = vector.create
local _ = game.Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local Sound = require(game.ReplicatedStorage.Modules.Sound)
local FX = require(game.ReplicatedStorage.Modules.FX)
Network:listen("GrabSlam", function(p)
	wait(0.25)
	Sound:Sound(script.Slam, p)
	FX:FX(script.SlamParticle, p - createVector(0, 0.5, 0))
end)