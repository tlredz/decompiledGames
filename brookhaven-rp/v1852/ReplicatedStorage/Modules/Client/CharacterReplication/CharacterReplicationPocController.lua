local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local YoungRoddoController = require(ReplicatedStorage.Modules.Client.LiveOps.YoungRoddoController)
local CharacterReplicationConfig = require(ReplicatedStorage.Modules.Shared.CharacterReplication.CharacterReplicationConfig)
local CharacterStateInterpolator = require(ReplicatedStorage.Modules.Shared.CharacterReplication.CharacterStateInterpolator)
local CharacterStateSerializer = require(ReplicatedStorage.Modules.Shared.CharacterReplication.CharacterStateSerializer)
local Ascii85Util = require(ReplicatedStorage.Modules.Shared.Utils.Ascii85Util)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local uDim = UDim2.fromScale(8, 1.6)
local rbxassetfontsfamiliesBuilderSansjson = Font.new(
	"rbxasset://fonts/families/BuilderSans.json",
	Enum.FontWeight.Bold
)
local TICK_RATE = CharacterReplicationConfig.TICK_RATE
local v = {}
local v2 = {}
local folder = nil
local enabled2 = false
local v4 = {
	batchesReceived = 0,
	framesReceived = 0,
	framesWithoutReplica = 0,
	renderFrames = 0,
	replicasBuilt = 0,
	replicasUnsupported = 0,
	replicasDestroyedStale = 0
}

local function createNameplate(folder2)
	local head = folder2:FindFirstChild("Head")

	if head == nil then
		return nil
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "YoungRoddoNameplate"
	billboardGui.Size = uDim
	billboardGui.StudsOffsetWorldSpace = createVector(0, 2.5, 0)
	billboardGui.MaxDistance = 500
	billboardGui.AlwaysOnTop = true
	billboardGui.Enabled = false
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Name"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.FontFace = rbxassetfontsfamiliesBuilderSansjson
	textLabel.Text = "Young Roddo"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Parent = billboardGui
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("8c6512")),
		ColorSequenceKeypoint.new(0.3, Color3.fromHex("e8b93c")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("e3db80")),
		ColorSequenceKeypoint.new(0.62, Color3.fromHex("e8b93c")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("7a5410"))
	})
	uIGradient.Parent = textLabel
	billboardGui.Parent = head
	return billboardGui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setNameplateEnabled(enabled: boolean)
	if enabled2 == enabled then
		return
	end

	enabled2 = enabled

	for _, v5 in v do
		if v5.nameplate ~= nil then
			v5.nameplate.Enabled = enabled
		end
	end
end

local function buildReplica(p: number, newestReceivedSampleTime: number)
	local now = os.clock()
	local folder2 = Players:CreateHumanoidModelFromUserIdAsync(p)
	local joints = CharacterStateSerializer.getJoints(folder2)

	if joints == nil then
		v4.replicasUnsupported += 1
		warn((`[CharacterReplicationPoc] {p} has no full AnimationConstraint rig, cannot render a replica`))
		folder2:Destroy()
		return nil
	else
		local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, p)

		if not success then
			nameFromUserIdAsync = tostring(p)
		end

		folder2.Name = `{nameFromUserIdAsync}_Replica`
		local humanoid = folder2:FindFirstChildOfClass("Humanoid")
		humanoid.DisplayName = nameFromUserIdAsync
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameDisplayDistance = 500
		humanoid.HealthDisplayDistance = 0
		humanoid.RequiresNeck = false
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.EvaluateStateMachine = false

		for _, part in folder2:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CollisionGroup = "PCollision"
			part.AudioCanCollide = false
			part.CanTouch = false
			part.Massless = true
		end

		local humanoidRootPart = folder2:FindFirstChild("HumanoidRootPart")
		humanoidRootPart.Anchored = true
		local nameplate = createNameplate(folder2)

		if nameplate ~= nil then
			nameplate.Enabled = enabled2
		end

		v4.replicasBuilt += 1
		return {
			model = folder2,
			rootPart = humanoidRootPart,
			joints = joints,
			interpolator = CharacterStateInterpolator.new(),
			lastSeen = now,
			offset = now - newestReceivedSampleTime,
			nameplate = nameplate,
			diagnostics = {
				framesReceived = 0,
				framesMissing = 0,
				framesLate = 0,
				newestReceivedSampleTime = newestReceivedSampleTime,
				lastRenderTime = 0,
				resyncs = 0,
				rendered = 0,
				skipped = 0
			}
		}
	end
end

local function onCharacterState(p: string)
	local decoded = Ascii85Util.decode(p)
	local v5 = buffer.readu8(decoded, 0)
	local v6 = bit32.band(v5, CharacterReplicationConfig.FLAG_YOUNG_RODDO) > 0
	local enabled = bit32.band(v5, CharacterReplicationConfig.FLAG_YOUNG_RODDO_NAME) > 0
	local v8 = buffer.readu8(decoded, 1)

	if v6 then
		YoungRoddoController.TryShow(v8)
	end

	setNameplateEnabled(enabled) -- equivalent call inferred; original call site unknown
	local v9 = (buffer.len(decoded) - 2) / CharacterStateSerializer.BUFFER_SIZE
	assert(math.round(v9) == v9)
	v4.batchesReceived += 1
	v4.framesReceived += v9
	local values = {}

	for i = 1, v9 do
		local buf = buffer.create(CharacterStateSerializer.BUFFER_SIZE)
		buffer.copy(
			buf,
			0,
			decoded,
			(i - 1) * CharacterStateSerializer.BUFFER_SIZE + 2,
			CharacterStateSerializer.BUFFER_SIZE
		)
		table.insert(values, CharacterStateSerializer.deserialize(buf))
	end

	local now = os.clock()

	for _, v12 in values do
		local v13 = v[v12.userId]

		if v13 == nil then
			v4.framesWithoutReplica += 1

			if v2[v12.userId] == nil then
				v2[v12.userId] = true
				local v15 = v12
				task.spawn(function()
					local success, result = pcall(buildReplica, v15.userId, v15.sampleTime)
					v2[v15.userId] = nil

					if success and result ~= nil then
						v[v15.userId] = result
					elseif not success then
						warn(result)
					end
				end)
			end
		else
			local diagnostics = v13.diagnostics
			diagnostics.framesReceived += 1
			local newestReceivedSampleTime = diagnostics.newestReceivedSampleTime

			if newestReceivedSampleTime < v12.sampleTime then
				diagnostics.framesMissing += math.max(
					math.round((v12.sampleTime - newestReceivedSampleTime) / TICK_RATE) - 1,
					0
				)
				diagnostics.newestReceivedSampleTime = v12.sampleTime
			else
				diagnostics.framesLate += 1
			end

			v13.lastSeen = now

			if v13.interpolator:Push(v12, now) then
				diagnostics.newestReceivedSampleTime = v12.sampleTime
				v13.offset = now - v12.sampleTime
			end
		end
	end
end

local function render()
	debug.profilebegin("replication_client")
	local now = os.clock()
	local v5 = now - CharacterReplicationConfig.INTERPOLATION_DELAY
	v4.renderFrames += 1

	for k, v7 in v do
		if now - v7.lastSeen > 60 then
			v4.replicasDestroyedStale += 1
			v7.model:Destroy()
			v[k] = nil
		else
			local lastRenderTime = v5 - v7.offset
			local resyncTarget = v7.interpolator:GetResyncTarget(lastRenderTime, now)

			if resyncTarget ~= nil then
				v7.diagnostics.resyncs += 1
				v7.offset = v5 - resyncTarget
				lastRenderTime = resyncTarget
			end

			v7.diagnostics.lastRenderTime = lastRenderTime
			local sample = v7.interpolator:Sample(lastRenderTime)

			if sample == nil then
				if v7.model.Parent ~= nil then
					v7.model.Parent = nil
				end

				v7.diagnostics.skipped += 1
			else
				local character = Players.LocalPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart == nil or not ((sample.positions[1] + CharacterReplicationConfig.REPLICA_OFFSET - humanoidRootPart.Position).Magnitude > 300) then
					if v7.model.Parent == nil then
						v7.model.Parent = folder
					end

					v7.diagnostics.rendered += 1
					CharacterStateSerializer.apply(
						sample,
						v7.rootPart,
						v7.joints,
						CharacterReplicationConfig.REPLICA_OFFSET
					)
				elseif v7.model.Parent ~= nil then
					v7.model.Parent = nil
				end
			end
		end
	end

	debug.profileend()
end

local function reportDiagnostics()
	if v4.batchesReceived == 0 and next(v) == nil then
		return
	end

	local v5 = {}

	if v4.framesWithoutReplica > 0 then
		table.insert(v5, (`orphaned {v4.framesWithoutReplica}`))
	end

	if v4.replicasUnsupported > 0 then
		table.insert(v5, (`unsupported {v4.replicasUnsupported}`))
	end

	if v4.replicasDestroyedStale > 0 then
		table.insert(v5, (`destroyedStale {v4.replicasDestroyedStale}`))
	end

	local v6 = `[CharacterReplicationPoc] client {5}s: batches {v4.batchesReceived} frames {v4.framesReceived}` .. ` | renderFrames {v4.renderFrames} | replicas built {v4.replicasBuilt}`

	if #v5 > 0 then
		v6 ..= " | " .. table.concat(v5, " ")
	end

	print(v6)

	for k, v7 in v do
		local diagnostics = v7.diagnostics
		local stats = v7.interpolator:GetStats()
		local v8 = string.format("%.3f", stats.newestSampleTime - diagnostics.lastRenderTime)
		local v9 = string.format("%.3f", stats.span)
		local v10 = {}

		if diagnostics.framesMissing > 0 then
			table.insert(v10, (`missing {diagnostics.framesMissing}`))
		end

		if diagnostics.framesLate > 0 then
			table.insert(v10, (`late {diagnostics.framesLate}`))
		end

		if diagnostics.resyncs > 0 then
			table.insert(v10, (`resyncs {diagnostics.resyncs}`))
		end

		if stats.rejectedStale > 0 then
			table.insert(v10, (`stale {stats.rejectedStale}`))
		end

		if diagnostics.skipped > 0 then
			table.insert(v10, (`skipped {diagnostics.skipped}`))
		end

		if stats.sampleClamped > 0 then
			table.insert(v10, (`clamped {stats.sampleClamped}`))
		end

		if stats.sampleWarmup > 0 then
			table.insert(v10, (`warmup {stats.sampleWarmup}`))
		end

		if stats.sampleEmpty > 0 then
			table.insert(v10, (`empty {stats.sampleEmpty}`))
		end

		local v11 = `[CharacterReplicationPoc]   {k}: recv {diagnostics.framesReceived} pushed {stats.pushed} evicted {stats.evicted}` .. ` | buffer {stats.buffered} span {v9}s lag {v8}s` .. ` | rendered {diagnostics.rendered} interpolated {stats.sampleInterpolated}`

		if #v10 > 0 then
			v11 ..= " | " .. table.concat(v10, " ")
		end

		print(v11)
		diagnostics.framesReceived = 0
		diagnostics.framesMissing = 0
		diagnostics.framesLate = 0
		diagnostics.resyncs = 0
		diagnostics.rendered = 0
		diagnostics.skipped = 0
		v7.interpolator:ResetCounters()
	end

	v4.batchesReceived = 0
	v4.framesReceived = 0
	v4.framesWithoutReplica = 0
	v4.renderFrames = 0
	v4.replicasBuilt = 0
	v4.replicasUnsupported = 0
	v4.replicasDestroyedStale = 0
end

return {
	FrameworkStart = function()
		folder = Instance.new("Folder")
		folder.Name = "CharacterReplicationPocReplicas"
		folder.Parent = Workspace
		Remotes.connectUnreliable(CharacterReplicationConfig.CHARACTER_STATE_EVENT, onCharacterState)
		RunService.PreSimulation:Connect(render)
		task.spawn(function()
			while true do
				task.wait(5)
				reportDiagnostics()
			end
		end)
	end
}