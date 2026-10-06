local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function printf(formatString, ...)
	return print(string.format(formatString, ...))
end

local function assertf(p, formatString, ...)
	assert(p, string.format(formatString, ...))
end

local function warnf(formatString, ...)
	warn(string.format(formatString, ...))
end

local function typeofIs(p, p2)
	return typeof(p) == p2
end

local function isInstance(instance)
	return typeof(instance) == "Instance"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValueOfClass(instance, p)
	return typeof(instance) == "Instance" and instance.ClassName == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModelCornerDist(model)
	local _, v = model:GetBoundingBox()
	local dist = model:GetAttribute("Dist") or 1
	return Vector3.new(v.X / 2.2 + v.Y / 2.2 + v.Z / 2.2).Magnitude / dist
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateCFrameAroundWorldAxis(cframe, p, p2)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(p)
	return cframe * CFrame.fromAxisAngle(vectorToObjectSpace, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateCFrameCameralike(cframe, p, p2)
	local _ = cframe.RightVector
	return rotateCFrameAroundWorldAxis(cframe, createVector(0, 1, 0), p2) * CFrame.Angles(p, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCFramePitch(p)
	local lookVector = p.LookVector
	return (math.atan2(lookVector.Y, Vector3.new(lookVector.X, 0, lookVector.Z).Magnitude))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCFrameYaw(p)
	local v = p.LookVector * createVector(1, 0, 1)
	return (math.atan2(v.x, v.z))
end

local function cFrameToAngles(p)
	return p - p.p
end

local function constrainAngles(p, pitchLimits, yawLimits)
	if pitchLimits then
		local cFramePitch = getCFramePitch(p) -- equivalent call inferred; original call site unknown

		if pitchLimits.Max < cFramePitch then
			p = rotateCFrameCameralike(p, -(cFramePitch - pitchLimits.Max), 0)
		elseif cFramePitch < pitchLimits.Min then
			p = rotateCFrameCameralike(p, pitchLimits.Min - cFramePitch, 0)
		end
	end

	if not yawLimits then
		return p
	end

	local cFrameYaw = getCFrameYaw(p) -- equivalent call inferred; original call site unknown

	if yawLimits.Max < cFrameYaw then
		return rotateCFrameCameralike(p, 0, -(cFrameYaw - yawLimits.Max))
	else
		if cFrameYaw < yawLimits.Min then
			p = rotateCFrameCameralike(p, 0, yawLimits.Min - cFrameYaw)
		end

		return p
	end
end

local function getMouseMovement(p)
	local v = nil

	if p.MouseMode == "LockPosition" then
		return (UserInputService:GetMouseDelta())
	end

	if p.MouseMode ~= "Default" then
		error("")
		return v
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local v2 = (_lastMousePosition or mouseLocation) - mouseLocation
	_lastMousePosition = mouseLocation
	return v2
end

local DragToRotateViewportFrame = {}
local v = {
	__index = DragToRotateViewportFrame
}

function DragToRotateViewportFrame.New(...)
	local self = setmetatable({}, v)
	self:Initialize(...)
	return self
end

function DragToRotateViewportFrame:Initialize(instance, instance2)
	assertf(
		instance == nil or isValueOfClass(instance, "ViewportFrame"),
		"Tried to initialize %s with argument #1 %s \"%s\", expected ViewportFrame.",
		"DragToRotateViewportFrame",
		typeof(instance),
		(tostring(instance))
	)
	assertf(
		instance2 == nil or isValueOfClass(instance2, "Camera"),
		"Tried to initialize %s with argument #2 %s \"%s\", expected Camera.",
		"DragToRotateViewportFrame",
		typeof(instance2),
		(tostring(instance2))
	)
	self.ViewportFrame = instance or Instance.new("ViewportFrame")
	self.Camera = instance2 or Instance.new("Camera")
	self.ViewportFrame.CurrentCamera = self.Camera
	self.Camera.CameraType = Enum.CameraType.Scriptable
	self.Camera.Parent = self.ViewportFrame
	self.PitchLimits = NumberRange.new(-1.0471975511965976, 1.0471975511965976)
	self.YawLimits = nil
	self.RotateMode = "CameraRotates"
	self.MouseMode = "LockPosition"
end

function DragToRotateViewportFrame:SetModel(model)
	assertf(
		isValueOfClass(model, "Model"),
		"Called %s:SetModel with argument #1 %s \"%s\", expected Model.",
		"DragToRotateViewportFrame",
		typeof(model),
		(tostring(model))
	)
	assertf(
		model.PrimaryPart ~= nil,
		"Called %s:SetModel with a model without a PrimaryPart.",
		"DragToRotateViewportFrame"
	)
	self.Model = model
	model.Parent = self.ViewportFrame
	model:SetPrimaryPartCFrame(CFrame.new())
	self:SetAngles(CFrame.Angles(0, 3.141592653589793, 0))
	self:Rotate(0, 0)
end

function DragToRotateViewportFrame:SetAngles(p)
	assertf(
		typeof(p) == "CFrame",
		"Called %s:SetAngles argument #1 with a %s \"%s\", expected CFrame.",
		"DragToRotateViewportFrame",
		typeof(p),
		(tostring(p))
	)
	local cframe = p - p.p

	if self.RotateMode == "CameraRotates" then
		local v2 = getModelCornerDist(self.Model) * 1
		local boundingBox, _ = self.Model:GetBoundingBox()
		self.Camera.CFrame = boundingBox * cframe * CFrame.new(0, 0, v2)
	elseif self.RotateMode == "ModelRotates" then
		self.Model:SetPrimaryPartCFrame(CFrame.new() * cframe:Inverse())
	else
		warnf("Invalid RotateMode %s, expected %s or %s", tostring(self.RotateMode), "CameraRotates", "ModelRotates")
	end
end

function DragToRotateViewportFrame:GetAngles()
	local cFrame = nil

	if self.RotateMode == "CameraRotates" then
		cFrame = self.Camera.CFrame
	elseif self.RotateMode == "ModelRotates" then
		cFrame = self.Model.PrimaryPart.CFrame:Inverse()
	else
		warnf("Invalid RotateMode %s, expected %s or %s", tostring(self.RotateMode), "CameraRotates", "ModelRotates")
	end

	return cFrame - cFrame.p
end

function DragToRotateViewportFrame:Rotate(p, p2)
	while math.abs(p) > 0.17453292519943295 do
		self:Rotate(math.sign(p) * 0.17453292519943295, 0)
		p -= math.sign(p) * 0.17453292519943295
	end

	while math.abs(p2) > 0.17453292519943295 do
		self:Rotate(0, math.sign(p2) * 0.17453292519943295)
		p2 -= math.sign(p2) * 0.17453292519943295
	end

	local v2 = rotateCFrameCameralike(self:GetAngles(), p, p2) -- equivalent call inferred; original call site unknown
	local pitchLimits

	if self.PitchLimits then
		pitchLimits = self.RotateMode == "CameraRotates" and self.PitchLimits or NumberRange.new(
			-self.PitchLimits.Max,
			-self.PitchLimits.Min
		)
	end

	local yawLimits

	if self.YawLimits then
		yawLimits = self.RotateMode == "CameraRotates" and self.YawLimits or NumberRange.new(
			-self.YawLimits.Max,
			-self.YawLimits.Min
		)
	end

	local v3

	if self.RotateMode == "CameraRotates" then
		v3 = constrainAngles(v2, pitchLimits, yawLimits)
	else
		v3 = constrainAngles(v2 * CFrame.Angles(0, 3.141592653589793, 0), pitchLimits, yawLimits) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
	end

	self:SetAngles(v3)
end

function DragToRotateViewportFrame:BeginDragging()
	_lastMousePosition = nil
	self.renderSteppedC = RunService.RenderStepped:Connect(function()
		if self.MouseMode == "LockCenter" then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)
	self.inputChangedC = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local v2 = self
			local mouseDelta = nil

			if v2.MouseMode == "LockPosition" then
				mouseDelta = UserInputService:GetMouseDelta()
			elseif v2.MouseMode == "Default" then
				local mouseLocation = UserInputService:GetMouseLocation()
				mouseDelta = (_lastMousePosition or mouseLocation) - mouseLocation
				_lastMousePosition = mouseLocation
			else
				error("")
			end

			if self.RotateMode == "ModelRotates" then
				mouseDelta *= Vector2.new(1, -1)
			end

			self:Rotate(mouseDelta.Y / 100, mouseDelta.X / 100)
		end
	end)
end

function DragToRotateViewportFrame:StopDragging()
	if self.inputChangedC then
		self.inputChangedC:Disconnect()
		self.inputChangedC = nil
	end

	if self.renderSteppedC then
		self.renderSteppedC:Disconnect()
		self.renderSteppedC = nil
	end
end

return DragToRotateViewportFrame