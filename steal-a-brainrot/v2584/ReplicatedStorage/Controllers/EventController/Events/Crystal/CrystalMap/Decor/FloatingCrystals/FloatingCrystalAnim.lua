if not script:IsDescendantOf(workspace) then
	return
end

local TweenService = game:GetService("TweenService")

for _, part in script.Parent:GetChildren() do
	if not part:IsA("BasePart") then
		continue
	end

	local v = part
	local cFrame = part.CFrame
	task.spawn(function()
		task.wait(math.random() * 3)

		while true do
			local v3 = math.random() * 20 - 10
			local cframe = CFrame.Angles(
				math.rad(math.random() * 50 - 25),
				math.rad(math.random() * 50 - 25),
				(math.rad(math.random() * 50 - 25))
			)
			local tween = TweenService:Create(
				v,
				TweenInfo.new(math.random() * 3 + 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					CFrame = CFrame.new(0, v3, 0) * cFrame * cframe
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end