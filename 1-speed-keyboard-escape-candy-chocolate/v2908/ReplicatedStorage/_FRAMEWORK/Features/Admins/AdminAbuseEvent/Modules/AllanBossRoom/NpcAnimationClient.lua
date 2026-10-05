local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local function resolveAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local v = humanoid:FindFirstChildOfClass("Animator")

	if not v then
		v = Instance.new("Animator")
		v.Parent = humanoid
	end

	return v
end

local function loadLoopedTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	animation:Destroy()
	track.Looped = true
	return track
end

local function getRootPart(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

	if primaryPart and primaryPart:IsA("BasePart") then
		return primaryPart
	end

	return nil
end

return {
	start = function(data)
		assert(RunService:IsClient(), "AllanBossRoom.NpcAnimationClient.start is client-only")
		local config = data.config
		local v = nil
		local v2 = nil
		local v3 = nil
		local v4 = nil

		local function releaseTracks()
			for _, v5 in { v2, v3, v4 } do
				if not v5 then
					continue
				end

				v5:Stop(0)
				v5:Destroy()
			end

			v2 = nil
			v3 = nil
			v4 = nil
			v = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bind(rig)
			local humanoid = rig:FindFirstChildOfClass("Humanoid")
			local v5

			if humanoid then
				v5 = humanoid:FindFirstChildOfClass("Animator")

				if not v5 then
					v5 = Instance.new("Animator")
					v5.Parent = humanoid
				end
			end

			if not v5 then
				return
			end

			v = rig
			local walkAnimation = config.walkAnimation
			local animation = Instance.new("Animation")
			animation.AnimationId = walkAnimation
			local track = v5:LoadAnimation(animation)
			animation:Destroy()
			track.Looped = true
			v2 = track
			local idleAnimation = config.idleAnimation
			local animation2 = Instance.new("Animation")
			animation2.AnimationId = idleAnimation
			local track2 = v5:LoadAnimation(animation2)
			animation2:Destroy()
			track2.Looped = true
			v3 = track2
		end

		return {
			update = function()
				local rig = data.getRig()

				if rig then
					if rig ~= v then
						releaseTracks()
						bind(rig) -- equivalent call inferred; original call site unknown
					end

					local primaryPart = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")

					if not (primaryPart and primaryPart:IsA("BasePart")) then
						primaryPart = nil
					end

					if not (primaryPart and v2 and v3) or v4 and v4.IsPlaying then
						return
					end

					local isJumping = data.isJumping

					if isJumping and isJumping() then
						return
					end

					local assemblyLinearVelocity = primaryPart.AssemblyLinearVelocity

					if Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude >= config.walkAnimationMinSpeed then
						if not v2.IsPlaying then
							v3:Stop(0.2)
							v2:Play(0.2)
						end
					elseif not v3.IsPlaying then
						v2:Stop(0.2)
						v3:Play(0.2)
					end
				elseif v then
					releaseTracks()
				end
			end,
			playTaunt = function(p: string)
				local v5 = v
				local v6

				if v5 then
					local humanoid = v5:FindFirstChildOfClass("Humanoid")

					if humanoid then
						v6 = humanoid:FindFirstChildOfClass("Animator")

						if not v6 then
							v6 = Instance.new("Animator")
							v6.Parent = humanoid
						end
					end
				end

				local primaryPart

				if v5 then
					primaryPart = v5.PrimaryPart or v5:FindFirstChild("HumanoidRootPart")

					if not (primaryPart and primaryPart:IsA("BasePart")) then
						primaryPart = nil
					end
				end

				if not (v5 and v6 and primaryPart) or v4 and v4.IsPlaying then
					return
				end

				local taunts = config.taunts
				local roarAnimation

				if p == "Roar" then
					roarAnimation = taunts.roarAnimation
				else
					roarAnimation = taunts.laughAnimation
				end

				local roarSound

				if p == "Roar" then
					roarSound = taunts.roarSound
				else
					roarSound = taunts.laughSound
				end

				local roarHoldSeconds

				if p == "Roar" then
					roarHoldSeconds = taunts.roarHoldSeconds
				else
					roarHoldSeconds = taunts.laughHoldSeconds
				end

				local animation = Instance.new("Animation")
				animation.AnimationId = roarAnimation
				local track = v6:LoadAnimation(animation)
				animation:Destroy()
				track.Priority = Enum.AnimationPriority.Action
				track.Looped = false
				track:Play(0.2)
				v4 = track
				local sound = Instance.new("Sound")
				sound.SoundId = roarSound
				sound.Volume = 1.6
				sound.Parent = primaryPart
				sound:Play()
				Debris:AddItem(sound, roarHoldSeconds + 2)
				task.delay(roarHoldSeconds, function()
					if v4 == track then
						track:Stop(0.4)
						v4 = nil
					end
				end)
			end,
			stop = releaseTracks
		}
	end
}