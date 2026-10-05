local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local GuiService = game:GetService("GuiService")
local isTenFootInterface = GuiService:IsTenFootInterface()

local function onRadioSongPlayed(object, soundId: string)
	if isTenFootInterface then
		return
	end

	if object.SoundId == soundId and object.IsPlaying then
		object:Stop()
		return
	end

	object:Stop()
	object.SoundId = soundId
	object:Play()
end

remotes:WaitForChild("Inventory"):WaitForChild("PlaySong").OnClientEvent:Connect(onRadioSongPlayed)
return {}