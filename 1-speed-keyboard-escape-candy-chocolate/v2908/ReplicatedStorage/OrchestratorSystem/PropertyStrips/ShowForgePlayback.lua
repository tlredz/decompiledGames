local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaybackSession = require(ReplicatedStorage.ShowForgeRuntime.PlaybackSession)
local object = setmetatable({}, {
	__mode = "k"
})

local function hasFolder(instance, childName: string)
	local folder = instance:FindFirstChild(childName)
	return folder ~= nil and folder:IsA("Folder")
end

local function hasRuntimeHierarchy(instance)
	local fixtures = instance:FindFirstChild("Fixtures")
	local beamTargetAnchor = instance:FindFirstChild("BeamTargetAnchor")
	local v

	if fixtures == nil then
		return false
	else
		v = fixtures:IsA("Folder")

		if v then
			if beamTargetAnchor == nil then
				return false
			else
				return (beamTargetAnchor:IsA("BasePart"))
			end
		end
	end

	return v
end

local function supports(model)
	if not model:IsA("Model") or model:GetAttribute("ShowForgePlaybackDriver") ~= "Orchestrator" then
		return false
	end

	local fixtures = model:FindFirstChild("Fixtures")
	local beamTargetAnchor = model:FindFirstChild("BeamTargetAnchor")
	local v

	if fixtures == nil then
		v = false
	else
		v = fixtures:IsA("Folder")

		if v then
			if beamTargetAnchor == nil then
				v = false
			else
				v = beamTargetAnchor:IsA("BasePart")
			end
		end
	end

	if not v then
		return false
	end

	local showForgeSchemaVersion = model:GetAttribute("ShowForgeSchemaVersion")
	local v2

	if model:GetAttribute("ShowForgeSchema") == "showforge.roblox.exchange" and (showForgeSchemaVersion == 2 or showForgeSchemaVersion == 3) then
		local dataChunks = model:FindFirstChild("DataChunks")

		if dataChunks == nil then
			v2 = false
		else
			v2 = dataChunks:IsA("Folder")
		end

		if v2 then
			local animationData = model:FindFirstChild("AnimationData")

			if animationData == nil then
				v2 = false
			else
				v2 = animationData:IsA("Folder")
			end
		end
	else
		v2 = false
	end

	if v2 then
		return true
	end

	local datasets = model:FindFirstChild("Datasets")

	if not (datasets and datasets:IsA("Folder")) then
		return false
	end

	for _, folder in datasets:GetChildren() do
		if not folder:IsA("Folder") then
			continue
		end

		local dataChunks = folder:FindFirstChild("DataChunks")
		local v3

		if dataChunks == nil then
			v3 = false
		else
			v3 = dataChunks:IsA("Folder")
		end

		if not v3 then
			continue
		end

		local animationData = folder:FindFirstChild("AnimationData")
		local v4

		if animationData == nil then
			v4 = false
		else
			v4 = animationData:IsA("Folder")
		end

		if v4 then
			return true
		end
	end

	return false
end

local function resolveDatasetRoot(instance, childName)
	if childName == nil then
		local dataChunks = instance:FindFirstChild("DataChunks")
		local v

		if dataChunks == nil then
			v = false
		else
			v = dataChunks:IsA("Folder")
		end

		if v then
			local animationData = instance:FindFirstChild("AnimationData")

			if animationData == nil then
				v = false
			else
				v = animationData:IsA("Folder")
			end
		end

		assert(v, "ShowForge legacy playback target has an invalid runtime hierarchy")
		return instance
	else
		local v

		if type(childName) == "string" then
			v = childName ~= ""
		else
			v = false
		end

		assert(v, "ShowForge DatasetName must be a non-empty string")
		local datasets = instance:FindFirstChild("Datasets")
		assert(datasets and datasets:IsA("Folder"), "ShowForge playback target has no Datasets folder")
		local folder = datasets:FindFirstChild(childName)
		assert(
			folder and folder:IsA("Folder") and folder.Parent == datasets,
			(`ShowForge dataset {childName} is missing or invalid`)
		)
		assert(folder:IsDescendantOf(instance), "ShowForge dataset must remain under the playback target")
		local dataChunks = folder:FindFirstChild("DataChunks")
		local v2

		if dataChunks == nil then
			v2 = false
		else
			v2 = dataChunks:IsA("Folder")
		end

		if v2 then
			local animationData = folder:FindFirstChild("AnimationData")

			if animationData == nil then
				v2 = false
			else
				v2 = animationData:IsA("Folder")
			end
		end

		assert(v2, (`ShowForge dataset {childName} has an invalid runtime hierarchy`))
		return folder
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evict(target)
	local v = object[target]

	if v and v.Session then
		v.Session:Destroy()
	end

	object[target] = nil
end

local ShowForgePlayback = {}
ShowForgePlayback.Type = "ShowForgePlayback"
ShowForgePlayback.DisplayName = "ShowForge Playback"
ShowForgePlayback.ContainsKeyframes = true
ShowForgePlayback.HasEditableKeyframes = false
ShowForgePlayback.Supports = supports

function ShowForgePlayback.Evaluate(data)
	if RunService:IsRunning() and data.IsServer then
		return
	end

	local target = data.Target

	if target:GetAttribute("ShowForgePlaybackDriver") ~= "Orchestrator" then
		evict(target) -- equivalent call inferred; original call site unknown
		error("ShowForgePlayback target is not owned by Orchestrator")
	end

	if not supports(target) then
		evict(target) -- equivalent call inferred; original call site unknown
		error("ShowForgePlayback target is not an imported ShowForge model")
	end

	local data2

	if type(data.Strip.Data) == "table" then
		data2 = data.Strip.Data
	end

	local datasetName

	if data2 then
		datasetName = data2.DatasetName
	end

	local loop

	if data2 then
		loop = data2.Loop
	end

	local timeOffset

	if data2 then
		timeOffset = data2.TimeOffset
	end

	local success, result = pcall(resolveDatasetRoot, target, datasetName)

	if not success then
		evict(target) -- equivalent call inferred; original call site unknown
		error((tostring(result)))
	end

	local showForgeDataRevision = result:GetAttribute("ShowForgeDataRevision") or 0
	local v = object[target]

	if v and (v.DatasetRoot ~= result or v.Revision ~= showForgeDataRevision or v.Loop ~= loop or v.TimeOffset ~= timeOffset or v.Session and not v.Session:IsValid()) then
		if v.Session then
			v.Session:Destroy()
		end

		object[target] = nil
		v = nil
	end

	local v2 = data.TimePosition - data.PreviousTimePosition

	if not data.IsSeeking and v2 <= 0 then
		return
	end

	if v and not v.Session then
		if v.Initializing or v.Blocked or (v.Failures >= 3 or os.clock() < v.RetryAt) then
			return
		end
	end

	if not (v and v.Session) then
		local v3 = v or {
			DatasetRoot = result,
			Revision = showForgeDataRevision,
			Loop = loop,
			TimeOffset = timeOffset,
			Failures = 0,
			RetryAt = 0
		}
		v3.Initializing = true
		object[target] = v3
		debug.profilebegin("ShowForge.InitializeSession")
		local success2, result2 = pcall(PlaybackSession.new, target, {
			PreserveStorage = true,
			DatasetRoot = result,
			Loop = loop,
			TimeOffset = timeOffset
		})
		debug.profileend()
		v3.Initializing = false

		if not success2 then
			local failures = not v3 and 1 or v3.Failures + 1
			object[target] = {
				DatasetRoot = result,
				Revision = showForgeDataRevision,
				Loop = loop,
				TimeOffset = timeOffset,
				Failures = failures,
				RetryAt = os.clock() + 2 ^ failures
			}
			error((`Could not initialize ShowForge playback: {tostring(result2)}`))
		end

		v = {
			DatasetRoot = result,
			Revision = showForgeDataRevision,
			Loop = loop,
			TimeOffset = timeOffset,
			Failures = 0,
			RetryAt = 0,
			Session = result2
		}
		object[target] = v
	end

	local session = v.Session
	assert(session, "ShowForge playback session was not initialized")
	debug.profilebegin("ShowForge.EvaluateSession")
	local success2, result2 = pcall(
		session.Evaluate,
		session,
		data.TimePosition,
		data.IsSeeking and 0 or v2,
		workspace.CurrentCamera
	)
	debug.profileend()

	if not success2 then
		session:Disable()
		v.Blocked = true
		error((`ShowForge playback failed closed: {tostring(result2)}`))
	end
end

function ShowForgePlayback.OnStop(p)
	evict(p.Target) -- equivalent call inferred; original call site unknown
end

return ShowForgePlayback