local StunCore = {
	ATTRIBUTE = "StunnedUntil",
	TAG = "StunLook",
	extend = function(p: number?, p2: number, p3: number)
		if not (p and p2 < p) then
			p = p2
		end

		return (math.max(p, p2 + math.max(p3, 0)))
	end,
	remaining = function(p: number?, p2: number)
		if p then
			return (math.max(p - p2, 0))
		end

		return 0
	end
}

function StunCore.isActive(p: number?, p2: number)
	return StunCore.remaining(p, p2) > 0
end

function StunCore.fade(p: number, p2: number, p3: number, p4: number)
	return (math.min(not (p3 > 0) and 1 or math.clamp(p / p3, 0, 1), not (p4 > 0) and 1 or math.clamp(p2 / p4, 0, 1)))
end

function StunCore.orbitOffset(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number)
	local v = p3 * p5 + (p - 1) * (6.283185307179586 / p2)
	return math.cos(v) * p4, math.sin(p3 * p7 + p * 2.1) * p6, math.sin(v) * p4
end

function StunCore.ringRadius(p: number)
	return (math.clamp(p * 0.6, 1, 3))
end

return StunCore