local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local _ = {
	DURATION = 2.8,
	MODEL_NAME = "PrisonCage",
	SOUND_ID = "rbxassetid://102841351704442",
	SOUND_VOLUME = 0.2,
	FREEZE_DURING_SPAWN = true
}
return {
	Run = function(player)
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		task.spawn(function()
			local prisonCage = ReplicatedStorage:FindFirstChild("PrisonCage")

			if not prisonCage then
				warn("[Tikfinity] Modèle 'PrisonCage' introuvable dans ReplicatedStorage")
				return
			end

			humanoidRootPart.Anchored = true
			local clone = prisonCage:Clone()
			clone.Name = "LocalCage_" .. player.Name
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace
			humanoidRootPart.Anchored = false
			local sound = Instance.new("Sound", humanoidRootPart)
			sound.SoundId = "rbxassetid://102841351704442"
			sound.Volume = 0.2
			sound:Play()
			Debris:AddItem(sound, 2)
			task.wait(2.8)

			if clone then
				clone:Destroy()
			end
		end)
	end
}