local BodyFacingModel = {}

local function wrap(p)
	return (math.atan2(math.sin(p), (math.cos(p))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yaw(p)
	return (math.atan2(-p.X, -p.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - 2 * v)
end

function BodyFacingModel.angle(p, p2)
	if p.Magnitude < 0.001 or p2.Magnitude < 0.001 then
		return 0
	end

	return (math.deg((math.acos((math.clamp(p.Unit:Dot(p2.Unit), -1, 1))))))
end

function BodyFacingModel.speedMultiplier(p, p2, data)
	if not (data.Enabled and data.SpeedPenaltyEnabled) then
		return 1
	end

	local angle = BodyFacingModel.angle(p, p2)
	local v = math.clamp(data.SideSpeedMultiplier, 0.1, 1)
	local v2 = math.clamp(data.BackSpeedMultiplier, 0.1, v)

	if angle <= 90 then
		return 1 + (v - 1) * smooth((angle - data.SlowdownStartsAt) / math.max(1, 90 - data.SlowdownStartsAt))
	else
		return v + (v2 - v) * smooth((angle - 90) / 90)
	end
end

function BodyFacingModel:step(data, p2, value, value2, data2)
	local v = yaw(p2) -- equivalent call inferred; original call site unknown
	local v2 = data.Magnitude >= data2.MovementThreshold
	local v3

	if v2 then
		local v4 = math.atan2(-data.X, -data.Z) - v
		v3 = math.atan2(math.sin(v4), (math.cos(v4))) or 0
	else
		v3 = 0
	end

	local maxTravelYaw = math.rad(data2.MaxTravelYaw)

	if math.abs(v3) > 1.5707963267948966 then
		local v4 = math.sign(v3)
		local v5 = math.abs(v3)
		v3 = v4 * (3.141592653589793 - v5)
	end

	local v4 = v + math.clamp(v3, -maxTravelYaw, maxTravelYaw)
	local bodyFollowRate = v2 and data2.BodyFollowRate or data2.IdleFollowRate
	self.worldYaw = self.worldYaw or v
	local worldYaw = self.worldYaw
	local v5 = v4 - self.worldYaw
	self.worldYaw = worldYaw + math.atan2(math.sin(v5), (math.cos(v5))) * (1 - math.exp(-bodyFollowRate * math.clamp(
		value2,
		0,
		0.1
	)))
	local v6 = self.worldYaw - v
	local v7 = math.clamp(math.atan2(math.sin(v6), (math.cos(v6))), -maxTravelYaw, maxTravelYaw)
	self.worldYaw = v + v7
	local hip = math.clamp(v7 * data2.TorsoLookShare, -math.rad(data2.MaxHipTwist), (math.rad(data2.MaxHipTwist)))
	local torso = v7 - hip
	return {
		torso = torso,
		hip = hip,
		head = math.clamp(-torso, -math.rad(data2.MaxHeadYaw), (math.rad(data2.MaxHeadYaw))),
		pitch = math.clamp(value, -math.rad(data2.MaxHeadPitch), (math.rad(data2.MaxHeadPitch))),
		angle = math.deg((math.abs(v3))),
		gait = not v2 and "Idle" or math.abs(v3) > 1.5707963267948966 and "Backward" or "Forward"
	}
end

return BodyFacingModel