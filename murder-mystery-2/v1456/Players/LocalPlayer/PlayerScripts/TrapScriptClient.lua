local trapSystem = game.ReplicatedStorage.TrapSystem
trapSystem.TrapHitLocal.OnClientEvent:Connect(function(p, player)
	local character = player.Character
	local v = { p.TrapVisual.CFrame:GetComponents() }
	v[1] = character.HumanoidRootPart.Position.X
	v[2] = p.TrapVisual.Position.Y
	v[3] = character.HumanoidRootPart.Position.Z
	p.TrapVisual.CFrame = CFrame.new(unpack(v))
	p.TrapVisual.Transparency = 0
	character.Humanoid.WalkSpeed = 0.01
	character.Humanoid.JumpPower = 1
	local clone = script.TrapGUI:Clone()
	clone.Enabled = true
	clone.Parent = game.Players.LocalPlayer.PlayerGui
	clone.Main.Progress.Bar.TweenScript.Disabled = false
	trapSystem.TrapReplicate:FireServer(p, p.TrapVisual.CFrame)
	task.wait(4)
	character.Humanoid.WalkSpeed = 16
	character.Humanoid.JumpPower = 50
end)
trapSystem.TrapHitVisual.OnClientEvent:Connect(function(p, cFrame, player)
	p.TrapVisual.CFrame = cFrame
	p.TrapVisual.Transparency = 0

	if game.Players.LocalPlayer == p.PlacedPlayer.Value then
		local clone = script.TrappedBillboard:Clone()
		clone.Parent = player.Character.HumanoidRootPart
		clone.Enabled = true
		game.Debris:AddItem(clone, 5)
	end
end)
trapSystem.PlaceTrapLocal.OnClientEvent:Connect(function(p)
	p.TrapVisual.Transparency = 0.5
	local clone = script.TrapBillboard:Clone()
	clone.Parent = p.TrapVisual
	clone.Enabled = true
end)
trapSystem.TrapNotification.OnClientEvent:Connect(function(folder)
	script.Sound:Play()

	for _, billboardGui in pairs(folder:GetDescendants()) do
		if billboardGui:IsA("BillboardGui") then
			billboardGui:Destroy()
		end
	end
end)