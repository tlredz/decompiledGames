local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
module:WaitInitialization()
local instance = module.Instance
local currentCamera = workspace.CurrentCamera
local character = instance.Character or instance.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local head = character:WaitForChild("Head")
local random = Random.new()
local v = 0
local v2 = 0
local v3 = 0
local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 5
local v8 = 5
local cameraOffset = createVector(0, 0, 0)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHorizontalSpeed(humanoidRootPart2)
	local assemblyLinearVelocity = humanoidRootPart2.AssemblyLinearVelocity
	return (math.min(Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude, 25))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCameraOffset()
	local pointToObjectSpace = (humanoidRootPart.CFrame + createVector(0, 1.8, 0)):PointToObjectSpace(head.CFrame.Position)
	cameraOffset = cameraOffset:Lerp(pointToObjectSpace, 0.25)
	humanoid.CameraOffset = cameraOffset
end

local function isDynamicEnabled()
	local settings = module.Data and module.Data.Settings
	return not not settings and settings["Dynamic Camera"] == true and not settings["Low Mode"]
end

module.Services.RunService.RenderStepped:Connect(function(dt: number)
	local settings = module.Data and module.Data.Settings
	local v10

	if settings and settings["Dynamic Camera"] == true then
		v10 = not settings["Low Mode"]
	else
		v10 = false
	end

	if not v10 or currentCamera.CameraType == Enum.CameraType.Scriptable or humanoid.Health <= 0 then
		return
	end

	if not (humanoidRootPart and humanoidRootPart.Parent) then
		return
	end

	updateCameraOffset() -- equivalent call inferred; original call site unknown
	local now = os.clock()
	local v11 = dt * 30
	local horizontalSpeed = getHorizontalSpeed(humanoidRootPart) -- equivalent call inferred; original call site unknown

	if v11 > 1.5 then
		v = 0
		v2 = 0
	else
		local v12 = v
		local v13 = math.cos(now * 0.5 * random:NextNumber(5, 7.5)) * (random:NextNumber(2.5, 10) / 100) * v11
		local v14 = v11 * 0.05
		v = v12 + (v13 - v12) * v14
		local v15 = v2
		local v16 = math.cos(now * 0.5 * random:NextNumber(2.5, 5)) * (random:NextNumber(1, 5) / 100) * v11
		local v17 = v11 * 0.05
		v2 = v15 + (v16 - v15) * v17
	end

	local v12 = math.max(humanoid.WalkSpeed, 0.01)
	local vectorToObjectSpace = currentCamera.CFrame:VectorToObjectSpace(humanoidRootPart.Velocity / v12)
	local v13 = v6
	local v14 = -vectorToObjectSpace.X * 0.04
	local v15 = v11 * 0.1
	v6 = math.clamp(v13 + (v14 - v13) * v15, -0.12, 0.1)
	local v16 = v3
	local v17 = math.clamp(module.Services.UserInputService:GetMouseDelta().X, -2.5, 2.5)
	local v18 = v11 * 0.25
	v3 = v16 + (v17 - v16) * v18
	local v19 = v4
	local v20 = math.sin(now * v7) / 5 * math.min(1, v8 / 10)
	local v21 = v11 * 0.25
	v4 = v19 + (v20 - v19) * v21

	if horizontalSpeed > 1 then
		local v22 = v5
		local v23 = math.cos(now * 0.5 * math.floor(v7)) * (v7 / 200)
		local v24 = v11 * 0.25
		v5 = v22 + (v23 - v22) * v24
	else
		local v22 = v5
		local v23 = v11 * 0.05
		v5 = v22 + (0 - v22) * v23
	end

	if horizontalSpeed > 6 then
		v7 = 10
		v8 = 9
	elseif horizontalSpeed > 0.1 then
		v7 = 6
		v8 = 7
	else
		v8 = 0
	end

	local v22 = CFrame.fromEulerAnglesXYZ(0, 0, (math.rad(v3))) * CFrame.fromEulerAnglesXYZ(
		math.rad(v4 * v11),
		math.rad(v5 * v11),
		v6
	) * CFrame.Angles(0, 0, (math.rad(v4 * v11 * (horizontalSpeed / 5)))) * CFrame.fromEulerAnglesXYZ(
		math.rad(v),
		math.rad(v2),
		(math.rad(v2 * 10))
	)
	currentCamera.CFrame *= v22
end)