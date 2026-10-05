local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local _ = {
	DURATION = 4,
	GHOST_TRANSPARENCY = 1,
	SOUND_ID = "rbxassetid://136774133309136",
	SOUND_VOL = 0.4
}
return {
	Run = function(player)
		local character = player.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		task.spawn(function()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://136774133309136"
			sound.Volume = 0.4
			sound.PlaybackSpeed = 0.5
			sound.Parent = SoundService
			sound:Play()
			Debris:AddItem(sound, 5)
			local transparenciesByDescendant = {}

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
					transparenciesByDescendant[descendant] = descendant.Transparency
					descendant.Transparency = 1
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					transparenciesByDescendant[descendant] = descendant.Transparency
					descendant.Transparency = 1
				end
			end

			task.wait(4)

			if character.Parent then
				for k, transparency in pairs(transparenciesByDescendant) do
					if k.Parent then
						k.Transparency = transparency
					end
				end
			end
		end)
	end
}