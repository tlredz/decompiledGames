local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RikaGrabController"
})

function controller.KnitStart(_)
	local v3 = {
		GrabSound = function(p, instance)
			v2:PlaySound(sounds.Yuta.Rika.GrabStart, p, game.SoundService.Effect)
			local v4 = v2:PlaySound(sounds.Yuta.Rika.GrabHold, p, game.SoundService.Effect)
			instance.AncestryChanged:Once(function()
				v4:Destroy()
			end)
		end
	}
	RikaGrabService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	RikaGrabService = Knit.GetService("RikaGrabService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller