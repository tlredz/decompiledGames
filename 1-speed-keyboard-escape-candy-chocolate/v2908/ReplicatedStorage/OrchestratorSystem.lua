local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local script2 = script
local Concert = require(ReplicatedStorage.Concert)
local ConcertState = require(ReplicatedStorage.Concert.ConcertState)
local ConcertUtils = require(ReplicatedStorage.Concert.ConcertUtils)
local MicroProfiler = require(ReplicatedStorage.Utilities.MicroProfiler)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local OrchestratorState = require(script2.OrchestratorState)
local OrchestratorUtils = require(script2.OrchestratorUtils)
local OrchestratorSystem = {}
local flag = false
local flag2 = false
OrchestratorSystem.OnSequenceChanged = Signal.new()
OrchestratorSystem.OnUpdated = Signal.new()
OrchestratorSystem.OnStripError = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function ReportStripError(actor, strip, p)
	local formatted = `[ORCHESTRATOR] {OrchestratorUtils.FormatActorPath(actor)} / {strip.Type}: {tostring(p)}`
	warn(formatted)
	OrchestratorSystem.OnStripError:Fire(actor, strip, (tostring(p)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MakeContext(actor, root, target, strip, timePosition: number, previousTimePosition: number, deltaTime: number, flag3: boolean)
	return {
		Sequence = OrchestratorState.ActiveSequence,
		Actor = actor,
		Root = root,
		Target = target,
		Strip = strip,
		TimePosition = timePosition,
		PreviousTimePosition = previousTimePosition,
		DeltaTime = deltaTime,
		IsSeeking = flag3,
		IsServer = RunService:IsServer()
	}
end

local function CallStripCallback(p, callback, p2)
	if not callback then
		return true
	end

	local success, result = pcall(callback, p2)

	if success then
		return success
	end

	ReportStripError(p2.Actor, p.Strip, result) -- equivalent call inferred; original call site unknown
	return success
end

local function StopRuntimeStrip(p, state, target)
	if not (state.Started and OrchestratorState.ActiveSequence) then
		return
	end

	local context = MakeContext(
		p.Actor,
		p.Root,
		target,
		state.Strip,
		OrchestratorState.TimePosition,
		OrchestratorState.PreviousTimePosition,
		0,
		true
	) -- equivalent call inferred; original call site unknown
	local onStop = state.Definition.OnStop

	if onStop then
		local success, result = pcall(onStop, context)

		if not success then
			ReportStripError(context.Actor, state.Strip, result) -- equivalent call inferred; original call site unknown
		end
	end

	state.Started = false
end

local function ResolveRuntimeActorTarget(runtimeActor, p)
	local actorTarget = OrchestratorUtils.ResolveActorTarget(runtimeActor.Actor, p)
	local target = actorTarget.Target
	local rootTag = runtimeActor.Actor.RootTag

	if actorTarget.RootCount > 1 and rootTag and not OrchestratorState.DuplicateRootTagsWarned[rootTag] then
		OrchestratorState.DuplicateRootTagsWarned[rootTag] = true
		local v = assert(actorTarget.Root)
		warn((`[ORCHESTRATOR] Tag "{rootTag}" has {actorTarget.RootCount} roots. Using {v:GetFullName()}.`))
	end

	if target == runtimeActor.Target and actorTarget.Root == runtimeActor.Root then
		if not (target or runtimeActor.MissingTargetWarned) then
			runtimeActor.MissingTargetWarned = true
			warn((`[ORCHESTRATOR] Actor path could not be resolved: {OrchestratorUtils.FormatActorPath(runtimeActor.Actor)}`))
		end

		return target
	else
		local target2 = runtimeActor.Target

		if target2 then
			for _, strip in runtimeActor.Strips do
				if not (strip.Started and OrchestratorState.ActiveSequence) then
					continue
				end

				local context = MakeContext(
					runtimeActor.Actor,
					runtimeActor.Root,
					target2,
					strip.Strip,
					OrchestratorState.TimePosition,
					OrchestratorState.PreviousTimePosition,
					0,
					true
				) -- equivalent call inferred; original call site unknown
				local onStop = strip.Definition.OnStop

				if onStop then
					local success, result = pcall(onStop, context)

					if not success then
						ReportStripError(context.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
					end
				end

				strip.Started = false
			end
		end

		runtimeActor.Target = target
		runtimeActor.Root = actorTarget.Root

		for _, strip in runtimeActor.Strips do
			strip.Started = false
			strip.Suppressed = false
			strip.UnsupportedTargetWarned = false
		end

		if target or runtimeActor.MissingTargetWarned then
			if target then
				runtimeActor.MissingTargetWarned = false
			end
		else
			runtimeActor.MissingTargetWarned = true
			warn((`[ORCHESTRATOR] Actor path could not be resolved: {OrchestratorUtils.FormatActorPath(runtimeActor.Actor)}`))
		end

		return target
	end
end

local function EvaluateRuntime(timePosition: number, timePosition2: number, deltaTime: number, flag3: boolean)
	if not OrchestratorState.ActiveSequence then
		return
	end

	local v = {}

	for _, runtimeActor in OrchestratorState.RuntimeActors do
		local target = ResolveRuntimeActorTarget(runtimeActor, v)

		if not target then
			continue
		end

		for _, strip in runtimeActor.Strips do
			if strip.Definition.Supports(target) then
				local context = MakeContext(
					runtimeActor.Actor,
					runtimeActor.Root,
					target,
					strip.Strip,
					timePosition,
					timePosition2,
					deltaTime,
					flag3
				) -- equivalent call inferred; original call site unknown
				local v4

				if strip.Strip.PremiereOnly == true then
					v4 = not (OrchestratorState.UsesConcertClock and Concert.IsPremiere())
				else
					v4 = false
				end

				if v4 then
					if strip.Started and strip.Started and OrchestratorState.ActiveSequence then
						local context2 = MakeContext(
							runtimeActor.Actor,
							runtimeActor.Root,
							target,
							strip.Strip,
							OrchestratorState.TimePosition,
							OrchestratorState.PreviousTimePosition,
							0,
							true
						) -- equivalent call inferred; original call site unknown
						local onStop = strip.Definition.OnStop

						if onStop then
							local success, result = pcall(onStop, context2)

							if not success then
								ReportStripError(context2.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
							end
						end

						strip.Started = false
					end

					if not strip.Suppressed then
						local onSuppressed = strip.Definition.OnSuppressed

						if onSuppressed then
							local success, result = pcall(onSuppressed, context)

							if not success then
								ReportStripError(context.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
							end
						end

						strip.Suppressed = true
					end
				else
					strip.Suppressed = false

					if not strip.Started then
						local onStart = strip.Definition.OnStart
						local success

						if onStart then
							local result
							success, result = pcall(onStart, context)

							if not success then
								ReportStripError(context.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
							end
						else
							success = true
						end

						strip.Started = success
					end

					if strip.Started then
						local evaluate = strip.Definition.Evaluate

						if evaluate then
							local success, result = pcall(evaluate, context)

							if not success then
								ReportStripError(context.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
							end
						end
					end
				end
			elseif not strip.UnsupportedTargetWarned then
				strip.UnsupportedTargetWarned = true
				ReportStripError(
					runtimeActor.Actor,
					strip.Strip,
					`Target is a {target.ClassName}, which this strip does not support.`
				) -- equivalent call inferred; original call site unknown
			end
		end
	end

	OrchestratorState.PreviousTimePosition = timePosition2
	OrchestratorState.TimePosition = timePosition
	OrchestratorSystem.OnUpdated:Fire(timePosition, timePosition2, flag3)
end

local function BuildRuntimeActors(data)
	local runtimeActors = {}

	for k, actor in data.Actors do
		local strips = {}

		for _, strip in actor.Strips do
			if strip.Enabled == false then
				continue
			end

			local stripDefinition = OrchestratorState.StripDefinitions[strip.Type]

			if stripDefinition then
				local flag3 = true

				if stripDefinition.ValidateKeyframe then
					for k2, keyframe in strip.Keyframes do
						local v4, v5 = stripDefinition.ValidateKeyframe(keyframe)

						if v4 then
							continue
						end

						ReportStripError(actor, strip, `Keyframe {k2}: {v5 or "invalid value"}`) -- equivalent call inferred; original call site unknown
						flag3 = false
						break
					end
				end

				if flag3 then
					table.insert(strips, {
						Strip = strip,
						Definition = stripDefinition,
						Started = false,
						Suppressed = false,
						UnsupportedTargetWarned = false
					})
				end
			else
				warn((`[ORCHESTRATOR] Unknown strip type "{strip.Type}" on {OrchestratorUtils.FormatActorPath(actor)}.`))
			end
		end

		table.insert(runtimeActors, {
			Actor = actor,
			Order = k,
			Root = nil,
			Target = nil,
			Strips = strips,
			MissingTargetWarned = false
		})
	end

	table.sort(runtimeActors, function(a, b)
		local count = #a.Actor.InstancePath
		local count2 = #b.Actor.InstancePath

		if count == count2 then
			return a.Order < b.Order
		end

		return count < count2
	end)
	OrchestratorState.RuntimeActors = runtimeActors
	OrchestratorState.DuplicateRootTagsWarned = {}
end

local function ActivateSequence(activeSequence, value: number?, usesConcertClock: boolean)
	OrchestratorSystem.Stop()
	local v = MicroProfiler.Call("Orchestrator.ValidateSequence", function()
		local isValid2, error2 = OrchestratorUtils.ValidateData(activeSequence.Data)
		return {
			IsValid = isValid2,
			Error = error2
		}
	end)
	local isValid = v.IsValid
	local error = v.Error

	if not isValid then
		warn((`[ORCHESTRATOR] Could not play {activeSequence.Name}: {error}`))
		return false
	end

	local v2 = MicroProfiler.Call("Orchestrator.ReconcileSequence", function()
		local v3, report2 = OrchestratorSystem.ReconcilePropertyStrips(activeSequence.Data)
		return {
			Data = v3,
			Report = report2
		}
	end)
	local data = v2.Data
	local report = v2.Report
	activeSequence.Data = data

	for _, error2 in report.Errors do
		warn((`[ORCHESTRATOR] {error2}`))
	end

	OrchestratorState.ActiveSequence = activeSequence
	OrchestratorState.TimePosition = math.max(value or 0, 0)
	OrchestratorState.PreviousTimePosition = OrchestratorState.TimePosition
	OrchestratorState.LastUpdateTime = os.clock()
	OrchestratorState.UsesConcertClock = usesConcertClock
	OrchestratorState.IsPlaying = true
	MicroProfiler.Call("Orchestrator.BuildRuntimeActors", function()
		BuildRuntimeActors(activeSequence.Data)
	end)
	MicroProfiler.Call("Orchestrator.InitialEvaluate", function()
		EvaluateRuntime(OrchestratorState.TimePosition, OrchestratorState.TimePosition, 0, true)
	end)
	OrchestratorSystem.OnSequenceChanged:Fire(activeSequence.Name)
	return true
end

local function LoadBuiltInDefinitions()
	if flag2 then
		return
	end

	flag2 = true
	local propertyStrips = script2:FindFirstChild("PropertyStrips")

	if not propertyStrips then
		warn("[ORCHESTRATOR] PropertyStrips folder was not found.")
		return
	end

	local descendants = propertyStrips:GetDescendants()
	table.sort(descendants, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	for _, moduleScript in descendants do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success then
			OrchestratorSystem.RegisterStripDefinition(result)
		else
			warn((`[ORCHESTRATOR] Could not load strip definition {moduleScript.Name}: {tostring(result)}`))
		end
	end
end

local function PlayConcertStage(name: string?)
	if not name then
		OrchestratorSystem.Stop()
		return
	end

	local stage = ConcertUtils.GetStage(name)
	local v = MicroProfiler.Call("Orchestrator.LoadConcertSequence", function()
		local sequence, error2 = OrchestratorUtils.LoadSequence(name, stage.AssetFolder)
		return {
			Sequence = sequence,
			Error = error2
		}
	end)
	local sequence = v.Sequence
	local error = v.Error

	if sequence then
		ActivateSequence(sequence, ConcertUtils.GetCurrentStageElapsedTime(), true)
		return
	end

	if stage.AssetFolder:FindFirstChild("Orchestrator") then
		warn((`[ORCHESTRATOR] {error}`))
	end

	OrchestratorSystem.Stop()
end

function OrchestratorSystem.RegisterStripDefinition(data)
	assert(type(data) == "table", "Strip definition must be a table.")
	local v

	if type(data.Type) == "string" then
		v = data.Type ~= ""
	else
		v = false
	end

	assert(v, "Strip definition needs a Type.")
	assert(
		data.ContainsKeyframes == nil or type(data.ContainsKeyframes) == "boolean",
		(`Strip definition {data.Type} ContainsKeyframes must be a boolean.`)
	)
	assert(
		data.HasEditableKeyframes == nil or type(data.HasEditableKeyframes) == "boolean",
		(`Strip definition {data.Type} HasEditableKeyframes must be a boolean.`)
	)
	assert(
		data.HasKeyframeEasing == nil or type(data.HasKeyframeEasing) == "boolean",
		(`Strip definition {data.Type} HasKeyframeEasing must be a boolean.`)
	)
	assert(
		data.GlobalEvent == nil or type(data.GlobalEvent) == "boolean",
		(`Strip definition {data.Type} GlobalEvent must be a boolean.`)
	)
	assert(
		data.CreateInitialKeyframe == nil or type(data.CreateInitialKeyframe) == "boolean",
		(`Strip definition {data.Type} CreateInitialKeyframe must be a boolean.`)
	)
	assert(
		data.ContainsKeyframes ~= false or data.HasEditableKeyframes ~= true,
		(`Strip definition {data.Type} cannot expose editable keyframes when it contains no keyframes.`)
	)
	assert(
		not data.GlobalEvent or data.CreateInitialKeyframe == false,
		(`Global event strip {data.Type} must not create a baseline keyframe.`)
	)
	assert(type(data.Supports) == "function", (`Strip definition {data.Type} needs Supports.`))
	assert(type(data.Evaluate) == "function", (`Strip definition {data.Type} needs Evaluate.`))
	assert(
		data.OnSuppressed == nil or type(data.OnSuppressed) == "function",
		(`Strip definition {data.Type} OnSuppressed must be a function.`)
	)
	assert(
		not data.CanAutoCapture or type(data.Capture) == "function",
		(`Auto-capturable strip {data.Type} needs Capture.`)
	)
	assert(
		not data.CanAutoCapture or OrchestratorSystem.StripHasEditableKeyframes(data),
		(`Auto-capturable strip {data.Type} needs editable keyframes.`)
	)
	assert(not OrchestratorState.StripDefinitions[data.Type], (`Strip definition {data.Type} is already registered.`))
	OrchestratorState.StripDefinitions[data.Type] = data
end

function OrchestratorSystem.StripContainsKeyframes(p)
	return p.ContainsKeyframes ~= false
end

function OrchestratorSystem.StripHasEditableKeyframes(p)
	return OrchestratorSystem.StripContainsKeyframes(p) and p.HasEditableKeyframes ~= false
end

function OrchestratorSystem.StripHasKeyframeEasing(p)
	return OrchestratorSystem.StripContainsKeyframes(p) and p.HasKeyframeEasing ~= false
end

function OrchestratorSystem.GetStripDefinition(p: string)
	LoadBuiltInDefinitions()
	return OrchestratorState.StripDefinitions[p]
end

function OrchestratorSystem.GetStripDefinitions()
	LoadBuiltInDefinitions()
	return table.clone(OrchestratorState.StripDefinitions)
end

function OrchestratorSystem.CaptureStripValue(p: string, instance)
	local stripDefinition = OrchestratorSystem.GetStripDefinition(p)
	assert(stripDefinition, (`Unknown strip type {p}.`))
	assert(stripDefinition.Supports(instance), (`{p} does not support {instance.ClassName}.`))
	assert(stripDefinition.Capture, (`{p} does not provide a Capture callback.`))
	return stripDefinition.Capture(instance)
end

function OrchestratorSystem.CreatePropertyStrip(p: string, instance)
	local stripDefinition = OrchestratorSystem.GetStripDefinition(p)
	assert(stripDefinition, (`Unknown strip type {p}.`))
	assert(stripDefinition.Supports(instance), (`{p} does not support {instance.ClassName}.`))
	local v = {
		Type = p,
		Keyframes = {}
	}

	if OrchestratorSystem.StripContainsKeyframes(stripDefinition) and stripDefinition.CreateInitialKeyframe ~= false then
		assert(stripDefinition.Capture, (`{p} cannot capture its initial keyframe because it has no Capture callback.`))
		local v2 = {
			Time = 0,
			Value = stripDefinition.Capture(instance)
		}

		if stripDefinition.ValidateKeyframe then
			local v3, v4 = stripDefinition.ValidateKeyframe(v2)
			assert(v3, v4 or `{p} captured an invalid baseline value.`)
		end

		v.Keyframes = { v2 }
	end

	if stripDefinition.CaptureStripData then
		v.Data = stripDefinition.CaptureStripData(instance)
	end

	return v
end

function OrchestratorSystem.ReconcilePropertyStrips(p)
	local stripDefinitions = OrchestratorSystem.GetStripDefinitions()
	local v = {}

	for k, stripDefinition in stripDefinitions do
		if stripDefinition.Capture or not OrchestratorSystem.StripContainsKeyframes(stripDefinition) then
			table.insert(v, k)
		end
	end

	table.sort(v)
	local actors = p.Actors
	local clone = p
	local v2 = {}
	local count = 0
	local errors = {}
	local changed = false
	local v5 = false

	for _, actor in actors do
		if actor.Id ~= OrchestratorUtils.GLOBAL_EVENT_ACTOR_ID then
			continue
		end

		v5 = true
		break
	end

	if not v5 then
		clone = table.clone(p)
		actors = table.clone(p.Actors)
		clone.Actors = actors
		table.insert(actors, 1, OrchestratorUtils.CreateGlobalEventActor())
		changed = true
	end

	for k, actor in actors do
		local target = OrchestratorUtils.ResolveActorTarget(actor, v2).Target

		if not target then
			continue
		end

		local v7 = {}

		for _, strip in actor.Strips do
			v7[strip.Type] = true
		end

		local strips = actor.Strips
		local flag3 = false

		for _, v8 in v do
			if v7[v8] then
				continue
			end

			local v9 = assert(stripDefinitions[v8])
			local v10 = actor.Id == OrchestratorUtils.GLOBAL_EVENT_ACTOR_ID

			if v9.GlobalEvent == true ~= v10 then
				continue
			end

			local success, result = pcall(v9.Supports, target)

			if success then
				if result then
					local success2, result2 = pcall(OrchestratorSystem.CreatePropertyStrip, v8, target)

					if success2 then
						if not flag3 then
							strips = table.clone(actor.Strips)
							flag3 = true
						end

						table.insert(strips, result2)
						v7[v8] = true
						count += 1
					else
						table.insert(
							errors,
							(`Could not capture {v8} for {OrchestratorUtils.FormatActorPath(actor)}: {tostring(result2)}`)
						)
					end
				end
			else
				table.insert(
					errors,
					(`{v8} failed to inspect {OrchestratorUtils.FormatActorPath(actor)}: {tostring(result)}`)
				)
			end
		end

		if not flag3 then
			continue
		end

		if not changed then
			clone = table.clone(p)
			actors = table.clone(p.Actors)
			clone.Actors = actors
			changed = true
		end

		local clone2 = table.clone(actor)
		clone2.Strips = strips
		actors[k] = clone2
	end

	return clone, {
		Changed = changed,
		AddedStripCount = count,
		Errors = errors
	}
end

function OrchestratorSystem.ApplyDataAtTime(name: string, p2, p3: number, flag3: boolean?)
	LoadBuiltInDefinitions()
	local v, v2 = OrchestratorUtils.ValidateData(p2)

	if not v then
		return false, { v2 or "Invalid orchestrator data." }
	end

	local v3 = table.create(#p2.Actors)

	for k, actor in p2.Actors do
		table.insert(v3, {
			Actor = actor,
			Order = k
		})
	end

	table.sort(v3, function(a, b)
		local count = #a.Actor.InstancePath
		local count2 = #b.Actor.InstancePath

		if count == count2 then
			return a.Order < b.Order
		end

		return count < count2
	end)
	local v4 = math.max(p3, 0)
	local v5 = {}
	local sequence = {
		Name = name,
		Data = p2
	}
	local result = {}

	for _, v7 in v3 do
		local actor = v7.Actor
		local actorTarget = OrchestratorUtils.ResolveActorTarget(actor, v5)
		local target = actorTarget.Target

		if not target then
			continue
		end

		for _, strip in actor.Strips do
			if strip.Enabled == false then
				continue
			end

			local stripDefinition = OrchestratorState.StripDefinitions[strip.Type]

			if not stripDefinition then
				continue
			end

			local success, result2 = pcall(stripDefinition.Supports, target)

			if success then
				if result2 then
					local v8 = {
						Sequence = sequence,
						Actor = actor,
						Root = actorTarget.Root,
						Target = target,
						Strip = strip,
						TimePosition = v4,
						PreviousTimePosition = v4,
						DeltaTime = 0,
						IsSeeking = true,
						IsServer = RunService:IsServer()
					}
					local onSuppressed

					if strip.PremiereOnly == true and flag3 == false then
						onSuppressed = stripDefinition.OnSuppressed
					else
						onSuppressed = stripDefinition.Evaluate
					end

					if onSuppressed then
						local success2, result3 = pcall(onSuppressed, v8)

						if not success2 then
							table.insert(
								result,
								(`{OrchestratorUtils.FormatActorPath(actor)} / {strip.Type}: {tostring(result3)}`)
							)
						end
					end
				end
			else
				table.insert(result, (`{OrchestratorUtils.FormatActorPath(actor)} / {strip.Type}: {tostring(result2)}`))
			end
		end
	end

	return #result == 0, result
end

function OrchestratorSystem.StopDataPreview(name: string, p2, p3: number)
	LoadBuiltInDefinitions()
	local v, v2 = OrchestratorUtils.ValidateData(p2)

	if not v then
		return false, { v2 or "Invalid orchestrator data." }
	end

	local v3 = math.max(p3, 0)
	local v4 = {}
	local sequence = {
		Name = name,
		Data = p2
	}
	local result = {}

	for _, actor in p2.Actors do
		local actorTarget = OrchestratorUtils.ResolveActorTarget(actor, v4)
		local target = actorTarget.Target

		if not target then
			continue
		end

		for _, strip in actor.Strips do
			local stripDefinition = OrchestratorState.StripDefinitions[strip.Type]

			if not (stripDefinition and stripDefinition.OnStop) then
				continue
			end

			local v6 = {
				Sequence = sequence,
				Actor = actor,
				Root = actorTarget.Root,
				Target = target,
				Strip = strip,
				TimePosition = v3,
				PreviousTimePosition = v3,
				DeltaTime = 0,
				IsSeeking = true,
				IsServer = RunService:IsServer()
			}
			local success, result2 = pcall(stripDefinition.OnStop, v6)

			if not success then
				table.insert(result, (`{OrchestratorUtils.FormatActorPath(actor)} / {strip.Type}: {tostring(result2)}`))
			end
		end
	end

	return #result == 0, result
end

function OrchestratorSystem.Start()
	if flag then
		return
	end

	flag = true
	LoadBuiltInDefinitions()
	Concert.OnStageChanged:Connect(PlayConcertStage)

	if ConcertState.PlayingStage then
		PlayConcertStage(ConcertState.PlayingStage.Name)
	end

	RunService.Heartbeat:Connect(function(dt)
		if not (OrchestratorState.ActiveSequence and OrchestratorState.IsPlaying) then
			return
		end

		local timePosition = OrchestratorState.TimePosition
		local v

		if OrchestratorState.UsesConcertClock and ConcertState.PlayingStage then
			v = math.max(ConcertUtils.GetCurrentStageElapsedTime(), 0)
		else
			v = timePosition + dt
		end

		EvaluateRuntime(v, timePosition, dt, math.abs(v - timePosition - dt) > 0.1)
		OrchestratorState.LastUpdateTime = os.clock()
	end)
end

function OrchestratorSystem.Play(p: string, p2, p3: number?)
	LoadBuiltInDefinitions()
	local sequence, v = OrchestratorUtils.LoadSequence(p, p2)

	if sequence then
		return (ActivateSequence(sequence, p3, false))
	end

	warn((`[ORCHESTRATOR] Could not play {p}: {v}`))
	return false
end

function OrchestratorSystem.PlayData(name: string, p2, p3: number?)
	LoadBuiltInDefinitions()
	return (ActivateSequence({
		Name = name,
		Data = p2
	}, p3, false))
end

OrchestratorSystem.PlaySave = OrchestratorSystem.PlayData

function OrchestratorSystem.Pause()
	OrchestratorState.IsPlaying = false
end

function OrchestratorSystem.Resume()
	if OrchestratorState.ActiveSequence then
		OrchestratorState.IsPlaying = true
		OrchestratorState.LastUpdateTime = os.clock()
	end
end

function OrchestratorSystem.Stop()
	if not OrchestratorState.ActiveSequence then
		return
	end

	for _, runtimeActor in OrchestratorState.RuntimeActors do
		local target = runtimeActor.Target

		if not target then
			continue
		end

		for _, strip in runtimeActor.Strips do
			if not (strip.Started and OrchestratorState.ActiveSequence) then
				continue
			end

			local context = MakeContext(
				runtimeActor.Actor,
				runtimeActor.Root,
				target,
				strip.Strip,
				OrchestratorState.TimePosition,
				OrchestratorState.PreviousTimePosition,
				0,
				true
			) -- equivalent call inferred; original call site unknown
			local onStop = strip.Definition.OnStop

			if onStop then
				local success, result = pcall(onStop, context)

				if not success then
					ReportStripError(context.Actor, strip.Strip, result) -- equivalent call inferred; original call site unknown
				end
			end

			strip.Started = false
		end
	end

	OrchestratorState.ActiveSequence = nil
	OrchestratorState.RuntimeActors = {}
	OrchestratorState.TimePosition = 0
	OrchestratorState.PreviousTimePosition = 0
	OrchestratorState.UsesConcertClock = false
	OrchestratorState.IsPlaying = false
	OrchestratorSystem.OnSequenceChanged:Fire(nil)
end

function OrchestratorSystem.SetTimePosition(p: number)
	if not OrchestratorState.ActiveSequence then
		return
	end

	local timePosition2 = math.max(p, 0)
	local timePosition = OrchestratorState.TimePosition

	if OrchestratorState.UsesConcertClock and RunService:IsServer() then
		Concert.SetMusicTimePosition(timePosition2)
	end

	EvaluateRuntime(timePosition2, timePosition, 0, true)
end

function OrchestratorSystem.GetTimePosition()
	return OrchestratorState.TimePosition
end

function OrchestratorSystem.GetActiveSequence()
	return OrchestratorState.ActiveSequence
end

function OrchestratorSystem.IsPlaying()
	return OrchestratorState.IsPlaying
end

return OrchestratorSystem