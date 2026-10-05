local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local _ = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(localPlayer.PlayerScripts.PlayerModule)
require(replicatedStorage.Modules.MVP)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "NightParadeController"
})

function controller.Start(_)
	local v3 = {
		PickVows = function() end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitStart(_) end

function controller.KnitInit(_)
	v = Knit.GetService("NightParadeService")
	v2 = Knit.GetController("FXController")
end

return controller