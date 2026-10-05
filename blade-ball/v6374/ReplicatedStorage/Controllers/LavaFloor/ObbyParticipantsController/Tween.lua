local TweenService = game:GetService("TweenService")

local function TweenAsync(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	return tween
end

return TweenAsync