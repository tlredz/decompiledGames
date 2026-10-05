local SoulvesterGuardCameraCore = {}

function SoulvesterGuardCameraCore.portraitTransit(p: number, p2: number)
	local v = math.clamp(p / math.max(p2, 1e-6), 0, 1)
	return v * v * (3 - v * 2)
end

function SoulvesterGuardCameraCore.heroAnglePenalty(p: number, p2: number, p3: number)
	return math.abs(p - p2) * p3
end

return SoulvesterGuardCameraCore