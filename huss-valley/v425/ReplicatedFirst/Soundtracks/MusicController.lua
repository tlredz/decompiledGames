local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local MusicController = {}
MusicController.__index = MusicController

local function usable(sound)
	local isA = sound:IsA("Sound")

	if isA then
		if sound:GetAttribute("Enabled") == false or sound.SoundId == "" then
			isA = false
		else
			isA = sound.SoundId ~= "rbxassetid://0"
		end
	end

	return isA
end

function MusicController.new(theme, config)
	local localPlayer = Players.LocalPlayer
	local folder = Instance.new("Folder")
	folder.Name = "LobbyMusicPlayback"
	folder.Parent = SoundService
	local v = math.clamp(config.MasterVolume or 0.3, 0, 1)

	local function outputVolume()
		local musicVolume = localPlayer:GetAttribute("MusicVolume")
		local v2 = type(musicVolume) == "number" and musicVolume == musicVolume and math.clamp(musicVolume, 0, 1) or 1

		if localPlayer:GetAttribute("MusicMuted") == true then
			return 0
		end

		return v * v2
	end

	local soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "LocalMusicVolume"
	local musicVolume = localPlayer:GetAttribute("MusicVolume")
	local v2 = (type(musicVolume) ~= "number" or musicVolume ~= musicVolume) and 1 or math.clamp(musicVolume, 0, 1) or 1
	soundGroup.Volume = localPlayer:GetAttribute("MusicMuted") == true and 0 or v * v2
	soundGroup.Parent = SoundService
	local object = setmetatable({
		player = localPlayer,
		theme = theme,
		config = config,
		folder = folder,
		group = soundGroup,
		alive = true,
		themeAttempted = false,
		current = nil,
		bag = {},
		lastTrack = nil,
		failed = {},
		generation = 0,
		random = Random.new(),
		connections = {}
	}, MusicController)

	local function updateVolume()
		if object.muteTween then
			object.muteTween:Cancel()
		end

		local v3 = object
		local tweenInfo = TweenInfo.new(config.MuteFade)
		local musicVolume2 = localPlayer:GetAttribute("MusicVolume")
		local v7 = (type(musicVolume2) ~= "number" or musicVolume2 ~= musicVolume2) and 1 or math.clamp(
			musicVolume2,
			0,
			1
		) or 1
		v3.muteTween = TweenService:Create(soundGroup, tweenInfo, {
			Volume = localPlayer:GetAttribute("MusicMuted") == true and 0 or v * v7
		})
		object.muteTween:Play()
	end

	for _, v3 in { "MusicMuted", "MusicVolume" } do
		table.insert(object.connections, localPlayer:GetAttributeChangedSignal(v3):Connect(updateVolume))
	end

	for _, v3 in { "InMatch", "GameRole" } do
		table.insert(object.connections, localPlayer:GetAttributeChangedSignal(v3):Connect(function()
			object:updateEligibility()
		end))
	end

	object:updateEligibility()
	task.spawn(function()
		object:run()
	end)
	task.spawn(function()
		task.wait(config.PrefetchDelay)
		local gameAudio = SoundService:WaitForChild("GameAudio", 15)
		local _01_Soundtracks = gameAudio and gameAudio:FindFirstChild("01_Soundtracks")
		local lobby = _01_Soundtracks and _01_Soundtracks:FindFirstChild("Lobby")

		if lobby then
			for _, sound in lobby:GetChildren() do
				if not object.alive then
					return
				end

				local isA = sound:IsA("Sound")

				if isA then
					if sound:GetAttribute("Enabled") == false or sound.SoundId == "" then
						isA = false
					else
						isA = sound.SoundId ~= "rbxassetid://0"
					end
				end

				if not isA then
					continue
				end

				local v3 = sound
				pcall(function()
					ContentProvider:PreloadAsync({ v3 })
				end)
			end
		end
	end)
	return object
end

function MusicController:isLobby()
	return self.player:GetAttribute("InMatch") ~= true and (self.player:GetAttribute("GameRole") or "Lobby") == "Lobby"
end

function MusicController:updateEligibility()
	local lobby = self:isLobby()
	self.folder:SetAttribute("LobbyEligible", lobby)

	if not lobby and self.current then
		local current = self.current
		self.current = nil
		self.generation += 1
		self:retire(current, self.config.FadeOut)
	end
end

function MusicController:retire(instance, duration)
	if instance:GetAttribute("Retiring") then
		return
	end

	instance:SetAttribute("Retiring", true)

	if self.fadeIn and self.fadeInSound == instance then
		self.fadeIn:Cancel()
	end

	TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0
	}):Play()
	task.delay(duration, function()
		instance:Stop()
		instance:Destroy()
	end)
end

function MusicController:nextTrack()
	local gameAudio = SoundService:FindFirstChild("GameAudio")
	local _01_Soundtracks = gameAudio and gameAudio:FindFirstChild("01_Soundtracks")
	local lobby = _01_Soundtracks and _01_Soundtracks:FindFirstChild("Lobby")

	if not lobby then
		return nil
	end

	if #self.bag == 0 then
		for _, sound in lobby:GetChildren() do
			local isA = sound:IsA("Sound")

			if isA then
				if sound:GetAttribute("Enabled") == false or sound.SoundId == "" then
					isA = false
				else
					isA = sound.SoundId ~= "rbxassetid://0"
				end
			end

			if not isA or self.failed[sound.SoundId] then
				continue
			end

			table.insert(self.bag, sound)
		end

		for i = #self.bag, 2, -1 do
			local integer = self.random:NextInteger(1, i)
			local bag = self.bag
			local bag2 = self.bag
			local v = self.bag[integer]
			local v2 = self.bag[i]
			bag[i] = v
			bag2[integer] = v2
		end

		if #self.bag > 1 and self.bag[#self.bag].SoundId == self.lastTrack then
			local bag = self.bag
			local bag2 = self.bag
			local v = #self.bag
			local v2 = self.bag[#self.bag]
			local v3 = self.bag[1]
			bag[1] = v2
			bag2[v] = v3
		end
	end

	while #self.bag > 0 do
		local sound = table.remove(self.bag)

		if not sound.Parent then
			continue
		end

		local isA = sound:IsA("Sound")

		if isA then
			if sound:GetAttribute("Enabled") == false or sound.SoundId == "" then
				isA = false
			else
				isA = sound.SoundId ~= "rbxassetid://0"
			end
		end

		if isA and not self.failed[sound.SoundId] then
			return sound
		end
	end

	return nil
end

function MusicController:play(instance, isJoiningTheme)
	self.generation += 1
	local generation = self.generation
	local clone = instance:Clone()
	clone.Name = isJoiningTheme and "JoiningTheme" or instance.Name
	clone.Looped = false
	clone.PlayOnRemove = false
	clone.TimePosition = 0
	clone.Volume = 0
	clone.SoundGroup = self.group
	clone.Parent = self.folder
	self.current = clone
	self.folder:SetAttribute("CurrentTrack", instance.Name)
	self.folder:SetAttribute("IsJoiningTheme", isJoiningTheme)
	local v = false
	local endedConnection = clone.Ended:Connect(function()
		v = true
	end)
	clone:Play()
	local v2 = os.clock() + self.config.LoadTimeout

	while self.alive and self.current == clone and not clone.IsLoaded and os.clock() < v2 do
		task.wait(0.05)
	end

	if self.current ~= clone or not self.alive then
		endedConnection:Disconnect()
	elseif clone.IsLoaded then
		self.fadeInSound = clone
		self.fadeIn = TweenService:Create(clone, TweenInfo.new(self.config.FadeIn), {
			Volume = instance.Volume
		})
		self.fadeIn:Play()
		self.folder:SetAttribute("TrackSequence", (self.folder:GetAttribute("TrackSequence") or 0) + 1)

		if isJoiningTheme then
			self.folder:SetAttribute("ThemePlayCount", (self.folder:GetAttribute("ThemePlayCount") or 0) + 1)
			self.folder:SetAttribute("ThemeStartedAt", workspace:GetServerTimeNow())
		end

		self.lastTrack = instance.SoundId
		local v3 = os.clock() + math.max(clone.TimeLength / math.max(clone.PlaybackSpeed, 0.01), 1) + 3

		while self.alive and self.current == clone and generation == self.generation and not v and os.clock() < v3 do
			task.wait(0.1)
		end

		endedConnection:Disconnect()

		if self.current == clone then
			self.current = nil
			clone:Destroy()
		end
	else
		self.failed[instance.SoundId] = true
		self.folder:SetAttribute("LastUnavailableTrack", instance.Name)
		self.current = nil
		endedConnection:Disconnect()
		clone:Destroy()
	end
end

function MusicController:run()
	while self.alive do
		if self:isLobby() then
			local theme = nil
			local v = false

			if self.themeAttempted then
				theme = self:nextTrack()
			else
				self.themeAttempted = true
				v = true
				local theme2 = self.theme
				local isA = theme2:IsA("Sound")

				if isA then
					if theme2:GetAttribute("Enabled") == false or theme2.SoundId == "" then
						isA = false
					else
						isA = theme2.SoundId ~= "rbxassetid://0"
					end
				end

				if isA then
					theme = self.theme
				end
			end

			if theme then
				self:play(theme, v)
				task.wait(self.config.TrackGap)
			else
				task.wait(self.config.EmptyRetry)
			end
		else
			task.wait(0.1)
		end
	end
end

function MusicController:destroy()
	self.alive = false
	self.generation += 1

	for _, connection in self.connections do
		connection:Disconnect()
	end

	if self.muteTween then
		self.muteTween:Cancel()
	end

	if self.fadeIn then
		self.fadeIn:Cancel()
	end

	self.folder:Destroy()
	self.group:Destroy()
end

return MusicController