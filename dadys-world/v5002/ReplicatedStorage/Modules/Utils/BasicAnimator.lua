local v = {
	idle = {
		{
			id = "rbxassetid://121960921916341",
			weight = 10
		}
	},
	quirk = {
		{
			id = "rbxassetid://123797291224009",
			weight = 10
		}
	},
	walk = {
		{
			id = "rbxassetid://135628475040410",
			weight = 10
		}
	},
	run = {
		{
			id = "rbxassetid://98111731270842",
			weight = 10
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidAnimationId(value: string)
	if typeof(value) == "string" then
		return value:match("^rbxassetid://%d+$") or value:match("^https://www%.roblox%.com/asset/%?id=%d+$")
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function safeStopAnimation(animationTrack, p)
	if animationTrack and animationTrack:IsA("AnimationTrack") and animationTrack.IsPlaying then
		animationTrack:Stop(p)
	end
end

local function preloadAnimation(animation, animator, p)
	local track = animation and animation.AnimationId and animator:LoadAnimation(animation)

	if track then
		track:Play(0)
		track:Stop()
		track:Destroy()
		p[animation.AnimationId] = true
	end
end

local function rollAnimation(p)
	if not p or p.totalWeight <= 0 then
		return 1
	end

	local v2 = math.random(1, p.totalWeight)
	local total = 0

	for i = 1, #p do
		total += p[i].weight or 1

		if v2 <= total then
			return i
		end
	end

	return 1
end

local function playAnimation(currentAnim: string, p: number, p2, state)
	if currentAnim == "idle" then
		return
	end

	local v2 = state.animTable[currentAnim]

	if not v2 then
		warn("No animation set found for:", currentAnim)
		return
	end

	if currentAnim == "quirk" then
		safeStopAnimation(state.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
		state.currentAnimTrack = nil
	else
		safeStopAnimation(state.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
		safeStopAnimation(state.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
		state.quirkAnimTrack = nil
	end

	local anim = v2[rollAnimation(v2)].anim
	local track = p2.Animator:LoadAnimation(anim)

	if currentAnim == "quirk" then
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = false
		track:Play(p)
		state.quirkAnimTrack = track
		track.Stopped:Connect(function()
			state.quirkAnimTrack = nil
		end)
		state.currentAnim = "quirk"
	else
		track.Priority = Enum.AnimationPriority.Movement
		track.Looped = true
		track:Play(p)
		state.currentAnimTrack = track
		state.currentAnim = currentAnim
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAllAnimations(state)
	safeStopAnimation(state.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
	safeStopAnimation(state.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
	state.currentAnimTrack = nil
	state.quirkAnimTrack = nil
	state.currentAnim = "idle"
end

local function tryPlayQuirk(state, humanoid)
	if state.currentAnim == "idle" and not state.quirkAnimTrack and tick() - state.lastQuirkTime > 8 and math.random() < 0.1 then
		playAnimation("quirk", 0.3, humanoid, state)
		state.lastQuirkTime = tick()
	end
end

local function onRunning(p, p2, player)
	if player.Character:GetAttribute("TreadmillMode") then
		return
	end

	local moveDirection = p.MoveDirection

	if p2 < 0.01 or moveDirection.Magnitude < 0.01 then
		if player.currentAnim == "walk" or player.currentAnim == "run" then
			stopAllAnimations(player) -- equivalent call inferred; original call site unknown
		end

		player.currentAnim = "idle"
	else
		local value = false
		local stats = player.Character:FindFirstChild("Stats")

		if stats then
			local sprinting = stats:FindFirstChild("Sprinting")

			if sprinting and sprinting:IsA("BoolValue") then
				value = sprinting.Value
			end
		end

		if value then
			if player.currentAnim ~= "run" then
				local run = player.animTable.run

				if run then
					safeStopAnimation(player.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
					safeStopAnimation(player.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
					player.quirkAnimTrack = nil
					local anim = run[rollAnimation(run)].anim
					local track = p.Animator:LoadAnimation(anim)
					track.Priority = Enum.AnimationPriority.Movement
					track.Looped = true
					track:Play(0.2)
					player.currentAnimTrack = track
					player.currentAnim = "run"
				else
					warn("No animation set found for:", "run")
				end
			end

			if player.currentAnimTrack then
				player.currentAnimTrack:AdjustSpeed(player.runOverrideValue)
			end

			player.currentAnim = "run"
		else
			if player.currentAnim ~= "walk" then
				local walk = player.animTable.walk

				if walk then
					safeStopAnimation(player.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
					safeStopAnimation(player.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
					player.quirkAnimTrack = nil
					local anim = walk[rollAnimation(walk)].anim
					local track = p.Animator:LoadAnimation(anim)
					track.Priority = Enum.AnimationPriority.Movement
					track.Looped = true
					track:Play(0.2)
					player.currentAnimTrack = track
					player.currentAnim = "walk"
				else
					warn("No animation set found for:", "walk")
				end
			end

			if player.currentAnimTrack then
				player.currentAnimTrack:AdjustSpeed(player.walkOverrideValue)
			end

			player.currentAnim = "walk"
		end
	end
end

return {
	SetupAnimations = function(instance)
		local v2 = {
			Character = instance,
			currentAnim = "idle",
			currentAnimTrack = nil,
			quirkAnimTrack = nil,
			lastQuirkTime = 0,
			animTable = {},
			walkOverrideValue = 1,
			runOverrideValue = 1
		}
		local humanoid = instance:WaitForChild("Humanoid")
		local animator = humanoid:WaitForChild("Animator")

		local function overrideAnimationsWithConfig(p)
			local animations = instance:FindFirstChild("Animations")

			if not animations then
				return
			end

			for k, childName in pairs({
				idle = "Idle",
				quirk = "Quirk",
				walk = "Walk",
				run = "Run"
			}) do
				local animation = animations:FindFirstChild(childName)

				if not (animation and animation:IsA("Animation")) then
					continue
				end

				-- equivalent call inferred; original call site unknown
				if isValidAnimationId(animation.AnimationId) then
					p[k] = {
						{
							id = animation.AnimationId,
							weight = 10
						}
					}
				end
			end
		end

		overrideAnimationsWithConfig(v)

		local function configureAnimationSet(k, list)
			local v3 = {
				count = 0,
				totalWeight = #list,
				connections = {}
			}

			for _, v4 in pairs(list) do
				-- equivalent call inferred; original call site unknown
				if isValidAnimationId(v4.id) then
					local animation = Instance.new("Animation")
					animation.AnimationId = v4.id
					animation.Parent = humanoid
					v3.totalWeight += 0
					table.insert(v3, {
						anim = animation,
						count = 1,
						totalWeight = v4.weight,
						weight = v4.weight
					})
					v3.count += 1
				else
					warn("Invalid AnimationId for '" .. k .. "': " .. tostring(v4.id))
				end
			end

			v2.animTable[k] = v3
		end

		for k, v3 in pairs(v) do
			configureAnimationSet(k, v3)
		end

		local v3 = {}

		for _, v4 in pairs(v2.animTable) do
			for i = 1, v4.count do
				if not v4[i] or not v4[i].anim or v3[v4[i].anim.AnimationId] then
					continue
				end

				local anim = v4[i].anim

				if not (anim and anim.AnimationId) then
					continue
				end

				local track = animator:LoadAnimation(anim)

				if not track then
					continue
				end

				track:Play(0)
				track:Stop()
				track:Destroy()
				v3[anim.AnimationId] = true
			end
		end

		local idle = v2.animTable.idle

		if idle and idle.count > 0 then
			local track = animator:LoadAnimation(idle[rollAnimation(idle)].anim)
			track.Priority = Enum.AnimationPriority.Idle
			track.Looped = true
			track:Play(0)
			v2.currentAnim = "idle"
		else
			warn("No idle animation found; idle won't play.")
		end

		local animations = instance:FindFirstChild("Animations")

		local function connectOverrideValue(instance2, p, p2)
			if instance2 then
				local instance3 = instance2:FindFirstChild(p2 .. "Override")

				if instance3 and (instance3:IsA("NumberValue") or instance3:IsA("IntValue")) then
					local value = instance3.Value

					if p2 == "Walk" then
						v2.walkOverrideValue = value
					else
						v2.runOverrideValue = value
					end

					instance3.Changed:Connect(function(p3)
						if p2 == "Walk" then
							v2.walkOverrideValue = p3

							if v2.currentAnim == "walk" and v2.currentAnimTrack then
								v2.currentAnimTrack:AdjustSpeed(v2.walkOverrideValue)
							end
						else
							v2.runOverrideValue = p3

							if v2.currentAnim == "run" and v2.currentAnimTrack then
								v2.currentAnimTrack:AdjustSpeed(v2.runOverrideValue)
							end
						end
					end)
				elseif p2 == "Walk" then
					v2.walkOverrideValue = p
				else
					v2.runOverrideValue = p
				end
			end
		end

		if animations then
			connectOverrideValue(animations:FindFirstChild("Walk"), 1, "Walk")
			connectOverrideValue(animations:FindFirstChild("Run"), 1, "Run")
		end

		local function onRunning2(p)
			if instance:GetAttribute("TreadmillMode") then
				return
			end

			local moveDirection = humanoid.MoveDirection

			if p < 0.01 or moveDirection.Magnitude < 0.01 then
				if v2.currentAnim == "walk" or v2.currentAnim == "run" then
					stopAllAnimations(v2) -- equivalent call inferred; original call site unknown
				end

				v2.currentAnim = "idle"
			else
				local value = false
				local stats = instance:FindFirstChild("Stats")

				if stats then
					local sprinting = stats:FindFirstChild("Sprinting")

					if sprinting and sprinting:IsA("BoolValue") then
						value = sprinting.Value
					end
				end

				if value then
					if v2.currentAnim ~= "run" then
						local parent = humanoid
						local v5 = v2
						local run = v5.animTable.run

						if run then
							safeStopAnimation(v5.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
							safeStopAnimation(v5.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
							v5.quirkAnimTrack = nil
							local anim = run[rollAnimation(run)].anim
							local track = parent.Animator:LoadAnimation(anim)
							track.Priority = Enum.AnimationPriority.Movement
							track.Looped = true
							track:Play(0.2)
							v5.currentAnimTrack = track
							v5.currentAnim = "run"
						else
							warn("No animation set found for:", "run")
						end
					end

					if v2.currentAnimTrack then
						v2.currentAnimTrack:AdjustSpeed(v2.runOverrideValue)
					end

					v2.currentAnim = "run"
				else
					if v2.currentAnim ~= "walk" then
						local parent = humanoid
						local v5 = v2
						local walk = v5.animTable.walk

						if walk then
							safeStopAnimation(v5.currentAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
							safeStopAnimation(v5.quirkAnimTrack, 0.2) -- equivalent call inferred; original call site unknown
							v5.quirkAnimTrack = nil
							local anim = walk[rollAnimation(walk)].anim
							local track = parent.Animator:LoadAnimation(anim)
							track.Priority = Enum.AnimationPriority.Movement
							track.Looped = true
							track:Play(0.2)
							v5.currentAnimTrack = track
							v5.currentAnim = "walk"
						else
							warn("No animation set found for:", "walk")
						end
					end

					if v2.currentAnimTrack then
						v2.currentAnimTrack:AdjustSpeed(v2.walkOverrideValue)
					end

					v2.currentAnim = "walk"
				end
			end
		end

		local function onDied()
			stopAllAnimations(v2) -- equivalent call inferred; original call site unknown
		end

		humanoid.Running:Connect(function(p)
			onRunning2(p)
		end)
		humanoid.Died:Connect(onDied)
		coroutine.wrap(function()
			while instance.Parent ~= nil do
				wait(0.1)

				if instance:GetAttribute("TreadmillMode") or instance:GetAttribute("DisableQuirks") or v2.currentAnim ~= "idle" then
					continue
				end

				tryPlayQuirk(v2, humanoid)
			end
		end)()
		return v2
	end
}