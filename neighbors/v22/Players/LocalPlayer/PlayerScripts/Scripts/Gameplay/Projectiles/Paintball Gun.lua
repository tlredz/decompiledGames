local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local _ = {
	Color3.fromRGB(126, 123, 224),
	Color3.fromRGB(187, 199, 246),
	Color3.fromRGB(230, 148, 227),
	Color3.fromRGB(108, 185, 116),
	Color3.fromRGB(120, 167, 188)
}
return {
	Impact = function(p, data, _)
		local clone = script.Assets.Splat:Clone()
		clone.Color = p.Object.Color
		clone.CFrame = CFrame.new(data.Position, data.Position + data.Normal) * CFrame.Angles(
			1.5707963267948966,
			math.rad((math.random(0, 360))),
			0
		)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = data.Instance
		local size = clone.Size * Vector3.new(math.random(800, 1200) / 1000, 1, math.random(800, 1200) / 1000)
		clone.Size = createVector(0, 0, 0)
		clone.Anchored = false
		clone.CanCollide = false
		weldConstraint.Parent = clone
		clone.Parent = workspace.ProjectileInstances
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
		Debris:AddItem(clone, math.random(6, 8))
		task.delay(0.1, function()
			local sound = Instance.new("Sound")
			sound.Name = "ObjectSound"
			sound.SoundId = `rbxassetid://{9113511307}`
			sound.Volume = 1
			sound.RollOffMinDistance = 5
			sound.RollOffMaxDistance = 85
			sound.Parent = clone
			sound:Play()
		end)
		local clone2 = script.Assets.PaintDust:Clone()
		clone2.Color = ColorSequence.new(p.Object.Color)
		clone2.Parent = clone
		clone2.Enabled = true
		task.delay(0.2, function()
			clone2.Enabled = false
		end)
		Debris:AddItem(clone2, 2)
	end
}