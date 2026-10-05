local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local clock = os.clock
local Geometry = require(script:WaitForChild("Geometry"))
local ClockBudget = require(game.ReplicatedStorage.Util.ClockBudget)
local v, v2 = ClockBudget(0.0025, RunService.Heartbeat)

-- equivalent calls inferred from this helper; original call sites unknown
local function DiscretePulse(p, pulseSpeed, pulseLength, fadeLength, p2, min, max)
	return (math.clamp(
		pulseLength / (2 * fadeLength) - math.abs((p - p2 * pulseSpeed + 0.5 * pulseLength) / fadeLength),
		min,
		max
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NoiseBetween(p, p2, p3, minThicknessMultiplier, maxThicknessMultiplier)
	return minThicknessMultiplier + (maxThicknessMultiplier - minThicknessMultiplier) * (math.noise(p, p2, p3) + 0.5)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(worldPosition, p, p2, worldPosition2, p3)
	return worldPosition * (1 - p3) ^ 3 + p * 3 * p3 * (1 - p3) ^ 2 + p2 * 3 * (1 - p3) * p3 ^ 2 + worldPosition2 * p3 ^ 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isMeshColorSupported(color)
	local typeName = typeof(color)
	return typeName == "Color3" or typeName == "ColorSequence"
end

local function resolveMeshColor(color)
	if typeof(color) == "Color3" then
		return color
	end

	if typeof(color) ~= "ColorSequence" then
		return nil
	end

	local keypoints = color.Keypoints
	local total = 0
	local total2 = 0
	local total3 = 0
	local total4 = 0

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]
		local v3 = keypoint2.Time - keypoint.Time
		local v4 = 0.5 * v3
		total += (keypoint.Value.R + keypoint2.Value.R) * v4
		total2 += (keypoint.Value.G + keypoint2.Value.G) * v4
		total3 += (keypoint.Value.B + keypoint2.Value.B) * v4
		total4 += v3
	end

	if total4 > 0 then
		return (Color3.new(total / total4, total2 / total4, total3 / total4))
	end

	return keypoints[1].Value
end

local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.CanQuery = false
part.CanTouch = false
part.Shape = "Cylinder"
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 1
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local v3 = {}
local v4 = 0
local count = 0
local heartbeatConnection = nil
local flag = false
local fn
local fn2
local v5 = nil

local function loadTemplate(childName)
	local part2 = script:FindFirstChild(childName)

	if part2 == nil then
		return nil
	end

	local meshPart

	if part2:IsA("MeshPart") then
		meshPart = part2
	else
		meshPart = part2:FindFirstChildWhichIsA("MeshPart", true)
	end

	if meshPart == nil then
		warn("LightningBoltShafi: template " .. childName .. " has no MeshPart; using legacy parts")
		return nil
	end

	local v6 = {}
	local ringCount = 0

	for _, bone in meshPart:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		local v8 = string.match(bone.Name, "^R(%d+)[AB]$")

		if v8 == nil then
			continue
		end

		local v9 = tonumber(v8)
		v6[v9] = (v6[v9] or 0) + 1

		if ringCount < v9 then
			ringCount = v9
		end
	end

	if ringCount < 3 then
		warn("LightningBoltShafi: template " .. childName .. " has too few ring bones; using legacy parts")
		return nil
	end

	for i = 1, ringCount do
		if v6[i] == 2 then
			continue
		end

		warn("LightningBoltShafi: template " .. childName .. " is missing ring bones; using legacy parts")
		return nil
	end

	return {
		Name = childName,
		Template = part2,
		RingCount = ringCount,
		Pool = {}
	}
end

local v6 = loadTemplate("BoltMesh12")
local v7 = loadTemplate("BoltMesh40")
local v8 = {}

if v6 ~= nil then
	table.insert(v8, v6)
end

if v7 ~= nil then
	table.insert(v8, v7)
end

local v9 = false
local cframe = CFrame.new(0, 9000000, 9000000)
local flag2 = false

local function sweepPools(p: number)
	local v10 = false

	for i = 1, #v8 do
		local pool = v8[i].Pool

		for i2 = #pool, 1, -1 do
			local v11 = pool[i2]

			if p - v11.ReleasedAt > 30 or v11.Dead then
				table.remove(pool, i2)
				v11.Root:Destroy()
			else
				v10 = true
			end
		end
	end

	return v10
end

local schedulePoolCleanup

schedulePoolCleanup = function()
	if flag2 then
		return
	end

	flag2 = true
	task.delay(30, function()
		flag2 = false

		if sweepPools(clock()) then
			schedulePoolCleanup()
		end
	end)
end

local LightningBoltShafi = {}
LightningBoltShafi.__index = LightningBoltShafi
LightningBoltShafi.ForceLegacy = false
local v10 = {}
local v11 = {}
local v12 = false
local flag3 = false
local count2 = 0
local count3 = 0

local function failParallelWorkers(p)
	if flag3 then
		return
	end

	flag3 = true

	for _, v13 in v10 do
		v13.Ready = false
		v13.Busy = false
		v13.SentAt = nil
	end

	for _, v13 in pairs(v3) do
		v13.ParallelInFlight = nil
	end

	table.clear(v11)
	warn("LightningBoltShafi: parallel workers disabled; using serial fallback (" .. tostring(p) .. ")")
end

local function startParallelWorkers()
	if v12 or flag3 or not (RunService:IsClient() and RunService:IsRunning()) then
		return
	end

	v12 = true
	task.spawn(function()
		local success, result = pcall(function()
			local localPlayer = Players.LocalPlayer

			if localPlayer == nil then
				error("LocalPlayer is unavailable")
			end

			local playerScripts = localPlayer:WaitForChild("PlayerScripts")
			local parallelWorker = script:FindFirstChild("ParallelWorker")

			if parallelWorker == nil or not parallelWorker:IsA("LocalScript") then
				error("ParallelWorker template is unavailable")
			end

			local folder = Instance.new("Folder")
			folder.Name = "LightningBoltShafiWorkers"
			folder.Parent = playerScripts

			for i = 1, 3 do
				local actor = Instance.new("Actor")
				actor.Name = "Worker" .. i
				local bindableEvent = Instance.new("BindableEvent")
				bindableEvent.Name = "Request"
				bindableEvent.Parent = actor
				local bindableEvent2 = Instance.new("BindableEvent")
				bindableEvent2.Name = "Result"
				bindableEvent2.Parent = actor
				local bindableEvent3 = Instance.new("BindableEvent")
				bindableEvent3.Name = "Ready"
				bindableEvent3.Parent = actor
				local clone = parallelWorker:Clone()
				clone.Enabled = false
				clone.Name = "Runtime"
				clone.Parent = actor
				local v13 = {
					Actor = actor,
					Request = bindableEvent,
					Ready = false,
					Busy = false,
					BatchId = 0,
					SentAt = nil
				}
				v10[i] = v13
				bindableEvent2.Event:Connect(function(p, p2, value)
					if flag3 or p ~= v13.BatchId then
						return
					end

					v13.Busy = false
					v13.SentAt = nil

					if p2 == nil then
						failParallelWorkers(value or "worker returned no results")
					else
						v11[#v11 + 1] = p2
					end
				end)
				local v15 = v13
				bindableEvent3.Event:Connect(function()
					if not flag3 then
						v15.Ready = true
					end
				end)
				actor.Parent = folder
				clone.Enabled = true
			end
		end)

		if not success then
			failParallelWorkers(result)
		end
	end)
end

local function hasReadyParallelWorker()
	if flag3 then
		return false
	end

	for _, v13 in v10 do
		if v13.Ready then
			return true
		end
	end

	return false
end

local function setRingTransform(data, i, rigAlign, p)
	local v13 = data.BonesA[i]
	local v14 = data.BonesB[i]
	v13.Transform = data.BindInverseA[i] * rigAlign * CFrame.fromAxisAngle(data.RigAxis, p) * data.BindRotA[i]
	v14.Transform = data.BindInverseB[i] * rigAlign * CFrame.fromAxisAngle(data.RigAxis, -p) * data.BindRotB[i]
end

local function buildLegacyParts(data)
	local attachment0 = data.Attachment0
	local attachment1 = data.Attachment1
	local skillVisuals = data.SkillVisuals
	local worldPosition = attachment0.WorldPosition
	local v13 = attachment0.WorldPosition + attachment0.WorldAxis * data.CurveSize0
	local v14 = attachment1.WorldPosition - attachment1.WorldAxis * data.CurveSize1
	local worldPosition2 = attachment1.WorldPosition
	local segmentCount = data.SegmentCount
	local v15 = worldPosition
	local v16 = v15
	v15 = v16

	for i = 1, segmentCount do
		local cubicBezier = CubicBezier(worldPosition, v13, v14, worldPosition2, i / segmentCount)
		local position

		if i == segmentCount then
			position = cubicBezier
		else
			position = CFrame.lookAt(v15, cubicBezier).Position or cubicBezier
		end

		local clone = part:Clone()
		clone.Size = Vector3.new((position - v16).Magnitude, 0, 0)
		clone.CFrame = CFrame.lookAt(0.5 * (v16 + position), position) * inverse
		clone.Parent = skillVisuals
		clone.Locked = true
		clone.CastShadow = false
		data.Parts[i] = clone
		v15 = cubicBezier
		v16 = position
	end
end

local function newMeshRig(template)
	local clone = template.Template:Clone()
	local meshPart

	if clone:IsA("MeshPart") then
		meshPart = clone
	else
		meshPart = clone:FindFirstChildWhichIsA("MeshPart", true)
	end

	meshPart.Anchored = true
	meshPart.CanCollide = false
	meshPart.CanQuery = false
	meshPart.CanTouch = false
	meshPart.CastShadow = false
	meshPart.AudioCanCollide = false
	meshPart.EnableFluidForces = false
	meshPart.Locked = true
	meshPart.Material = Enum.Material.Neon
	local ringCount = template.RingCount
	local bones = table.create(ringCount)
	local bones2 = table.create(ringCount)
	local parents = table.create(ringCount)
	local parents2 = table.create(ringCount)

	for _, bone in meshPart:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		local v13, v14 = string.match(bone.Name, "^R(%d+)([AB])$")

		if v13 == nil then
			continue
		end

		local v15 = tonumber(v13)

		if v14 == "A" then
			local parent = bone.Parent
			bones[v15] = bone
			parents[v15] = parent
		else
			local parent = bone.Parent
			bones2[v15] = bone
			parents2[v15] = parent
		end
	end

	local cFrame = meshPart.CFrame
	local unit = (cFrame:ToObjectSpace(bones[ringCount].WorldCFrame).Position - cFrame:ToObjectSpace(bones[1].WorldCFrame).Position).Unit
	local rotations = table.create(ringCount)
	local rotations2 = table.create(ringCount)
	local inverses = table.create(ringCount)
	local inverses2 = table.create(ringCount)

	for i = 1, ringCount do
		local cframe2 = cFrame:ToObjectSpace(bones[i].WorldCFrame)
		local cframe3 = cFrame:ToObjectSpace(bones2[i].WorldCFrame)
		local rotation = cframe2.Rotation
		local inverse2 = cframe2:Inverse()
		rotations[i] = rotation
		inverses[i] = inverse2
		local rotation2 = cframe3.Rotation
		local inverse3 = cframe3:Inverse()
		rotations2[i] = rotation2
		inverses2[i] = inverse3
	end

	local v13 = math.abs(unit.Y) > 0.99 and createVector(0, 0, 1) or createVector(0, 1, 0)
	local inverse2 = (CFrame.lookAt(createVector(0, 0, 0), unit, v13) * inverse):Inverse()

	if clone:IsA("Model") then
		local humanoid = Instance.new("Humanoid")
		humanoid.EvaluateStateMachine = false
		humanoid.RequiresNeck = false
		humanoid.BreakJointsOnDeath = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.MaxHealth = 0
		humanoid.Health = 0
		humanoid.Parent = clone
	end

	local v14 = {
		Template = template,
		Root = clone,
		MeshPart = meshPart,
		BonesA = bones,
		BonesB = bones2,
		OrigParentA = parents,
		OrigParentB = parents2,
		RigAxis = unit,
		RigAlign = inverse2,
		BindRotA = rotations,
		BindRotB = rotations2,
		BindInverseA = inverses,
		BindInverseB = inverses2,
		TailIndex = nil,
		Dead = false
	}
	clone.Destroying:Connect(function()
		v14.Dead = true
	end)
	return v14
end

local function acquireMeshRig(template)
	local pool = template.Pool

	while #pool > 0 do
		local v13 = table.remove(pool)

		if not v13.Dead and clock() - v13.ReleasedAt <= 30 then
			return v13
		end

		v13.Root:Destroy()
	end

	return (newMeshRig(template))
end

local function releaseMeshRig(p)
	local rig = p.Rig
	p.Rig = nil
	p.MeshRoot = nil
	p.MeshPart = nil
	p.BonesA = nil
	p.BonesB = nil
	p.BindRotA = nil
	p.BindRotB = nil
	p.BindInverseA = nil
	p.BindInverseB = nil
	p.TemplateName = nil

	if rig.Dead or not pcall(function()
		rig.Root.Parent = nil
	end) then
		return
	end

	rig.MeshPart.Transparency = 1
	rig.MeshPart.CFrame = cframe
	rig.ReleasedAt = clock()
	table.insert(rig.Template.Pool, rig)

	if flag2 then
		return
	end

	flag2 = true
	task.delay(30, function()
		flag2 = false

		if sweepPools(clock()) then
			schedulePoolCleanup()
		end
	end)
end

local function buildMeshBolt(self, template)
	local rig = acquireMeshRig(template)
	local meshPart = rig.MeshPart
	local ringCount = template.RingCount
	local bonesA = rig.BonesA
	local bonesB = rig.BonesB
	local tailIndex = self.SegmentCount + 2

	if ringCount < tailIndex then
		tailIndex = nil
	end

	if rig.TailIndex ~= tailIndex then
		if rig.TailIndex ~= nil then
			for i = rig.TailIndex + 1, ringCount do
				bonesA[i].Parent = rig.OrigParentA[i]
				bonesB[i].Parent = rig.OrigParentB[i]
			end
		end

		if tailIndex ~= nil then
			local parent = bonesA[tailIndex]
			local parent2 = bonesB[tailIndex]

			for i = tailIndex + 1, ringCount do
				bonesA[i].Parent = parent
				bonesB[i].Parent = parent2
			end
		end

		rig.TailIndex = tailIndex
	end

	if tailIndex ~= nil then
		local inverse2 = rig.BindRotA[tailIndex]:Inverse()
		local inverse3 = rig.BindRotB[tailIndex]:Inverse()

		for i = tailIndex + 1, ringCount do
			local v15 = bonesA[i]
			local v16 = bonesB[i]
			v15.Transform = v15.CFrame:Inverse() * inverse2 * rig.BindRotA[i]
			v16.Transform = v16.CFrame:Inverse() * inverse3 * rig.BindRotB[i]
		end
	end

	local v15 = math.min(meshPart.Size.X, meshPart.Size.Y, meshPart.Size.Z)
	local v16 = math.max(4, (self.Thickness or 1) * self.MaxThicknessMultiplier * 0.5)
	meshPart.Size *= v16 / (v15 * 0.5)
	meshPart.Transparency = 1
	self.Rig = rig
	self.MeshRoot = rig.Root
	self.MeshPart = meshPart
	self.BonesA = bonesA
	self.BonesB = bonesB
	self.RingCount = ringCount
	self.RigAxis = rig.RigAxis
	self.RigAlign = rig.RigAlign
	local bindRotA = rig.BindRotA
	local bindRotB = rig.BindRotB
	self.BindRotA = bindRotA
	self.BindRotB = bindRotB
	local bindInverseA = rig.BindInverseA
	local bindInverseB = rig.BindInverseB
	self.BindInverseA = bindInverseA
	self.BindInverseB = bindInverseB
	self.BindRadius = math.min(meshPart.Size.X, meshPart.Size.Y, meshPart.Size.Z) * 0.5
	self.TemplateName = template.Name
	self.Mode = "Mesh"
	self.PackedInvisible = true
	self.MeshReady = false
	self.MeshOrigin = nil
	self.AppliedMeshOrigin = nil
	meshPart.CFrame = CFrame.new(self.Attachment0.WorldPosition)

	for i = 1, tailIndex or ringCount do
		setRingTransform(self, i, self.RigAlign, 1.5707963267948966)
	end

	rig.Root.Parent = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function convertToLegacy(p)
	p.ParallelInFlight = nil
	p.Mode = "Legacy"
	buildLegacyParts(p)

	if p.Rig ~= nil then
		releaseMeshRig(p)
	end
end

function LightningBoltShafi.new(attachment, attachment2, value, thickness, skillVisuals, color)
	local self = setmetatable({}, LightningBoltShafi)
	self.Enabled = true
	self.Attachment0 = attachment
	self.Attachment1 = attachment2
	self.CurveSize0 = 0
	self.CurveSize1 = 0
	self.MinRadius = 0
	self.MaxRadius = 5.4
	self.Frequency = 2
	self.AnimationSpeed = 3
	self.Thickness = thickness
	local maxThicknessMultiplier = math.random(1, 2)
	self.MinThicknessMultiplier = 0.2
	self.MaxThicknessMultiplier = maxThicknessMultiplier
	self.MinTransparency = 0
	self.MaxTransparency = 1
	self.PulseSpeed = 10
	self.PulseLength = 1000000
	self.FadeLength = 0.2
	self.ContractFrom = 0.5
	self.Color = Color3.new(0.388235, 0.470588, 1)
	self.ColorOffsetSpeed = 3

	if color then
		self.Color = color
	end

	self.Parts = {}
	local segmentCount = math.floor(value or 30)
	self.SegmentCount = segmentCount
	self.Points = table.create(segmentCount + 1)
	self.Radii = table.create(segmentCount)
	self.Opacities = table.create(segmentCount)
	self.TrackSegmentState = false
	self.Destroyed = false
	self.SkillVisuals = skillVisuals
	local v15 = nil

	if LightningBoltShafi.ForceLegacy ~= true and isMeshColorSupported(self.Color) and segmentCount >= 1 then
		if v6 == nil or not (segmentCount <= v6.RingCount - 1) then
			if v7 == nil or not (segmentCount <= v7.RingCount - 1) then
				if (v6 ~= nil or v7 ~= nil) and v9 == false then
					v9 = true
					warn("LightningBoltShafi: PartCount " .. segmentCount .. " exceeds the largest bolt mesh template; using legacy parts")
				end
			else
				v15 = v7
			end
		else
			v15 = v6
		end
	end

	if v15 == nil then
		self.Mode = "Legacy"
		buildLegacyParts(self)
	else
		buildMeshBolt(self, v15)
		startParallelWorkers()
	end

	self.PartsHidden = false
	self.DisabledTransparency = 1
	self.StartT = clock()
	self.RanNum = math.random() * 100
	count += 1
	self.RefIndex = count
	v3[self.RefIndex] = self
	v4 += 1
	fn()
	return self
end

function LightningBoltShafi:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.ParallelInFlight = nil
	v3[self.RefIndex] = nil
	v4 -= 1

	if v4 == 0 then
		fn2()
	end

	if self.Rig ~= nil then
		releaseMeshRig(self)
	end

	for i = 1, #self.Parts do
		self.Parts[i]:Destroy()

		if i % 100 == 0 then
			task.wait()
		end
	end
end

local v13 = 0
local v14 = {}
local v15 = {}
local count4 = 0
local v16 = {}
local v17 = {}
local v18 = {}
local count5 = 0
local v19 = {}
local count6 = 0
local v20 = {}
local v21 = {}
local v22 = {}
local v23 = {}

local function makeMeshJob(state, timePassed: number)
	count3 += 1
	local attachment0 = state.Attachment0
	local attachment1 = state.Attachment1
	local worldPosition = attachment0.WorldPosition
	local worldPosition2 = attachment1.WorldPosition
	local meshOrigin2 = (worldPosition + worldPosition2) * 0.5
	local meshOrigin = state.MeshOrigin

	if meshOrigin == nil then
		state.MeshOrigin = meshOrigin2
		meshOrigin = meshOrigin2
	else
		local vector2 = meshOrigin2 - meshOrigin

		if vector2:Dot(vector2) >= 4 then
			state.MeshOrigin = meshOrigin2
			meshOrigin = meshOrigin2
		end
	end

	return {
		BranchId = state.RefIndex,
		JobId = count3,
		TemplateName = state.TemplateName,
		SegmentCount = state.SegmentCount,
		P0 = worldPosition,
		P1 = worldPosition + attachment0.WorldAxis * state.CurveSize0,
		P2 = worldPosition2 - attachment1.WorldAxis * state.CurveSize1,
		P3 = worldPosition2,
		MeshOrigin = meshOrigin,
		TimePassed = timePassed,
		MinOpacity = 1 - state.MaxTransparency,
		MaxOpacity = 1 - state.MinTransparency,
		MinRadius = state.MinRadius,
		MaxRadius = state.MaxRadius,
		Thickness = state.Thickness,
		RandomSeed = state.RanNum,
		AnimationSpeed = state.AnimationSpeed,
		Frequency = state.Frequency,
		MinThicknessMultiplier = state.MinThicknessMultiplier,
		MaxThicknessMultiplier = state.MaxThicknessMultiplier,
		PulseLength = state.PulseLength,
		PulseSpeed = state.PulseSpeed,
		FadeLength = state.FadeLength,
		ContractFactor = 1 - state.ContractFrom,
		BindRadius = state.BindRadius,
		PackedInvisible = state.PackedInvisible,
		TrackSegmentState = state.TrackSegmentState
	}
end

local function collectMeshResult(data, flag4: boolean, p: number)
	local v24 = v3[data.BranchId]

	if v24 == nil then
		return
	end

	if flag4 then
		if v24.ParallelInFlight ~= data.JobId then
			return
		end

		v24.ParallelInFlight = nil
	end

	if not v24.Destroyed and v24.Enabled and v24.Mode == "Mesh" and isMeshColorSupported(v24.Color) and v24.Rig ~= nil and not (v24.Rig.Dead or p - v24.StartT >= (v24.PulseLength + 1) / v24.PulseSpeed) then
		if data.Points ~= nil then
			v24.Points = data.Points
		end

		if data.Radii ~= nil then
			v24.Radii = data.Radii
		end

		if data.Opacities ~= nil then
			v24.Opacities = data.Opacities
		end

		v24.PackedInvisible = data.PackedInvisible
		local transforms = data.Transforms

		if transforms == nil then
			return
		end

		local meshOrigin = data.MeshOrigin

		if v24.AppliedMeshOrigin ~= meshOrigin then
			v24.MeshPart.CFrame = CFrame.new(meshOrigin)
			v24.AppliedMeshOrigin = meshOrigin
		end

		for i = 1, data.PoseCount do
			local v25 = i * 2 - 1
			count4 += 1
			v14[count4] = v24.BonesA[i]
			v15[count4] = transforms[v25]
			count4 += 1
			v14[count4] = v24.BonesB[i]
			v15[count4] = transforms[v25 + 1]
		end

		if data.GrowTo > 0 then
			count5 += 1
			v16[count5] = v24
			v17[count5] = data.GrowTo
			v18[count5] = data.BindRadius
		end

		if not (v24.MeshReady or v24.RevealQueued) then
			v24.RevealQueued = true
			count6 += 1
			v19[count6] = v24
		end
	end
end

local function drainParallelResults(now: number)
	for i = 1, #v11 do
		local v24 = v11[i]

		for i2 = 1, #v24 do
			collectMeshResult(v24[i2], true, now)
		end
	end

	table.clear(v11)
end

local function flushMeshWrites()
	for i = 1, count4 do
		v14[i].Transform = v15[i]
		v14[i] = nil
		v15[i] = nil
	end

	count4 = 0

	for i = 1, count5 do
		local v24 = v16[i]
		local v25 = v18[i]

		if not v24.Destroyed and v24.Mode == "Mesh" and v24.Rig ~= nil and not v24.Rig.Dead and v24.BindRadius == v25 then
			local v26 = v17[i] * 1.25 / v25
			v24.MeshPart.Size = v24.MeshPart.Size * v26
			v24.BindRadius = v25 * v26
		end

		v16[i] = nil
		v17[i] = nil
		v18[i] = nil
	end

	count5 = 0

	for i = 1, count6 do
		local v24 = v19[i]
		v24.RevealQueued = nil

		if not v24.Destroyed and v24.Enabled and v24.Mode == "Mesh" and v24.Rig ~= nil and not v24.Rig.Dead then
			v24.MeshRoot.Parent = v24.SkillVisuals
			v24.MeshPart.Transparency = 0
			v24.MeshReady = true
			v24.PartsHidden = false
		end

		v19[i] = nil
	end

	count6 = 0
end

local function resetMeshWriteBuffers()
	for i = 1, count4 do
		v14[i] = nil
		v15[i] = nil
	end

	for i = 1, count5 do
		v16[i] = nil
		v17[i] = nil
		v18[i] = nil
	end

	for i = 1, count6 do
		v19[i].RevealQueued = nil
		v19[i] = nil
	end

	count4 = 0
	count5 = 0
	count6 = 0
end

local function dispatchMeshCandidates(total: number)
	local v24 = {}

	for _, v25 in v10 do
		if not v25.Ready or v25.Busy then
			continue
		end

		v24[#v24 + 1] = v25
	end

	if #v24 == 0 then
		return
	end

	local v25 = math.min(#v24, (math.max(1, (math.ceil(total / 48)))))
	local v26 = table.create(v25)
	local v27 = table.create(v25, 0)

	for i = 1, v25 do
		v26[i] = {}
	end

	for i = 1, #v20 do
		local v28 = v20[i]

		if not (v3[v28.RefIndex] == v28 and v28.Enabled and v28.Mode == "Mesh" and v28.ParallelInFlight == nil) then
			continue
		end

		local v29 = 1

		for i2 = 2, v25 do
			if v27[i2] < v27[v29] then
				v29 = i2
			end
		end

		local meshJob = makeMeshJob(v28, v21[i])
		local meshJobs = v26[v29]
		meshJobs[#meshJobs + 1] = meshJob
		v27[v29] += v28.SegmentCount
		v28.ParallelInFlight = meshJob.JobId
	end

	for i = 1, v25 do
		local v28 = v26[i]

		if not (#v28 > 0) then
			continue
		end

		local v29 = v24[i]
		count2 += 1
		v29.BatchId = count2
		v29.Busy = true
		v29.SentAt = clock()
		local v31 = v28
		local success, result = pcall(function()
			v29.Request:Fire(count2, v31)
			return nil
		end)

		if success then
			continue
		end

		failParallelWorkers(result)
		break
	end
end

local function updateLegacyBranch(data, p: number, clientFramedropping: boolean)
	local v24 = 1 - data.MaxTransparency
	local v25 = 1 - data.MinTransparency
	local minRadius = data.MinRadius
	local maxRadius = data.MaxRadius
	local thickness = data.Thickness
	local segmentCount = data.SegmentCount
	local points = data.Points
	local radii = data.Radii
	local opacities = data.Opacities
	local ranNum = data.RanNum
	local animationSpeed = data.AnimationSpeed
	local frequency = data.Frequency
	local minThicknessMultiplier = data.MinThicknessMultiplier
	local maxThicknessMultiplier = data.MaxThicknessMultiplier
	local attachment0 = data.Attachment0
	local attachment1 = data.Attachment1
	local worldPosition = attachment0.WorldPosition
	local v26 = worldPosition + attachment0.WorldAxis * data.CurveSize0
	local worldPosition2 = attachment1.WorldPosition
	local v27 = worldPosition2 - attachment1.WorldAxis * data.CurveSize1
	local pulseLength = data.PulseLength
	local pulseSpeed = data.PulseSpeed
	local fadeLength = data.FadeLength
	local color = data.Color
	local colorOffsetSpeed = data.ColorOffsetSpeed
	local v28 = 1 - data.ContractFrom
	local parts = data.Parts
	local v29 = worldPosition
	local v30 = v29
	v29 = v30

	for i = 1, segmentCount do
		v(clientFramedropping)
		local part2 = parts[i]
		local v32 = i / segmentCount
		local discretePulse = DiscretePulse(v32, pulseSpeed, pulseLength, fadeLength, p, v24, v25) -- equivalent call inferred; original call site unknown
		local cubicBezier = CubicBezier(worldPosition, v26, v27, worldPosition2, v32)
		local v35 = -p
		local v36 = animationSpeed * v35 + frequency * 10 * v32 - 0.2 + ranNum * 4
		local v37 = 5 * (animationSpeed * 0.01 * v35 / 10 + frequency * v32) + ranNum * 4
		local v38 = 5 * v36
		local v39 = 1 * v37
		local v40 = 0 + 0.6283185307179586 * (math.noise(v38, 1.5, v39) + 0.5)
		local v41 = 0.5 * v36
		local v42 = 0.1 * v37
		local v43 = v40 + (0 + 5.654866776461628 * (math.noise(v41, 1.5, v42) + 0.5))
		local v44 = NoiseBetween(3.4, v37, v36, minRadius, maxRadius) * math.exp(-5000 * (v32 - 0.5) ^ 10)
		local noiseBetween = NoiseBetween(2.3, v37, v36, minThicknessMultiplier, maxThicknessMultiplier) -- equivalent call inferred; original call site unknown
		local position

		if i == segmentCount then
			position = cubicBezier
		else
			position = (CFrame.new(v29, cubicBezier) * CFrame.Angles(0, 0, v43) * CFrame.Angles(
				math.acos((math.clamp(
					6.123233995736766e-17 + 0.9999999999999999 * (math.noise(v37, v36, 2.7) + 0.5),
					-1,
					1
				))),
				0,
				0
			) * CFrame.new(0, 0, -v44)).Position
		end

		points[i] = v30
		opacities[i] = discretePulse

		if v28 < discretePulse then
			radii[i] = 0.5 * thickness * noiseBetween * discretePulse
			part2.Size = Vector3.new(
				(position - v30).Magnitude,
				thickness * noiseBetween * discretePulse,
				thickness * noiseBetween * discretePulse
			)
			part2.CFrame = CFrame.lookAt(0.5 * (v30 + position), position) * inverse

			if part2.Transparency ~= 0 then
				part2.Transparency = 0
			end
		elseif v28 - 1 / (segmentCount * fadeLength) < discretePulse then
			radii[i] = 0.5 * thickness * noiseBetween * discretePulse
			local v46 = (1 - (discretePulse - (v28 - 1 / (segmentCount * fadeLength))) * segmentCount * fadeLength) * (v32 < p * pulseSpeed - 0.5 * pulseLength and 1 or -1)
			part2.Size = Vector3.new(
				(1 - math.abs(v46)) * (position - v30).Magnitude,
				thickness * noiseBetween * discretePulse,
				thickness * noiseBetween * discretePulse
			)
			part2.CFrame = CFrame.lookAt(
				v30 + (position - v30) * (math.max(0, v46) + (1 - math.abs(v46)) * 0.5),
				position
			) * inverse

			if part2.Transparency ~= 0 then
				part2.Transparency = 0
			end
		else
			radii[i] = 0

			if part2.Transparency ~= 1 then
				part2.Transparency = 1
			end
		end

		if typeof(color) == "Color3" then
			part2.Color = color
		else
			local v46 = (ranNum + v32 - p * colorOffsetSpeed) % 1
			local keypoints = color.Keypoints

			for i2 = 1, #keypoints - 1 do
				local keypoint = keypoints[i2]
				local keypoint2 = keypoints[i2 + 1]

				if not (keypoint.Time < v46 and v46 < keypoint2.Time) then
					continue
				end

				part2.Color = keypoint.Value:Lerp(
					keypoint2.Value,
					(v46 - keypoint.Time) / (keypoint2.Time - keypoint.Time)
				)
				break
			end
		end

		v29 = cubicBezier
		v30 = position
	end

	points[segmentCount + 1] = v30
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideBranch(state)
	if state.PartsHidden then
		return
	end

	state.PartsHidden = true
	state.ParallelInFlight = nil
	local disabledTransparency = state.DisabledTransparency

	if state.Mode == "Mesh" then
		if state.MeshReady then
			state.MeshPart.Transparency = disabledTransparency
		end
	else
		for i = 1, #state.Parts do
			state.Parts[i].Transparency = disabledTransparency
		end
	end
end

local function updateBranches()
	if flag then
		return
	end

	flag = true
	v2()
	local now = clock()

	for _, v24 in v10 do
		if not (v24.Busy and v24.SentAt ~= nil and now - v24.SentAt > 1) then
			continue
		end

		failParallelWorkers("worker timed out")
		break
	end

	if v13 <= now then
		v13 = now + 5
		sweepPools(now)
	end

	if not pcall(function()
		drainParallelResults(now)
		flushMeshWrites()
		table.clear(v20)
		table.clear(v21)
		table.clear(v22)
		table.clear(v23)
		local flag4

		if flag3 then
			flag4 = false
		else
			local flag5 = true

			for _, v24 in v10 do
				if not v24.Ready then
					continue
				end

				flag4 = true
				flag5 = false
				break
			end

			if flag5 then
				flag4 = false
			end
		end

		local total = 0

		for _, v24 in pairs(v3) do
			if v24.Enabled then
				if v24.PartsHidden then
					v24.PartsHidden = false

					if v24.Mode == "Mesh" and v24.MeshReady then
						v24.MeshPart.Transparency = 0
					end
				end

				local timePassed = now - v24.StartT

				if (v24.PulseLength + 1) / v24.PulseSpeed <= timePassed then
					v24:Destroy()
				else
					local color = v24.Color

					if v24.Mode == "Mesh" then
						local typeName = typeof(color)

						if typeName ~= "Color3" and typeName ~= "ColorSequence" then
							convertToLegacy(v24) -- equivalent call inferred; original call site unknown
						end
					end

					if v24.Mode == "Mesh" then
						if color ~= v24.AppliedColor then
							v24.AppliedColor = color
							local meshColor = resolveMeshColor(color)
							v24.RenderedColor = meshColor
							v24.MeshPart.Color = meshColor
						end

						if v24.ParallelInFlight == nil then
							if flag4 then
								v20[#v20 + 1] = v24
								v21[#v21 + 1] = timePassed
								total += v24.SegmentCount
							else
								local meshJob = makeMeshJob(v24, timePassed)
								collectMeshResult(Geometry.computeMesh(meshJob, v24), false, now)
							end
						end
					else
						v22[#v22 + 1] = v24
						v23[#v23 + 1] = timePassed
					end
				end
			else
				hideBranch(v24) -- equivalent call inferred; original call site unknown
			end
		end

		if flag4 and total < 48 then
			for i = 1, #v20 do
				local v24 = v20[i]

				if not (v3[v24.RefIndex] == v24 and v24.Enabled and v24.Mode == "Mesh" and v24.ParallelInFlight == nil) then
					continue
				end

				local meshJob = makeMeshJob(v24, v21[i])
				collectMeshResult(Geometry.computeMesh(meshJob, v24), false, now)
			end

			total = 0
		end

		flushMeshWrites()

		if flag4 and total > 0 then
			dispatchMeshCandidates(total)
		end

		if #v22 > 0 then
			v5 = v5 or require(game.ReplicatedStorage.Global)
			local clientFramedropping = v5.isClientFramedropping()

			for i = 1, #v22 do
				local v24 = v22[i]

				if not (v3[v24.RefIndex] == v24 and v24.Enabled and v24.Mode == "Legacy") then
					continue
				end

				v(clientFramedropping)
				updateLegacyBranch(v24, v23[i], clientFramedropping)
			end
		end
	end) then
		resetMeshWriteBuffers()
	end

	flag = false
end

fn = function()
	if heartbeatConnection == nil and v4 > 0 then
		heartbeatConnection = RunService.Heartbeat:Connect(updateBranches)
	end
end

fn2 = function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

return LightningBoltShafi