local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local v = 1 / Stats.FrameTime
local flag = false

local function initialize()
	if flag then
		return
	end

	flag = true
	local total = 0
	local v2 = 1 / Stats.FrameTime
	v = v2
	local v3 = v2
	local v4 = 1
	RunService.Stepped:Connect(function(_, dt)
		v2 = 1 / Stats.FrameTime
		v3 += v2
		v4 += 1
		total += dt

		if total > 1 then
			total = 0
			v = v3 / v4
			v3 = 0
			v4 = 0
		end
	end)
end

local ClientPerformanceTrackingController = {
	GetOneSecondAverageFPS = function()
		return v
	end
}

if flag then
	return ClientPerformanceTrackingController
end

flag = true
local total = 0
local v2 = 1 / Stats.FrameTime
v = v2
local v3 = v2
local v4 = 1
RunService.Stepped:Connect(function(_, dt)
	v2 = 1 / Stats.FrameTime
	v3 += v2
	v4 += 1
	total += dt

	if total > 1 then
		total = 0
		v = v3 / v4
		v3 = 0
		v4 = 0
	end
end)
return ClientPerformanceTrackingController