local NumSeqMap = {
	__type = "NumSeqMap"
}
NumSeqMap.__index = NumSeqMap

function NumSeqMap.new(sequence, value)
	local object = setmetatable({}, NumSeqMap)
	object._mapSize = value or 20
	object._map = {}
	local keypoints = sequence.Keypoints

	if #keypoints == 2 then
		object._mapSize = 1
	end

	object._map[0] = keypoints[1].Value
	object._map[object._mapSize] = keypoints[#keypoints].Value
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
		object._map[i] = keypoint2.Value + (keypoint.Value - keypoint2.Value) * (v2 - keypoint2.Time) / (keypoint.Time - keypoint2.Time)
	end

	return object
end

function NumSeqMap:GetValue(p)
	local v = math.floor(p * self._mapSize)
	local v2 = math.min(self._mapSize, v + 1)
	return self._map[v] + (self._map[v2] - self._map[v]) * (p - v * self._samplingInterval) * self._mapSize
end

return NumSeqMap