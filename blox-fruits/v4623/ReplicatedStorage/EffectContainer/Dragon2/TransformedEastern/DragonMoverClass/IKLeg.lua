local createVector = vector.create
local Compute2JointIKPosition = require(script.Parent.Compute2JointIKPosition)
local Util = require(game.ReplicatedStorage.Util)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Effect"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
ReplicatedStorage2:WaitForChild("FX")
local IKLeg = {}
IKLeg.__index = IKLeg

function IKLeg.new(hipAttachment, upperLegLength: number, lowerLegLength: number, flag: boolean, flag2: boolean, flag3: boolean)
	local self = setmetatable({}, IKLeg)
	self.hipAttachment = hipAttachment
	self.upperLegLength = upperLegLength
	self.lowerLegLength = lowerLegLength
	self.footStartsForwardMultiplier = flag == true and -1 or 1
	self.isLeftFootMultiplier = flag2 == true and -1 or 1
	self.orientForward = flag3 == true and -1 or 1
	local clone = self.hipAttachment:Clone()
	clone.Name = "Knee"
	clone.Parent = self.hipAttachment
	self.kneeAttachment = clone
	local clone2 = self.kneeAttachment:Clone()
	clone2.Name = "Foot"
	clone2.Parent = self.hipAttachment
	self.footAttachment = clone2
	self.FLOOR_MAX_ANGLE_OFFSET = 0.7853981633974483
	self.STEP_FORWARD_RATIO_BEGIN = 1
	self.STEP_FORWARD_RATIO_END = 4
	self.STEP_HEIGHT_MULTIPLIER = 0.8
	self.HEIGHT_RATIO_UNTIL_MIDAIR = 0.8
	self.LATERAL_CENTER_MULTIPLIER = 0.5
	self.footReachesFloor = false
	self.footUpVector = nil
	self:initializeFloorStoodOn()
	self:initializeFootAttachmentPosition()
	return self
end

local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()

function IKLeg:getDebugPart(p2: string, p3)
	local v = workspace:FindFirstChild(p2 .. "_IKLegDebug" .. "_" .. self.hipAttachment.Parent.Name)

	if v ~= nil then
		return v
	end

	v = Instance.new("Part")
	v.Color = Color3.fromHSV(math.random(), 1, 1)
	v.CastShadow = false
	v.CanCollide = false
	v.CanTouch = false
	v.CanQuery = false
	v.TopSurface = 0
	v.BottomSurface = 0
	v.Anchored = true
	v.Name = p2 .. "_IKLegDebug" .. "_" .. self.hipAttachment.Parent.Name
	v.Parent = p3 or workspace
	return v
end

function IKLeg:visualizeVector(p: string, vector2: Vector3, vector3: Vector3, p2: number, p3: number)
	local debugPart = self:getDebugPart(p)
	local unit = vector3.Unit
	debugPart.Size = Vector3.new(p3, p3, p2)
	debugPart.CFrame = CFrame.lookAt(vector2, vector2 + unit * p2) * CFrame.new(0, 0, -p2 * 0.5 + 0.01 * math.random())
	debugPart.Material = Enum.Material.Neon

	if debugPart:GetAttribute("ColorAlreadySet") == nil then
		debugPart.Color = Color3.fromHSV(math.random(), 1, 1)
		debugPart:SetAttribute("ColorAlreadySet", true)
	end

	local v = math.atan2(unit.X, unit.Z)
	local v2 = math.acos(unit.Y)
	local _ = ((v + 3.141592653589793) / 12.566370614359172 + v2 / 6.283185307179586) % 1
	local debugPart2 = self:getDebugPart(p .. "_Arrowhead")
	debugPart2.Shape = Enum.PartType.Ball
	debugPart2.Size = Vector3.new(p3, p3, p3) * 2
	debugPart2.CFrame = CFrame.new(vector2 + unit * p2)
	debugPart2.Color = debugPart.Color
	debugPart2.Material = Enum.Material.Neon
	return debugPart
end

function IKLeg:visualizeCircle(p: string, p2: number, vector2: Vector3, vector3: Vector3?)
	local debugPart = self:getDebugPart(p .. "_Circle")
	debugPart.Shape = Enum.PartType.Cylinder
	debugPart.Size = Vector3.new(0.1, p2 * 2, p2 * 2)
	debugPart.Transparency = 0.7
	local v = math.random() * 0.01
	debugPart.CFrame = CFrame.lookAt(createVector(0, 0, 0), vector3 or createVector(0, 1, 0)) * CFrame.new(0, 0, -v) * inverse + vector2
	return debugPart
end

function IKLeg:visualizePoint(p: string, position: Vector3, value: number?)
	local debugPart = self:getDebugPart(p .. "_Point")
	local v = value or 0.5
	debugPart.Shape = Enum.PartType.Ball
	debugPart.Size = Vector3.new(v * 2, v * 2, v * 2)
	debugPart.CFrame = CFrame.new(position)
	return debugPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectVectorOntoPlane(vector2: Vector3, vector3: Vector3)
	local unit = vector3.Unit
	return vector2 - vector2:Dot(unit) * unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClosestPointOnPlaneToPoint(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return vector2 + projectVectorOntoPlane(vector4 - vector2, vector3)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicHermite(p: number, footPlantProxyPosition: Vector3, vector2: Vector3, lateralFootPlantSpaceToWorld: Vector3, vector3: Vector3)
	return (p ^ 3 * 2 - p ^ 2 * 3 + 1) * footPlantProxyPosition + (p ^ 3 - p ^ 2 * 2 + p) * vector2 + (p ^ 3 * -2 + p ^ 2 * 3) * lateralFootPlantSpaceToWorld + (p ^ 3 - p ^ 2) * vector3
end

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function slerp(vector2: Vector3, vector3: Vector3, p: number)
	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local dot = unit:Dot(unit2)

	if dot > 0.9995 then
		return (unit + p * (unit2 - unit)).Unit
	end

	local v = math.clamp(dot, -1, 1)
	local v2 = math.acos(v) * p
	local v3 = math.sin(v2)
	local unit3 = (unit2 - unit * v).Unit

	if v < -0.9995 then
		unit3 = CFrame.lookAlong(createVector(0, 0, 0), unit).RightVector
	end

	return (unit * math.cos(v2) + unit3 * v3).Unit
end

function IKLeg:updateKneeAttachment()
	local currentProjectionVector2 = self.hipAttachment.WorldCFrame.RightVector * self.orientForward - self.hipAttachment.WorldCFrame.LookVector * self.isLeftFootMultiplier + 4 * self.hipAttachment.WorldCFrame.UpVector

	if self.currentProjectionVector == nil then
		self.currentProjectionVector = currentProjectionVector2
	else
		self.currentProjectionVector = slerp(self.currentProjectionVector, currentProjectionVector2, 0.1)
	end

	local currentProjectionVector = self.currentProjectionVector
	local worldPosition, solutionVector = Compute2JointIKPosition(
		self.hipAttachment.WorldPosition,
		self.upperLegLength,
		self.footAttachment.WorldPosition,
		self.lowerLegLength,
		currentProjectionVector,
		self.hipAttachment.Parent.Name,
		self.solutionVector
	)
	self.solutionVector = solutionVector
	self.kneeAttachment.WorldPosition = worldPosition
end

function IKLeg:initializeFloorStoodOn()
	self.floorPosition = nil
	self.floorNormal = nil
	local raycastResult = workspace:Raycast(
		self.hipAttachment.WorldPosition,
		createVector(-0, -1, -0) * self.HEIGHT_RATIO_UNTIL_MIDAIR * (self.upperLegLength + self.lowerLegLength),
		raycastParams
	)

	if raycastResult and raycastResult.Normal:Angle(createVector(0, 1, 0)) < self.FLOOR_MAX_ANGLE_OFFSET then
		self:updateFloorStoodOn(raycastResult.Position, raycastResult.Normal)
	end
end

function IKLeg:updateFloorStoodOn(floorPosition: Vector3, unit: Vector3)
	self.floorPosition = floorPosition
	self.floorNormal = unit

	if unit == nil then
		unit = (self.kneeAttachment.WorldPosition - self.footAttachment.WorldPosition).Unit
	end

	self.footUpVector = unit
end

function IKLeg:computeFloorMaxArea()
	local closestPointOnPlaneToPoint = getClosestPointOnPlaneToPoint(
		self.floorPosition,
		self.floorNormal,
		self.hipAttachment.WorldPosition
	) -- equivalent call inferred; original call site unknown
	local magnitude = (self.hipAttachment.WorldPosition - closestPointOnPlaneToPoint).Magnitude
	local v = math.sqrt((self.upperLegLength + self.lowerLegLength) ^ 2 - magnitude ^ 2)

	if v ~= v then
		v = nil
	end

	return closestPointOnPlaneToPoint, v
end

function IKLeg:footCanReachFloor(vector2: Vector3, vector3: Vector3)
	local closestPointOnPlaneToPoint = getClosestPointOnPlaneToPoint(vector2, vector3, self.hipAttachment.WorldPosition) -- equivalent call inferred; original call site unknown
	local v = (self.hipAttachment.WorldPosition - closestPointOnPlaneToPoint).Magnitude * math.sign((vector3:Dot(self.hipAttachment.WorldPosition - closestPointOnPlaneToPoint)))
	return v > 0 and v < self.HEIGHT_RATIO_UNTIL_MIDAIR * (self.upperLegLength + self.lowerLegLength)
end

function IKLeg:setFootPlantProxyPosition(footPlantProxyPosition: Vector3)
	local floorPosition = self.floorPosition
	local floorNormal = self.floorNormal
	assert(
		(getClosestPointOnPlaneToPoint(floorPosition, floorNormal, footPlantProxyPosition) - footPlantProxyPosition).Magnitude < 0.01,
		"footPlantProxyPosition must lie on the floor plane"
	)
	self.footPlantProxyPosition = footPlantProxyPosition
end

function IKLeg:getHipFloorRotation()
	local unit = (projectVectorOntoPlane(-self.hipAttachment.WorldCFrame.RightVector, self.floorNormal)).Unit
	local floorNormal = self.floorNormal
	local cross = floorNormal:Cross(unit)
	return CFrame.fromMatrix(createVector(0, 0, 0), cross, floorNormal, unit)
end

function IKLeg:computeLateralFootPlantArea()
	local floorMaxArea, v = self:computeFloorMaxArea()

	if v == nil then
		return floorMaxArea, nil
	end

	local v2 = v * 0.5
	return
		floorMaxArea + self:getHipFloorRotation():VectorToWorldSpace((Vector3.new(
			self.isLeftFootMultiplier * v2 * self.LATERAL_CENTER_MULTIPLIER,
			0,
			0
		))),
		v2
end

function IKLeg:worldToLateralFootPlantSpace(vector2: Vector3)
	local floorPosition = self.floorPosition
	local floorNormal = self.floorNormal
	assert(
		(getClosestPointOnPlaneToPoint(floorPosition, floorNormal, vector2) - vector2).Magnitude < 0.01,
		"inputVector must lie on the floor plane"
	)
	local lateralFootPlantArea, _ = self:computeLateralFootPlantArea()
	return (self:getHipFloorRotation() + lateralFootPlantArea):PointToObjectSpace(vector2)
end

function IKLeg:lateralFootPlantSpaceToWorld(vector2: Vector3)
	local lateralFootPlantArea, _ = self:computeLateralFootPlantArea()
	return (self:getHipFloorRotation() + lateralFootPlantArea):PointToWorldSpace(vector2)
end

function IKLeg:initializeFootAttachmentPosition()
	if self.floorPosition == nil then
		self.footPlantProxyPosition = createVector(0, 0, 0)
		self:updateFloorStoodOn(
			self.hipAttachment.WorldPosition - createVector(0, 1, 0) * self.HEIGHT_RATIO_UNTIL_MIDAIR * (self.upperLegLength + self.lowerLegLength),
			createVector(0, 1, 0)
		)
		local _, v = self:computeLateralFootPlantArea()
		local v2 = self.STEP_FORWARD_RATIO_BEGIN * v
		local lateralFootPlantSpaceToWorld = self:lateralFootPlantSpaceToWorld((Vector3.new(
			0,
			0,
			self.footStartsForwardMultiplier * v2
		)))
		self.footAttachment.WorldPosition = lateralFootPlantSpaceToWorld
		self:updateFloorStoodOn(nil, nil)
	else
		local _, v = self:computeLateralFootPlantArea()
		local v2 = self.STEP_FORWARD_RATIO_BEGIN * v
		self:setFootPlantProxyPosition((self:lateralFootPlantSpaceToWorld((Vector3.new(
			0,
			0,
			self.footStartsForwardMultiplier * v2
		)))))
		self.footAttachment.WorldPosition = self.footPlantProxyPosition
		self:updateKneeAttachment()
		self.footUpVector = (self.kneeAttachment.WorldPosition - self.footAttachment.WorldPosition).Unit
	end
end

function IKLeg:updateFootAttachment(_: number)
	if self.floorPosition == nil or not self:footCanReachFloor(self.floorPosition, self.floorNormal) then
		self.footReachesFloor = false
		local raycastResult = workspace:Raycast(
			self.hipAttachment.WorldPosition,
			createVector(-0, -1, -0) * self.HEIGHT_RATIO_UNTIL_MIDAIR * (self.upperLegLength + self.lowerLegLength),
			raycastParams
		)

		if raycastResult and raycastResult.Normal:Angle(createVector(0, 1, 0)) < self.FLOOR_MAX_ANGLE_OFFSET then
			self:updateFloorStoodOn(raycastResult.Position, raycastResult.Normal)
			self:setFootPlantProxyPosition(raycastResult.Position)
			self.footAttachment.WorldPosition = self.footPlantProxyPosition
			return
		else
			local raycastResult2 = workspace:Raycast(
				self.footAttachment.WorldPosition + createVector(0, 1, 0),
				createVector(-0, -2, -0)
			)

			if raycastResult2 and self:footCanReachFloor(raycastResult2.Position, raycastResult2.Normal) and raycastResult2.Normal:Angle(createVector(
				0,
				1,
				0
			)) < self.FLOOR_MAX_ANGLE_OFFSET then
				self:updateFloorStoodOn(raycastResult2.Position, raycastResult2.Normal)
				self:setFootPlantProxyPosition(raycastResult2.Position)
				self.footAttachment.WorldPosition = self.footPlantProxyPosition
			else
				return
			end
		end
	end

	self.footReachesFloor = true
	local footUpVector

	if self.floorNormal == nil then
		footUpVector = (self.kneeAttachment.WorldPosition - self.footAttachment.WorldPosition).Unit
	else
		footUpVector = self.floorNormal
	end

	self.footUpVector = footUpVector
	local lateralFootPlantArea, v2 = self:computeLateralFootPlantArea()
	local v3 = (self.footPlantProxyPosition - lateralFootPlantArea).Magnitude / v2
	local STEP_FORWARD_RATIO_BEGIN = self.STEP_FORWARD_RATIO_BEGIN
	local STEP_FORWARD_RATIO_END = self.STEP_FORWARD_RATIO_END

	if not (STEP_FORWARD_RATIO_BEGIN < v3) then
		self.footAttachment.WorldPosition = self.footPlantProxyPosition
		return
	end

	local v4 = math.clamp((v3 - STEP_FORWARD_RATIO_BEGIN) / (STEP_FORWARD_RATIO_END - STEP_FORWARD_RATIO_BEGIN), 0, 1)
	self.footUpVector = slerp(
		self.floorNormal,
		(self.kneeAttachment.WorldPosition - self.footAttachment.WorldPosition).Unit,
		1 - math.abs(v4 - 0.5) * 2
	)
	local v5 = STEP_FORWARD_RATIO_BEGIN * v2
	local _ = STEP_FORWARD_RATIO_END * v2
	local lateralFootPlantSpaceToWorld = self:lateralFootPlantSpaceToWorld(-self:worldToLateralFootPlantSpace(self.footPlantProxyPosition).Unit * v5)

	if STEP_FORWARD_RATIO_END <= v3 then
		self:setFootPlantProxyPosition(lateralFootPlantSpaceToWorld)
		self.footAttachment.WorldPosition = lateralFootPlantSpaceToWorld
		local raycastResult = workspace:Raycast(
			self.footAttachment.WorldPosition + 1 * self.floorNormal,
			-self.floorNormal * 2
		)

		if not (raycastResult and self:footCanReachFloor(raycastResult.Position, raycastResult.Normal) and raycastResult.Normal:Angle(createVector(
			0,
			1,
			0
		)) < self.FLOOR_MAX_ANGLE_OFFSET) then
			self:updateFloorStoodOn(nil, nil)
			return
		end

		self:updateFloorStoodOn(raycastResult.Position, raycastResult.Normal)
		self:setFootPlantProxyPosition(raycastResult.Position)
		self.footAttachment.WorldPosition = self.footPlantProxyPosition
		local v6 = Util.Sound:Play(
			"EasternHeavenlyDragonFruitFlyingLowFootstep" .. tostring(math.random(1, 3)),
			self.footAttachment
		)
		v6.RollOffMinDistance = math.max(v6.RollOffMinDistance, 200)
		Util.DestroyAfter(v6, 3)
	else
		local closestPointOnPlaneToPoint = getClosestPointOnPlaneToPoint(
			self.floorPosition,
			self.floorNormal,
			self.hipAttachment.WorldPosition
		) -- equivalent call inferred; original call site unknown
		local v6 = (self.hipAttachment.WorldPosition - closestPointOnPlaneToPoint).Magnitude * self.STEP_HEIGHT_MULTIPLIER
		local worldPosition = cubicHermite(
			v4,
			self.footPlantProxyPosition,
			self.floorNormal * v6 * 4,
			lateralFootPlantSpaceToWorld,
			-self.floorNormal * v6 * 4
		)
		local raycastResult = workspace:Raycast(
			self.footAttachment.WorldPosition,
			worldPosition - self.footAttachment.WorldPosition,
			raycastParams
		)

		if not (raycastResult and self:footCanReachFloor(raycastResult.Position, raycastResult.Normal) and raycastResult.Normal:Angle(createVector(
			0,
			1,
			0
		)) < self.FLOOR_MAX_ANGLE_OFFSET) then
			self.footAttachment.WorldPosition = worldPosition
			return
		end

		self:updateFloorStoodOn(raycastResult.Position, raycastResult.Normal)
		self:setFootPlantProxyPosition(raycastResult.Position)
		self.footAttachment.WorldPosition = self.footPlantProxyPosition
	end
end

function IKLeg:update(p)
	self:updateFootAttachment(p)
	self:updateKneeAttachment()
end

return IKLeg