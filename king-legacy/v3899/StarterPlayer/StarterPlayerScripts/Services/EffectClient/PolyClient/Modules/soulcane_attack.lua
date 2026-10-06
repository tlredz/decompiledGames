local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
return function(p)
	local char = p.char
	wait(0.25)
	local v = (char.HumanoidRootPart.CFrame or p.cf) * CFrame.new(
		math.random(-10, 10) / 10,
		math.random(-10, 10) / 10,
		-5
	)
	local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.rapierfx:Clone()
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(v * CFrame.Angles(0, -1.5707963267948966, 0))
	TweenService:Create(clone.part0, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, -1.5707963267948966, 0)
	}):Play()
	TweenService:Create(clone.part1, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, -1.5707963267948966, 0)
	}):Play()
	local run = require(clone.run)
	run()
	_G.PU:Dust(clone, 1)
end