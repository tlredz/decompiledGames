local RunService = game:GetService("RunService")
local YoutuberSpecialSteakAdminAbuseConfig = require(script.Parent.YoutuberSpecialSteakAdminAbuseConfig)
local NPCDanceController = {}
local states = {}
local heartbeatConnection = nil

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")

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

local function loadTrack(instance, animationId: string)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
	local v

	if humanoid then
		v = humanoid:FindFirstChildOfClass("Animator")

		if not v then
			v = Instance.new("Animator")
			v.Parent = humanoid
		end
	else
		v = nil
	end

	if not v then
		warn(
			"[YoutuberSpecialSteakAdminAbuse/NPCDanceController] No Humanoid\\AnimationController found on",
			instance:GetFullName()
		)
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return v:LoadAnimation(animation)
	end)
	animation:Destroy()

	if success then
		return result
	end

	warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController] LoadAnimation failed:", result)
	return nil
end

local function buildState(model)
	local tracks = {}
	local v2

	if model.Name == "Steak" then
		v2 = { YoutuberSpecialSteakAdminAbuseConfig.ANIM_IDS.SteakDance }
	else
		v2 = YoutuberSpecialSteakAdminAbuseConfig.ANIM_IDS.NPCDances
	end

	for _, v3 in v2 do
		local v4 = loadTrack(model, v3)

		if not v4 then
			continue
		end

		v4.Looped = true
		table.insert(tracks, v4)
	end

	if #tracks ~= 0 then
		return {
			rig = model,
			tracks = tracks,
			currentIndex = nil,
			timeSinceLastChange = 0,
			nextChangeDuration = math.random(
				YoutuberSpecialSteakAdminAbuseConfig.NPC_DANCE_SWITCH_MIN_SEC,
				YoutuberSpecialSteakAdminAbuseConfig.NPC_DANCE_SWITCH_MAX_SEC
			)
		}
	end

	warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController] No dance tracks loaded for", model:GetFullName())
	return nil
end

local function pickNextIndex(list, p: number?)
	local v = math.random(1, #list)

	if v ~= p or not (#list > 1) then
		return v
	end

	if v == #list then
		return v - 1
	end

	return v + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIndex(state, currentIndex: number)
	if state.currentIndex then
		local track = state.tracks[state.currentIndex]

		if track.IsPlaying then
			track:Stop(0.25)
		end
	end

	state.tracks[currentIndex]:Play(0.25)
	state.currentIndex = currentIndex
end

function NPCDanceController.Start(instance)
	if not instance then
		warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController.Start - Missing mapClone arg]")
		return
	end

	NPCDanceController.Stop()

	if #YoutuberSpecialSteakAdminAbuseConfig.ANIM_IDS.NPCDances == 0 then
		warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController.Start - ANIM_IDS.NPCDances vide, rien à jouer]")
		return
	end

	local scriptables = instance:FindFirstChild("Scriptables")
	local nPCs = scriptables and scriptables:FindFirstChild("NPCs")

	if not nPCs then
		warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController.Start - Scriptables/NPCs not found]")
		return
	end

	for _, model in nPCs:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local state = buildState(model)

		if not state then
			continue
		end

		playIndex(state, math.random(1, #state.tracks)) -- equivalent call inferred; original call site unknown
		table.insert(states, state)
	end

	if #states == 0 then
		warn("[YoutuberSpecialSteakAdminAbuse/NPCDanceController.Start - No NPC rigs found under Scriptables/NPCs]")
	else
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			for _, v in states do
				if #v.tracks == 1 then
					continue
				end

				v.timeSinceLastChange += dt

				if not (v.timeSinceLastChange >= v.nextChangeDuration) then
					continue
				end

				v.timeSinceLastChange = 0
				v.nextChangeDuration = math.random(
					YoutuberSpecialSteakAdminAbuseConfig.NPC_DANCE_SWITCH_MIN_SEC,
					YoutuberSpecialSteakAdminAbuseConfig.NPC_DANCE_SWITCH_MAX_SEC
				)
				local tracks = v.tracks
				local currentIndex = v.currentIndex
				local v2 = math.random(1, #tracks)

				if v2 == currentIndex and #tracks > 1 then
					if v2 == #tracks then
						v2 -= 1
					else
						v2 += 1
					end
				end

				playIndex(v, v2) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

function NPCDanceController.Stop()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for _, v in states do
		for _, track in v.tracks do
			if track.IsPlaying then
				track:Stop(0)
			end
		end
	end

	table.clear(states)
end

return NPCDanceController