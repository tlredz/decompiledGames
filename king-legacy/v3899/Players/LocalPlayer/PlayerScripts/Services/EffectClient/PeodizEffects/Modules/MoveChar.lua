local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
return function(data)
	local startCF = data.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
		FieldOfView = 110
	}):Play()
	TweenService:Create(data.Part, TweenInfo.new(data.Time, Enum.EasingStyle.Sine), {
		CFrame = data.EndCF
	}):Play()
	spawn(function()
		wait(data.Time * 1.5)
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
			FieldOfView = 70
		}):Play()
	end)
end