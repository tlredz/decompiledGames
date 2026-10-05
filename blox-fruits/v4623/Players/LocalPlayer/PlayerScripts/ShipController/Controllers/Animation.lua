local Animation = {}

function Animation.register(boat)
	local v = {
		Boat = boat,
		AnimationController = nil,
		Cache = {}
	}

	for _, descendant in pairs(v.Boat:GetDescendants()) do
		if descendant:IsA("AnimationController") then
			v.AnimationController = descendant
		elseif descendant:IsA("Animation") then
			table.insert(v.Cache, {
				Track = nil,
				Object = descendant,
				AnimationSpeed = descendant:GetAttribute("AnimationSpeed") or 1,
				SpeedInfluence = descendant:GetAttribute("SpeedInfluence"),
				DistanceInfluence = descendant:GetAttribute("DistanceInfluence")
			})
		end
	end

	return (setmetatable(v, {
		__index = Animation
	}))
end

function Animation.update(data, p: number, _: number, _: number)
	if not data.AnimationController then
		return
	end

	local distanceAlpha = data.Boat:GetAttribute("DistanceAlpha")

	for _, v in pairs(data.Cache) do
		if v.Track then
			local animationSpeed = v.AnimationSpeed

			if v.SpeedInfluence then
				animationSpeed = v.AnimationSpeed * p + v.AnimationSpeed * v.SpeedInfluence * p
			end

			if v.DistanceInfluence then
				animationSpeed *= distanceAlpha + v.DistanceInfluence * distanceAlpha * (1 - distanceAlpha)
			end

			v.Track:AdjustSpeed(animationSpeed)
		elseif not v.Track then
			v.Track = data.AnimationController:LoadAnimation(v.Object)
			local animationSpeed = v.AnimationSpeed

			if v.SpeedInfluence then
				animationSpeed = v.AnimationSpeed * p + v.AnimationSpeed * v.SpeedInfluence * p
			end

			if v.DistanceInfluence then
				animationSpeed *= distanceAlpha + v.DistanceInfluence * distanceAlpha * (1 - distanceAlpha)
			end

			v.Track:Play(nil, nil, animationSpeed)
		end
	end
end

return Animation