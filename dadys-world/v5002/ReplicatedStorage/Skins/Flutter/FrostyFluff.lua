local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FrostyFluff = {
	Name = "Frosty Fluff",
	TowerName = "Flutter",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://133669944857402"
		hurtTexture.Texture = "rbxassetid://71623632527778"
		normalTexture.Texture = "rbxassetid://78840854785943"
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		instance.RootPart.root_jnt:Destroy()
		clone.RootPart.root_jnt.Parent = instance.RootPart
		instance.LeftWing.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(142, 134, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 134, 230))
		})
		instance.RightWing.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(142, 134, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 134, 230))
		})
		local animations = instance:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = instance:WaitForChild(v[part.Name] or part.Name)
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}
game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

function FrostyFluff.UseAbility(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance:WaitForChild("Stats"):WaitForChild("Skin")
	local _ = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
	task.delay(0.12, function()
		local leftWing = instance:FindFirstChild("LeftWing")
		local rightWing = instance:FindFirstChild("RightWing")

		if leftWing then
			leftWing.Trail.Enabled = true
		end

		if rightWing then
			rightWing.Trail.Enabled = true
		end
	end)
	task.delay(0.8, function()
		local leftWing = instance:FindFirstChild("LeftWing")
		local rightWing = instance:FindFirstChild("RightWing")

		if leftWing then
			leftWing.Trail.Enabled = false
		end

		if rightWing then
			rightWing.Trail.Enabled = false
		end
	end)
	local clone = script.FlutterFly:Clone()
	clone.Parent = workspace
	Debris:AddItem(clone, 2)
	clone.CFrame = humanoidRootPart.CFrame
	clone.SmokePart:Emit(10)
	TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(clone.Size.X * 1.25, clone.Size.Y * 1.5, clone.Size.Z * 1.25),
		CFrame = clone.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, 2.6179938779914944),
		Transparency = 1
	}):Play()
end

return FrostyFluff