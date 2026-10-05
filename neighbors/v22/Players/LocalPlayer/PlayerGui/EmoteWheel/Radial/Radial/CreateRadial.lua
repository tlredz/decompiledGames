local CONSTANTS = require(script.Parent:WaitForChild("CONSTANTS"))
local Triangle = require(script.Parent:WaitForChild("Triangle"))
local TAU = CONSTANTS.TAU
local GAP = CONSTANTS.GAP
local PART_PER_UNIT = CONSTANTS.PART_PER_UNIT
local CENTER = CONSTANTS.CENTER
local EXTERIOR_RADIUS = CONSTANTS.EXTERIOR_RADIUS
local EX_OFFSET = CONSTANTS.EX_OFFSET
local G_OFFSET = CONSTANTS.G_OFFSET
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Ambient = Color3.new(1, 1, 1)
viewportFrame.LightColor = Color3.new(1, 1, 1)
viewportFrame.LightDirection = vector.create(0, 0, -1)
viewportFrame.BackgroundTransparency = 1
viewportFrame.Size = UDim2.new(1, 0, 1, 0)
local camera = Instance.new("Camera")
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = CFrame.new()
camera.FieldOfView = CONSTANTS.FOV

-- equivalent calls inferred from this helper; original call sites unknown
local function pivotAround(folder, cframe, p)
	local inverse = cframe:Inverse()

	for _, descendant in folder:GetDescendants() do
		descendant.CFrame = p * (inverse * descendant.CFrame)
	end
end

local function createSection(p, p2, p3, p4)
	local model = Instance.new("Model")
	local v = TAU * p3 / p - GAP
	local v2 = TAU * p2 / p - GAP
	local v3 = v / p3
	local v4 = v2 / p2
	local v5 = v3 - v4
	local v6 = math.ceil(v / p4)
	local v7 = {}
	local v8 = {}

	for i = 0, v6 do
		v7[i + 1] = CENTER * CFrame.fromEulerAnglesXYZ(0, 0, i / v6 * v3) * Vector3.new(p3, 0, 0)
		v8[i + 1] = CENTER * CFrame.fromEulerAnglesXYZ(0, 0, v5 / 2 + i / v6 * v4) * Vector3.new(p2, 0, 0)
	end

	for i = 1, v6 do
		local v9 = v7[i]
		local v10 = v8[i]
		local v11 = v7[i + 1]
		local v12 = v8[i + 1]
		Triangle(model, v9, v10, v11)
		Triangle(model, v10, v11, v12)
	end

	return model
end

local function createRadial(p, p2, value)
	local v = (1 - p2) * EXTERIOR_RADIUS - 1
	local v2 = v - 2
	local section = createSection(p, (1 - p2) * EXTERIOR_RADIUS, EXTERIOR_RADIUS, PART_PER_UNIT)
	local section2 = createSection(p, v2, v, PART_PER_UNIT / 2)
	local frame = Instance.new("Frame")
	local frame2 = Instance.new("Frame")
	local frame3 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame3.BackgroundTransparency = 1
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame3.Size = UDim2.new(1, 0, 1, 0)
	frame2.Name = "Radial"
	frame3.Name = "Attach"
	frame2.Parent = frame
	frame3.Parent = frame
	local v4 = EXTERIOR_RADIUS - p2 * EXTERIOR_RADIUS
	local v5 = 1 - p2 / 2
	local v6 = TAU * EXTERIOR_RADIUS / p / EXTERIOR_RADIUS
	local v7 = (TAU * v4 / p - GAP) / v4
	local v8 = math.min(
		(Vector2.new(math.cos(v7), (math.sin(v7))) * v4 - Vector2.new(v4, 0)).Magnitude / (EXTERIOR_RADIUS * 2),
		0.18
	)
	local v9 = value or 0

	for i = 0, p - 1 do
		local clone = viewportFrame:Clone()
		local clone2 = camera:Clone()
		clone.CurrentCamera = clone2
		clone.Name = i + 1
		local v10 = i / p * TAU + v9
		local clone3 = section:Clone()
		pivotAround(clone3, CENTER, CENTER * CFrame.fromEulerAnglesXYZ(0, 0, v10 + EX_OFFSET)) -- equivalent call inferred; original call site unknown
		clone3.Parent = clone
		local v13 = v10 - EX_OFFSET + v6 / 2 + G_OFFSET
		local v14 = -math.cos(v13) / 2 * v5
		local v15 = math.sin(v13) / 2 * v5
		local frame4 = Instance.new("Frame")
		frame4.Name = i + 1
		frame4.BackgroundTransparency = 1
		frame4.BackgroundColor3 = Color3.new()
		frame4.BorderSizePixel = 0
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.Position = UDim2.new(0.5 + v14, 0, 0.5 + v15, 0)
		frame4.Size = UDim2.new(v8, 0, v8, 0)
		frame4.Parent = frame3
		clone2.Parent = clone
		clone.Parent = frame2
	end

	section:Destroy()
	local clone = viewportFrame:Clone()
	clone.CurrentCamera = camera:Clone()
	clone.Name = "RadialDial"
	local v10 = GAP / (2 * v)
	local v11 = -TAU / 4 + v10
	pivotAround(section2, CENTER, CENTER * CFrame.fromEulerAnglesXYZ(0, 0, v9 + v11)) -- equivalent call inferred; original call site unknown
	section2.Parent = clone
	clone.Parent = frame
	frame.BackgroundTransparency = 1
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.Size = UDim2.new(1, 0, 1, 0)
	return frame
end

return createRadial