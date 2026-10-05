local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local _ = {
	SCALE = 0.2,
	DURATION = 4,
	SOUND_ID = "rbxassetid://122501020672503",
	SOUND_VOL = 0.4
}
return {
	Run = function(player)
		local character = player.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid and humanoidRootPart then
			task.spawn(function()
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://122501020672503"
				sound.Volume = 0.4
				sound.PlaybackSpeed = 1.8
				sound.Parent = SoundService
				sound:Play()
				Debris:AddItem(sound, 5)
				local scale = character:GetScale()
				local walkSpeed = humanoid.WalkSpeed
				character:ScaleTo(0.2)
				humanoid.WalkSpeed = walkSpeed
				task.wait(4)

				if character.Parent and humanoid.Parent and humanoidRootPart.Parent then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local walkSpeed2 = humanoid.WalkSpeed
					character:ScaleTo(scale)
					humanoid.WalkSpeed = walkSpeed2
					humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
				end
			end)
		end
	end
}