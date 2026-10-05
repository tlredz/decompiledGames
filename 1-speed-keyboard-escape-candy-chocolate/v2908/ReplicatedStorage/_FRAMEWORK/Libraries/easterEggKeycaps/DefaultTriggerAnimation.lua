return {
	apply = function(p, cframe: CFrame, value: number, p2: number, p3: number, data)
		local v = math.clamp(value, 0, 1)
		local v2 = p2 * (data.baseFrequencyHz + data.frequencyGainHz * v) * 3.141592653589793 * 2 + p3
		local v3 = data.maxPositionStuds * v
		local v4 = data.maxRotationRadians * v
		local v5 = math.sin(v2) * v3
		local v6 = math.sin(v2 * 1.37 + 1.2) * v3 * 0.55
		local v7 = math.sin(v2 * 1.71 + 0.4) * v4 * 0.6
		local v8 = math.sin(v2 * 1.19 + 2.1) * v4
		p.CFrame = cframe * CFrame.new(v5, 0, v6) * CFrame.Angles(v7, 0, v8)
	end
}