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
	OverwriteAnimations = {
		Run = "rbxassetid://109438752615622",
		Walk = "rbxassetid://82362067360374",
		Idle = "rbxassetid://114371645858993",
		Quirk = "rbxassetid://112081529479855",
		Ability = "rbxassetid://105270883055867",
		Decode = "rbxassetid://73122063663340"
	},
	FaceTextures = {
		Normal = "rbxassetid://78840854785943",
		Blink = "rbxassetid://133669944857402",
		Hurt = "rbxassetid://71623632527778"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local leftWing = instance:FindFirstChild("LeftWing")
		local trail = leftWing and leftWing:FindFirstChild("Trail")

		if trail then
			trail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(142, 134, 230)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 134, 230))
			})
		end

		local rightWing = instance:FindFirstChild("RightWing")
		local trail2 = rightWing and rightWing:FindFirstChild("Trail")

		if trail2 then
			trail2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(142, 134, 230)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 134, 230))
			})
		end
	end
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

function FrostyFluff.UseAbility(instance)
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
	local clone = ReplicatedStorage2.Parts.RenderModules.FlutterFly.FlutterFly:Clone()
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