local ColorSeqMap = {
	__type = "ColorSeqMap"
}
ColorSeqMap.__index = ColorSeqMap

function ColorSeqMap.new(sequence, value, value2)
	local object = setmetatable({}, ColorSeqMap)
	object._mapSize = value or 10
	object._gamma = value2 or 2
	object._gammaDiv = 1 / object._gamma
	object._map = {}
	local keypoints = sequence.Keypoints

	if #keypoints == 2 then
		object._mapSize = 1
	end

	local _gamma = object._gamma
	object._map[0] = Color3.new(
		keypoints[1].Value.R ^ _gamma,
		keypoints[1].Value.G ^ _gamma,
		keypoints[1].Value.B ^ _gamma
	)
	object._map[object._mapSize] = Color3.new(
		keypoints[#keypoints].Value.R ^ _gamma,
		keypoints[#keypoints].Value.G ^ _gamma,
		keypoints[#keypoints].Value.B ^ _gamma
	)
	object._samplingInterval = 1 / object._mapSize
	local v = 2

	for i = 1, object._mapSize - 1 do
		local v2 = i * object._samplingInterval

		if keypoints[v].Time < v2 then
			for i2 = v + 1, #keypoints do
				if not (v2 < keypoints[i2].Time) then
					continue
				end

				v = i2
				break
			end
		end

		local keypoint = keypoints[v]
		local keypoint2 = keypoints[v - 1]
		object._map[i] = object:_interpColorExponent(
			keypoint2.Value,
			keypoint.Value,
			(v2 - keypoint2.Time) / (keypoint.Time - keypoint2.Time)
		)
	end

	return object
end

function ColorSeqMap:_interpColorExponent(data, data2, p2)
	local _gamma = self._gamma
	return (Color3.new(data.R ^ _gamma, data.G ^ _gamma, data.B ^ _gamma):Lerp(
		Color3.new(data2.R ^ _gamma, data2.G ^ _gamma, data2.B ^ _gamma),
		p2
	))
end

function ColorSeqMap:_interpColor(p2, p3, p4)
	local _gammaDiv = self._gammaDiv
	local lerped = p2:Lerp(p3, p4)
	return Color3.new(lerped.R ^ _gammaDiv, lerped.G ^ _gammaDiv, lerped.B ^ _gammaDiv)
end

function ColorSeqMap:GetValue(p)
	local v = math.floor(p * self._mapSize)
	local v2 = math.min(self._mapSize, v + 1)
	return self:_interpColor(self._map[v], self._map[v2], (p - v * self._samplingInterval) * self._mapSize)
end

return ColorSeqMap