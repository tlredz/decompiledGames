local createVector = vector.create
local RunService = game:GetService("RunService")
local v = {
	OrbitRing1 = {
		Bob = 0.22,
		Radius = 4.70158,
		Normal = (createVector(-0.60476, 0.68092, -0.41305)).Unit,
		Direction = 1
	},
	OrbitRing2 = {
		Bob = -0.18,
		Radius = 5.20829,
		Normal = (createVector(0.51574, 0.77177, 0.372)).Unit,
		Direction = -1
	}
}
local v2 = {
	"MainSun",
	"MainSunRays",
	"MainMoon",
	"FlatMoon"
}
local v3 = {
	SmallSun1 = {
		Ring = "OrbitRing1",
		Spins = 2
	},
	SmallMoon1 = {
		Ring = "OrbitRing1",
		Spins = 1
	},
	SmallMoon2 = {
		Ring = "OrbitRing2",
		Spins = 2
	},
	SmallMoon3 = {
		Ring = "OrbitRing2",
		Spins = 1
	},
	SmallSun2 = {
		Ring = "OrbitRing2",
		Spins = 1
	}
}

for k in v do
	table.insert(v2, k)
end

for k in v3 do
	table.insert(v2, k)
end

local v4 = {}
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function aroundY(X: number, Y: number, Z: number, p: number)
	local v5 = p / 2
	return CFrame.new(X, Y, Z, 0, math.sin(v5), 0, (math.cos(v5)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function aroundZ(p: number, p2: number, p3: number, p4: number)
	local v5 = p4 / 2
	return CFrame.new(p, p2, p3, 0, 0, math.sin(v5), (math.cos(v5)))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function phaseAt(value: number)
	return 6.283185307179586 * (value % 8.333333333333334) / 8.333333333333334
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScale(model)
	local orbitScale = model:GetAttribute("OrbitScale")
	return model:GetScale() * (typeof(orbitScale) ~= "number" and 1 or orbitScale)
end

local function measure(state)
	local scale = getScale(state.Model) -- equivalent call inferred; original call site unknown
	local position = state.MainMoon.CFrame.Position
	state.Scale = scale
	state.MoonRest = position
	state.MoonRadius = scale * 1.84
	state.MoonSwing = math.asin((math.clamp(-position.X / state.MoonRadius, -1, 1)))

	for _, body in state.Bodies do
		local position2 = body.Bone.CFrame.Position
		local normal = body.Ring.Normal
		local unit = (position2 - normal * position2:Dot(normal)).Unit
		local v5 = body.Ring.Radius * scale
		body.Rest = position2
		body.U = unit * v5
		body.V = normal:Cross(unit) * v5
	end
end

local function buildRig(model, instance)
	local v5 = {}

	for _, v6 in instance:QueryDescendants("Bone"), nil, nil do
		v5[v6.Name] = v6
	end

	for _, v6 in v2 do
		if v5[v6] then
			continue
		end

		warn((`[EclipseOrbitAnimation] {model:GetFullName()} is missing bone {v6}`))
		return nil
	end

	local rings = {}

	for k, v7 in v do
		table.insert(rings, {
			Bone = v5[k],
			Bob = v7.Bob
		})
	end

	local bodies = {}

	for k, v8 in v3 do
		table.insert(bodies, {
			Bone = v5[k],
			Ring = v[v8.Ring],
			Spins = v8.Spins,
			Rest = createVector(0, 0, 0),
			U = createVector(0, 0, 0),
			V = createVector(0, 0, 0)
		})
	end

	local fixedRotationOffset = model:GetAttribute("FixedRotationOffset")
	local weldConstraint = instance:FindFirstChildOfClass("WeldConstraint")
	local part0

	if weldConstraint and weldConstraint.Part1 == instance then
		part0 = weldConstraint.Part0
	end

	local bones = {}

	for _, bone in instance:GetChildren() do
		if bone:IsA("Bone") then
			table.insert(bones, bone)
		end
	end

	local v8 = {
		Model = model,
		RootPart = instance,
		Scale = 1,
		MainSun = v5.MainSun,
		MainSunRays = v5.MainSunRays,
		MainMoon = v5.MainMoon,
		FlatMoon = v5.FlatMoon,
		Rings = rings,
		Bodies = bodies,
		MoonRest = createVector(0, 0, 0),
		MoonRadius = 0,
		MoonSwing = 0,
		Anchor = part0,
		FixedOffset = 0,
		TopBones = 0
	}

	if typeof(fixedRotationOffset) ~= "CFrame" then
		fixedRotationOffset = nil
	end

	v8.FixedOffset = fixedRotationOffset
	v8.TopBones = bones
	measure(v8)
	return v8
end

local function poseRig(data, p: number)
	local scale = data.Scale
	local v5 = math.sin(p)
	local v6 = math.cos(p)
	data.MainSun.Transform = CFrame.new(0, scale * 0.26 * v5, 0)
	local mainSunRays = data.MainSunRays
	mainSunRays.Transform = aroundZ(0, 0, 0, p)
	local v7 = -data.MoonSwing * v6
	local moonRest = data.MoonRest
	local mainMoon = data.MainMoon
	mainMoon.Transform = aroundZ(
		data.MoonRadius * math.sin(v7) - moonRest.X,
		scale * 0.12 * v5 * v5,
		data.MoonRadius * math.cos(v7) - moonRest.Z,
		v5 * 0.15707963267948966
	)
	local flatMoon = data.FlatMoon
	flatMoon.Transform = aroundZ(scale * -1.1 * v5, scale * 0.09 * math.sin(p * 2), 0, v5 * 0.10471975511965978)

	for _, ring in data.Rings do
		ring.Bone.Transform = CFrame.new(0, ring.Bob * scale * v5, 0)
	end

	for _, body in data.Bodies do
		local v13 = body.Ring.Direction * p
		local vector2 = body.U * math.cos(v13) + body.V * math.sin(v13) - body.Rest
		local bone = body.Bone
		bone.Transform = aroundY(vector2.X, vector2.Y, vector2.Z, body.Spins * p)
	end

	local fixedOffset = data.FixedOffset
	local anchor = data.Anchor

	if fixedOffset and anchor then
		local v13 = data.RootPart.CFrame:Inverse() * CFrame.new(anchor.Position) * fixedOffset

		for _, topBone in data.TopBones do
			local cFrame = topBone.CFrame
			topBone.Transform = cFrame:Inverse() * v13 * cFrame * topBone.Transform
		end
	end
end

local function step()
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local position = cFrame.Position
	local lookVector = cFrame.LookVector
	local viewportSize = currentCamera.ViewportSize
	local v5 = not (viewportSize.Y > 0) and 1 or viewportSize.X / viewportSize.Y
	local v6 = math.atan(math.tan(math.rad(currentCamera.FieldOfView) / 2) * math.sqrt(1 + v5 * v5))
	local v7 = 6.283185307179586 * (workspace:GetServerTimeNow() % 8.333333333333334) / 8.333333333333334

	for _, v8 in v4 do
		if getScale(v8.Model) ~= v8.Scale then
			measure(v8)
		end

		local vector2 = v8.RootPart.Position - position
		local magnitude = vector2.Magnitude
		local v9 = v8.Scale * 9

		if v9 < magnitude and (magnitude - v9 > 250 or math.acos((math.clamp(vector2:Dot(lookVector) / magnitude, -1, 1))) > v6 + math.asin(v9 / magnitude)) then
			continue
		end

		poseRig(v8, v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addRig(p)
	table.insert(v4, p)

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end
end

local function removeRig(p)
	local index = table.find(v4, p)

	if not index then
		return
	end

	v4[index] = v4[#v4]
	v4[#v4] = nil

	for _, v5 in p.RootPart:QueryDescendants("Bone"), nil, nil do
		v5.Transform = CFrame.identity
	end

	if #v4 == 0 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local v5 = {
	Period = 8.333333333333334,
	Bind = function(model)
		local v6

		if typeof(model) == "Instance" then
			v6 = model:IsA("Model")
		else
			v6 = false
		end

		assert(v6, "EclipseOrbitAnimation.Bind expects a Model")
		local v7 = nil

		local function attach(part)
			if v7 or part.Name ~= "RootPart" or not part:IsA("BasePart") then
				return
			end

			v7 = buildRig(model, part)

			if v7 then
				addRig(v7) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function detach()
			if not v7 then
				return
			end

			removeRig(v7)
			v7 = nil
		end

		local childAddedConnection = model.ChildAdded:Connect(attach)
		local childRemovedConnection = model.ChildRemoved:Connect(function(child)
			if v7 and child == v7.RootPart then
				detach() -- equivalent call inferred; original call site unknown
			end
		end)
		local rootPart = model:FindFirstChild("RootPart")

		if rootPart and not v7 and rootPart.Name == "RootPart" and rootPart:IsA("BasePart") then
			v7 = buildRig(model, rootPart)

			if v7 then
				addRig(v7) -- equivalent call inferred; original call site unknown
			end
		end

		return function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
			detach() -- equivalent call inferred; original call site unknown
		end
	end,
	Pose = function(model, value: number)
		local v6

		if typeof(model) == "Instance" then
			v6 = model:IsA("Model")
		else
			v6 = false
		end

		assert(v6, "EclipseOrbitAnimation.Pose expects a Model")
		assert(typeof(value) == "number", "EclipseOrbitAnimation.Pose expects a time")
		local rootPart = model:FindFirstChild("RootPart")
		assert(rootPart and rootPart:IsA("BasePart"), (`{model:GetFullName()} has no RootPart`))
		local rig = buildRig(model, rootPart)
		assert(rig, (`{model:GetFullName()} is missing EclipseOrbit bones`))
		poseRig(rig, phaseAt(value))
	end
}
return table.freeze(v5)