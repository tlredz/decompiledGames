local SplashLavaClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")

function GrowLavaAdded(p)
	local Z = p.Size.Z
	Client.TweenModule.new(function(p2)
		local v = (0.5 + 0.5 * p2) * Z
		p.Size = Vector3.new(0.2, v, v)
	end, 1, "Quad"):Play()
end

function SplashLavaClient.Init()
	Client.Utility.ForAllTagged("GrowLava", GrowLavaAdded)
end

return SplashLavaClient