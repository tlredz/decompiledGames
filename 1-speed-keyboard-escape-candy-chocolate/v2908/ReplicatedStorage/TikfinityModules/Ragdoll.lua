local createVector = vector.create
local Debris = game:GetService("Debris")
local _ = {
	DURATION = 2,
	FORCE_H = 30,
	FORCE_V = 35,
	TILT_ANGLE = 70,
	SOUND_ID = "rbxassetid://129432532096499"
}
return {
	Run = function(player)
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")

		if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			return
		end

		local sound = Instance.new("Sound", humanoidRootPart)
		sound.SoundId = "rbxassetid://129432532096499"
		sound:Play()
		Debris:AddItem(sound, 3)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.PlatformStand = true
		humanoidRootPart.CFrame *= CFrame.Angles(1.2217304763960306, 0, 0)
		local v = -humanoidRootPart.CFrame.LookVector
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v.X * 30, 35, v.Z * 30)
		task.delay(2, function()
			if character.Parent and humanoid then
				humanoid.PlatformStand = false
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			end
		end)
	end
}