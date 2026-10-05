local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(list)
	local v = list[1]
	local clone = ReplicatedStorage.Assets.GUI.BossNotifier:Clone()
	clone.Size = UDim2.new(0, 0, 0, 0)
	clone.Parent = v
	clone.Adornee = v
	local tween = TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = UDim2.new(36, 0, 36, 0)
	})
	coroutine.resume(coroutine.create(function()
		RunService.RenderStepped:Wait()
		tween:Play()
	end))
	tween.Completed:Wait()
	local lastTime = tick()

	while tick() - lastTime < 3.141592653589793 do
		local v2 = math.sin(3.141592653589793 + (tick() - lastTime) * 4) ^ 2
		clone.TextLabel.TextColor3 = Color3.fromHSV(0, v2, 1)
		RunService.RenderStepped:Wait()
	end

	clone.TextLabel.TextColor3 = Color3.new(1, 0, 0)
	local tween2 = TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = UDim2.new(12, 0, 12, 0)
	})
	tween2.Completed:Connect(function() end)
	tween2:Play()
end