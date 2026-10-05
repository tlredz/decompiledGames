local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Equipment"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local v = not EventLibrary.IS_ACTIVE and "Default" or EventLibrary.EVENT_DETAILS.LOBBY_MUSIC or "Default"
local LOBBY_MUSIC_MUFFLED = EventLibrary.IS_ACTIVE and EventLibrary.EVENT_DETAILS.LOBBY_MUSIC_MUFFLED or "DefaultMuffled"
local v2 = {
	[""] = { "", 1 },
	Default = { "rbxassetid://17697682466", 1 },
	DefaultMuffled = { "rbxassetid://17733314783", 1 },
	Spooky = { "rbxassetid://100081814360953", 1 },
	SpookyMuffled = { "rbxassetid://86062306109271", 0.5 },
	Festive = { "rbxassetid://82135261819112", 1 },
	FestiveMuffled = { "rbxassetid://96771526359691", 1 },
	Tropical = { "rbxassetid://120824068504773", 1 },
	TropicalMuffled = { "rbxassetid://114306049661290", 1 },
	Obby = { "rbxassetid://91718252417630", 1 },
	Spleef = { "rbxassetid://91718252417630", 1 },
	ZombieTower = { "rbxassetid://120087790552326", 1 }
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.LocalFighter = nil
	self._volume = 0.5
	self._sound_name = ""
	self._sound_info = v2[""]
	self._is_tweening = false
	self._sound = Instance.new("Sound")
	self._next_sound = Instance.new("Sound")
	self._volume_multiplier = 1
	self._duel_subject_connections = {}
	self:_Init()
	return self
end

function class:SetSoundID(value, value2)
	assert(not value or v2[value], "Argument 1 invalid, expected a string or nil")
	assert(not value2 or typeof(value2) == "number", "Argument 2 invalid, expected a number or nil")

	if value == self._sound_name then
		return
	end

	self._sound_name = value or ""
	self._sound_info = v2[self._sound_name]
	self._volume_multiplier = value2 or 1
	task.spawn(self._TweenSoundID, self)
end

function class:SetVolume(volume)
	assert(typeof(volume) == "number", "Argument 1 invalid, expected a number")
	self._volume = volume
	self:_UpdateVolume()
end

function class:_UpdateSoundGroups(p, setting)
	local function get(p2)
		if p2 == p then
			return setting
		end

		return (PlayerDataController:GetSetting(p2))
	end

	local master = SoundService.Master
	local volume

	if p == "Master Volume" then
		volume = setting
	else
		volume = PlayerDataController:GetSetting("Master Volume")
	end

	master.Volume = volume
	local music = SoundService.Master.Music
	local volume2

	if p == "Music Volume" then
		volume2 = setting
	else
		volume2 = PlayerDataController:GetSetting("Music Volume")
	end

	music.Volume = volume2
	local other = SoundService.Master.Other
	local volume3

	if p == "Other Volume" then
		volume3 = setting
	else
		volume3 = PlayerDataController:GetSetting("Other Volume")
	end

	other.Volume = volume3
	local finisher = SoundService.Master.Finisher
	local volume4

	if p == "Finisher Volume" then
		volume4 = setting
	else
		volume4 = PlayerDataController:GetSetting("Finisher Volume")
	end

	finisher.Volume = volume4
	local emote = SoundService.Master.Emote
	local volume5

	if p == "Emote Volume" then
		volume5 = setting
	else
		volume5 = PlayerDataController:GetSetting("Emote Volume")
	end

	emote.Volume = volume5
	local finisherFromOthers = SoundService.Master.Finisher.FinisherFromOthers
	local v8

	if p == "Mute Finishers From Others" then
		v8 = setting
	else
		v8 = PlayerDataController:GetSetting("Mute Finishers From Others")
	end

	finisherFromOthers.Volume = v8 and 0 or 1
	local emoteFromOthers = SoundService.Master.Emote.EmoteFromOthers

	if p ~= "Mute Emotes From Others" then
		setting = PlayerDataController:GetSetting("Mute Emotes From Others")
	end

	emoteFromOthers.Volume = setting and 0 or 1
end

function class:_GetCurrentEmoteInfo()
	local currentEmote = SpectateController.CurrentSubject and SpectateController.CurrentSubject.Entity and SpectateController.CurrentSubject.Entity:GetCurrentEmote()

	if currentEmote then
		return currentEmote.Info
	end

	local selectedCosmetic = Equipment.IsOpen and Equipment.EquipmentState.SelectedCosmetic
	local cosmetic = CosmeticLibrary.Cosmetics[selectedCosmetic]

	if cosmetic and cosmetic.Type == "Emote" then
		return cosmetic
	end
end

function class:_GetVolume()
	local v3 = self._sound_info[2]
	local _GetCurrentEmoteInfo = self:_GetCurrentEmoteInfo()
	local v4 = _GetCurrentEmoteInfo and _GetCurrentEmoteInfo.IsAudioIntrusive and 0 or 1
	return v3 * self._volume_multiplier * self._volume * v4
end

function class:_TweenSoundID()
	if self._is_tweening then
		return
	end

	self._is_tweening = true

	while self._sound.SoundId ~= self._sound_info[1] do
		local v3 = (self._sound_name == "" or self._sound.SoundId == "") and 0.25 or 2
		self._next_sound.SoundId = self._sound_info[1]

		if self._sound_name ~= "" then
			self._next_sound:Play()
			self._next_sound.TimePosition = self._sound.TimePosition
		end

		local volume = self._sound.Volume
		Utility:RenderstepForLoop(0, 100, v3, function(p)
			local v5 = p / 100
			self._sound.Volume = (1 - v5) * volume
			self._next_sound.Volume = v5 * self:_GetVolume()
		end)
		self._sound:Stop()
		local _next_sound = self._next_sound
		self._next_sound = self._sound
		self._sound = _next_sound
	end

	self._is_tweening = false
end

function class:_UpdateVolume()
	if not self._is_tweening then
		self._sound.Volume = self:_GetVolume()
	end
end

function class:_UpdateSoundID()
	self:SetSoundID((Equipment.IsOpen or SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject:Get("Status") == "GameOver") and LOBBY_MUSIC_MUFFLED or (not SpectateController.CurrentDuelSubject and self.LocalFighter and not self.LocalFighter:Get("IsInShootingRange") and true or false) and (Pages.PageSystem.CurrentPage and LOBBY_MUSIC_MUFFLED or v) or SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject:Get("DuelMusic") or nil)
end

function class:_DuelSubjectChanged()
	self:_UpdateSoundID()

	if not SpectateController.CurrentDuelSubject then
		return
	end

	table.insert(
		self._duel_subject_connections,
		SpectateController.CurrentDuelSubject:GetDataChangedSignal("DuelMusic"):Connect(function()
			self:_UpdateSoundID()
		end)
	)
end

function class:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateSoundID()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateSoundID()
	end)
	self:_UpdateSoundID()
end

function class:_Setup()
	self._sound.Name = "Music"
	self._sound.Looped = true
	self._sound.SoundGroup = SoundService.Master.Music
	self._sound.Parent = script
	self._next_sound.Name = "NextMusic"
	self._next_sound.Looped = true
	self._next_sound.SoundGroup = SoundService.Master.Music
	self._next_sound.Parent = script
end

function class:_Init()
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_DuelSubjectChanged()
	end)
	SpectateController.DuelSubjectStatusChanged:Connect(function()
		self:_UpdateSoundID()
	end)
	SpectateController.SubjectEmoteStatusChanged:Connect(function()
		self:_UpdateVolume()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateSoundID()
		self:_UpdateVolume()
	end)
	Equipment.CustomizingStateChanged:Connect(function()
		self:_UpdateVolume()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateSoundID()
		self:_UpdateVolume()
	end)
	PlayerDataController:GetSettingChangedSignal("Master Volume"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Music Volume"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Other Volume"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Finisher Volume"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Emote Volume"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Mute Finishers From Others"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController:GetSettingChangedSignal("Mute Emotes From Others"):Connect(function()
		self:_UpdateSoundGroups()
	end)
	PlayerDataController.SettingsSliderChanged:Connect(function(p, p2)
		if p == "Master Volume" or p == "Music Volume" then
			self:_UpdateSoundGroups(p, p2)
		end
	end)
	self:_Setup()
	self:_UpdateVolume()
	self:_DuelSubjectChanged()
	task.spawn(self._HookLocalFighter, self)
	task.defer(self._UpdateSoundGroups, self)
end

return class._new()