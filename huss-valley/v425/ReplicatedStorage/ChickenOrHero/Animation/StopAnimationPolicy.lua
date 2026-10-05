-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - 2 * v)
end

local StopAnimationPolicy = {}

function StopAnimationPolicy.new()
	return {
		runTime = 0,
		mode = nil,
		lastPlayedAt = -1e999
	}
end

function StopAnimationPolicy:step(data, value, data2, p)
	local v

	if data.mode == "Braking" then
		v = self.mode ~= "Braking"
	else
		v = false
	end

	self.mode = data.mode
	local runTime = self.runTime
	local v2 = p.MaxSpeed * data2.EntrySpeedRatio
	local v3 = math.abs(data.angle) <= 90.5

	if not (data2.Enabled and data.allowed) then
		self.runTime = 0
	elseif v then
		self.runTime = 0
		local v4 = math.min(data.entrySpeed or 0, p.MaxSpeed)
		local clipEnd = math.min(data2.ClipEnd, data.clipLength or 0)
		local v6 = v4 / math.max(p.Deceleration, 0.01)

		if runTime + 1e-6 < data2.HoldTime or v4 < v2 or not v3 or clipEnd <= 0 or v6 < data2.MinBrakeTime or data.now - self.lastPlayedAt < data2.RetriggerDelay then
			return
		end

		self.lastPlayedAt = data.now
		local v7 = smooth((v4 / p.MaxSpeed - data2.EntrySpeedRatio) / math.max(1 - data2.EntrySpeedRatio, 0.01)) -- equivalent call inferred; original call site unknown
		return {
			duration = math.clamp(v6, clipEnd / data2.MaxPlaybackRate, clipEnd / data2.MinPlaybackRate),
			clipEnd = clipEnd,
			weight = data2.MinWeight + (1 - data2.MinWeight) * v7
		}
	elseif (data.mode == "Running" or data.mode == "Accelerating") and v2 <= data.speed and v3 then
		self.runTime = math.min(data2.HoldTime, runTime + math.clamp(value, 0, 0.1))
	else
		self.runTime = 0
	end
end

return StopAnimationPolicy