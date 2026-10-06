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

	for i = 1, 2 do
		local clone = ReplicatedStorage.Chest.FruitEffect.Gura.Shock:Clone()
		clone.Size = createVector(5, 25, 5)
		clone.CFrame = startCF * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(i * 350, 25, i * 350)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 2)
		wait()
	end
end