local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ColorLib = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.ColorLib)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function randomInRange(p: number, p2: number)
	return p + math.random() * (p2 - p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getContainer()
	if v and v.Parent then
		return v
	end

	local folder = Instance.new("Folder")
	folder.Name = "AllanBossRoomLandingDebris"
	folder.Parent = Workspace
	v = folder
	return folder
end

local function probeParams()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local container = getContainer() -- equivalent call inferred; original call site unknown
	raycastParams.FilterDescendantsInstances = { container }
	return raycastParams
end

local function resolveGround(position: Vector3, fallbackColor: Color3?, p)
	local v3 = position + createVector(0, 3, 0)
	local vector2 = Vector3.new(0, -(p.surfaceProbeDepthStuds + 3), 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local container = getContainer() -- equivalent call inferred; original call site unknown
	raycastParams.FilterDescendantsInstances = { container }
	local raycastResult = Workspace:Raycast(v3, vector2, raycastParams)

	if raycastResult then
		position = raycastResult.Position
	end

	if fallbackColor then
		return position, fallbackColor
	end

	if raycastResult then
		return position, raycastResult.Instance.Color
	end

	fallbackColor = p.fallbackColor
	return position, fallbackColor
end

local function groundYAt(p: number, p2: number, p3: number, p4)
	local vector2 = Vector3.new(p, p3 + 6, p2)
	local vector3 = Vector3.new(0, -(p4.surfaceProbeDepthStuds + 12), 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local container = getContainer() -- equivalent call inferred; original call site unknown
	raycastParams.FilterDescendantsInstances = { container }
	local raycastResult = Workspace:Raycast(vector2, vector3, raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

local function spawnSlab(position: Vector3, p: number, color: Color3, data)
	local v2 = math.cos(p)
	local v3 = math.sin(p)
	local v4 = randomInRange(data.ringRadiusMinStuds, data.ringRadiusMaxStuds) -- equivalent call inferred; original call site unknown
	local v5 = position.X + v2 * v4
	local v6 = position.Z + v3 * v4
	local Y = position.Y
	local vector2 = Vector3.new(v5, Y + 6, v6)
	local vector3 = Vector3.new(0, -(data.surfaceProbeDepthStuds + 12), 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local container = getContainer() -- equivalent call inferred; original call site unknown
	raycastParams.FilterDescendantsInstances = { container }
	local raycastResult = Workspace:Raycast(vector2, vector3, raycastParams)
	local Y2

	if raycastResult then
		Y2 = raycastResult.Position.Y
	end

	if not Y2 then
		return
	end

	local v9 = randomInRange(data.sizeMinStuds, data.sizeMaxStuds) -- equivalent call inferred; original call site unknown
	local v10 = randomInRange(data.sizeMinStuds, data.sizeMaxStuds) -- equivalent call inferred; original call site unknown
	local v11 = randomInRange(data.thicknessMinStuds, data.thicknessMaxStuds) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Slate
	part.Size = Vector3.new(v9, v11, v10)
	part.Color = ColorLib.adjustHsv(color, 0, 0, randomInRange(-data.shadeJitter, data.shadeJitter))
	part.CFrame = CFrame.new(v5, Y2 + (-0.4 + math.random() * 0.7), v6) * CFrame.fromAxisAngle(
		createVector(0, 1, 0),
		p + (-0.6 + math.random() * 1.2)
	) * CFrame.Angles(math.rad(-15 + math.random() * 30), 0, (math.rad(-15 + math.random() * 30)))
	local container2 = getContainer() -- equivalent call inferred; original call site unknown
	part.Parent = container2
	local v13 = randomInRange(data.outwardSpeedMin, data.outwardSpeedMax) -- equivalent call inferred; original call site unknown
	local v14 = randomInRange(data.upSpeedMin, data.upSpeedMax) -- equivalent call inferred; original call site unknown
	part.AssemblyLinearVelocity = Vector3.new(v2 * v13, v14, v3 * v13)
	local v16 = randomInRange(-data.spinSpeed, data.spinSpeed) -- equivalent call inferred; original call site unknown
	local v18 = randomInRange(-data.spinSpeed, data.spinSpeed) -- equivalent call inferred; original call site unknown
	local v19 = -data.spinSpeed
	local spinSpeed3 = data.spinSpeed
	part.AssemblyAngularVelocity = Vector3.new(v16, v18, randomInRange(v19, spinSpeed3))
	local tween = TweenService:Create(part, TweenInfo.new(data.fadeSeconds, Enum.EasingStyle.Linear), {
		Transparency = 1
	})
	task.delay(math.max(0, data.lifetimeSeconds - data.fadeSeconds), function()
		if part.Parent then
			tween:Play()
		end
	end)
	Debris:AddItem(part, data.lifetimeSeconds + 0.25)
end

local LandingDebris = {}

function LandingDebris.burst(position: Vector3, color: Color3?, data)
	assert(RunService:IsClient(), "AllanBossRoom.LandingDebris.burst is client-only")
	local v3 = position + createVector(0, 3, 0)
	local vector2 = Vector3.new(0, -(data.surfaceProbeDepthStuds + 3), 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local container = getContainer() -- equivalent call inferred; original call site unknown
	raycastParams.FilterDescendantsInstances = { container }
	local raycastResult = Workspace:Raycast(v3, vector2, raycastParams)

	if raycastResult then
		position = raycastResult.Position
	end

	if not color then
		if raycastResult then
			color = raycastResult.Instance.Color
		else
			color = data.fallbackColor
		end
	end

	local v5 = 6.283185307179586 / data.slabCount

	for i = 1, data.slabCount do
		spawnSlab(position, (i - 1) * v5 + randomInRange(-v5 * 0.4, v5 * 0.4), color, data)
	end
end

function LandingDebris.cleanup()
	if v then
		v:Destroy()
		v = nil
	end
end

return LandingDebris