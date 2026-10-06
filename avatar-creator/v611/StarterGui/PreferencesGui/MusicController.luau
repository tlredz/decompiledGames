local v = {
	{ "101483797008554", "Ambient Loading Screen" },
	{ "105207989327304", "AFK Ambient Drift" },
	{ "72606200411561", "Relaxing Pixel Waves" },
	{ "73989489073157", "Next Level Chill" },
	{ "83285881689721", "Late Session Chill" },
	{ "139592242488230", "Beat To Chill & Game To" },
	{ "109583650015752", "gaming chill" },
	{ "114091156980400", "Post-Match Lofi Cooldown" },
	{ "85466437024964", "Game Over Chill" },
	{ "135971751701584", "Galactic serenity" }
}
local v2 = 1
local SavedPreferences = require(game.ReplicatedStorage:WaitForChild("SavedPreferences"))
local loaded = SavedPreferences.Load()
local music = script.Parent.Panel.Pages.Music
local musicToggle = music.MusicToggle
local sound = Instance.new("Sound")
sound.Name = "BackgroundMusic"
sound.SoundId = "rbxassetid://101483797008554"
sound.Volume = game.Players.LocalPlayer:GetAttribute("MusicVolume") or 0.06
sound.Looped = false
sound:SetAttribute("Track", "Ambient Loading Screen")
sound:SetAttribute("Credit", "DistrokidOfficial; Roblox Creator Store")
sound.Parent = game:GetService("SoundService")
local musicPaused = loaded.MusicPaused
local v3 = false
local flag = false
local v4 = false

local function update()
	musicToggle.Text = v4 and "Retry music" or musicPaused and "Play music" or v3 and "Music paused near radio" or "Pause music"
	music.CurrentTrack.Text = v4 and "Music could not load. Tap Retry music." or (musicPaused and "Paused: " or v3 and "Nearby radio playing · " or "Now playing: ") .. (sound:GetAttribute("Track") or "")
	musicToggle:SetAttribute("Paused", musicPaused)
end

local v5 = false
local flag2 = false

local function load()
	if v5 or flag2 then
		return
	end

	v5 = true
	v4 = false
	flag = false

	for _ = 1, #v do
		sound:Stop()
		local v6 = v[v2]
		sound.SoundId = "rbxassetid://" .. v6[1]
		sound:SetAttribute("Track", v6[2])
		sound:SetAttribute("PlaylistIndex", v2)
		sound:SetAttribute("PlaylistCount", #v)
		local v7 = false
		task.spawn(function()
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync({ sound })
			end)
			v7 = true
		end)
		local v8 = os.clock() + 12

		repeat
			task.wait(0.1)
		until v7 and sound.IsLoaded or flag2 or v8 <= os.clock()

		if flag2 then
			return
		end

		if v7 and sound.IsLoaded then
			flag = true
			break
		else
			v2 = v2 % #v + 1
		end
	end

	v4 = not flag
	v5 = false
	sound.TimePosition = 0

	if flag and not (musicPaused or v3) then
		sound:Play()
	end

	update()
end

sound.Ended:Connect(function()
	v2 = v2 % #v + 1
	task.spawn(load)
end)
script.Destroying:Connect(function()
	flag2 = true
end)
musicToggle.Activated:Connect(function()
	if v4 then
		task.spawn(load)
		return
	end

	musicPaused = not musicPaused
	SavedPreferences.Set("MusicPaused", musicPaused)

	if flag then
		if musicPaused or v3 then
			sound:Pause()
		else
			sound:Resume()
		end
	end

	update()
end)
local TweenService = game:GetService("TweenService")
musicToggle.MouseEnter:Connect(function()
	TweenService:Create(musicToggle, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(49, 61, 79)
	}):Play()
end)
musicToggle.MouseLeave:Connect(function()
	TweenService:Create(musicToggle, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(34, 38, 45)
	}):Play()
end)
update()
task.spawn(load)
script.Destroying:Connect(function()
	sound:Destroy()
end)
local localPlayer = game.Players.LocalPlayer
local flag3 = true
script.Destroying:Connect(function()
	flag3 = false
end)

local function updateBoomboxes()
	local currentCamera = workspace.CurrentCamera
	local position = currentCamera and currentCamera.CFrame.Position
	local muteBoomboxMusic = localPlayer:GetAttribute("MuteBoomboxMusic") == true
	local v6 = false

	for _, v7 in game.Players:GetPlayers() do
		local character = v7.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local passBoombox = humanoidRootPart and humanoidRootPart:FindFirstChild("PassBoombox")

		if not passBoombox then
			continue
		end

		passBoombox.Volume = muteBoomboxMusic and 0 or 0.5
		local v8 = false

		for _, tool in character:GetChildren() do
			if not (tool:IsA("Tool") and tool:GetAttribute("GamepassTool") == "Boombox") then
				continue
			end

			v8 = true
			break
		end

		if muteBoomboxMusic or not v8 or not position or not passBoombox.IsLoaded then
			continue
		end

		if not (passBoombox.IsPlaying and (humanoidRootPart.Position - position).Magnitude < passBoombox.RollOffMaxDistance) then
			continue
		end

		v6 = true
	end

	if v3 ~= v6 then
		v3 = v6

		if flag then
			if musicPaused or v6 then
				sound:Pause()
			else
				sound:Resume()
			end
		end

		update()
	end
end

localPlayer:GetAttributeChangedSignal("MuteBoomboxMusic"):Connect(updateBoomboxes)
task.spawn(function()
	while flag3 do
		updateBoomboxes()
		task.wait(0.1)
	end
end)