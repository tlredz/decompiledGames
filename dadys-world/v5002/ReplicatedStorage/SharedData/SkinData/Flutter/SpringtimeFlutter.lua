local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SpringtimeFlutter = {}
SpringtimeFlutter.Name = "Spring-Time Flutter"
SpringtimeFlutter.TowerName = "Flutter"
SpringtimeFlutter.Description = "No description yet"
SpringtimeFlutter.Mastery = false
SpringtimeFlutter.OverwriteAnimations = {
	Run = "rbxassetid://109438752615622",
	Walk = "rbxassetid://82362067360374",
	Idle = "rbxassetid://114371645858993",
	Quirk = "rbxassetid://112081529479855",
	Ability = "rbxassetid://104966321633572",
	Decode = "rbxassetid://130988661654435"
}
SpringtimeFlutter.FaceTextures = {
	Normal = "rbxassetid://106865735788381",
	Blink = "rbxassetid://104581797423255",
	Hurt = "rbxassetid://117795787899110"
}
SpringtimeFlutter.USE_SKIN_MODEL = true

function SpringtimeFlutter.ApplySkin(instance, _)
	local leftWing = instance:FindFirstChild("LeftWing")
	local trail = leftWing and leftWing:FindFirstChild("Trail")

	if trail then
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 149, 181)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(137, 156, 127))
		})
	end

	local rightWing = instance:FindFirstChild("RightWing")
	local trail2 = rightWing and rightWing:FindFirstChild("Trail")

	if trail2 then
		trail2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 149, 181)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(137, 156, 127))
		})
	end
end

function SpringtimeFlutter.UseAbility(instance)
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

return SpringtimeFlutter