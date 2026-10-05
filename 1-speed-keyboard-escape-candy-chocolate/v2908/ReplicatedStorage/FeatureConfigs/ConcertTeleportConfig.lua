local RunService = game:GetService("RunService")
local ConcertTeleportConfig = {
	ENABLED = true,
	STUDIO_TEST = RunService:IsStudio(),
	EVENT_TIMESTAMP = DateTime.fromUniversalTime(2026, 7, 25, 18, 0, 0).UnixTimestamp,
	WORLD_INDEX = 4,
	OPEN_OFFSET = 21600,
	JOIN_PROMPT_DELAY_MIN = 30,
	JOIN_PROMPT_DELAY_MAX = 180,
	REPROMPT_INTERVAL = 300,
	CLOSE_TIMESTAMP = DateTime.fromUniversalTime(2026, 8, 1, 18, 0, 0).UnixTimestamp,
	BATCH_WINDOW = 3,
	MAX_BATCH_SIZE = 50,
	RETRY_ATTEMPTS = 2,
	RETRY_DELAY = 2,
	GetOpenTime = function(self)
		return self.EVENT_TIMESTAMP - self.OPEN_OFFSET
	end,
	IsWindowOpen = function(self, p: number)
		if not self.ENABLED then
			return false
		end

		if self.STUDIO_TEST then
			return true
		end

		return self:GetOpenTime() <= p and p < self.CLOSE_TIMESTAMP
	end
}

if ConcertTeleportConfig.STUDIO_TEST then
	ConcertTeleportConfig.EVENT_TIMESTAMP = os.time() + 90
	ConcertTeleportConfig.REPROMPT_INTERVAL = 30
end

return ConcertTeleportConfig