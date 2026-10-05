local RunService = game:GetService("RunService")
local v = {}

local function SyncAnimators(object, animator)
	local function syncAnimation(data)
		if not (data.Animation and data.IsPlaying) then
			return
		end

		local track = animator:LoadAnimation(data.Animation)
		track.Looped = data.Looped
		track.Priority = data.Priority
		track:Play()
		track:AdjustSpeed(data.Speed)
		track.TimePosition = data.TimePosition
		v[track] = data
	end

	for _, v2 in object:GetPlayingAnimationTracks() do
		task.spawn(syncAnimation, v2)
	end

	local animationPlayedConnection = object.AnimationPlayed:Connect(syncAnimation)
	return function()
		for _, v2 in animator:GetPlayingAnimationTracks() do
			v2:Stop()
		end

		animationPlayedConnection:Disconnect()
	end
end

RunService.Heartbeat:Connect(function(_)
	for k, v2 in v do
		if k.IsPlaying then
			if v2.IsPlaying then
				k.Looped = v2.Looped
				k.Priority = v2.Priority
				k:AdjustSpeed(k.Speed)
				k:AdjustWeight(k.WeightTarget, 0.1)
				k.TimePosition = v2.TimePosition
			elseif k.IsPlaying then
				k:Stop()
			end
		else
			v[k] = nil
		end
	end
end)
return SyncAnimators