local container = script.Parent:WaitForChild("Container"):WaitForChild("Mute"):WaitForChild("Container")
local SoundService = game:GetService("SoundService")
local music = SoundService:WaitForChild("Music")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remotes")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("AudioService"))
local mutedIcon = container:WaitForChild("Icon"):WaitForChild("MutedIcon")
local unmutedIcon = container:WaitForChild("Icon"):WaitForChild("UnmutedIcon")

local function isMuted()
	return music.Volume <= 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateMuteIcon()
	mutedIcon.Visible = music.Volume <= 0
	unmutedIcon.Visible = not (music.Volume <= 0)
end

local function onMuteToggled()
	if music.Volume > 0 then
		music.Volume = 0
	else
		music.Volume = 1
	end

	updateMuteIcon() -- equivalent call inferred; original call site unknown
end

updateMuteIcon() -- equivalent call inferred; original call site unknown
container:WaitForChild("Button").Activated:Connect(onMuteToggled)