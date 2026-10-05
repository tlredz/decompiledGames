function scaleParticle(state, p: number, flag: boolean)
	local v = {
		Size = state.Size.Keypoints,
		Speed = state.Speed,
		Acceleration = state.Acceleration
	}

	for i = 1, #v.Size do
		v.Size[i] = NumberSequenceKeypoint.new(v.Size[i].Time, v.Size[i].Value * p, v.Size[i].Envelope * p)
	end

	state.Size = NumberSequence.new(v.Size)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)

	if flag then
		state.Acceleration = Vector3.new(v.Acceleration.X * p, v.Acceleration.Y * p, v.Acceleration.Z * p)
	end
end

return scaleParticle