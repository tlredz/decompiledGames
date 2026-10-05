game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
Random.new()
TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
return function(data)
	local MAX = data.MAX
	local ITERATION = data.ITERATION
	local WIDTH = data.WIDTH
	local LENGTH = data.LENGTH
	local COLOR1 = data.COLOR1
	local COLOR2 = data.COLOR2
	local STARTPOS = data.STARTPOS
	local ENDGOAL = data.ENDGOAL

	for _ = 1, ITERATION do
		for i = 1, MAX do
			local clone = script.Part:Clone()
			clone.Size = Vector3.new(WIDTH, WIDTH, LENGTH)
			clone.Material = Enum.Material.Neon
			local specialMesh = Instance.new("SpecialMesh", clone)
			specialMesh.MeshType = Enum.MeshType.Sphere

			if i % 2 == 0 then
				clone.Color = COLOR1
			else
				clone.Color = COLOR2 or COLOR1
			end

			clone.CFrame = STARTPOS * CFrame.new(
				math.random(-MAX * 2, MAX * 2),
				math.random(1, MAX * 2),
				math.random(-MAX * 2, 0)
			)
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(data.SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					CFrame = clone.CFrame * ENDGOAL
				}
			)
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		RunService.RenderStepped:Wait()
	end
end