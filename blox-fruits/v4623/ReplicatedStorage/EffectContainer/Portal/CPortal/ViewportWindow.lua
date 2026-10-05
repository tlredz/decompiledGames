local createVector = vector.create
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local cframe = CFrame.fromEulerAnglesXYZ(0, 3.141592653589793, 0)
local viewportFrame = Instance.new("ViewportFrame")
local uDim = UDim2.fromScale(1, 1)
local uDim2 = UDim2.new()
local script2 = script
viewportFrame.Size = uDim
viewportFrame.Position = uDim2
viewportFrame.BackgroundTransparency = 1
viewportFrame.Parent = script2
local ViewportWindow = {}
ViewportWindow.__index = ViewportWindow

function ViewportWindow.new(parent, vector2: Vector3?)
	local object = setmetatable({}, ViewportWindow)
	object.SurfaceGui = parent
	object.Camera = Instance.new("Camera", parent)
	local clone = viewportFrame:Clone()
	clone.LightDirection = vector2 or -Lighting:GetSunDirection()
	clone.CurrentCamera = object.Camera
	clone.Parent = parent
	object.ViewportFrame = clone
	object.Connection = RunService.RenderStepped:Connect(function()
		object:RenderFrame()
	end)
	return object
end

function ViewportWindow.FromPart(adornee, face, parent, p: number?, p2: number?, vector2: Vector3?)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = face
	surfaceGui.Brightness = p or surfaceGui.Brightness
	surfaceGui.LightInfluence = p2 or surfaceGui.LightInfluence
	surfaceGui.CanvasSize = Vector2.new(1024, 1024)
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surfaceGui.Adornee = adornee
	surfaceGui.ClipsDescendants = true
	surfaceGui.Parent = parent
	surfaceGui.Name = "PortalCDepthEffect"
	return ViewportWindow.new(surfaceGui, vector2)
end

function ViewportWindow.GetPart(p)
	return p.SurfaceGui.Adornee
end

function ViewportWindow:GetSurfaceInfo()
	local adornee = self.SurfaceGui.Adornee
	local cFrame = adornee.CFrame
	local size = adornee.Size
	local vector2 = -Vector3.FromNormalId(self.SurfaceGui.Face)
	local v = math.abs(vector2.y) ~= 1 and createVector(0, 1, 0) or Vector3.new(vector2.y, 0, 0) or createVector(
		0,
		1,
		0
	)
	local v2 = CFrame.fromAxisAngle(v, 1.5707963267948966) * vector2
	local unit = vector2:Cross(v2).Unit
	return
		cFrame * CFrame.fromMatrix(-vector2 * size / 2, v2, unit, vector2),
		(Vector3.new((size * v2).Magnitude, (size * unit).Magnitude, (size * vector2).Magnitude))
end

function ViewportWindow:RenderFrame(p, surfaceInfo, p2)
	local currentCamera = workspace.CurrentCamera
	local v = p or currentCamera.CFrame

	if not (surfaceInfo and p2) then
		surfaceInfo, p2 = self:GetSurfaceInfo()
	end

	local v2 = surfaceInfo * Vector3.new(0, p2.y / 2, 0)
	local v3 = surfaceInfo * Vector3.new(0, -p2.y / 2, 0)
	local vector2 = v.LookVector:Cross(surfaceInfo.UpVector)
	local unit = vector2:Dot(vector2) > 0 and vector2.Unit or v.RightVector
	local inverse = CFrame.fromMatrix(v.p, unit, surfaceInfo.UpVector, unit:Cross(surfaceInfo.UpVector)):Inverse()
	local v4 = inverse * v3
	local v5 = inverse * v2
	local unit2 = (v4 * createVector(0, 1, 1)).Unit
	local unit3 = (v5 * createVector(0, 1, 1)).Unit
	local v6 = math.sign(unit2.y) * math.acos((unit2:Dot(createVector(0, 0, -1))))
	local v7 = math.sign(unit3.y) * math.acos((unit3:Dot(createVector(0, 0, -1))))
	local v8 = math.tan(math.rad(currentCamera.FieldOfView) / 2) * 2
	local v9 = (math.tan(v7) - math.tan(v6)) / v8
	local vectorToObjectSpace = surfaceInfo:VectorToObjectSpace(surfaceInfo.p - v.p)
	local v10 = vectorToObjectSpace * createVector(1, 0, 1)
	local v11 = vectorToObjectSpace * createVector(0, 1, 1)
	local dot = v10.Unit:Dot(createVector(0, 0, -1))
	local v12 = (surfaceInfo:VectorToObjectSpace(v.LookVector) * createVector(1, 0, 1)).Unit:Dot(v10.Unit) / (createVector(
		0,
		0,
		-1
	)):Dot(v10.Unit)
	local v13 = math.sqrt(1 - dot * dot) / dot
	local v14 = p2.x / p2.y
	local v15 = math.sign(vectorToObjectSpace.x * vectorToObjectSpace.z) * v13
	local v16 = v11.y / v11.z * v14
	local v17 = math.abs(v12 * v9 * v14)
	local v18 = { ((surfaceInfo - surfaceInfo.p) * cframe * CFrame.new(0, 0, 0, 1, 0, 0, 0, v14, 0, v15, v16, v17)):GetComponents() }
	local v19 = {}

	for i = 1, #v18 do
		v19[i] = math.abs(v18[i])
	end

	local v20 = math.max(unpack(v19))
	local cframe2 = CFrame.new(
		v18[1],
		v18[2],
		v18[3],
		v18[4] / v20,
		v18[5] / v20,
		v18[6] / v20,
		v18[7] / v20,
		v18[8] / v20,
		v18[9] / v20,
		v18[10] / v20,
		v18[11] / v20,
		v18[12] / v20
	)
	self.Camera.FieldOfView = currentCamera.FieldOfView
	self.Camera.CFrame = cframe2 + v.p
end

function ViewportWindow:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
	end

	if self.SurfaceGui then
		self.SurfaceGui:Destroy()
	end

	table.clear(self)
end

return ViewportWindow