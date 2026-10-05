local parent = script.Parent
local frame1 = parent:WaitForChild("Frame1")
local frame2 = parent:WaitForChild("Frame2")
local frame3 = parent:WaitForChild("Frame3")
local RunService = game:GetService("RunService")
local v = { frame1, frame2, frame3 }
local v2 = {}

for _, v3 in ipairs(v) do
	v2[v3] = v3.Position
end

for i, v3 in ipairs(v) do
	v3.Visible = i == 1
end

local total = 0
local v3 = 1
local v4 = 0
RunService.RenderStepped:Connect(function(dt)
	if not frame1.Parent then
		return
	end

	total += dt
	v4 += dt

	while v4 >= 0.07142857142857142 do
		v4 -= 0.07142857142857142
		v3 += 1

		if v3 > #v then
			v3 = 1
		end
	end

	for i, v5 in ipairs(v) do
		v5.Visible = i == v3
	end
end)