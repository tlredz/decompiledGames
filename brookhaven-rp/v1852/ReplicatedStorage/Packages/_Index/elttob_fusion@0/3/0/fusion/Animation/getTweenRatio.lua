local TweenService = game:GetService("TweenService")

local function getTweenRatio(data, p: number)
	local delayTime = data.DelayTime
	local time = data.Time
	local reverses = data.Reverses
	local v = 1 + data.RepeatCount
	local easingStyle = data.EasingStyle
	local easingDirection = data.EasingDirection
	local v2 = delayTime + time

	if reverses then
		v2 += time
	end

	if p == 1e999 or v2 * v <= p and data.RepeatCount > -1 then
		return 1
	end

	local v3 = p % v2

	if v3 <= delayTime then
		return 0
	end

	local v4 = (v3 - delayTime) / time

	if v4 > 1 then
		v4 = 2 - v4
	end

	return (TweenService:GetValue(v4, easingStyle, easingDirection))
end

return getTweenRatio