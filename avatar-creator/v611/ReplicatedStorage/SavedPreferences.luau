local flag = false
local flag2 = false
local result = {}
local v = {
	MusicVolume = 0.06,
	InterfaceScale = 1,
	ReducedMotion = false,
	MuteItemSounds = false,
	MuteBoomboxMusic = false,
	MusicPaused = false,
	SkyPreset = "Daylight",
	GroundPreset = "Classic"
}
local replicatedStorage = game.ReplicatedStorage
local SavedPreferences = {}

function SavedPreferences.Load()
	if flag then
		return result
	end

	if flag2 then
		repeat
			task.wait()
		until flag
	else
		flag2 = true

		while not flag do
			local success, result2 = pcall(function()
				return replicatedStorage:WaitForChild("PlayerSettingsRead"):InvokeServer()
			end)

			if success and type(result2) == "table" then
				for k, v2 in v do
					result[k] = result2[k]

					if result[k] == nil then
						result[k] = v2
					end

					game.Players.LocalPlayer:SetAttribute(k, result[k])
				end

				flag = true
			else
				task.wait(5)
			end
		end
	end

	return result
end

function SavedPreferences.Set(p, p2)
	result[p] = p2
	game.Players.LocalPlayer:SetAttribute(p, p2)
	replicatedStorage:WaitForChild("PlayerSettingsWrite"):FireServer({
		[p] = p2
	})
end

return SavedPreferences