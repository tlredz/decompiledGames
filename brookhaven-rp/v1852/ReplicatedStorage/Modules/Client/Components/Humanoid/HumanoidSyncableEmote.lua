local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HumanoidSyncableEmote"
})
local EmotesConfig = require(ReplicatedStorage.Modules.Shared.DB.Emotes.EmotesConfig)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v2 = {}

function v:SyncAnimationWithOtherPlayer()
	local syncableAnimation, v3 = self:GetSyncableAnimation()

	if not syncableAnimation then
		return
	end

	local v4 = string.match(syncableAnimation, "%d+")

	if not v4 then
		return
	end

	local emote = EmotesConfig.GetEmoteFromId(v4)

	if not emote then
		return
	end

	EmotesController.PlayEmote(emote, false, v3)
	EmotesController.PlaySyncableEmote(emote, self.Instance.Parent.Name)
end

function v:GetSyncableAnimation()
	local playingAnimationTracks = self.Instance:WaitForChild("Animator"):GetPlayingAnimationTracks()

	for _, playingAnimationTrack in playingAnimationTracks do
		local animationId = playingAnimationTrack.Animation.AnimationId
		local length = playingAnimationTrack.Length
		local v3 = string.match(animationId, "%d+")
		local isSyncable = EmotesConfig.GetIsSyncableFromId(v3)
		self.hasSyncableAnimation = isSyncable

		if not isSyncable then
			continue
		end

		self.animationId = animationId
		self.animationTime = playingAnimationTrack.TimePosition
		self.animationLength = length
		break
	end

	return self.animationId, self.animationTime, self.animationLength
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.startedTime = os.time()
	local localPlayer = Players.LocalPlayer
	self.animator = self.Instance:WaitForChild("Animator")
	v2[self.Instance.Parent.Name] = self

	if self.Instance.Parent.Name == localPlayer.Name then
		return
	end

	local syncablePlayerName = self.Instance:GetAttribute("SyncablePlayerName")

	if not syncablePlayerName then
		return
	end

	task.defer(function()
		local v3 = v2[syncablePlayerName]

		if not v3 then
			return
		end

		local syncableAnimation, timePosition = v3:GetSyncableAnimation()

		if not syncableAnimation then
			return
		end

		local v5 = string.match(syncableAnimation, "%d+")

		if not EmotesConfig.GetEmoteFromId(v5) then
			return
		end

		local playingAnimationTracks = self.animator:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in playingAnimationTracks do
			if playingAnimationTrack.Animation.AnimationId == syncableAnimation then
				playingAnimationTrack.TimePosition = timePosition
			end
		end
	end)
end

function v:Stop()
	if self.Instance.Parent.Name == Players.LocalPlayer.Name then
		local timeActive = os.time() - self.startedTime
		local syncableAnimation, v4, animationLength = self:GetSyncableAnimation()

		if syncableAnimation and v4 then
			local v6 = string.match(syncableAnimation, "%d+")
			local emote = EmotesConfig.GetEmoteFromId(v6)

			if emote then
				TelemetryController.SendClientInteraction("emoteLoopedTime", {
					emoteName = emote.Name,
					timeActive = timeActive,
					animationLength = animationLength
				})
			end
		end
	end

	v2[self.Instance.Parent.Name] = nil
	self._Janitor:Destroy()
end

return v