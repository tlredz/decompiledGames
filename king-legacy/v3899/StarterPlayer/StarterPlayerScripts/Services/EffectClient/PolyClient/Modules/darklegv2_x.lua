local _ = game.ReplicatedStorage
local _ = game.ReplicatedStorage
game:GetService("TweenService")
return function(p, p2)
	local _ = game.Players.LocalPlayer
	local v = p.diable and "Diable" or "Default"
	local v2 = p.azure and "Azure" or v

	if not script:FindFirstChild(v2) then
		return
	end

	local module = require(script[v2])
	module(p, p2)
end