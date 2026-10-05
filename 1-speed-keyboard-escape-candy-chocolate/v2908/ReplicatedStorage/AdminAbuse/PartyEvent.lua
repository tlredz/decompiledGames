local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Janitor = require(script.Parent.Parent.Utilities.Janitor)
local SoundFade = require(script.Parent.Parent.Utilities.Events.SoundFade)
local v = {
	MaxDurationSeconds = 1200,
	DefaultDurationSeconds = 600,
	NeedsDuration = true,
	RequiresRespawnRefire = true,
	SkipDoorTransition = true,
	IsAdminAbuse = false,
	Sounds = {}
}
local PartyEvent = {}
PartyEvent.__index = PartyEvent

function PartyEvent.new(items)
	local self = setmetatable({}, PartyEvent)

	for k, v2 in v do
		self[k] = v2
	end

	if items then
		for k, item in items do
			self[k] = item
		end
	end

	self._activeSession = nil
	self._sound = nil
	self._soundFader = nil
	self._soundEndedConn = nil
	self._priorityLocked = false
	return self
end

function PartyEvent:_ensureSound()
	if self._sound then
		return
	end

	local v2 = type(self.Sounds) ~= "table" and {} or self.Sounds

	if #v2 == 0 then
		return
	end

	local sound = Instance.new("Sound")
	sound.Volume = 0
	sound.Looped = false
	sound:SetAttribute("IsEventSound", true)
	sound.Parent = SoundService
	local v3 = nil

	local function pickNext()
		if #v2 == 1 then
			return v2[1]
		end

		local v4

		repeat
			v4 = v2[math.random(1, #v2)]
		until v4 ~= v3

		return v4
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playNext()
		local soundId = pickNext()
		v3 = soundId
		sound.SoundId = soundId
		sound.TimePosition = 0
		sound:Play()
	end

	self._soundEndedConn = sound.Ended:Connect(function()
		if self._activeSession then
			playNext() -- equivalent call inferred; original call site unknown
		end
	end)
	self._soundFader = SoundFade.new(sound, {
		fadeIn = 0.5,
		fadeOut = 1,
		volume = 0.8
	})
	self._sound = sound
	self._playNextSound = playNext
end

function PartyEvent:Stop()
	local _activeSession = self._activeSession

	if not _activeSession then
		return
	end

	if _activeSession.connection then
		_activeSession.connection:Disconnect()
		_activeSession.connection = nil
	end

	if self._soundFader and self._sound then
		local _sound = self._sound
		self._soundFader:fadeOut(function()
			if _sound.Parent then
				_sound:Stop()
			end
		end)
	end

	if self.OnStop then
		self:OnStop(_activeSession)
	end

	_activeSession.janitor:Cleanup()
	self._activeSession = nil
end

function PartyEvent:Fire()
	self:Stop()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 30)

	if not humanoidRootPart then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
		currentCamera = workspace.CurrentCamera
	end

	if not currentCamera then
		return
	end

	local activeSession = {
		connection = nil,
		janitor = Janitor.new()
	}
	self._activeSession = activeSession
	self:_ensureSound()

	if self._sound then
		if not self._sound.IsPlaying then
			self._playNextSound()
		end

		if not self._priorityLocked then
			self._soundFader:fadeIn()
		end
	end

	if self.OnStart then
		self:OnStart(activeSession, character, humanoidRootPart, currentCamera)
	end

	activeSession.connection = RunService.RenderStepped:Connect(function()
		if self._activeSession == activeSession then
			local character2 = character
			local humanoidRootPart2 = humanoidRootPart

			if self.RequiresRespawnRefire == false then
				local localPlayer2 = Players.LocalPlayer
				character2 = localPlayer2 and localPlayer2.Character
				humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
			elseif not (character.Parent and humanoidRootPart.Parent) then
				self:Stop()
				return
			end

			local currentCamera2 = workspace.CurrentCamera

			if not currentCamera2 then
				return
			end

			if self.OnRender then
				self:OnRender(activeSession, os.clock(), character2, humanoidRootPart2, currentCamera2)
			end
		elseif activeSession.connection then
			activeSession.connection:Disconnect()
		end
	end)
end

function PartyEvent:SetPriorityLocked(priorityLocked: boolean)
	if self._priorityLocked == priorityLocked then
		return
	end

	self._priorityLocked = priorityLocked

	if not (self._activeSession and self._sound) then
		return
	end

	if priorityLocked then
		self._soundFader:fadeOut()
	else
		self._soundFader:fadeIn()
	end
end

function PartyEvent:Destroy()
	self:Stop()

	if self._soundEndedConn then
		self._soundEndedConn:Disconnect()
		self._soundEndedConn = nil
	end

	if self._sound then
		self._sound:Destroy()
		self._sound = nil
		self._soundFader = nil
	end
end

return PartyEvent