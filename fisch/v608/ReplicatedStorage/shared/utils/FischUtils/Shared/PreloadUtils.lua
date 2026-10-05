local ContentProvider = game:GetService("ContentProvider")
local PreloadUtils = {
	PreloadAsync = function(self, callback)
		for _, sound in ipairs(self) do
			if typeof(sound) == "Instance" and sound:IsA("Sound") and sound:HasTag("LazyLoadSound") and sound:GetAttribute("SoundId") then
				sound.SoundId = sound:GetAttribute("SoundId")
				sound:RemoveTag("LazyLoadSound")
			elseif typeof(sound) == "Instance" then
				for _, v in sound:QueryDescendants("Sound.LazyLoadSound"), nil, nil do
					v.SoundId = v:GetAttribute("SoundId")
					v:RemoveTag("LazyLoadSound")
				end
			end
		end

		ContentProvider:PreloadAsync(self, callback)
	end
}

function PreloadUtils.PreloadSpawn(p, callback)
	return task.spawn(PreloadUtils.PreloadAsync, p, callback)
end

return PreloadUtils