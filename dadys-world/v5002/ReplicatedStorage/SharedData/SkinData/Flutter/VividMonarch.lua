local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local VividMonarch = {}
VividMonarch.Name = "Vivid Monarch"
VividMonarch.Cost = 600
VividMonarch.DandyStore = true
VividMonarch.OverwriteAnimations = {
	Ability = "rbxassetid://104966321633572",
	Decode = "rbxassetid://130988661654435",
	Idle = "rbxassetid://114371645858993",
	Run = "rbxassetid://109438752615622",
	Walk = "rbxassetid://82362067360374",
	Quirk = "rbxassetid://112081529479855"
}
VividMonarch.FaceTextures = {
	Blink = "rbxassetid://83371193490138",
	Hurt = "rbxassetid://120914839600284",
	Normal = "rbxassetid://109880639765181"
}
VividMonarch.USE_SKIN_MODEL = true

function VividMonarch.ApplySkin(instance)
	local leftWing = instance:FindFirstChild("LeftWing")
	local trail = leftWing and leftWing:FindFirstChild("Trail")

	if trail then
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 30))
		})
	end

	local rightWing = instance:FindFirstChild("RightWing")
	local trail2 = rightWing and rightWing:FindFirstChild("Trail")

	if trail2 then
		trail2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 30)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 30))
		})
	end
end

function VividMonarch.UseAbility(instance)
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

return VividMonarch