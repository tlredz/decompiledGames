local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

return function(data)
	local emitter = data.Emitter
	local scale = data.Scale
	local time = data.Time
	local easingDirection = data.EasingDirection or Enum.EasingDirection.Out
	local easingStyle = data.EasingStyle or Enum.EasingStyle.Quad
	local keypoints = emitter.Size.Keypoints

	for i = 1, #keypoints do
		keypoints[i] = NumberSequenceKeypoint.new(keypoints[i].Time, keypoints[i].Value, keypoints[i].Envelope)
	end

	local speed = emitter.Speed
	local acceleration = emitter.Acceleration

	if time <= 0 then
		local keypoints2 = emitter.Size.Keypoints

		for i = 1, #keypoints2 do
			keypoints2[i] = NumberSequenceKeypoint.new(
				keypoints2[i].Time,
				keypoints[i].Value * scale,
				keypoints2[i].Envelope
			)
		end

		emitter.Speed = NumberRange.new(speed.Min * scale, speed.Max * scale)
		emitter.Acceleration = acceleration * scale
		emitter.Size = NumberSequence.new(keypoints2)
	else
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1
		local tween = TweenService:Create(numberValue, TweenInfo.new(time, easingStyle, easingDirection), {
			Value = scale
		})
		tween:Play()
		local v = true
		task.spawn(function()
			tween.Completed:Wait()
			numberValue:Destroy()
			v = false
		end)
		resume(create(function()
			while v and numberValue do
				local keypoints2 = emitter.Size.Keypoints

				for i = 1, #keypoints2 do
					keypoints2[i] = NumberSequenceKeypoint.new(
						keypoints2[i].Time,
						keypoints[i].Value * numberValue.Value,
						keypoints2[i].Envelope
					)
				end

				local emitter2 = emitter
				local speed2 = speed
				local value = numberValue.Value
				emitter2.Speed = NumberRange.new(speed2.Min * value, speed2.Max * value)
				emitter.Acceleration = acceleration * numberValue.Value
				emitter.Size = NumberSequence.new(keypoints2)
				task.wait()
			end
		end))
		return function()
			v = false
		end
	end
end