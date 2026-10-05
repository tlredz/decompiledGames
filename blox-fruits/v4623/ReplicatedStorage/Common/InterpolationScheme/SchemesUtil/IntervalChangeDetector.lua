local IntervalChangeDetector = {
	__type = "IntervalChangeDetector"
}
IntervalChangeDetector.__index = IntervalChangeDetector

function IntervalChangeDetector.new(sequence)
	local object = setmetatable({}, IntervalChangeDetector)
	object._keypoints = sequence.Keypoints
	object._numKeypoints = #object._keypoints
	object._lastLowerKeypointIndex = 1
	object.lowerKeypointIndex = 1
	object.lowerKeypoint = object._keypoints[object.lowerKeypointIndex]
	return object
end

function IntervalChangeDetector:TimeUpdate(p)
	self._lastLowerKeypointIndex = self.lowerKeypointIndex

	for i = self._numKeypoints - 1, self.lowerKeypointIndex + 1, -1 do
		local _keypoint = self._keypoints[i]

		if not (_keypoint.Time < p) then
			continue
		end

		self.lowerKeypointIndex = i
		self.lowerKeypoint = _keypoint
		break
	end
end

function IntervalChangeDetector:PrevTimeUpdateChangedInterval()
	return self._lastLowerKeypointIndex ~= self.lowerKeypointIndex
end

return IntervalChangeDetector