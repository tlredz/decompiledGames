local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reward = require(ReplicatedStorage.Client.Notifications.Reward)
local Rain = require(ReplicatedStorage.Client.UI.VFX.Rain)
local playbackSpeed = { 0.9, 1.1 }

local function showerRecipe()
	return {
		Ambience = {
			Volume = 1.3,
			PlaybackSpeed = playbackSpeed,
			Sounds = { "rbxassetid://78590382571227" }
		},
		Sheets = {
			{
				SizeMultiplier = 3,
				Texture = "rbxassetid://78137530993637"
			}
		},
		Seconds = 1
	}
end

local frozen = table.freeze((showerRecipe()))
return {
	Announce = function(value: number)
		local v2

		if type(value) == "number" then
			v2 = value > 0
		else
			v2 = false
		end

		assert(v2, "a speed power announcement needs a positive amount")
		Rain.Fall(frozen)
		Reward.Show({
			Item = {
				Amount = math.round(value),
				Kind = "SpeedPower"
			}
		})
	end
}