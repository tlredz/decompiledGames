local _ = game.ReplicatedStorage
local _ = game.ReplicatedStorage
game:GetService("TweenService")
return function(p, _)
	local state = p.state

	if not state then
		return
	end

	local child = script:FindFirstChild(state)

	if not child then
		return
	end

	local module = require(child)
	module(p)
end