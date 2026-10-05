local TweenService = game:GetService("TweenService")
local v = {
	Make = function(p, p2, p3)
		return (TweenService:Create(p, p2 or TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), p3))
	end
}

function v.Do(p, p2, duration, p3, p4, p5)
	local tweenInfo = TweenInfo.new(duration, p3, p4)
	local v2 = v.Make(p, tweenInfo, p2)
	v2:Play()

	if p5 then
		return v2, v2.Completed:Wait()
	end

	return v2
end

return v.Do