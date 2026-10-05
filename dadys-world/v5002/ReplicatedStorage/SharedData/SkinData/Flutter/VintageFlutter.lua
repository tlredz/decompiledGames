local VintageFlutter = {
	Name = "Vintage Flutter",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://137099996057145",
		Hurt = "rbxassetid://92174728955673",
		Blink = "rbxassetid://85232064862128"
	},
	USE_SKIN_MODEL = false
}

function VintageFlutter.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageFlutter.FaceTextures.Normal
		end
	end

	local leftWing = folder:FindFirstChild("LeftWing")
	local trail = leftWing and leftWing:FindFirstChild("Trail")

	if trail then
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
	end

	local rightWing = folder:FindFirstChild("RightWing")
	local trail2 = rightWing and rightWing:FindFirstChild("Trail")

	if trail2 then
		trail2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
	end
end

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

function VintageFlutter.UseAbility(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
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
	local clone = ReplicatedStorage.Parts.RenderModules.FlutterFly.FlutterFly:Clone()
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

return VintageFlutter