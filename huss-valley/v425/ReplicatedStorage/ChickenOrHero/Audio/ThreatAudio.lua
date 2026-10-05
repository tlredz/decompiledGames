local ThreatAudio = {}
ThreatAudio.__index = ThreatAudio

function ThreatAudio.new(playback, player, session, cfg)
	return (setmetatable({
		playback = playback,
		player = player,
		session = session,
		cfg = cfg,
		level = 0
	}, ThreatAudio))
end

function ThreatAudio:update(p, p2)
	local player = self.player
	local cfg = self.cfg
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local phase = self.session:GetAttribute("Phase")
	local enabled = cfg.Enabled

	if enabled then
		if player:GetAttribute("DangerAudioMuted") == true or player:GetAttribute("InMatch") ~= true or player:GetAttribute("GameRole") ~= "Runner" or player:GetAttribute("RunState") ~= "Active" then
			enabled = false
		elseif humanoid then
			if humanoid.Health > 0 then
				enabled = not character:GetAttribute("MovementLocked") and not (player:GetAttribute("ChoiceSpotlightActive") or player:GetAttribute("ScreenPresentationActive")) and not player:GetAttribute("TutorialModalActive") and (phase == "HeroRun" or phase == "GroupRun" or phase == "FinalRun")
			else
				enabled = false
			end
		else
			enabled = humanoid
		end
	end

	local v = p2 - (player:GetAttribute("CatcherThreatUpdatedAt") or -1e999) <= cfg.SampleTimeout
	local v2 = enabled and v and math.clamp(player:GetAttribute("CatcherThreatIntensity") or 0, 0, 1) or 0
	local inactiveFadeTime = not enabled and cfg.InactiveFadeTime or self.level < v2 and cfg.AttackTime or cfg.ReleaseTime
	self.level += (v2 - self.level) * (1 - math.exp(-p / math.max(0.01, inactiveFadeTime)))

	if self.level < 0.002 then
		self.level = 0
	end

	local v3 = self.level ^ 1.35
	local v4 = cfg.MinRate + (cfg.MaxRate - cfg.MinRate) * self.level
	self.playback:loop("Danger", v3 > 0.001 and "DangerPulse" or nil, nil, v3, v4)
end

function ThreatAudio:destroy()
	self.level = 0
	self.playback:loop("Danger", nil)
end

return ThreatAudio