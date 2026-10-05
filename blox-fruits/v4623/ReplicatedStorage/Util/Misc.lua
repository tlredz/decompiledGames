local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Misc = {
	lerpNumber = function(p, p2, p3)
		return p + (p2 - p) * p3
	end,
	map = function(p, p2, p3, p4, p5)
		return p4 + (p - p2) * (p5 - p4) / (p3 - p2)
	end,
	round = function(p, value)
		local v = 10 ^ (value or 0)
		return math.floor(p * v + 0.5) / v
	end
}

local function lerpNumber2(p, p2, p3)
	return p + (p2 - p) * p3
end

function Misc.LerpKeypoints(items, value, p)
	local v = value or 1
	local numberSequenceKeypoints = {}

	for _, item in pairs(items) do
		local time = item.Time
		local value2 = item.Value
		local envelope = item.Envelope
		local v2 = value2 + (v - value2) * p
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(time, v2, envelope))
	end

	return numberSequenceKeypoints
end

function Misc.ScaleKeypoint(data, p)
	local v = math.max(0, data.Value * p)
	return NumberSequenceKeypoint.new(data.Time, v, v < data.Envelope and v or data.Envelope)
end

function Misc.ScaleKeypoints(keypoints, p)
	if type(keypoints) ~= "table" then
		keypoints = keypoints.Keypoints
	end

	local v = {}

	for _, keypoint in next, keypoints, nil do
		table.insert(v, Misc.ScaleKeypoint(keypoint, p))
	end

	return NumberSequence.new(v)
end

function Misc:ScaleParticle(p, data)
	local size = data and data.Size or self.Size.Keypoints
	local speed = data and data.Speed or self.Speed
	local acceleration = data and data.Acceleration or self.Acceleration
	local scaleKeypoints = Misc.ScaleKeypoints(size, p)
	local acceleration2 = acceleration * p
	self.Size = scaleKeypoints
	self.Speed = NumberRange.new(speed.Min * p, speed.Max * p)
	self.Acceleration = acceleration2
	return scaleKeypoints
end

function Misc.ScaleParticleInfo(data, p, data2)
	local size = data2 and data2.Size or data.Size.Keypoints
	local speed = data2 and data2.Speed or data.Speed
	local acceleration = data2 and data2.Acceleration or data.Acceleration
	local scaleKeypoints = Misc.ScaleKeypoints(size, p)
	local v = acceleration * p
	return scaleKeypoints, NumberRange.new(speed.Min * p, speed.Max * p), v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorToVector(value)
	return (Vector3.new(value.r, value.g, value.b))
end

local function vectorToColor(data)
	return Color3.new(data.x, data.y, data.z)
end

Misc.ColorToVector = colorToVector
Misc.colorToVector = colorToVector
Misc.VectorToColor = vectorToColor
Misc.vectorToColor = vectorToColor

function Misc.swapColor(p, p2, p3, value)
	local colorToVector2 = Misc.ColorToVector(p2 or Color3.new(1, 1, 1))
	Misc.ColorToVector(p3 or Color3.new())
	local magnitude = (colorToVector2 - Misc.ColorToVector(p)).Magnitude

	if magnitude < (value or 0.75) then
		p = p3:Lerp(Misc.CalculateIntensity(p) > 0.5 and Color3.new(1, 1, 1) or Color3.new(), magnitude)
	end

	return p
end

function Misc.swapColorInKeypoints(keypoints, p, p2, value)
	if typeof(keypoints) == "Instance" and (keypoints:IsA("ParticleEmitter") or keypoints:IsA("Beam") or keypoints:IsA("Trail")) then
		keypoints = keypoints.Color.Keypoints
	elseif typeof(keypoints) ~= "table" then
		keypoints = keypoints.Keypoints
	end

	local colorToVector2 = Misc.ColorToVector(p or Color3.new(1, 1, 1))
	Misc.ColorToVector(p2 or Color3.new())
	local v = value or 0.75
	local colorSequenceKeypoints = {}

	for _, keypoint in pairs(keypoints) do
		local colorToVector3 = Misc.ColorToVector(keypoint.Value)
		local value2 = keypoint.Value
		local magnitude = (colorToVector2 - colorToVector3).Magnitude

		if magnitude < v then
			value2 = p2:Lerp(
				Misc.CalculateIntensity(keypoint.Value) > 0.5 and Color3.new(1, 1, 1) or Color3.new(),
				magnitude
			)
		end

		table.insert(colorSequenceKeypoints, (ColorSequenceKeypoint.new(keypoint.Time, value2)))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

Misc.SwapColorInKeypoints = Misc.swapColorInKeypoints

function Misc.CalculateLuminosity(data)
	return 0.2126 * data.R + 0.7152 * data.G + 0.0722 * data.B
end

function Misc.CalculateIntensity(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

function Misc.CalculateColorByIntensity(data, p)
	if p > 1 then
		local v = Vector3.new(1 - data.r, 1 - data.g, 1 - data.b) * (p - 1)
		return Color3.new(data.r + v.x, data.g + v.y, data.b + v.z)
	else
		return Color3.new(data.r * p, data.g * p, data.b * p)
	end
end

function Misc.SwapColors(keypoints, items, value)
	local v = value or 0.25

	if typeof(keypoints) == "Instance" and (keypoints:IsA("ParticleEmitter") or keypoints:IsA("Beam") or keypoints:IsA("Trail")) then
		keypoints = keypoints.Color.Keypoints
	end

	local v2 = {}

	for _, keypoint in next, keypoints, nil do
		local value2 = keypoint.Value
		local v3 = false

		for _, item in next, items, nil do
			local v4 = colorToVector(value2) -- equivalent call inferred; original call site unknown
			local v5 = item[1]

			if not ((v4 - Vector3.new(v5.r, v5.g, v5.b)).Magnitude <= v) then
				continue
			end

			table.insert(v2, ColorSequenceKeypoint.new(keypoint.Time, item[2]))
			v3 = true
		end

		if not v3 then
			table.insert(v2, keypoint)
		end
	end

	return ColorSequence.new(v2)
end

function Misc.LoadTexture(instance, list, value, p)
	local v = value or 0.016666666666666666
	local v2 = {}

	if instance:IsA("BasePart") or instance:IsA("Attachment") then
		for _, child in pairs(instance:GetChildren()) do
			if not (child:IsA("Decal") or child:IsA("Texture") or child:IsA("ParticleEmitter")) then
				continue
			end

			table.insert(v2, child)
		end
	elseif instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ParticleEmitter") then
		table.insert(v2, instance)
	end

	for i = not p and 1 or #list or 1, p and 1 or #list, p and -1 or 1 do
		local texture = list[i]

		for _, v4 in pairs(v2) do
			v4.Texture = texture
		end

		if v <= 0.016666666666666666 then
			if RunService:IsServer() then
				RunService.Heartbeat:Wait()
			else
				RunService.RenderStepped:Wait()
			end
		else
			task.wait(v)
		end
	end
end

function Misc.ScaleCFrame(object, p)
	local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = object:components()
	return CFrame.new(components * p, v * p, v2 * p, v3, v4, v5, v6, v7, v8, v9, v10, v11)
end

function Misc.AlignCFrame(data, p, p2)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p3 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit

	if not p2 then
		return CFrame.fromMatrix(p3, unit2, v, unit3)
	end

	local part = Instance.new("Part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.FrontSurface = 6
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.new(0, 1, 0)
	local clone = part:Clone()
	clone.Color = Color3.new(1, 1, 0)
	local clone2 = part:Clone()
	clone2.Color = Color3.new(1, 0, 0)
	part.CFrame = CFrame.new(p3, p3 + unit2)
	clone.CFrame = CFrame.new(p3, p3 + v)
	clone2.CFrame = CFrame.new(p3, p3 + unit3)
	local _WorldOrigin = workspace._WorldOrigin
	local _WorldOrigin2 = workspace._WorldOrigin
	local _WorldOrigin3 = workspace._WorldOrigin
	part.Parent = _WorldOrigin
	clone.Parent = _WorldOrigin2
	clone2.Parent = _WorldOrigin3
	return CFrame.fromMatrix(p3, unit2, v, unit3)
end

function Misc.ReflectVector(vector2, p)
	return vector2 - 2 * vector2:Dot(p) * p
end

function Misc.VectorIntersectsPlane(p, p2, p3, p4)
	local vector2 = p4 - p3
	local v = (p - p3):Dot(p2) / vector2:Dot(p2)

	if v == v and math.abs(v) ~= 1e999 then
		return true, p3 + v * vector2, v
	end
end

function Misc.PointWithinBox(p, instance)
	local cFrame = instance.CFrame
	local size = instance.Size
	local pointToObjectSpace = cFrame:PointToObjectSpace(p)
	return math.abs(pointToObjectSpace.X) <= size.X / 2 and math.abs(pointToObjectSpace.Y) <= size.Y / 2 and math.abs(pointToObjectSpace.Z) <= size.Z / 2
end

function Misc.PointWithinCylinder(p, instance)
	local cFrame = instance.CFrame
	local size = instance.Size
	local v = math.max(size.X, size.Y)
	local Z = size.Z
	local v2 = cFrame * Vector3.new(0, 0, size.Z / 2)
	local v3 = cFrame * Vector3.new(0, 0, -size.Z / 2) - v2
	local vector2 = p - v2
	local unit = v3.Unit
	local rounded = Misc.round(vector2:Dot(unit), 2)

	if rounded < 0 or Z < rounded then
		return false
	end

	local rounded2 = Misc.round((vector2 - unit * rounded).Magnitude, 2)
	local v4 = v2 + unit * rounded
	local unit2 = (p - v4).Unit
	return rounded2 <= v / 2, v4, unit2
end

function Misc.PointWithinCone(p, p2, p3, p4, p5)
	local vector2 = p - p2
	local dot = vector2:Dot(p3)

	if dot < 0 or p4 < dot then
		return false
	end

	local v = dot / p4 * p5
	local magnitude = (vector2 - p3 * dot).Magnitude
	local v2 = p2 + p3 * dot
	return magnitude < p5, v, v2, (p - v2).Unit
end

function Misc.GetSurfaceNormal(data, p, p2, value)
	local upVector = data.UpVector
	local rightVector = data.RightVector
	local lookVector = data.LookVector
	local unit = p and p.Unit or createVector(0, 1, 0)
	local v = p2 or unit
	local v2 = math.abs((upVector:Dot(v)))
	local v3 = {
		{ math.abs((rightVector:Dot(v))), rightVector, "X" },
		{ v2, upVector, "Y" },
		{ math.abs((lookVector:Dot(v))), lookVector, "Z" }
	}

	if value then
		local upper = value:upper()

		for k, v4 in next, v3, nil do
			if upper:find(v4[3]) then
				table.remove(v3, k)
			end
		end
	end

	table.sort(v3, function(a, b)
		return a[1] > b[1]
	end)
	return (v3[1][2]:Dot(v) > 0 and 1 or -1) * v3[1][2], v3
end

function Misc.recurse(items, callback)
	for k, item in pairs(items) do
		callback(k, item)

		if typeof(item) == "table" then
			Misc.recurse(item, callback)
		end
	end
end

local function dragRatio(p, p2)
	return 2 ^ (p * -p2)
end

function Misc.CalculatePosition(value, value2, value3, value4)
	local v = value or 0
	local v2 = value2 or 0
	local v3 = value3 or 0
	local v4 = value4 or 1

	if v3 == 0 then
		return v + 0.5 * v2 * v4 ^ 2
	end

	return -1 / (0.4804530139182014 * v3 ^ 2) * (-0.6931471805599453 * v3 * v2 * v4 - 2 ^ (v4 * -v3) * (v2 - 0.6931471805599453 * v3 * v)) - (-0.6931471805599453 * v3 * v + v2) / (0.4804530139182014 * v3 ^ 2)
end

function Misc.CalculateVelocity(value, value2, value3)
	local v = value or 10
	local v2 = value2 or 1
	local v3 = value3 or 0

	if v3 == 0 then
		return v / v2
	end

	return 0.6931471805599453 * v * v3 / (1 - 2 ^ (v2 * -v3))
end

Misc.Physics = {
	Trajectory = function(p, p2, p3, p4)
		return 0.5 * p3 * p4 ^ 2 + p2 * p4 + p
	end,
	Velocity = function(p, p2, p3, p4)
		return (p2 - p - 0.5 * p3 * p4 ^ 2) / p4
	end,
	GravityFromHeight = function(p, p2)
		return p * p / (2 * p2)
	end
}

function Misc:ScalePart(value, value2)
	if not self:GetAttribute("RawSize") then
		self:SetAttribute("RawSize", self.Size)
	end

	self.Size = self:GetAttribute("RawSize") / (value2 or 1) * (value or 1)
end

function Misc:ScaleMesh(value, value2)
	if not self:GetAttribute("RawSize") then
		self:SetAttribute("RawSize", self.Scale)
	end

	self.Scale = self:GetAttribute("RawSize") / (value2 or 1) * (value or 1)
end

function Misc.ScaleModel(instance, value, value2)
	local v2 = value or 1
	local v3 = value2 or 1

	for _, part in pairs(instance:GetChildren()) do
		if part:IsA("BasePart") then
			Misc.ScalePart(part, v2, v3)
		end
	end
end

function Misc.RotateTowards(p, p2, value, value2)
	local v2 = value2 or 0
	local magnitude = p2.Magnitude
	local magnitude2 = p.Magnitude
	local v3 = p2 / magnitude
	local vector2 = p / magnitude2
	local dot = vector2:Dot(v3)
	local v4 = math.min(math.acos(dot), value or 0.03333333333333333)

	if magnitude2 < magnitude then
		magnitude2 = math.min(magnitude, magnitude2 + v2)
	elseif magnitude2 ~= magnitude then
		magnitude2 = math.max(magnitude, magnitude2 - v2)
	end

	return ((v3 + vector2 * dot).Unit * math.sin(v4) + vector2 * math.cos(v4)).Unit * magnitude2
end

local random = Random.new()

function Misc.SpreadAngleFromCFrame(p, p2)
	local v2 = p or CFrame.new()
	local v3 = p2 or Vector2.new()
	local _ = v2.p
	local X = math.rad(v3.X)
	local Y = math.rad(v3.Y)
	local v4 = random:NextNumber(-1, 1) * X
	local v5 = random:NextNumber(-1, 1) * Y
	local cframe = CFrame.fromAxisAngle(createVector(1, 0, 0), v4)
	local cframe2 = CFrame.fromAxisAngle(createVector(0, 1, 0), v5)
	local v6 = v2 * cframe * cframe2
	return v6, v6.LookVector
end

function Misc.ScreenToWorldSpace(p, p2, value)
	local v2 = p or Vector2.new()
	local v3 = p2 or Vector2.new(1080, 800)
	local v4 = value or 1
	local guiInset, _ = GuiService:GetGuiInset()
	local cFrame = currentCamera.CFrame
	local v5 = v3 - guiInset
	local v6 = v5.X / v5.Y
	local v7 = math.tan(math.rad(currentCamera.FieldOfView) / 2)
	local v8 = 2 * v4 * (v2.X / (v5.X - 1)) - v4 * 1
	local v9 = 2 * v4 * (v2.Y / (v5.Y - 1)) - v4 * 1
	local v10 = v6 * v7 * v8
	local v11 = -v7 * v9
	local v12 = -v4
	local v13 = cFrame * CFrame.new(v10, v11, v12)
	return CFrame.new(v13.p, cFrame.p) * CFrame.Angles(0, 3.141592653589793, 0)
end

function Misc.invertCF(object)
	local components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = object:components()

	if v10 < 0 or v11 < 0 or v12 < 0 then
		return object
	end

	return CFrame.new(components, v2, v3, v4, v5, v6, v7, v8, v9, -v10, -v11, -v12)
end

function Misc.scaleCF(object, p, data)
	local components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = object:components()

	if typeof(data) == "table" then
		local X = data.X or 1
		local Y = data.Y or 1
		local Z = data.Z or 1
		components *= X
		v2 *= Y
		v3 *= Z
	elseif data == "X" then
		components *= p
	elseif data == "Y" then
		v2 *= p
	else
		if data ~= "Z" then
			components *= p
			v2 *= p
		end

		v3 *= p
	end

	return CFrame.new(components, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12)
end

function Misc.GenerateSpherePoints(value, value2, value3, value4)
	local v2 = value3 or 5
	local v3 = value or 6.283185307179586
	local v4 = value2 or 6.283185307179586
	local v5 = value4 or 1
	local result = {}

	for i = 1, v2 do
		local v6 = v3 * (i / v2)

		for i2 = 1, v2 do
			local v7 = v4 * (i2 / v2)
			table.insert(
				result,
				Vector3.new(math.cos(v6) * math.cos(v7), math.sin(v7), math.sin(v6) * math.cos(v7)).Unit * v5
			)
		end
	end

	return result
end

function Misc.GenerateID()
	return HttpService:GenerateGUID()
end

Misc.generateID = Misc.GenerateID
Misc.generateId = Misc.GenerateID
Misc.GenerateId = Misc.GenerateID
return Misc