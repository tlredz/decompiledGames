local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(p)
	local startCF = p.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	local clone = ReplicatedStorage.Chest.Etc.HydraSB.RingDecal:Clone()
	clone.Size = createVector(50, 1, 50)
	clone.Decal.Transparency = 1
	clone.Decal2.Transparency = 1
	clone.CFrame = CFrame.new(startCF.p)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 4)
	TweenService:Create(clone.Decal, TweenInfo.new(1), {
		Transparency = 0
	}):Play()
	TweenService:Create(clone.Decal2, TweenInfo.new(1), {
		Transparency = 0
	}):Play()
	TweenService:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Size = createVector(0, 1, 0)
	}):Play()
end