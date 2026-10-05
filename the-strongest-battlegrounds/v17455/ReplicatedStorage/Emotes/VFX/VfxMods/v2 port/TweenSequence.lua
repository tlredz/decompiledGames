local RunService = game:GetService("RunService")
local TweenSequence = {}
TweenSequence.__index = TweenSequence

local function evalNumberSequence(sequence, p: number)
	local keypoints = sequence.Keypoints
	local count = #keypoints

	if count == 0 then
		return 1
	end

	if p <= keypoints[1].Time then
		return keypoints[1].Value
	end

	if keypoints[count].Time <= p then
		return keypoints[count].Value
	end

	for i = 1, count - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v
	end

	return keypoints[count].Value
end

function TweenSequence.new(model, sequence, value: number?, flag: boolean?, value2: number?)
	assert(model and model:IsA("Model"), "ModelSequenceScaler.new: 'model' must be a Model")
	assert(typeof(sequence) == "NumberSequence", "ModelSequenceScaler.new: 'sequence' must be a NumberSequence")
	local object = setmetatable({}, TweenSequence)
	object.Model = model
	object.Sequence = sequence
	object.Duration = value or 1
	object.Loop = flag == nil or flag
	object.BaseScale = value2 or 1
	object._running = false
	object._t = 0
	object._conn = nil
	return object
end

function TweenSequence.fromAttribute(instance, attributeName: string, p: number?, flag: boolean?, p2: number?)
	local attribute = instance:GetAttribute(attributeName)
	assert(
		typeof(attribute) == "NumberSequence",
		("ModelSequenceScaler.fromAttribute: Attribute '%s' must be a NumberSequence"):format(attributeName)
	)
	return TweenSequence.new(instance, attribute, p, flag, p2)
end

function TweenSequence:Start()
	if self._running then
		return
	end

	self._running = true
	self._t = 0
	self._conn = RunService.Heartbeat:Connect(function(dt: number)
		if not self._running then
			return
		end

		if not (self.Model and self.Model.Parent) then
			self:Stop()
			return
		end

		if self.Duration <= 0 then
			self.Duration = 0.001
		end

		self._t += dt / self.Duration
		local _t = self._t

		if _t >= 1 then
			if self.Loop then
				_t %= 1
				self._t = _t
			else
				self._running = false
				_t = 1
			end
		end

		local v2 = evalNumberSequence(self.Sequence, math.clamp(_t, 0, 1))
		local v3 = self.BaseScale * v2
		local success, result = pcall(function()
			self.Model:ScaleTo((math.clamp(v3, 0.001, 1e999)))
		end)

		if not success then
			warn("[ModelSequenceScaler] ScaleTo failed: ", result)
			self:Stop()
		end

		if not self._running and self._conn then
			self._conn:Disconnect()
			self._conn = nil
		end
	end)
end

function TweenSequence:Stop()
	self._running = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end
end

function TweenSequence:SetSequence(sequence)
	assert(typeof(sequence) == "NumberSequence", "SetSequence: seq must be a NumberSequence")
	self.Sequence = sequence
end

function TweenSequence:SetDuration(duration: number)
	self.Duration = duration
end

return TweenSequence