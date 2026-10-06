return function()
	local _ = script.Parent.CFrame

	for i = 1, 3 do
		local v = script.Parent["Beam" .. i]
		v.Enabled = true
		task.spawn(function()
			wait(0.5)
			task.wait(math.random(1, 10) * task.wait())
			v.Enabled = false
		end)
	end

	for i = 1, 4 do
		local v = script.Parent["AT" .. i]
		v.CFrame = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(math.random(-70, 70) / 5, math.random(-70, 70) / 5, math.random(-70, 70) / 5)
		v.star.Enabled = true
		v.star:Emit(1)
		task.spawn(function()
			task.wait(math.random(1, 2) * task.wait())
			game.TweenService:Create(v, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = v.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -3)
			}):Play()
			wait(0.4)
			task.wait(math.random(1, 10) * task.wait())
			v.star.Enabled = false
		end)
	end
end