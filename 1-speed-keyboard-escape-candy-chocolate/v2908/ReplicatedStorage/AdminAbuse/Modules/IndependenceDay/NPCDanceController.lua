local RunService = game:GetService("RunService")
local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local IndependenceDayCutscenes = require(script.Parent.IndependenceDayCutscenes)
local NPCDanceController = {}
local states = {}
local heartbeatConnection = nil

local function buildState(model)
	local tracks = {}

	for _, nPCDance in IndependenceDayConfig.ANIM_IDS.NPCDances do
		local track = IndependenceDayCutscenes.loadTrack(model, nPCDance)

		if not track then
			continue
		end

		track.Looped = true
		table.insert(tracks, track)
	end

	if #tracks ~= 0 then
		return {
			rig = model,
			tracks = tracks,
			currentIndex = nil,
			timeSinceLastChange = 0,
			nextChangeDuration = math.random(
				IndependenceDayConfig.NPC_DANCE_SWITCH_MIN_SEC,
				IndependenceDayConfig.NPC_DANCE_SWITCH_MAX_SEC
			)
		}
	end

	warn("[NPCDanceController] No dance tracks loaded for", model:GetFullName())
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
		warn("[NPCDanceController.Start - Missing mapClone arg]")
		return
	end

	NPCDanceController.Stop()
	local scriptables = instance:FindFirstChild("Scriptables")
	local nPCs = scriptables and scriptables:FindFirstChild("NPCs")

	if not nPCs then
		warn("[NPCDanceController.Start - Scriptables/NPCs not found]")
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
		warn("[NPCDanceController.Start - No NPC rigs found under Scriptables/NPCs]")
	else
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			for _, v in states do
				v.timeSinceLastChange += dt

				if not (v.timeSinceLastChange >= v.nextChangeDuration) then
					continue
				end

				v.timeSinceLastChange = 0
				v.nextChangeDuration = math.random(
					IndependenceDayConfig.NPC_DANCE_SWITCH_MIN_SEC,
					IndependenceDayConfig.NPC_DANCE_SWITCH_MAX_SEC
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