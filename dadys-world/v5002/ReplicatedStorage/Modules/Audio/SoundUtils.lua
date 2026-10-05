local Debris = game:GetService("Debris")
local SoundUtils = {
	SafeCleanup = function(sound, value)
		if not (sound and sound:IsA("Sound")) then
			return
		end

		local timeLength = sound.TimeLength

		if timeLength == 0 and sound.Loaded:Wait() then
			timeLength = sound.TimeLength
		end

		Debris:AddItem(sound, (math.max(timeLength, value or 1)))
	end
}

function SoundUtils.PlayAndCleanup(sound, parent, p)
	if not (sound and sound:IsA("Sound")) then
		return nil
	end

	local clone = sound:Clone()
	clone.Parent = parent
	clone:Play()
	SoundUtils.SafeCleanup(clone, p)
	return clone
end

return SoundUtils