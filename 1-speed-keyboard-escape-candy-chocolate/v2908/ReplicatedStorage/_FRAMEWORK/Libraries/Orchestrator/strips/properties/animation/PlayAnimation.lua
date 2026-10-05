local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.Parent.types.Save)
require(script.Parent.Parent.Parent.Parent.types.Strip)
local ResourceClaims = require(script.Parent.Parent.Parent.Parent.runtime.ResourceClaims)
local Preloader = require(ReplicatedStorage._FRAMEWORK.Features.Preloader)
local v = { "PLAY", "STOP" }
local dataTemplate = {
	mode = "STOP",
	animationId = ""
}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveAnimator(instance)
	if instance:IsA("Humanoid") or instance:IsA("AnimationController") then
		return instance:FindFirstChildOfClass("Animator")
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkAnimator(instance)
	local animator = resolveAnimator(instance) -- equivalent call inferred; original call site unknown

	if animator == nil then
		return nil, "Animation requires an Animator beneath its Humanoid or AnimationController."
	end

	return animator, nil
end

local function normalizeAnimationId(animationId)
	local v3

	if type(animationId) == "number" then
		if animationId ~= animationId or animationId <= 0 or animationId % 1 ~= 0 or math.abs(animationId) == 1e999 then
			return nil, "Animation ID must be a positive integer."
		end

		v3 = string.format("%.0f", animationId)
	elseif type(animationId) == "string" then
		v3 = string.match(animationId, "^%s*rbxassetid://(%d+)%s*$") or string.match(animationId, "^%s*(%d+)%s*$")
	else
		return nil, "Animation ID must be a number or rbxassetid string."
	end

	if v3 == nil or string.find(v3, "[1-9]") == nil then
		return nil, "Animation ID must be a positive integer."
	end

	return `rbxassetid://{v3}`, nil
end

local function preloadAnimation(p)
	if p.mode == "PLAY" then
		local animationId = normalizeAnimationId(p.animationId)

		if animationId ~= nil then
			local animation = Instance.new("Animation")
			animation.AnimationId = animationId
			Preloader.preload(animation)
			animation:Destroy()
		end
	end
end

local function findActiveKeyframe(keyframes, timeSeconds: number)
	local count = #keyframes
	local v3 = 1
	local v4 = nil

	while v3 <= count do
		local v5 = math.floor((v3 + count) / 2)

		if keyframes[v5].timeSeconds <= timeSeconds then
			v3 = v5 + 1
			v4 = v5
		else
			count = v5 - 1
		end
	end

	if v4 == nil then
		return nil, nil
	end

	return v4, keyframes[v4]
end

local function captureStudioPose(folder)
	local v3 = {
		motors = {},
		bones = {},
		constraints = {}
	}

	if RunService:IsRunning() then
		return v3
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Motor6D") then
			v3.motors[descendant] = true
		elseif descendant:IsA("Bone") then
			v3.bones[descendant] = true
		elseif descendant:IsA("AnimationConstraint") then
			v3.constraints[descendant] = true
		end
	end

	return v3
end

local function restoreStudioPose(p)
	if not RunService:IsRunning() then
		pcall(p.animator.StepAnimations, p.animator, 0)

		for k in p.studioPose.motors do
			if k.Parent ~= nil then
				k.Transform = CFrame.identity
			end
		end

		for k in p.studioPose.bones do
			if k.Parent ~= nil then
				k.Transform = CFrame.identity
			end
		end

		for k in p.studioPose.constraints do
			if k.Parent ~= nil then
				k.Transform = CFrame.identity
			end
		end
	end
end

local function stopOwnedTrack(state)
	if state.studioLoadConnection ~= nil then
		state.studioLoadConnection:Disconnect()
		state.studioLoadConnection = nil
	end

	state.studioDesiredElapsed = nil

	if state.track ~= nil then
		pcall(state.track.Stop, state.track, 0)
		pcall(state.track.Destroy, state.track)
		state.track = nil
	end

	if state.animation ~= nil then
		state.animation:Destroy()
		state.animation = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEveryTrack(p)
	for _, v3 in p.animator:GetPlayingAnimationTracks() do
		v3:Stop(0)
	end

	stopOwnedTrack(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDesiredTrackTime(p, p2: number)
	if p.Length <= 0 then
		return nil
	end

	if p.Looped then
		return p2 % p.Length
	end

	return (math.min(p2, (math.max(p.Length - 0.0001, 0))))
end

local function getTrackDrift(data, p: number)
	local v3 = math.abs(data.TimePosition - p)

	if data.Looped and data.Length > 0 then
		return (math.min(v3, (math.max(data.Length - v3, 0))))
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function synchronizeTrack(state, p: number, flag: boolean)
	if state.IsPlaying then
		local desiredTrackTime = getDesiredTrackTime(state, p) -- equivalent call inferred; original call site unknown

		if desiredTrackTime ~= nil then
			if flag then
				state.TimePosition = desiredTrackTime
			else
				local v3 = math.abs(state.TimePosition - desiredTrackTime)

				if state.Looped and state.Length > 0 then
					v3 = math.min(v3, (math.max(state.Length - v3, 0)))
				end

				if v3 > 0.3 then
					state.TimePosition = desiredTrackTime
				end
			end
		end
	end
end

local function watchStudioTrackLoad(state, track)
	if not RunService:IsRunning() and track.Length <= 0 then
		if state.studioLoadConnection ~= nil then
			state.studioLoadConnection:Disconnect()
		end

		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if state.track == track then
				if track.Length > 0 then
					state.animator:StepAnimations(0)
					local studioDesiredElapsed = state.studioDesiredElapsed or 0
					synchronizeTrack(track, studioDesiredElapsed, true) -- equivalent call inferred; original call site unknown
					state.animator:StepAnimations(0)

					if heartbeatConnection ~= nil then
						heartbeatConnection:Disconnect()
					end

					state.studioLoadConnection = nil
				end
			elseif heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
			end
		end)
		state.studioLoadConnection = heartbeatConnection
	end
end

local function createAnimationRuntime(p, callback)
	local v3 = {}
	local v4 = nil
	local v5 = nil
	local count = 0

	local function release(flag: boolean)
		count += 1
		local v6 = count
		local v7 = v4
		local v8 = v5
		v4 = nil
		v5 = nil

		if v8 ~= nil then
			stopOwnedTrack(v8)

			if flag then
				restoreStudioPose(v8)

				if not RunService:IsRunning() then
					RunService.Heartbeat:Once(function()
						if count == v6 and v4 == nil then
							restoreStudioPose(v8)
						end
					end)
				end
			end
		end

		if v7 ~= nil then
			ResourceClaims.release(v3, v7, "property:Animation")
		end
	end

	local function evaluate(p2)
		local v6 = v5

		if v6 == nil then
			return
		end

		local lastStudioTime = v6.lastStudioTime
		local v7 = (RunService:IsRunning() or lastStudioTime == nil) and 0 or p2.timeSeconds - lastStudioTime

		if not RunService:IsRunning() then
			v6.lastStudioTime = p2.timeSeconds
		end

		local activeKeyframe, v8 = findActiveKeyframe(p.keyframes, p2.timeSeconds)

		if activeKeyframe == nil or v8 == nil then
			if v6.commandKey == nil then
				return
			end

			stopOwnedTrack(v6)
			v6.commandKey = nil
			restoreStudioPose(v6)
		else
			local data = v8.data

			if data.mode == "STOP" then
				local formatted = `{activeKeyframe}:STOP`

				if v6.commandKey == formatted and not p2.isSeeking then
					return
				end

				stopEveryTrack(v6) -- equivalent call inferred; original call site unknown
				v6.commandKey = formatted
				restoreStudioPose(v6)
			else
				local animationId, v9 = normalizeAnimationId(data.animationId)

				if animationId == nil then
					error(v9 or "Animation keyframe has an invalid Animation ID.")
				end

				local formatted = `{activeKeyframe}:PLAY:{animationId}`
				local studioDesiredElapsed = math.max(p2.timeSeconds - v8.timeSeconds, 0)
				local v11 = v6.commandKey ~= formatted or v6.track == nil

				if v11 then
					stopOwnedTrack(v6)
					local animation = Instance.new("Animation")
					animation.Name = "OrchestratorAnimation"
					animation.AnimationId = animationId
					v6.animation = animation
					local track = v6.animator:LoadAnimation(animation)
					v6.track = track
					v6.commandKey = formatted
					track:Play(0)
					watchStudioTrackLoad(v6, track)
				end

				if not RunService:IsRunning() then
					v6.studioDesiredElapsed = studioDesiredElapsed
				end

				local track = v6.track

				if track == nil then
					return
				end

				if RunService:IsRunning() then
					local isSeeking = p2.isSeeking

					if not track.IsPlaying then
						return
					end

					local desiredTrackTime = getDesiredTrackTime(track, studioDesiredElapsed) -- equivalent call inferred; original call site unknown

					if desiredTrackTime == nil then
						return
					end

					if not isSeeking then
						local v12 = math.abs(track.TimePosition - desiredTrackTime)

						if track.Looped and track.Length > 0 then
							v12 = math.min(v12, (math.max(track.Length - v12, 0)))
						end

						if not (v12 > 0.3) then
							return
						end
					end

					track.TimePosition = desiredTrackTime
				elseif v11 or lastStudioTime == nil or v7 <= 0 then
					synchronizeTrack(track, studioDesiredElapsed, true) -- equivalent call inferred; original call site unknown
					v6.animator:StepAnimations(0)
				else
					synchronizeTrack(track, math.max(lastStudioTime - v8.timeSeconds, 0), false) -- equivalent call inferred; original call site unknown
					v6.animator:StepAnimations(v7)
				end
			end
		end
	end

	return {
		attach = function(_, p2, p3)
			local animator, v7 = checkAnimator(p2) -- equivalent call inferred; original call site unknown
			local v8 = false

			if animator == nil then
				callback(v7 or "Animation requires an Animator beneath its Humanoid or AnimationController.")
				return false
			end

			count += 1
			local v9 = v4
			local v10 = v5
			v4 = nil
			v5 = nil

			if v10 ~= nil then
				stopOwnedTrack(v10)
			end

			if v9 ~= nil then
				ResourceClaims.release(v3, v9, "property:Animation")
			end

			if not ResourceClaims.claim(v3, p2, "property:Animation") then
				callback("Animation is already controlled by another Sequence.")
				return v8
			end

			count += 1
			v4 = p2
			v5 = {
				animator = animator,
				commandKey = nil,
				track = nil,
				animation = nil,
				studioLoadConnection = nil,
				lastStudioTime = nil,
				studioDesiredElapsed = nil,
				studioPose = captureStudioPose(p2.Parent or p2)
			}
			local success, result = pcall(evaluate, p3)

			if success then
				return true
			end

			release(true)
			error(result)
			return v8
		end,
		update = function(_, p2)
			evaluate(p2)
		end,
		detach = function(_, _: string, flag: boolean)
			release(flag)
		end,
		destroy = function(_, _: string, flag: boolean)
			release(flag)
			ResourceClaims.releaseOwner(v3)
		end
	}
end

local PlayAnimation = {}
PlayAnimation.stripType = "property"
PlayAnimation.playbackMode = "custom"
PlayAnimation.propertyName = "Animation"
PlayAnimation.context = "client"
PlayAnimation.catchUpPolicies = { "seek" }
PlayAnimation.dataTemplate = dataTemplate
PlayAnimation.supportsGlobal = false

function PlayAnimation.buildEditor(p, state, _)
	p.Components:AddDropdown(function(object)
		object:SetText("Mode"):SetChoiceList(v):SetSelected(state.mode):SetOnChanged(function(p2: string)
			state.mode = p2 == "PLAY" and "PLAY" or "STOP"
		end)
	end)
	p.Components:AddField(function(object)
		object:SetText("Animation ID"):SetValue((tostring(state.animationId))):SetOnChangedUnfocus(function(animationId: string)
			state.animationId = animationId
		end)
	end)
end

function PlayAnimation.supports(instance)
	local animator = resolveAnimator(instance) -- equivalent call inferred; original call site unknown
	return animator ~= nil
end

function PlayAnimation.capture(_, _)
	return table.clone(dataTemplate)
end

PlayAnimation.createRuntime = createAnimationRuntime
PlayAnimation.preload = preloadAnimation
return PlayAnimation