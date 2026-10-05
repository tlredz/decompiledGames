local createVector = vector.create
local RunService = game:GetService("RunService")
local Trail = {}
local v = {
	MaxConcurrent = 200,
	Duration = 0.35,
	HeadStart = 0,
	EasePower = 2,
	ArcHeight = 4,
	RandomArcJitter = 1.5,
	FollowTangent = true,
	PartSize = createVector(0.2, 0.2, 0.2),
	PartMaterial = Enum.Material.Neon,
	PartColor = Color3.fromRGB(255, 225, 90),
	PartTransparency = 0,
	FadeOutAt = 0.8,
	TrailLifetime = 0.25,
	TrailMinLength = 0.1,
	TrailColor = ColorSequence.new(Color3.fromRGB(255, 255, 200), Color3.fromRGB(255, 170, 60)),
	TrailTransparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 0.5) }),
	TrailTexture = "",
	TrailLightInfluence = 0,
	TrailFaceCamera = true,
	TrailOffsetDown = 0.15,
	TrailHalfWidth = 0.08,
	FolderName = "_BezierTrailTendrils"
}
local parent = nil
local bundles = {}
local v3 = {}
local heartbeatConnection = nil
local v4 = false
local random = Random.new()
local clock = os.clock

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(value)
	local v5 = math.clamp(value, 0, 1)
	return v5 * v5 * (3 - 2 * v5)
end

local function bezier(p, p2, p3, p4, p5)
	local v5 = 1 - p5
	return v5 * v5 * v5 * p + 3 * (v5 * v5 * p5) * p2 + 3 * (v5 * p5 * p5) * p3 + p5 * p5 * p5 * p4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bezierTangent(p, p2, p3, p4, p5)
	local v5 = 1 - p5
	local v6 = 3 * v5 * v5 * (p2 - p) + 6 * v5 * p5 * (p3 - p2) + 3 * p5 * p5 * (p4 - p3)
	return v6.Magnitude > 1e-6 and v6.Unit or createVector(0, 1, 0)
end

local function makeBundle()
	local part = Instance.new("Part")
	part.Name = "BT_Node"
	part.Size = v.PartSize
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Material = v.PartMaterial
	part.Color = v.PartColor
	part.Transparency = v.PartTransparency
	part.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Name = "A0"
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "A1"
	attachment2.Parent = part
	local trail = Instance.new("Trail")
	trail.Name = "BT_Trail"
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = v.TrailColor
	trail.Transparency = v.TrailTransparency
	trail.Lifetime = v.TrailLifetime
	trail.MinLength = v.TrailMinLength
	trail.Texture = v.TrailTexture
	trail.LightInfluence = v.TrailLightInfluence
	trail.FaceCamera = v.TrailFaceCamera
	trail.Enabled = false
	trail.Parent = part
	return {
		part = part,
		a0 = attachment,
		a1 = attachment2,
		trail = trail,
		inUse = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTrailAttachmentOffsets(p)
	local trailOffsetDown = v.TrailOffsetDown
	local trailHalfWidth = v.TrailHalfWidth
	p.a0.Position = Vector3.new(-trailHalfWidth, -trailOffsetDown, 0)
	p.a1.Position = Vector3.new(trailHalfWidth, -trailOffsetDown, 0)
end

local function acquire()
	for i = 1, #bundles do
		local result = bundles[i]

		if result.inUse then
			continue
		end

		result.inUse = true
		return result
	end

	if #bundles < v.MaxConcurrent then
		local bundle = makeBundle()
		applyTrailAttachmentOffsets(bundle) -- equivalent call inferred; original call site unknown
		bundle.inUse = true
		table.insert(bundles, bundle)
		return bundle
	else
		local v5 = v3[1]

		if not v5 then
			bundles[1].inUse = true
			return bundles[1]
		end

		v5.trail.Enabled = false
		v5.bundle.inUse = false
		table.remove(v3, 1)
		v5.bundle.inUse = true
		return v5.bundle
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(bundle)
	bundle.trail.Enabled = false
	bundle.inUse = false
end

local function step(_)
	local now = clock()

	for i = #v3, 1, -1 do
		local v5 = v3[i]
		local v6 = now - v5.tStart

		if v6 <= v5.duration then
			local v7 = smoothstep(v5.t0 + v6 / v5.duration * (1 - v5.t0)) ^ v5.easePow
			local p0 = v5.p0
			local p1 = v5.p1
			local p2 = v5.p2
			local p3 = v5.p3
			local v8 = 1 - v7
			local v9 = v8 * v8 * v8 * p0 + 3 * (v8 * v8 * v7) * p1 + 3 * (v8 * v7 * v7) * p2 + v7 * v7 * v7 * p3

			if v5.followTangent then
				local v11 = bezierTangent(v5.p0, v5.p1, v5.p2, v5.p3, math.clamp(v7 + 0.001, 0, 1)) -- equivalent call inferred; original call site unknown
				local cframe = CFrame.lookAt(v9, v9 + v11)
				v5.bundle.part.CFrame = cframe
			else
				v5.bundle.part.CFrame = CFrame.new(v9)
			end

			if v5.fadeStart <= v7 then
				local v10 = (v7 - v5.fadeStart) / math.max(1e-6, 1 - v5.fadeStart)
				v5.bundle.part.Transparency = v5.baseTransparency + (1 - v5.baseTransparency) * math.clamp(v10, 0, 1)
			end
		elseif not (v6 <= v5.duration + v5.trail.Lifetime) then
			release(v5.bundle) -- equivalent call inferred; original call site unknown
			table.remove(v3, i)
		end
	end

	if #v3 == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
		v4 = false
	end
end

function Trail.Init(items)
	if items then
		for k, item in pairs(items) do
			v[k] = item
		end
	end

	if not (parent and parent.Parent) then
		parent = workspace:FindFirstChild(v.FolderName) or Instance.new("Folder")
		parent.Name = v.FolderName
		parent.Parent = workspace
	end

	for _ = 1, math.min(12, v.MaxConcurrent) do
		local bundle = makeBundle()
		applyTrailAttachmentOffsets(bundle) -- equivalent call inferred; original call site unknown
		table.insert(bundles, bundle)
	end
end

function Trail.FireCFrame(cFrame: CFrame, position: Vector3, options)
	local v5 = options or {}

	if not parent then
		Trail.Init()
	end

	local position2 = cFrame.Position
	local position3 = (cFrame * CFrame.new(position)).Position
	local duration = v5.Duration or v.Duration
	local easePower = v5.EasePower or v.EasePower
	local t0 = math.clamp(v5.HeadStart or v.HeadStart, 0, 0.98)
	local followTangent = v5.FollowTangent ~= nil and v5.FollowTangent or v.FollowTangent
	local position4, position5

	if v5.Control1 and v5.Control2 then
		position4 = (cFrame * CFrame.new(v5.Control1)).Position
		position5 = (cFrame * CFrame.new(v5.Control2)).Position
	else
		local lookVector = cFrame.LookVector
		local rightVector = cFrame.RightVector
		local upVector = cFrame.UpVector
		local magnitude = (position3 - position2).Magnitude
		local v7 = (v5.ArcHeight or v.ArcHeight) + random:NextNumber(-1, 1) * (v5.RandomArcJitter or v.RandomArcJitter)
		position4 = position2 + lookVector * (magnitude * 0.33) + upVector * v7 + rightVector * random:NextNumber(
			-0.4,
			0.4
		) * magnitude * 0.1
		position5 = position2 + lookVector * (magnitude * 0.66) + upVector * v7 + rightVector * random:NextNumber(
			-0.4,
			0.4
		) * magnitude * 0.1
	end

	local bundle = acquire()
	bundle.part.Size = v5.PartSize or v.PartSize
	bundle.part.Material = v5.PartMaterial or v.PartMaterial
	bundle.part.Color = v5.PartColor or v.PartColor
	bundle.part.Transparency = v5.PartTransparency or v.PartTransparency
	local transparency = bundle.part.Transparency
	bundle.trail.Lifetime = v5.TrailLifetime or v.TrailLifetime
	bundle.trail.MinLength = v5.TrailMinLength or v.TrailMinLength
	bundle.trail.Color = v5.TrailColor or v.TrailColor
	bundle.trail.Transparency = v5.TrailTransparency or v.TrailTransparency
	bundle.trail.Texture = v5.TrailTexture or v.TrailTexture
	bundle.trail.LightInfluence = v5.TrailLightInfluence ~= nil and v5.TrailLightInfluence or v.TrailLightInfluence
	bundle.trail.FaceCamera = v5.TrailFaceCamera ~= nil and v5.TrailFaceCamera or v.TrailFaceCamera

	if v5.TrailOffsetDown or v5.TrailHalfWidth then
		local trailOffsetDown = v5.TrailOffsetDown or v.TrailOffsetDown
		local trailHalfWidth = v5.TrailHalfWidth or v.TrailHalfWidth
		bundle.a0.Position = Vector3.new(-trailHalfWidth, -trailOffsetDown, 0)
		bundle.a1.Position = Vector3.new(trailHalfWidth, -trailOffsetDown, 0)
	else
		applyTrailAttachmentOffsets(bundle) -- equivalent call inferred; original call site unknown
	end

	bundle.part.CFrame = cFrame
	bundle.trail.Enabled = true
	local v8 = {
		bundle = bundle,
		part = bundle.part,
		trail = bundle.trail,
		p0 = position2,
		p1 = position4,
		p2 = position5,
		p3 = position3,
		duration = duration,
		easePow = easePower,
		t0 = t0,
		followTangent = followTangent,
		baseTransparency = transparency,
		fadeStart = v5.FadeOutAt or v.FadeOutAt,
		tStart = clock()
	}
	table.insert(v3, v8)

	if not v4 then
		v4 = true
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end

	return v8
end

function Trail.FireForward(cframe: CFrame, p: number, options)
	local vector2 = Vector3.new(0, 0, -p)
	return Trail.FireCFrame(cframe, vector2, options or {})
end

function Trail.Clear()
	for i = #v3, 1, -1 do
		local v5 = v3[i]
		v5.trail.Enabled = false
		release(v5.bundle) -- equivalent call inferred; original call site unknown
		table.remove(v3, i)
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v4 = false
end

return Trail