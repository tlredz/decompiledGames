local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local game2 = chickenOrHero:WaitForChild("Game")
local hitReplayEvent = game2:WaitForChild("HitReplayEvent")
local HitReplayMath = require(game2.HitReplayMath)
local ContactCatchConfig = require(game2.ContactCatchConfig)
local DaggerConfig = require(chickenOrHero.Weapons.DaggerConfig)
local AnimationConfig = require(chickenOrHero.Animation.AnimationConfig)
local MeleeAttackTimeline = require(chickenOrHero.Animation.MeleeAttackTimeline)
local ParticipantDirectory = require(chickenOrHero.Presentation.ParticipantDirectory)
local CombatPrediction = {}
local v = {}
local v2 = {}
local v3 = {}
local connections = {}
local flag = false
local v4 = nil
local v5 = nil
local characters = {}
local characters2 = {}
local v6 = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true

-- equivalent calls inferred from this helper; original call sites unknown
local function clock()
	return workspace:GetServerTimeNow()
end

local function point(instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoid and humanoid.Health > 0 and not humanoidRootPart.Anchored then
		return {
			position = humanoidRootPart.Position,
			reset = instance:GetAttribute("MovementReset"),
			relocation = instance:GetAttribute("CombatRelocation")
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(p)
	for callback in v3 do
		task.spawn(callback, p)
	end
end

function CombatPrediction.subscribe(p)
	v3[p] = true
	return {
		Disconnect = function()
			v3[p] = nil
		end
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTrack(object, value)
	if object and object.IsPlaying then
		object:Stop(value or 0.06)
	end
end

local function clearLocal(character)
	if character and character.Parent then
		for _, v7 in {
			"LocalMeleeActive",
			"LocalMeleeStartedAt",
			"LocalMeleeDirection",
			"LocalMeleePhase"
		} do
			character:SetAttribute(v7, nil)
		end
	end
end

local function releaseAnimation()
	if not v4 then
		return
	end

	clearLocal(v4.character)

	for _, track in v4.tracks do
		track:Stop(0.06)
		track:Destroy()
	end

	for _, asset in v4.assets do
		asset:Destroy()
	end

	v4 = nil
end

local function prepareAnimation(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	if v4 and v4.character == character and v4.animator == animator then
		return v4
	end

	releaseAnimation()
	local v7 = {
		character = character,
		animator = animator,
		tracks = {},
		assets = {},
		retryAt = 0
	}
	v4 = v7
	return v7
end

local function ensureTracks(state, p)
	if p < state.retryAt then
		return
	end

	state.retryAt = p + 5

	for k, animationId in {
		Windup = AnimationConfig.PublishedIds.DaggerWindup,
		Stab = AnimationConfig.PublishedIds.DaggerStab
	} do
		local track = state.tracks[k]

		if track and track.Length > 0 then
			continue
		end

		if track then
			track:Destroy()
		end

		if state.assets[k] then
			state.assets[k]:Destroy()
		end

		local animation = Instance.new("Animation")
		animation.Name = "CoH_Predicted" .. k
		animation.AnimationId = animationId
		state.assets[k] = animation
		local success, result = pcall(state.animator.LoadAnimation, state.animator, animation)

		if success then
			result.Priority = Enum.AnimationPriority.Action2
			result.Looped = false
			state.tracks[k] = result
		else
			state.tracks[k] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endAttack(p, p2, p3)
	for k in p.ids do
		v[k] = nil
		v2[k] = p2 + 5
	end

	if v5 == p then
		v5 = nil
		clearLocal(p.character)

		if v4 and v4.character == p.character then
			stopTrack(v4.tracks.Windup) -- equivalent call inferred; original call site unknown

			if p3 then
				stopTrack(v4.tracks.Stab) -- equivalent call inferred; original call site unknown
			end

			v4.attack = nil
		end
	end
end

function CombatPrediction.cancel(p)
	local v7 = v[p]

	if v7 then
		endAttack(v7, workspace:GetServerTimeNow(), true)
	end
end

local function updateAttack(state, data)
	state.confirmed = true

	if type(data.startedAt) == "number" then
		state.startedAt = data.startedAt
	end

	if type(data.starts) == "number" then
		state.starts = data.starts
	end

	if type(data.ends) == "number" then
		state.ends = data.ends
	end

	if HitReplayMath.vector(data.direction) then
		if state.direction:Dot(data.direction) < 0.99 then
			table.clear(state.previous)
		end

		state.direction = data.direction
	end

	if type(data.box) == "table" then
		state.box = data.box
	end

	if type(data.targets) == "table" then
		state.targets = data.targets
	end

	if data.canonicalId then
		state.ids[data.canonicalId] = true
		v[data.canonicalId] = state
		state.id = data.canonicalId
	end
end

function CombatPrediction.reconcile(p, p2, p3)
	local v7 = v[p]

	if not v7 then
		return
	end

	if not p2 then
		endAttack(v7, workspace:GetServerTimeNow(), true)
		return
	end

	local v8 = type(p3) == "table" and p3 or {}

	if type(v8.startedAt) == "number" and v7.kind == "Melee" then
		v8.starts = v8.starts or v8.startedAt + ContactCatchConfig.Windup
		v8.ends = v8.ends or v8.starts + ContactCatchConfig.ActiveDuration
	end

	updateAttack(v7, v8)
end

function CombatPrediction:begin()
	CombatPrediction.start()

	if type(self.id) ~= "string" or v2[self.id] or self.character ~= localPlayer.Character then
		return nil
	end

	local v7 = v[self.id]

	if v7 then
		updateAttack(v7, self)
		return v7
	end

	if self.kind == "Melee" and not self.predicted and v5 and not v5.confirmed and math.abs((self.startedAt or self.starts - ContactCatchConfig.Windup) - v5.startedAt) < ContactCatchConfig.Windup + ContactCatchConfig.ActiveDuration + ContactCatchConfig.Recovery then
		self.canonicalId = self.id
		updateAttack(v5, self)
		return v5
	else
		local createdAt = clock() -- equivalent call inferred; original call site unknown
		local v9 = point(self.character)

		if not v9 then
			return nil
		end

		local v10 = {
			id = self.id,
			ids = {
				[self.id] = true
			},
			kind = self.kind,
			character = self.character,
			startedAt = self.startedAt or self.kind == "Melee" and self.starts - ContactCatchConfig.Windup or self.starts,
			starts = self.starts,
			ends = self.ends,
			direction = self.direction,
			box = self.box,
			targets = self.targets,
			previous = {},
			sent = {},
			confirmed = self.predicted ~= true,
			reset = v9.reset,
			relocation = v9.relocation,
			visualElapsed = 0,
			createdAt = createdAt
		}
		v[self.id] = v10

		if v10.kind ~= "Melee" then
			return v10
		end

		if v5 then
			endAttack(v5, createdAt, true)
		end

		v5 = v10
		v10.character:SetAttribute("LocalMeleeActive", true)
		v10.character:SetAttribute("LocalMeleeStartedAt", v10.startedAt)
		v10.character:SetAttribute("LocalMeleeDirection", v10.direction)
		return v10
	end
end

function CombatPrediction.debugAttacks()
	local v7 = clock() -- equivalent call inferred; original call site unknown
	local v8 = {}
	local result = {}

	for _, v9 in v do
		if v8[v9] then
			continue
		end

		v8[v9] = true
		local humanoidRootPart

		if v9.character == localPlayer.Character then
			humanoidRootPart = v9.character:FindFirstChild("HumanoidRootPart")
		else
			humanoidRootPart = false
		end

		if humanoidRootPart and v9.starts <= v7 and v7 <= v9.ends then
			table.insert(result, {
				id = v9.id,
				kind = v9.kind,
				character = v9.character,
				position = humanoidRootPart.Position,
				direction = v9.direction,
				width = v9.box.width,
				height = v9.box.height,
				forwardStart = v9.box.near,
				forwardEnd = v9.box.far
			})
		end
	end

	return result
end

function CombatPrediction.meleeRemaining()
	return v5 and math.max(0, v5.ends + ContactCatchConfig.Recovery - workspace:GetServerTimeNow()) or 0
end

function CombatPrediction.meleeBox(instance)
	local bounds = HitReplayMath.bounds("Melee", ContactCatchConfig)

	if instance:GetAttribute("BigDaggerActive") == true then
		bounds.far *= 2
	end

	return bounds
end

local function updateTargets(p)
	if p < v6 then
		return
	end

	v6 = p + 0.1
	table.clear(characters)
	table.clear(characters2)
	local v7 = game2.Session:GetAttribute("AdminMatchMode") == "FFACatchers"

	for _, v8 in ParticipantDirectory.list() do
		if v8.Character then
			table.insert(characters2, v8.Character)
		end

		if not (v8 ~= localPlayer and v8.Character and v8:GetAttribute("RunState") == "Active") then
			continue
		end

		if not ((v8:GetAttribute("GameRole") == "Runner" or v7 and v8:GetAttribute("GameRole") == "Catcher") and v8:GetAttribute("FFAInvincible") ~= true) then
			continue
		end

		table.insert(characters, v8.Character)
	end

	raycastParams.FilterDescendantsInstances = characters2
end

local function reportContacts(data, at, data2)
	for _, target in data.targets or characters do
		local victim = target.Parent and point(target)
		local v9 = data.previous[target]

		if victim and not data.sent[target] and data.starts <= at and at <= data.ends + 0.08 then
			local position = data2.position
			local position2 = victim.position
			local position3 = data2.position
			local position4 = victim.position
			local at2 = math.min(at, data.ends)
			local v11

			if v9 and at - v9.at <= 0.08 and v9.attacker.reset == data2.reset and v9.attacker.relocation == data2.relocation and v9.victim.reset == victim.reset and v9.victim.relocation == victim.relocation and (v9.attacker.position - data2.position).Magnitude <= 14 and (v9.victim.position - victim.position).Magnitude <= 14 then
				v11 = math.max(v9.at, data.starts)
				local v12 = not (v9.at < at) and 1 or (v11 - v9.at) / (at - v9.at) or 1
				position = v9.attacker.position:Lerp(data2.position, v12)
				position2 = v9.victim.position:Lerp(victim.position, v12)
				local v13 = not (v9.at < at) and 1 or (at2 - v9.at) / (at - v9.at) or 1
				position3 = v9.attacker.position:Lerp(data2.position, (math.clamp(v13, 0, 1)))
				position4 = v9.victim.position:Lerp(victim.position, (math.clamp(v13, 0, 1)))
			else
				v11 = at
			end

			local v12, v13, v14

			if v11 <= at2 then
				v12, v13, v14 = HitReplayMath.sweep(position, position3, position2, position4, data.direction, data.box)
			else
				v12 = false
			end

			local humanoidRootPart = data.character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart.CollisionGroup then
				raycastParams.CollisionGroup = humanoidRootPart.CollisionGroup
			end

			local v15 = v13 or position3

			if v12 and not workspace:Raycast(v15, (v14 or position4) - v15, raycastParams) then
				data.sent[target] = true
				hitReplayEvent:FireServer({
					id = data.id,
					target = target,
					at = at2,
					span = math.min(0.08, at2 - v11),
					origin = position3,
					targetPosition = position4,
					previousOrigin = position,
					previousTargetPosition = position2
				})
			end
		end

		if victim then
			data.previous[target] = {
				at = at,
				attacker = data2,
				victim = victim
			}
		end
	end
end

local function animate(p)
	local character = localPlayer.Character
	local v7 = prepareAnimation(character)

	if not v7 then
		return
	end

	ensureTracks(v7, p)

	if character:GetAttribute("TackleActive") or character:GetAttribute("MovementLocked") or localPlayer:GetAttribute("GameRole") ~= "Catcher" or localPlayer:GetAttribute("RunState") ~= "Active" then
		stopTrack(v7.tracks.Windup) -- equivalent call inferred; original call site unknown
		stopTrack(v7.tracks.Stab) -- equivalent call inferred; original call site unknown
	else
		local attack = v5

		if attack then
			attack.visualElapsed = math.max(attack.visualElapsed, p - attack.startedAt)
			local sample, v9, v10 = MeleeAttackTimeline.sample(attack.visualElapsed, ContactCatchConfig, DaggerConfig)
			character:SetAttribute("LocalMeleePhase", sample)
			character:SetAttribute("LocalMeleeDirection", attack.direction)
			local v11 = sample == "Windup" and "Windup" or "Stab"
			local track = v7.tracks[v11]

			if track and track.Length > 0 and sample ~= "Complete" then
				if v7.attack == attack and v7.key == v11 and track.IsPlaying then
					if v7.phase ~= sample then
						track:AdjustSpeed(v10)
					end

					if v9 - track.TimePosition > 0.05 then
						track.TimePosition = math.min(v9, (math.max(0, track.Length - 0.001)))
					end
				else
					local track2 = v7.tracks[v11 == "Stab" and "Windup" or "Stab"]

					if track2 and track2.IsPlaying then
						track2:Stop(0.035)
					end

					track:Play(DaggerConfig.FadeIn, 1, v10)
					track.TimePosition = math.min(v9, (math.max(0, track.Length - 0.001)))
				end

				if v11 == "Windup" and track.TimePosition >= track.Length - DaggerConfig.WindupHoldTail then
					track:AdjustSpeed(0)
				end

				v7.attack = attack
				v7.key = v11
				v7.phase = sample
			end
		elseif character:GetAttribute("ReachPhase") == "Tracking" and character:GetAttribute("DaggerState") == "Held" then
			local windup = v7.tracks.Windup

			if windup and windup.Length > 0 then
				if not windup.IsPlaying then
					windup:Play(DaggerConfig.FadeIn, 1, DaggerConfig.WindupRate)
				end

				if windup.TimePosition >= windup.Length - DaggerConfig.WindupHoldTail then
					windup:AdjustSpeed(0)
				end
			end
		else
			stopTrack(v7.tracks.Windup) -- equivalent call inferred; original call site unknown
		end
	end
end

function CombatPrediction.start()
	if flag then
		return
	end

	flag = true
	table.insert(connections, hitReplayEvent.OnClientEvent:Connect(function(p, p2)
		if p == "Attack" then
			CombatPrediction.begin(p2)
		elseif p == "Cancel" then
			CombatPrediction.cancel(p2)
		elseif p == "Verdict" then
			notify(p2) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, RunService.RenderStepped:Connect(function()
		local at = clock() -- equivalent call inferred; original call site unknown
		updateTargets(at)
		local v8 = {}

		for _, v9 in v do
			if v8[v9] then
				continue
			end

			v8[v9] = true
			local attacker = point(v9.character)

			if attacker and v9.character == localPlayer.Character and attacker.reset == v9.reset and attacker.relocation == v9.relocation and localPlayer:GetAttribute("RunState") == "Active" and not v9.character:GetAttribute("MovementLocked") and (v9.kind ~= "Melee" or not v9.character:GetAttribute("TackleActive")) then
				if v9.ends + (v9.kind ~= "Melee" and 0.1 or ContactCatchConfig.Recovery or 0.1) < at then
					endAttack(v9, at, false) -- equivalent call inferred; original call site unknown
				else
					reportContacts(v9, at, attacker)
				end
			else
				endAttack(v9, at, true)
			end
		end

		for k, v9 in v2 do
			if v9 < at then
				v2[k] = nil
			end
		end

		animate(at)
	end))
	table.insert(connections, localPlayer.CharacterRemoving:Connect(function()
		table.clear(v)
		table.clear(v2)
		v5 = nil
		releaseAnimation()
	end))
end

function CombatPrediction.destroy()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	table.clear(v)
	table.clear(v2)
	table.clear(v3)
	v5 = nil
	flag = false
	releaseAnimation()
end

script.Destroying:Connect(CombatPrediction.destroy)
return CombatPrediction