local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Jukebox"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._selectedTrack = nil
	self._playingMusic = nil
	self._selectedButton = nil
	self._endedConnection = nil
	self._fadeOutTween = nil
end

function v:NotityStateChanged()
	if self.isNear == nil or not self._playingMusic then
		return
	end

	local playing

	if self._playingMusic then
		playing = self._playingMusic.Playing or false
	else
		playing = false
	end

	if self.currentTrackingMusic and self.startTime and (self._playingMusic.SoundId ~= self.currentTrackingMusic or not (playing and self.isNear)) then
		local duration = tick() - self.startTime

		if duration > 1 then
			TelemetryController.SendClientInteraction("musicListened", {
				trackID = self.currentTrackingMusic,
				source = "Jukebox",
				duration = duration
			})
		end

		if playing and self.isNear then
			self.startTime = tick()
		else
			self.startTime = nil
		end

		self.currentTrackingMusic = self._playingMusic.SoundId
	end

	if self._playingMusic.IsPlaying and self.isNear then
		self.startTime = tick()
		self.currentTrackingMusic = self._playingMusic.SoundId
	end
end

function v:Start()
	self:ChangeTrack(1)
	self:ConnectMusicToButton(1)
	self:ConnectMusicToButton(2)
	self:ConnectMusicToButton(3)

	for _, child in self.Instance:FindFirstChild("InteractButtons"):GetChildren() do
		self:SetupInteractionButton(child)
	end

	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "JukeboxMusicStop", function()
		if self._playingMusic then
			self._playingMusic:Pause()
		end
	end))
	self._Janitor:Add(task.spawn(function()
		local WAIT_INTERVAL = 1
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer

		while true do
			if localPlayer.Character == nil then
				task.wait(WAIT_INTERVAL)
			else
				local distanceTo = CharacterUtil.distanceTo(localPlayer.Character, self.Instance)

				if distanceTo == nil then
					task.wait(WAIT_INTERVAL)
				else
					local isNear = distanceTo < 70

					if self.isNear ~= isNear then
						self.isNear = isNear
						self:NotityStateChanged()
					end

					task.wait(WAIT_INTERVAL)
				end
			end
		end
	end))
end

function v:ConnectMusicToButton(p: number)
	local child = self.Instance:FindFirstChild("Button" .. p)
	local v2 = self._Janitor:Add(Instance.new("ClickDetector"))
	v2.Parent = child
	self._Janitor:Add(v2.MouseClick:Connect(function(player)
		if not player.Character or CharacterUtil.distanceTo(player.Character, child) > 37 then
			return
		end

		local match = child.Name:match("Button(%d+)")
		self:ChangeTrack(tonumber(match), true)
		self:NotityStateChanged()
	end))
end

function v:ChangeTrack(p: number, flag: boolean?)
	if p == self._selectedTrack then
		return
	end

	if self._endedConnection then
		self._endedConnection:Disconnect()
		self._endedConnection = nil
	end

	self._selectedTrack = p < 1 and 3 or p > 3 and 1 or p
	local child = self.Instance:FindFirstChild("Button" .. self._selectedTrack)
	local child2 = self.Instance.Touch:FindFirstChild("Music" .. self._selectedTrack)

	if self._playingMusic then
		local _playingMusic = self._playingMusic

		if self._fadeOutTween then
			self._fadeOutTween:Cancel()
			self._fadeOutTween = nil
		end

		self._fadeOutTween = TweenService:Create(_playingMusic, TweenInfo.new(1), {
			Volume = 0
		})
		self._fadeOutTween:Play()
		task.delay(1, function()
			if self._playingMusic == _playingMusic then
				return
			end

			_playingMusic:Stop()
		end)
	end

	child2.Volume = 0
	child2:Play()

	if flag then
		TelemetryController.SendClientInteraction("musicStart", {
			trackID = child2.SoundId,
			source = "Jukebox",
			vehicleName = nil
		})
	end

	TweenService:Create(child2, TweenInfo.new(1), {
		Volume = 0.05
	}):Play()
	self._playingMusic = child2
	self._endedConnection = child2.Ended:Connect(function()
		self:ChangeTrack(self._selectedTrack + 1)
		self:NotityStateChanged()
	end)

	if self._selectedButton then
		self._selectedButton.Light.Color = Color3.fromRGB(0, 63, 0)
	end

	child.Light.Color = Color3.fromRGB(0, 255, 0)
	self._selectedButton = child
end

function v:SetupInteractionButton(parent)
	local v2 = self._Janitor:Add(Instance.new("ClickDetector"))
	v2.Parent = parent
	local light = parent:FindFirstChild("Light")
	self._Janitor:Add(v2.MouseClick:Connect(function(_)
		if parent.Name == "PlayPause" then
			if self._playingMusic then
				TelemetryController.SendClientInteraction("musicStart", {
					trackID = self._playingMusic.Playing and "JukeboxPause" or `{self._playingMusic.SoundId}`,
					source = "Jukebox",
					vehicleName = nil
				})

				if self._playingMusic.Playing then
					self._playingMusic:Pause()
					light.Color = Color3.fromRGB(255, 0, 0)
				else
					self._playingMusic:Resume()
					light.Color = Color3.fromRGB(0, 63, 0)
				end
			end
		elseif parent.Name == "Next" then
			self:ChangeTrack(self._selectedTrack + 1, true)
		elseif parent.Name == "Prev" then
			self:ChangeTrack(self._selectedTrack - 1, true)
		end

		self:NotityStateChanged()
	end))
end

function v:Stop()
	self:NotityStateChanged()

	if self._endedConnection then
		self._endedConnection:Disconnect()
		self._endedConnection = nil
	end

	if self._fadeOutTween then
		self._fadeOutTween:Cancel()
		self._fadeOutTween = nil
	end

	self._Janitor:Destroy()
end

return v