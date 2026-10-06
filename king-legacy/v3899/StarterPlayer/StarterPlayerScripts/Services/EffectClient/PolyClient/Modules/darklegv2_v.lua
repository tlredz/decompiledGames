local _ = game.ReplicatedStorage
local _ = game.ReplicatedStorage
game:GetService("TweenService")
return function(data, p)
	local _ = game.Players.LocalPlayer
	local char = data.char
	local _ = data.cf

	if not char then
		return
	end

	local v = data.diable and "Diable" or "Default"
	local v2 = data.azure and "Azure" or v

	if not script:FindFirstChild(v2) then
		return
	end

	local module = require(script[v2])
	module(data, p)
end