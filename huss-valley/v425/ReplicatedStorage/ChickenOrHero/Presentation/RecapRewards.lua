local ProgressionMath = require(script.Parent.Parent.Progression.ProgressionMath)
local RecapRewards = {}
RecapRewards.__index = RecapRewards

function RecapRewards.new(frame, cfg, cue, player)
	return (setmetatable({
		frame = frame,
		cfg = cfg,
		cue = cue,
		player = player
	}, RecapRewards))
end

function RecapRewards:show(row, p)
	self.active = true
	self.row = row
	self.started = p + self.cfg.CountDelay
	self.lastTick = -1e999
	self.lastEarned = 0
	self.completed = false
	self.levelCue = false
	self.frame.LevelUp.Visible = false
	self:update(p)
end

function RecapRewards:update(lastTick)
	if not self.active then
		return
	end

	local row = self.row
	local frame = self.frame
	local v = math.clamp((lastTick - self.started) / self.cfg.CountDuration, 0, 1)
	local v2 = 1 - (1 - v) ^ 3
	local v3 = math.round((not row and 0 or row.crossingXP or 0) * v2)
	local v4 = math.round((not row and 0 or row.catchXP or 0) * v2)
	local v5 = math.round((not row and 0 or row.winXP or 0) * v2)
	local v6 = math.round((not row and 0 or row.bonusXP or 0) * v2)
	local lastEarned = v3 + v4 + v5 + v6
	frame.Amount.Text = not row and "READY FOR THE NEXT MATCH" or "YOU EARNED +" .. lastEarned .. " XP" or "READY FOR THE NEXT MATCH"
	local v8 = {}

	if row then
		if row.crossingXP > 0 then
			table.insert(v8, "Crossings +" .. v3)
		end

		if row.catchXP > 0 then
			table.insert(v8, "Catches +" .. v4)
		end

		if row.winXP > 0 then
			table.insert(v8, "Win +" .. v5)
		end

		if (row.bonusXP or 0) > 0 then
			table.insert(v8, "Bonus +" .. v6)
		end
	end

	frame.Breakdown.Text = table.concat(v8, "  ·  ")
	local xpBefore = row and row.xpBefore

	if xpBefore == nil and self.player:GetAttribute("StatsLoaded") == true then
		xpBefore = math.max(0, (self.player:GetAttribute("TotalXP") or 0) - (row and row.earnedXP or 0))
	end

	local v9 = false
	frame.Track.Visible = xpBefore ~= nil

	if xpBefore == nil then
		frame.Level.Text = ""
		frame.Progress.Text = "PROGRESS SYNCING"
	else
		local state2 = ProgressionMath.state(xpBefore)
		local state3 = ProgressionMath.state(xpBefore + lastEarned)
		frame.Level.Text = "LVL " .. state3.level
		frame.Progress.Text = ("%d / %d XP"):format(state3.earned, state3.needed)
		frame.Track.Fill.Size = UDim2.fromScale(state3.ratio, 1)
		v9 = state3.level > state2.level
		frame.Level.TextColor3 = v9 and Color3.fromRGB(255, 205, 112) or Color3.fromRGB(233, 243, 247)
	end

	if v > 0 and v < 1 and lastEarned ~= self.lastEarned and lastTick - self.lastTick >= self.cfg.CountTickInterval then
		self.cue("RecapTick", v2 * 0.3 + 0.92)
		self.lastTick = lastTick
	end

	self.lastEarned = lastEarned

	if v >= 1 then
		if v9 and not self.levelCue then
			self.levelCue = true
			frame.LevelUp.Visible = true
			self.cue("RecapLevelUp")
		end

		if not self.completed then
			self.completed = true

			if lastEarned > 0 and not v9 then
				self.cue("RecapComplete")
			end
		end
	end
end

function RecapRewards:hide()
	self.active = false
end

function RecapRewards:destroy()
	self:hide()
end

return RecapRewards