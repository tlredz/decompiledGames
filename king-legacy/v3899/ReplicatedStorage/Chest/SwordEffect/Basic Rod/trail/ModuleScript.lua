return function()
	local parent = script.Parent
	local humanoidRootPart = script.Parent.Parent.HumanoidRootPart
	tick()
	parent.Star.Enabled = true

	for i = 1, 25 do
		local v = i / 25
		local v2 = 9.42477796076938 * v
		local v3 = 6 - v * 4
		local vector = Vector3.new(math.cos(v2) * v3, v * 6, math.sin(v2) * v3)
		parent.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.new(vector)
		task.wait()
	end

	parent.Star.Enabled = false
end