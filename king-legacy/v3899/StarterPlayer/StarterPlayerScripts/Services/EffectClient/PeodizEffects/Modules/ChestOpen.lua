local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
return function(p)
	local startCF = p.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	local rootPart = p.Target:FindFirstChild("RootPart")

	if not rootPart then
		return
	end

	local track = p.Target.AnimationController:LoadAnimation(p.Target.ChestAnim)
	track:Play()
	track.KeyframeReached:Connect(function(p2)
		if p2 == "Open" then
			wait(0.2)

			if p.Target and p.Target.Parent then
				p.Target.Coins.Sound:Play()
				TweenService:Create(p.Target.Coins, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end
		end
	end)
	task.spawn(function()
		wait(1.5)
		local openingAura = p.Target and p.Target.Parent and rootPart:FindFirstChild("OpeningAura")

		if openingAura then
			for _, child in pairs(openingAura:GetChildren()) do
				child.Enabled = true
			end
		end
	end)
	track.Stopped:connect(function()
		local openingAura = rootPart:FindFirstChild("OpeningAura")

		if openingAura then
			for _, child in pairs(openingAura:GetChildren()) do
				child.Enabled = false
			end
		end

		local attachment = rootPart:FindFirstChild("Attachment")

		if attachment then
			for _, child in pairs(attachment:GetChildren()) do
				child.Enabled = false
			end
		end

		if p.Target:FindFirstChild("ChestAnimIdle") then
			p.Target.AnimationController:LoadAnimation(p.Target.ChestAnimIdle):Play()
		end
	end)

	if rootPart:FindFirstChild("AuraSound") then
		rootPart.AuraSound:Play()
	end

	if rootPart:FindFirstChild("OpeningSound") then
		rootPart.OpeningSound:Play()
	end
end