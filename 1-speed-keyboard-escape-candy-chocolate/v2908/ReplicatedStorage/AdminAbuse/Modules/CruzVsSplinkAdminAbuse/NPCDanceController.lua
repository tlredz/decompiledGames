local RunService = game:GetService("RunService")
local CruzVsSplinkAdminAbuseConfig = require(script.Parent.CruzVsSplinkAdminAbuseConfig)
local states = {}
local heartbeatConnection = nil

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")

	if humanoid == nil then
		return nil
	end

	local v = humanoid:FindFirstChildOfClass("Animator")

	if v == nil then
		v = Instance.new("Animator")
		v.Parent = humanoid
	end

	return v
end

local function loadTrack(instance, animationId: string)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
	local v

	if humanoid ~= nil then
		v = humanoid:FindFirstChildOfClass("Animator")

		if v == nil then
			v = Instance.new("Animator")
			v.Parent = humanoid
		end
	end

	if v == nil then
		warn(
			"[CruzVsSplinkAdminAbuse/NPCDanceController]",
			"No Humanoid/AnimationController on",
			instance:GetFullName()
		)
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(v.LoadAnimation, v, animation)
	animation:Destroy()

	if success then
		return result
	end

	warn("[CruzVsSplinkAdminAbuse/NPCDanceController]", "LoadAnimation failed:", result)
	return nil
end

local function randomSwitchDuration()
	return math.random(
		CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MIN_SEC,
		CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MAX_SEC
	)
end

local function buildState(model)
	local tracks = {}

	for _, v2 in CruzVsSplinkAdminAbuseConfig.RIG_DANCES[model.Name] or CruzVsSplinkAdminAbuseConfig.NPC_DANCES do
		local v3 = loadTrack(model, v2)

		if not v3 then
			continue
		end

		v3.Looped = true
		table.insert(tracks, v3)
	end

	if #tracks ~= 0 then
		return {
			rig = model,
			tracks = tracks,
			currentIndex = nil,
			timeSinceLastChange = 0,
			nextChangeDuration = math.random(
				CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MIN_SEC,
				CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MAX_SEC
			)
		}
	end

	warn("[CruzVsSplinkAdminAbuse/NPCDanceController]", "No dance tracks loaded for", model:GetFullName())
	return nil
end

local function pickNextIndex(p: number, p2: number?)
	if p == 1 or p2 == nil then
		return math.random(1, p)
	end

	local v = math.random(1, p - 1)

	if p2 <= v then
		return v + 1
	end

	return v
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

local function onHeartbeat(p: number)
	for _, v in states do
		if #v.tracks == 1 then
			continue
		end

		v.timeSinceLastChange += p

		if not (v.timeSinceLastChange >= v.nextChangeDuration) then
			continue
		end

		v.timeSinceLastChange = 0
		v.nextChangeDuration = math.random(
			CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MIN_SEC,
			CruzVsSplinkAdminAbuseConfig.NPC_DANCE_SWITCH_MAX_SEC
		)
		local count = #v.tracks
		local currentIndex = v.currentIndex
		local v2

		if count == 1 or currentIndex == nil then
			v2 = math.random(1, count)
		else
			v2 = math.random(1, count - 1)

			if currentIndex <= v2 then
				v2 += 1
			end
		end

		playIndex(v, v2) -- equivalent call inferred; original call site unknown
	end
end

local NPCDanceController = {}

function NPCDanceController.start(instance)
	NPCDanceController.stop()
	local scriptables = instance:FindFirstChild("Scriptables")
	local nPCs

	if scriptables then
		nPCs = scriptables:FindFirstChild("NPCs")
	end

	if nPCs == nil then
		warn("[CruzVsSplinkAdminAbuse/NPCDanceController]", "Scriptables/NPCs not found on", instance:GetFullName())
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

	if #states > 0 then
		heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
	else
		warn("[CruzVsSplinkAdminAbuse/NPCDanceController]", "No NPC rig found under Scriptables/NPCs")
	end
end

function NPCDanceController.stop()
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