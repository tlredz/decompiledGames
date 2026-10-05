local createVector = vector.create
local dependencies = script.Parent.Parent:WaitForChild("Dependencies")
local Config = require(dependencies:WaitForChild("Config"))
local Gizmo = require(dependencies:WaitForChild("Debug"):WaitForChild("Gizmo"))
local Utilities = require(dependencies:WaitForChild("Utilities"))
local constraints = script.Parent:WaitForChild("Constraints")
local AxisConstraint = require(constraints:WaitForChild("AxisConstraint"))
local CollisionConstraint = require(constraints:WaitForChild("CollisionConstraint"))
local DistanceConstraint = require(constraints:WaitForChild("DistanceConstraint"))
local FrictionConstraint = require(constraints:WaitForChild("FrictionConstraint"))
local RopeConstraint = require(constraints:WaitForChild("RopeConstraint"))
local RotationConstraint = require(constraints:WaitForChild("RotationConstraint"))
local SpringConstraint = require(constraints:WaitForChild("SpringConstraint"))
local _ = Utilities.SB_ASSERT_CB

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(vector2: Vector3)
	if vector2.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return vector2.Unit
end

local function IsNaN(p)
	return p ~= p
end

local now = 0
local v = {}
local QueryTransformedWorldCFrameNonSmartbone

QueryTransformedWorldCFrameNonSmartbone = function(p)
	local v2 = v[p]

	if v2 and v2.Frame == shared.FrameCounter then
		return v2.CFrame
	end

	local parent = p.Parent

	if parent == nil then
		return v2 and v2.CFrame or CFrame.identity
	end

	local v3

	if parent:IsA("Bone") then
		v3 = QueryTransformedWorldCFrameNonSmartbone(parent)
	else
		v3 = parent.CFrame
	end

	local cFrame = v3 * p.TransformedCFrame
	v[p] = {
		Frame = shared.FrameCounter,
		CFrame = cFrame
	}
	return cFrame
end

local QueryTransformedWorldCFrame

QueryTransformedWorldCFrame = function(p, bone)
	bone.SolvedAnimatedCFrame = true
	local parentIndex = bone.ParentIndex
	local bone2 = bone.Bone

	if parentIndex < 1 then
		return (QueryTransformedWorldCFrameNonSmartbone(bone2))
	end

	local bone3 = p.Bones[parentIndex]

	if not bone3.SolvedAnimatedCFrame then
		bone3.AnimatedWorldCFrame = QueryTransformedWorldCFrame(p, bone3)
	end

	return bone3.AnimatedWorldCFrame * bone2.TransformedCFrame
end

local function ClipVector(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return vector2 * (createVector(1, 1, 1) - vector4) + vector3 * vector4
end

local function GetFriction(p, p2)
	local currentPhysicalProperties = p.CurrentPhysicalProperties
	local currentPhysicalProperties2 = p2.CurrentPhysicalProperties
	local friction = currentPhysicalProperties.Friction
	local frictionWeight = currentPhysicalProperties.FrictionWeight
	local friction2 = currentPhysicalProperties2.Friction
	local frictionWeight2 = currentPhysicalProperties2.FrictionWeight
	return (friction * frictionWeight + friction2 * frictionWeight2) / (frictionWeight + frictionWeight2)
end

local function SolveWind(data, data2, vector2: Vector3)
	local settings = data2.Settings
	local windType = settings.WindType

	if windType ~= "Sine" and windType ~= "Noise" and windType ~= "Hybrid" then
		return createVector(0, 0, 0)
	end

	local windSpeed = settings.WindSpeed
	local windStrength = settings.WindStrength

	if windSpeed <= 1e-6 or windStrength <= 1e-6 then
		return createVector(0, 0, 0)
	end

	local v2 = data2.WindOffset + (os.clock() - data.HeirarchyLength * 0.2 + (data.TransformOffset.Position - data2.Root.WorldPosition).Magnitude * 0.2) * settings.WindInfluence
	local windDirection = settings.WindDirection
	local vector3 = SafeUnit(vector2) -- equivalent call inferred; original call site unknown
	local v3 = 1 - math.abs((vector3:Dot(windDirection)))

	if windSpeed > 0 then
		if vector3:Dot(windDirection) > 0 then
			v3 *= math.abs(1 - vector2.Magnitude / windSpeed)
		else
			v3 *= 1 + vector2.Magnitude / windSpeed
		end
	end

	local v4 = windSpeed * v3

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function EaseInExpo(magnitude: number)
		if magnitude == 0 then
			return 0
		end

		return 2 ^ (magnitude * 10 - 10)
	end

	local magnitude = vector2.Magnitude < 100 and vector2.Magnitude or 100
	local v5 = math.min(EaseInExpo(magnitude), 100)
	local v6 = v2 * math.max(v5, 1)
	local v7

	if v4 < 1 then
		v7 = v4 * v5
	else
		local v8 = v5 / 2
		v7 = v4 * (v8 > 1 and v8 or 1)
	end

	local v8 = nil

	local function GetNoise(p, p2, p3, p4)
		local v9 = math.clamp(math.noise(p, p2, p3), -1, 1)

		if p4 then
			return v9 ^ 2
		end

		return v9
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SampleGust()
		return math.sin(v6 * 1) * 0.3 + 0.7
	end

	local function SampleSin()
		local v9 = windStrength ^ 0.8
		local v10 = v7 * 2
		local v11 = math.sin(v6 * v9)
		local v12 = math.cos(v6 / 10 * v9)
		local v13 = math.sin(v6 * 2 * v9)
		local v14 = math.cos(v6 * 3 * v9)
		local v15 = (v11 + v12 + v13 + v14) / 4
		local v16 = v15 * 0.5 + 0.5
		local v17 = v15 * v10
		local v18 = v16 * v10

		if v17 < v18 then
			v17 = v18 or v17
		end

		return windDirection * v17
	end

	local function SampleNoise(value, p)
		local v9 = value or 0
		local v10 = windStrength ^ 0.8
		local v11 = v7 * 2
		local windOffset = data2.WindOffset
		local v12 = math.clamp(math.noise(v10, 0, windOffset), -1, 1)

		if p then
			v12 ^= 2
		end

		local v13 = v12 * (v11 + v9)
		local v14 = math.clamp(math.noise(0, v10, windOffset), -1, 1)

		if p then
			v14 ^= 2
		end

		local v15 = v14 * (v11 + v9)
		local v16 = math.clamp(math.noise(windOffset, 0, v10), -1, 1)

		if p then
			v16 ^= 2
		end

		local v17 = v16 * (v11 + v9)
		return windDirection * Vector3.new(v13, v15, v17)
	end

	if settings.WindType == "Sine" then
		v8 = SampleSin() * SampleGust()
	elseif settings.WindType == "Noise" then
		v8 = SampleNoise(0, true) * SampleGust()
	elseif settings.WindType == "Hybrid" then
		v8 = (SampleSin() * SampleGust() + SampleNoise(0.5, true) * SampleGust()) * 0.5
	end

	return v8 / (data.FreeLength < 0.01 and 0.01 or data.FreeLength) * (settings.WindInfluence * (windStrength * 0.01) * (math.clamp(
		data.HeirarchyLength,
		1,
		10
	) * 0.1)) * data.Weight
end

local Bone = {}
Bone.__index = Bone

function Bone.new(instance, rootBone, rootPart)
	local transformedWorldCFrame = instance.Parent:IsA("Bone") and instance.Parent.TransformedWorldCFrame or rootPart.CFrame
	local object = setmetatable({
		Bone = instance,
		FreeLength = -1,
		Weight = 0.7,
		ParentIndex = -1,
		HeirarchyLength = 0,
		Transform = instance.TransformedWorldCFrame:ToObjectSpace(transformedWorldCFrame):Inverse(),
		LocalTransform = instance.TransformedCFrame:ToObjectSpace(rootBone.TransformedCFrame):Inverse(),
		RootPart = rootPart,
		RootBone = rootBone,
		Radius = 0,
		Friction = 0,
		RotationLimit = 0,
		Force = nil,
		Gravity = nil,
		SolvedAnimatedCFrame = false,
		HasChild = false,
		AnimatedWorldCFrame = instance.TransformedWorldCFrame,
		StartingCFrame = instance.TransformedCFrame,
		TransformOffset = CFrame.identity,
		LocalTransformOffset = CFrame.identity,
		RestPosition = createVector(0, 0, 0),
		CalculatedWorldCFrame = instance.TransformedWorldCFrame,
		Position = instance.TransformedWorldCFrame.Position,
		LastPosition = instance.TransformedWorldCFrame.Position,
		WeldPosition = createVector(0, 0, 0),
		WeldCFrame = CFrame.identity,
		ActiveWeld = false,
		RigidWeld = false,
		Anchored = false,
		AxisLocked = { false, false, false },
		XAxisLimits = NumberRange.new(-1e999, 1e999),
		YAxisLimits = NumberRange.new(-1e999, 1e999),
		ZAxisLimits = NumberRange.new(-1e999, 1e999),
		IsSkippingUpdates = false,
		CollisionHits = {},
		CollisionsData = {}
	}, Bone)
	object.AttributeConnection = instance.AttributeChanged:Connect(function(_)
		local boneSettings = Utilities.GatherBoneSettings(instance)

		for k, boneSetting in boneSettings do
			local v2 = object

			if boneSetting == "¬" or not boneSetting then
				boneSetting = nil
			end

			v2[k] = boneSetting
		end
	end)
	object.SmartWeld = instance:FindFirstChild("SmartWeld")
	object.WeldAddedConnection = instance.ChildAdded:Connect(function(smartWeld)
		if smartWeld.Name == "SmartWeld" then
			object.SmartWeld = smartWeld
		end
	end)
	object.WeldRemovedConnection = instance.ChildRemoved:Connect(function(child)
		if child == object.SmartWeld then
			object.SmartWeld = instance:FindFirstChild("SmartWeld")
		end
	end)
	return object
end

function Bone:ClipVelocity(vector2: Vector3, vector3: Vector3)
	self.LastPosition = self.LastPosition * (createVector(1, 1, 1) - vector3) + vector2 * vector3
end

function Bone:PreUpdate(p)
	local bone = p.Bones[1]
	local bone2 = p.Bones[self.ParentIndex]
	self.SolvedAnimatedCFrame = true
	local parentIndex = self.ParentIndex
	local bone3 = self.Bone
	local animatedWorldCFrame

	if parentIndex < 1 then
		animatedWorldCFrame = QueryTransformedWorldCFrameNonSmartbone(bone3)
	else
		local bone4 = p.Bones[parentIndex]

		if not bone4.SolvedAnimatedCFrame then
			bone4.AnimatedWorldCFrame = QueryTransformedWorldCFrame(p, bone4)
		end

		animatedWorldCFrame = bone4.AnimatedWorldCFrame * bone3.TransformedCFrame
	end

	self.AnimatedWorldCFrame = animatedWorldCFrame
	local smartWeld = self.SmartWeld
	self.ActiveWeld = false

	if smartWeld and smartWeld:IsA("ObjectValue") then
		local value = smartWeld.Value
		self.RigidWeld = smartWeld:GetAttribute("Rigid") == true

		if value then
			if value:IsA("Attachment") then
				self.WeldPosition = value.WorldPosition
				self.WeldCFrame = value.WorldCFrame
				self.ActiveWeld = true
			elseif value:IsA("BasePart") then
				self.WeldPosition = value.Position
				self.WeldCFrame = value.CFrame
				self.ActiveWeld = true
			end
		end
	end

	if self.ParentIndex < 1 then
		self.Anchored = true
	end

	if self.Bone == self.RootBone then
		local cFrame

		if self.Bone.Parent and self.Bone.Parent:IsA("Bone") then
			cFrame = QueryTransformedWorldCFrameNonSmartbone(self.Bone.Parent)
		elseif self.RootPart then
			cFrame = self.RootPart.CFrame
		else
			return
		end

		self.TransformOffset = cFrame * self.Transform
	else
		self.TransformOffset = bone2.AnimatedWorldCFrame * self.Transform
	end

	self.LocalTransformOffset = (p.RootBoneCFrame or bone.Bone.CFrame) * self.LocalTransform
end

function Bone:StepPhysics(p, vector2: Vector3, p2: number)
	if self.Anchored then
		self.LastPosition = self.AnimatedWorldCFrame.Position
		self.Position = self.AnimatedWorldCFrame.Position
	else
		if self.Force or self.Gravity then
			vector2 = (self.Gravity or p.Settings.Gravity) + (self.Force or p.Settings.Force)
		end

		local settings = p.Settings
		local v2 = (self.Position - self.LastPosition) / p2

		if v2.Magnitude > 50 then
			v2 = v2.Unit * 50 or v2
		end

		local v3 = p.ObjectAcceleration * settings.Inertia
		local vector3 = SolveWind(self, p, v2)
		local v4 = vector2 + v3
		self.LastPosition = self.Position
		self.Position += v2 * (1 - settings.Damping) * p2 + v4 * p2 * p2 + vector3
	end
end

function Bone:Constrain(data, list, p: number)
	if self.Anchored then
		return
	end

	local position = self.Position
	local rootPartCFrame = data.RootPartCFrame or self.RootPart.CFrame
	local frictionConstraint = FrictionConstraint(self, position, self.LastPosition)

	if #list ~= 0 then
		frictionConstraint = CollisionConstraint(self, frictionConstraint, list)
	end

	local position2

	if data.Settings.Constraint == "Spring" then
		position2 = SpringConstraint(self, frictionConstraint, nil, data, p)
	elseif data.Settings.Constraint == "Distance" then
		position2 = DistanceConstraint(self, frictionConstraint, data)
	elseif data.Settings.Constraint == "Rope" then
		position2 = RopeConstraint(self, frictionConstraint, data)
	else
		position2 = self.AnimatedWorldCFrame.Position
	end

	local weldPosition = RotationConstraint(
		self,
		AxisConstraint(self, position2, self.LastPosition, rootPartCFrame, data.RootPartCFrameInverse),
		data
	)

	if self.ActiveWeld then
		if self.RigidWeld then
			weldPosition = self.WeldPosition
		else
			weldPosition = SpringConstraint(self, weldPosition, self.WeldPosition, data, p)
		end
	end

	self.Friction = 0

	for _, collisionHit in self.CollisionHits do
		local currentPhysicalProperties = self.RootPart.CurrentPhysicalProperties
		local currentPhysicalProperties2 = collisionHit.CurrentPhysicalProperties
		local friction = currentPhysicalProperties.Friction
		local frictionWeight = currentPhysicalProperties.FrictionWeight
		local friction2 = currentPhysicalProperties2.Friction
		local frictionWeight2 = currentPhysicalProperties2.FrictionWeight
		local friction3 = (friction * frictionWeight + friction2 * frictionWeight2) / (frictionWeight + frictionWeight2)

		if friction3 < self.Friction then
			friction3 = self.Friction or friction3
		end

		self.Friction = friction3
	end

	self.Position = weldPosition
end

function Bone:SkipUpdate()
	if self.IsSkippingUpdates == false and Config.RESET_TRANSFORM_ON_SKIP then
		self.CalculatedWorldCFrame = self.AnimatedWorldCFrame
		self.IsSkippingUpdates = true
	end

	self.LastPosition = self.AnimatedWorldCFrame.Position + (self.LastPosition - self.Position)
	self.Position = self.AnimatedWorldCFrame.Position
end

function Bone:SolveTransform(p, p2: number)
	if self.ParentIndex < 1 then
		return
	end

	self.IsSkippingUpdates = false
	local bone = p.Bones[self.ParentIndex]
	local bone2 = bone.Bone

	if bone and bone2 then
		local flag = false
		local X = self.Position.X
		local animatedWorldCFrame, X2

		if X ~= X then
			animatedWorldCFrame = self.AnimatedWorldCFrame
			X2 = animatedWorldCFrame.Position.X

			if X2 ~= X2 then
				animatedWorldCFrame = self.RootPart.CFrame
			end

			self.Position = animatedWorldCFrame.Position
			self.LastPosition = animatedWorldCFrame.Position
			flag = true
		else
			local X3 = self.LastPosition.X

			if X3 ~= X3 then
				animatedWorldCFrame = self.AnimatedWorldCFrame
				X2 = animatedWorldCFrame.Position.X

				if X2 ~= X2 then
					animatedWorldCFrame = self.RootPart.CFrame
				end

				self.Position = animatedWorldCFrame.Position
				self.LastPosition = animatedWorldCFrame.Position
				flag = true
			end
		end

		local transformOffset = bone.TransformOffset
		local v2 = self.Position - bone.Position
		local v3 = Utilities.GetRotationBetween(transformOffset.UpVector, v2).Rotation * transformOffset.Rotation
		local v4 = math.min(1 - 0.00001 ^ p2, 1)

		if bone.ActiveWeld and bone.RigidWeld then
			bone.CalculatedWorldCFrame = bone.WeldCFrame
		else
			bone.CalculatedWorldCFrame = bone2.WorldCFrame:Lerp(CFrame.new(bone.Position) * v3, v4)
		end

		local X3 = bone.CalculatedWorldCFrame.Position.X

		if X3 ~= X3 then
			local animatedWorldCFrame2 = bone.AnimatedWorldCFrame
			local X4 = animatedWorldCFrame2.Position.X

			if X4 ~= X4 then
				animatedWorldCFrame2 = self.RootPart.CFrame
			end

			bone.CalculatedWorldCFrame = animatedWorldCFrame2
			bone.Position = animatedWorldCFrame2.Position
			bone.LastPosition = animatedWorldCFrame2.Position
			flag = true
		end

		if flag and os.clock() - now > 3 then
			now = os.clock()
			local parent = self.RootPart.Parent
			warn((`[SmartBone] NaN bone on {parent and parent.Name or "?"}.{self.RootPart.Name}, reset to rest pose (throttled)`))
		end
	end
end

function Bone:ApplyTransform(p2)
	self.SolvedAnimatedCFrame = false

	if self.ParentIndex < 1 then
		return
	end

	local bone = p2.Bones[self.ParentIndex]
	local bone2 = bone.Bone

	if bone and bone2 then
		local transformOffset

		if bone.Anchored and not p2.Settings.AnchorsRotate then
			transformOffset = bone.TransformOffset
		elseif bone.Anchored then
			transformOffset = CFrame.new(bone.Position) * bone.CalculatedWorldCFrame.Rotation
		else
			transformOffset = bone.CalculatedWorldCFrame
		end

		local X = transformOffset.Position.X

		if X ~= X then
			bone2.CFrame = bone.StartingCFrame
		else
			bone2.WorldCFrame = transformOffset
		end
	end
end

function Bone.DrawDebug(data, p, flag: boolean, flag2: boolean, flag3: boolean, flag4: boolean, flag5: boolean)
	local color = Color3.fromRGB(255, 0, 0)
	local color2 = Color3.fromRGB(255, 94, 0)
	local color3 = Color3.fromRGB(234, 1, 255)
	local color4 = Color3.fromRGB(0, 255, 255)
	local color5 = Color3.fromRGB(255, 0, 0)
	local color6 = Color3.fromRGB(0, 255, 0)
	local color7 = Color3.fromRGB(0, 0, 255)
	local color8 = Color3.fromRGB(0, 183, 255)
	local color9 = Color3.fromRGB(255, 0, 0)
	local color10 = Color3.fromRGB(0, 255, 0)
	local color11 = Color3.fromRGB(0, 0, 255)
	local color12 = Color3.fromRGB(28, 41, 224)
	local color13 = Color3.fromRGB(255, 27, 27)
	local v2 = 1
	local animatedWorldCFrame = data.AnimatedWorldCFrame
	local position = animatedWorldCFrame.Position
	local cframe = CFrame.new(data.Position)
	local cframe2 = CFrame.new(data.LastPosition)

	if flag3 then
		Gizmo.PushProperty("AlwaysOnTop", false)
		Gizmo.PushProperty("Color3", color)
		Gizmo.Sphere:Draw(cframe, data.Radius, 10, 360)
		Gizmo.PushProperty("Color3", color2)
		Gizmo.Sphere:Draw(cframe2, data.Radius, 10, 360)
		Gizmo.PushProperty("Color3", color3)
		Gizmo.Ray:Draw(data.Position, data.LastPosition)
	end

	if flag4 and not data.Anchored then
		local v3 = data.AxisLocked[1]
		local v4 = data.AxisLocked[2]
		local v5 = data.AxisLocked[3]
		local rootPart = data.RootPart
		local pointToObjectSpace = rootPart.CFrame:PointToObjectSpace(position)
		local rightVector = rootPart.CFrame.RightVector
		local upVector = rootPart.CFrame.UpVector
		local lookVector = rootPart.CFrame.LookVector

		if not v3 then
			Gizmo.PushProperty("Color3", color9)
			Gizmo.Arrow:Draw(position - rightVector * 2, position + rightVector * 2, 0.05, 0.15, 9)
			local v6 = data.XAxisLimits.Min - pointToObjectSpace.X
			local v7 = data.XAxisLimits.Max - pointToObjectSpace.X
			Gizmo.Plane:Draw(position + rightVector * v6, rightVector, createVector(5, 5, 0))
			Gizmo.Plane:Draw(position + rightVector * v7, rightVector, createVector(5, 5, 0))
		end

		if not v4 then
			Gizmo.PushProperty("Color3", color10)
			Gizmo.Arrow:Draw(position - upVector * 2, position + upVector * 2, 0.05, 0.15, 9)
			local v6 = data.YAxisLimits.Min - pointToObjectSpace.Y
			local v7 = data.YAxisLimits.Max - pointToObjectSpace.Y
			Gizmo.Plane:Draw(position + upVector * v6, upVector, createVector(5, 5, 0))
			Gizmo.Plane:Draw(position + upVector * v7, upVector, createVector(5, 5, 0))
		end

		if not v5 then
			Gizmo.PushProperty("Color3", color11)
			Gizmo.Arrow:Draw(position - lookVector * 2, position + lookVector * 2, 0.05, 0.15, 9)
			local v6 = data.ZAxisLimits.Min - pointToObjectSpace.Z
			local v7 = data.ZAxisLimits.Max - pointToObjectSpace.Z
			Gizmo.Plane:Draw(position - lookVector * v6, lookVector, createVector(5, 5, 0))
			Gizmo.Plane:Draw(position - lookVector * v7, lookVector, createVector(5, 5, 0))
		end
	end

	if flag2 then
		Gizmo.PushProperty("Color3", color4)
		Gizmo.Sphere:Draw(animatedWorldCFrame, 0.08, 5, 360)
		Gizmo.PushProperty("Color3", color5)
		Gizmo.VolumeArrow:Draw(position, position + animatedWorldCFrame.LookVector * 0.25, 0.005, 0.015, 0.05, true)
		Gizmo.PushProperty("Color3", color6)
		Gizmo.VolumeArrow:Draw(position, position + animatedWorldCFrame.UpVector * 0.25, 0.005, 0.015, 0.05, true)
		Gizmo.PushProperty("Color3", color7)
		Gizmo.VolumeArrow:Draw(position, position + animatedWorldCFrame.RightVector * 0.25, 0.005, 0.015, 0.05, true)
	end

	if flag and not data.Anchored then
		for _, v3 in data.CollisionsData do
			Gizmo.PushProperty("Color3", color12)
			Gizmo.Sphere:Draw(CFrame.new(v3.ClosestPoint), 0.08, 5, 360)
			Gizmo.PushProperty("Color3", color13)
			Gizmo.Arrow:Draw(v3.ClosestPoint, v3.ClosestPoint + v3.Normal * 0.5, 0.05, 0.15, 9)
		end
	end

	if flag5 and data.RotationLimit < 180 and data.RotationLimit > 0 and data.ParentIndex > 0 and data.HasChild then
		local v3 = 1
		local v4

		if data.RotationLimit < 89.5 then
			v4 = v2 * math.tan((math.rad(data.RotationLimit)))
		elseif data.RotationLimit > 90 then
			v4 = v2 * math.tan((math.rad(180 - data.RotationLimit)))
			v3 = -1
		else
			v4 = 5
			v2 = 0
		end

		local v5 = math.min(v4, 5)
		local v6 = v5 == 5 and 0 or v2
		local v7 = (data.Position - p.Bones[data.ParentIndex].Position).Unit * v3
		local cframe3 = CFrame.lookAt(position + v7 * (v6 * 0.5), position + -v7 * 500, animatedWorldCFrame.LookVector)
		Gizmo.PushProperty("Color3", color8)
		Gizmo.Cone:Draw(cframe3, v5, v6, 8 + v5 * 2)
	end
end

function Bone.DrawOverlay(data, p)
	p.Text((`Bone: {data.Bone.Name}`))

	if Config.DEBUG_OVERLAY_BONE_INFO or Config.DEBUG_OVERLAY_BONE_NUMERICS then
		p.Text((`Free Length: {data.FreeLength}`))
		p.Text((`Weight: {data.Weight}`))
		p.Text((`Parent Index: {data.ParentIndex}`))
		p.Text((`Heirarchy Length: {data.HeirarchyLength}`))
		p.Text((`Radius: {data.Radius}`))
		p.Text((`Friction: {data.Friction}`))
		p.Text((`Rotation Limit: {data.RotationLimit}`))
	end

	if Config.DEBUG_OVERLAY_BONE_INFO or Config.DEBUG_OVERLAY_BONE_CONSTRAIN then
		p.Text((`Anchored: {data.Anchored}`))
		p.Text((`Axis Locked: {data.AxisLocked[1]}, {data.AxisLocked[2]}, {data.AxisLocked[3]}`))
		p.Text((`X Axis Limit: {data.XAxisLimits}`))
		p.Text((`Y Axis Limit: {data.YAxisLimits}`))
		p.Text((`Z Axis Limit: {data.ZAxisLimits}`))
	end

	if Config.DEBUG_OVERLAY_BONE_INFO or Config.DEBUG_OVERLAY_BONE_WELD then
		p.Text((`Active Weld: {data.ActiveWeld}`))
		p.Text((`Rigid Weld: {data.RigidWeld}`))
		p.Text((`Weld Position: {string.format("%.3f, %.3f, %.3f", data.WeldPosition.X, data.WeldPosition.Y, data.WeldPosition.Z)}`))
	end

	if Config.DEBUG_OVERLAY_BONE_INFO or Config.DEBUG_OVERLAY_BONE_FORCES then
		local v2 = not data.Force and "-, -, -" or string.format(
			"%.3f, %.3f, %.3f",
			data.Force.X,
			data.Force.Y,
			data.Force.Z
		) or "-, -, -"
		local v3 = data.Gravity and string.format("%.3f, %.3f, %.3f", data.Gravity.X, data.Gravity.Y, data.Gravity.Z) or "-, -, -"
		p.Text((`Force: {v2}`))
		p.Text((`Gravity: {v3}`))
	end
end

function Bone.Destroy(data)
	if Config.RESET_BONE_ON_DESTROY then
		task.synchronize()
		data.Bone.CFrame = data.StartingCFrame
	end

	data.AttributeConnection:Disconnect()
	data.WeldAddedConnection:Disconnect()
	data.WeldRemovedConnection:Disconnect()
	setmetatable(data, nil)
end

return Bone