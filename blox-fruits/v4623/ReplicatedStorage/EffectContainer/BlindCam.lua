local localPlayer = game.Players.LocalPlayer
return function(options)
	local v = options or {}
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local blindGui = playerGui:FindFirstChild("BlindGui") or Instance.new("ScreenGui", playerGui)
	blindGui.Name = "BlindGui"
	blindGui.DisplayOrder = -1
	blindGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = v.Color or Color3.new(0.4, 0.4, 0.4)
	frame.Size = UDim2.new(2, 0, 2, 0)
	frame.Position = UDim2.new(-0.25, 0, -0.25, 0)
	frame.BackgroundTransparency = 1

	if v.ZIndex then
		frame.ZIndex = v.ZIndex
	end

	frame.Parent = blindGui
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(frame, TweenInfo.new(v.Fade or 0.25), {
		BackgroundTransparency = 0
	})
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function()
		completedConnection:Disconnect()

		if v.Reference then
			repeat
				task.wait()
			until v.Reference.Parent == nil
		end

		task.wait(v.Duration or 1)
		local TweenService2 = game:GetService("TweenService")
		local tween2 = TweenService2:Create(frame, TweenInfo.new(v.Fade or 0.25), {
			BackgroundTransparency = 1
		})
		local completedConnection2 = nil
		completedConnection2 = tween2.Completed:Connect(function()
			frame:Destroy()
			completedConnection2:Disconnect()
		end)
		tween2:Play()
	end)
	tween:Play()
end