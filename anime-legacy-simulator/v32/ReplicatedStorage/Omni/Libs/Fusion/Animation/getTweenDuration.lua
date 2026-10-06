game:GetService("TweenService")

local function getTweenDuration(data)
	if data.RepeatCount <= -1 then
		return 1e999
	end

	local v = data.DelayTime + data.Time

	if data.Reverses then
		v += data.Time
	end

	return v * (data.RepeatCount + 1)
end

return getTweenDuration