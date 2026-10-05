game:GetService("TweenService")
require(game.ReplicatedStorage.Util)

local function InRange(p, p2)
	if (p - workspace.CurrentCamera.CFrame.Position).Magnitude < p2 then
		return true
	end
end

return function(p)
	if typeof(p.HRP) == "Instance" then
	end
end