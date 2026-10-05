local VerletSim = {
	SUBSTEP = 0.016666666666666666,
	MAX_SUBSTEPS = 3
}

local function windAccel(p, _windAmp, p2, _windSeedA, _windSeedB)
	local v = p * 3 - p2
	local v2 = p * 8.1 - p2 * 1.6
	return (Vector3.new(
		(math.noise(v, _windSeedA) + 0.5 * math.noise(v2, _windSeedA + 37.1)) * _windAmp,
		0,
		(math.noise(v, _windSeedB) + 0.5 * math.noise(v2, _windSeedB + 37.1)) * _windAmp
	))
end

function VerletSim:step(list2, p, state, lastH, p2)
	local _lastH = state._lastH or lastH
	state._lastH = lastH
	local v = 1 - (state._damping or 0)

	if lastH ~= VerletSim.SUBSTEP and v < 1 and v > 0 then
		v ^= lastH / VerletSim.SUBSTEP
	end

	local v2 = v * (lastH / _lastH)
	local _gravity = state._gravity
	local _windAmp = state._windAmp or 0
	local pinStart = state._pinStart ~= false
	local _pinEnd = state._pinEnd

	for i = pinStart and 2 or 1, _pinEnd and p or p + 1 do
		local v3 = self[i]
		local v4

		if _windAmp == 0 then
			v4 = _gravity
		else
			v4 = _gravity + windAccel((i - 1) / p, _windAmp, p2, state._windSeedA, state._windSeedB)
		end

		self[i] = v3 + (v3 - list2[i]) * v2 + v4 * (lastH * lastH)
		list2[i] = v3
	end

	local _restLenEff = state._restLenEff or state._restLen
	local _bendStiffness = state._bendStiffness or 0

	for _ = 1, state._stiffness or 4 do
		for i = 1, p do
			local v3 = self[i]
			local v4 = self[i + 1]
			local v5 = v4 - v3
			local magnitude = v5.Magnitude

			if not (magnitude > 1e-6) then
				continue
			end

			local v6 = v5 * ((magnitude - _restLenEff) / magnitude)
			local v7 = pinStart and i == 1
			local v8 = _pinEnd and i + 1 == p + 1

			if v7 then
				if not v8 then
					self[i + 1] = v4 - v6
				end
			elseif v8 then
				self[i] = v3 + v6
			else
				local v9 = v6 * 0.5
				self[i] = v3 + v9
				self[i + 1] = v4 - v9
			end
		end

		if not (_bendStiffness > 0) then
			continue
		end

		local v3 = _bendStiffness * 0.5

		for i = 2, p do
			local v4 = (self[i - 1] + self[i + 1]) * 0.5
			self[i] += (v4 - self[i]) * v3
		end
	end
end

function VerletSim:translate(list2, p, p2)
	for i = 1, p + 1 do
		self[i] += p2
		list2[i] += p2
	end
end

function VerletSim.calm(list, list2, p)
	for i = 1, p + 1 do
		list2[i] = list[i]
	end
end

return VerletSim