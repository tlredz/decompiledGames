local parent = script.Parent
local easterEgg = parent.EasterEgg

while true do
	if parent.Visible then
		local lastTime = tick()

		while tick() - lastTime < 0.6 do
			local v = (tick() - lastTime) / 0.6
			local v2 = math.sin(v * 3.141592653589793 * 2 * 2)
			local v3 = 1 - v
			local v4 = 0.5 + v2 * 0.1 * v3
			easterEgg.Size = UDim2.fromScale(v4, v4)
			task.wait()
		end

		easterEgg.Size = UDim2.fromScale(0.5, 0.5)
		task.wait(1.2)
	else
		task.wait()
		parent:GetPropertyChangedSignal("Visible"):Wait()
	end
end