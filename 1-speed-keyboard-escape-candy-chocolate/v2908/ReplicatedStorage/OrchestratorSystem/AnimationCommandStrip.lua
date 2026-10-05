local RunService = game:GetService("RunService")
require(script.Parent.OrchestratorState)

local function CaptureStudioPose(folder)
	local transformsByDescendant = {}
	local transformsByDescendant2 = {}
	local transformsByDescendant3 = {}

	if RunService:IsRunning() or not folder then
		return transformsByDescendant, transformsByDescendant2, transformsByDescendant3
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Motor6D") then
			transformsByDescendant[descendant] = descendant.Transform
		elseif descendant:IsA("Bone") then
			transformsByDescendant2[descendant] = descendant.Transform
		elseif descendant:IsA("AnimationConstraint") then
			transformsByDescendant3[descendant] = descendant.Transform
		end
	end

	return transformsByDescendant, transformsByDescendant2, transformsByDescendant3
end

local function RestoreStudioPose(data)
	if RunService:IsRunning() then
		return
	end

	pcall(data.Animator.StepAnimations, data.Animator, 0)

	for k in data.MotorTransforms do
		if k.Parent then
			k.Transform = CFrame.identity
		end
	end

	for k in data.BoneTransforms do
		if k.Parent then
			k.Transform = CFrame.identity
		end
	end

	for k in data.ConstraintTransforms do
		if k.Parent then
			k.Transform = CFrame.identity
		end
	end
end

local function NormalizeAnimationId(animationId)
	local v

	if type(animationId) == "number" then
		if animationId ~= animationId or animationId <= 0 or animationId % 1 ~= 0 or math.abs(animationId) == 1e999 then
			return nil, "Animation ID must be a positive integer."
		end

		v = string.format("%.0f", animationId)
	elseif type(animationId) == "string" then
		v = string.match(animationId, "^%s*rbxassetid://(%d+)%s*$") or string.match(animationId, "^%s*(%d+)%s*$")
	else
		return nil, "Animation ID must be a number or rbxassetid string."
	end

	if v and string.find(v, "[1-9]") then
		return `rbxassetid://{v}`, nil
	end

	return nil, "Animation ID must be a positive integer."
end

local function FindActiveCommand(keyframes, timePosition: number)
	local count = #keyframes
	local v = 1
	local v2 = nil

	while v <= count do
		local v3 = math.floor((v + count) / 2)

		if keyframes[v3].Time <= timePosition then
			v = v3 + 1
			v2 = v3
		else
			count = v3 - 1
		end
	end

	if v2 then
		return v2, keyframes[v2]
	end

	return v2, nil
end

local function StopOwnedTrack(state)
	local studioLoadConnection = state.StudioLoadConnection

	if studioLoadConnection then
		studioLoadConnection:Disconnect()
		state.StudioLoadConnection = nil
	end

	state.StudioDesiredElapsed = nil
	local track = state.Track

	if track then
		pcall(track.Stop, track, 0)
		pcall(track.Destroy, track)
		state.Track = nil
	end

	local animation = state.Animation

	if animation then
		pcall(animation.Destroy, animation)
		state.Animation = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopEveryTrack(p)
	for _, v in p.Animator:GetPlayingAnimationTracks() do
		v:Stop(0)
	end

	StopOwnedTrack(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDesiredTrackTime(p, p2: number)
	local length = p.Length

	if length <= 0 then
		return nil
	end

	if p.Looped then
		return p2 % length
	end

	return (math.min(p2, (math.max(length - 0.0001, 0))))
end

local function GetTrackDrift(data, p: number)
	local v = math.abs(data.TimePosition - p)

	if data.Looped and data.Length > 0 then
		return (math.min(v, (math.max(data.Length - v, 0))))
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SynchronizeTrack(state, p: number, flag: boolean)
	if not state.IsPlaying then
		return
	end

	local timePosition = GetDesiredTrackTime(state, p) -- equivalent call inferred; original call site unknown

	if timePosition then
		if flag then
			state.TimePosition = timePosition
		else
			local v2 = math.abs(state.TimePosition - timePosition)

			if state.Looped and state.Length > 0 then
				v2 = math.min(v2, (math.max(state.Length - v2, 0)))
			end

			if v2 > 0.3 then
				state.TimePosition = timePosition
			end
		end
	end
end

return {
	Create = function(data)
		local v = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RestoreStudioPoseNextFrame(p, p2)
			if RunService:IsRunning() then
				return
			end

			RunService.Heartbeat:Once(function()
				if v[p] ~= nil then
					return
				end

				RestoreStudioPose(p2)
			end)
		end

		local function CleanupRecord(p)
			local v2 = v[p]

			if not v2 then
				return
			end

			v[p] = nil
			StopOwnedTrack(v2)
			local ancestryConnection = v2.AncestryConnection

			if ancestryConnection then
				ancestryConnection:Disconnect()
			end

			local animatorAncestryConnection = v2.AnimatorAncestryConnection

			if animatorAncestryConnection then
				animatorAncestryConnection:Disconnect()
			end

			RestoreStudioPose(v2)
			RestoreStudioPoseNextFrame(p, v2) -- equivalent call inferred; original call site unknown
		end

		local function GetRecord(target)
			local animator = data.ResolveAnimator(target)
			assert(animator, (`{data.Type} requires an existing Animator.`))
			local v2 = v[target]

			if v2 and v2.Animator ~= animator then
				CleanupRecord(target)
				v2 = nil
			end

			if v2 then
				return v2
			end

			local motorTransforms, boneTransforms, constraintTransforms = CaptureStudioPose(data.ResolveRig(target))
			v2 = {
				Animator = animator,
				CommandKey = nil,
				Track = nil,
				Animation = nil,
				AncestryConnection = nil,
				AnimatorAncestryConnection = nil,
				StudioLoadConnection = nil,
				LastStudioTime = nil,
				StudioDesiredElapsed = nil,
				MotorTransforms = motorTransforms,
				BoneTransforms = boneTransforms,
				ConstraintTransforms = constraintTransforms
			}
			v[target] = v2
			v2.AncestryConnection = target.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					CleanupRecord(target)
				end
			end)
			v2.AnimatorAncestryConnection = animator.AncestryChanged:Connect(function()
				if data.ResolveAnimator(target) ~= animator then
					CleanupRecord(target)
				end
			end)
			return v2
		end

		local function WatchStudioTrackLoad(target, state, track)
			if RunService:IsRunning() or track.Length > 0 then
				return
			end

			local studioLoadConnection = state.StudioLoadConnection

			if studioLoadConnection then
				studioLoadConnection:Disconnect()
			end

			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if v[target] == state and state.Track == track then
					state.Animator:StepAnimations(0)

					if track.Length <= 0 then
						return
					end

					local studioDesiredElapsed = state.StudioDesiredElapsed or 0
					SynchronizeTrack(track, studioDesiredElapsed, true) -- equivalent call inferred; original call site unknown
					state.Animator:StepAnimations(0)

					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end

					state.StudioLoadConnection = nil
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
			end)
			state.StudioLoadConnection = heartbeatConnection
		end

		return {
			Type = data.Type,
			DisplayName = data.DisplayName or "Animation",
			HasKeyframeEasing = false,
			EditableProperties = {
				{
					Path = { "Value", "Mode" },
					DisplayName = "Mode",
					ValueType = "enum",
					Default = "STOP",
					Options = { "PLAY", "STOP" }
				},
				{
					Path = { "Value", "AnimationId" },
					DisplayName = "Animation ID",
					ValueType = "string",
					Default = ""
				}
			},
			Supports = data.Supports,
			ValidateKeyframe = function(p)
				local value = p.Value

				if type(value) ~= "table" then
					return false, (`{data.Type} keyframes must contain a command table.`)
				end

				if value.Mode == "STOP" then
					return true, nil
				end

				if value.Mode ~= "PLAY" then
					return false, (`{data.Type} Mode must be PLAY or STOP.`)
				end

				local _, v2 = NormalizeAnimationId(value.AnimationId)
				return v2 == nil, v2
			end,
			Capture = function(_)
				return {
					Mode = "STOP"
				}
			end,
			Evaluate = function(data2)
				local isRunning = RunService:IsRunning()

				if isRunning and data2.IsServer then
					return
				end

				local target = data2.Target
				local record = GetRecord(target)
				local lastStudioTime = record.LastStudioTime
				local v3 = (isRunning or lastStudioTime == nil) and 0 or data2.TimePosition - lastStudioTime

				if not isRunning then
					record.LastStudioTime = data2.TimePosition
				end

				local v4, v5 = FindActiveCommand(data2.Strip.Keyframes, data2.TimePosition)

				if v4 and v5 then
					local value = v5.Value

					if value.Mode == "STOP" then
						local formatted = `{v4}:STOP`

						if record.CommandKey ~= formatted or isRunning and data2.IsSeeking then
							StopEveryTrack(record) -- equivalent call inferred; original call site unknown
							record.CommandKey = formatted
							RestoreStudioPose(record)
						end
					else
						local animationId, v7 = NormalizeAnimationId(value.AnimationId)

						if not animationId then
							error(v7 or `{data.Type} has an invalid Animation ID.`)
						end

						local formatted = `{v4}:PLAY:{animationId}`
						local studioDesiredElapsed = math.max(data2.TimePosition - v5.Time, 0)
						local v9 = record.CommandKey ~= formatted or not record.Track

						if v9 then
							StopOwnedTrack(record)
							local animation = Instance.new("Animation")
							animation.Name = "OrchestratorAnimation"
							animation.AnimationId = animationId
							record.Animation = animation
							local track = record.Animator:LoadAnimation(animation)
							record.Track = track
							record.CommandKey = formatted
							track:Play(0)
							WatchStudioTrackLoad(target, record, track)
						end

						if not isRunning then
							record.StudioDesiredElapsed = studioDesiredElapsed
						end

						local track = record.Track

						if not track then
							return
						end

						if isRunning then
							local isSeeking = data2.IsSeeking

							if not track.IsPlaying then
								return
							end

							local timePosition = GetDesiredTrackTime(track, studioDesiredElapsed) -- equivalent call inferred; original call site unknown

							if not timePosition then
								return
							end

							if not isSeeking then
								local v11 = math.abs(track.TimePosition - timePosition)

								if track.Looped and track.Length > 0 then
									v11 = math.min(v11, (math.max(track.Length - v11, 0)))
								end

								if not (v11 > 0.3) then
									return
								end
							end

							track.TimePosition = timePosition
						elseif v9 or lastStudioTime == nil or v3 <= 0 then
							SynchronizeTrack(track, studioDesiredElapsed, true) -- equivalent call inferred; original call site unknown
							record.Animator:StepAnimations(0)
						else
							SynchronizeTrack(track, math.max(lastStudioTime - v5.Time, 0), false) -- equivalent call inferred; original call site unknown
							record.Animator:StepAnimations(v3)
						end
					end
				elseif record.CommandKey ~= nil then
					StopOwnedTrack(record)
					record.CommandKey = nil
					RestoreStudioPose(record)
				end
			end,
			OnStop = function(p)
				CleanupRecord(p.Target)
			end
		}
	end
}