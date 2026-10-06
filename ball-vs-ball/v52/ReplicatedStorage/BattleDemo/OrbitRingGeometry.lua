local OrbitRingGeometry = {
	RING_COUNT = 4,
	radiusForRing = function(p, p2: number)
		return (p.radiusBase or 0) + (p2 - 1) * (p.radiusStep or 0)
	end,
	periodForRing = function(p, p2: number)
		return (math.max((p.periodBase or 0) + (p2 - 1) * (p.periodStep or 0), 1e-6))
	end
}

function OrbitRingGeometry.angularSpeedForRing(p, p2: number)
	return 6.283185307179586 / OrbitRingGeometry.periodForRing(p, p2)
end

function OrbitRingGeometry.spinForRing(p: number)
	if p % 2 == 1 then
		return 1
	end

	return -1
end

function OrbitRingGeometry.capacityForRing(p, p2: number)
	return (math.max(0, (math.floor(tonumber(p["ring" .. p2 .. "Capacity"]) or 0))))
end

return OrbitRingGeometry