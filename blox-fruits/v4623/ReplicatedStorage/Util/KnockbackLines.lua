game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local _ = data.MAX
	local ITERATION = data.ITERATION
	local WIDTH = data.WIDTH
	local LENGTH = data.LENGTH
	local COLOR1 = data.COLOR1
	local COLOR2 = data.COLOR2
	local STARTPOS = data.STARTPOS
	local ENDGOAL = data.ENDGOAL
	local tweenInfo = TweenInfo.new(data.SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _ = 1, ITERATION do
		for i = 1, 2 do
			local clone = script.Part:Clone()
			clone.Size = Vector3.new(WIDTH, WIDTH, LENGTH)
			clone.Material = Enum.Material.Neon

			if i % 2 == 0 then
				clone.Color = COLOR1
			else
				clone.Color = COLOR2 or COLOR1
			end

			clone.CFrame = STARTPOS * CFrame.new(math.random(-4, 4), math.random(1, 4), math.random(-4, 0))
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, tweenInfo, {
				Transparency = 1,
				CFrame = clone.CFrame * ENDGOAL
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		RunService.RenderStepped:Wait()
	end
end