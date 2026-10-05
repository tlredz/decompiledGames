if not script:IsDescendantOf(workspace) then
	return
end

local pinkRing = script.Parent.PinkRing
local purpleRing = script.Parent.PurpleRing
local pivot = pinkRing:GetPivot()
local pivot2 = purpleRing:GetPivot()
local total = 0
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function(dt)
	total += dt
	pinkRing:PivotTo(CFrame.new(0, math.sin(total * 0.6) * 10, 0) * pivot * CFrame.Angles(
		0,
		total * 0.05235987755982989,
		0
	))
	purpleRing:PivotTo(CFrame.new(0, math.sin(total * 0.6 + 1.5707963267948966) * 10, 0) * pivot2 * CFrame.Angles(
		0,
		-total * 0.05235987755982989,
		0
	))
end)