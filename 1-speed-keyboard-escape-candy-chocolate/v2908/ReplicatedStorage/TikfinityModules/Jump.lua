local createVector = vector.create
local Debris = game:GetService("Debris")
local _ = {
	POWER = 120,
	SOUND_ID = "rbxassetid://9111926008",
	VOLUME = 0.1
}
return {
	Run = function(player)
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoid) then
			return
		end

		local sound = Instance.new("Sound", humanoidRootPart)
		sound.SoundId = "rbxassetid://9111926008"
		sound.Volume = 0.1
		sound:Play()
		Debris:AddItem(sound, 2)
		local attachment = Instance.new("Attachment", humanoidRootPart)
		local linearVelocity = Instance.new("LinearVelocity", humanoidRootPart)
		linearVelocity.Attachment0 = attachment
		linearVelocity.MaxForce = 100000
		linearVelocity.VectorVelocity = createVector(0, 120, 0)
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		Debris:AddItem(attachment, 0.2)
		Debris:AddItem(linearVelocity, 0.2)
	end
}