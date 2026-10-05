local createVector = vector.create
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Size = UDim2.new(1, 0, 1, 0)
viewportFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
viewportFrame.BackgroundTransparency = 1

local function getSurfaceInfo(surfaceGui)
	local adornee = surfaceGui.Adornee
	local cFrame = adornee.CFrame
	local size = adornee.Size
	local vector2 = -Vector3.FromNormalId(surfaceGui.Face)
	local v = math.abs(vector2.Y) ~= 1 and createVector(0, 1, 0) or Vector3.new(vector2.Y, 0, 0) or createVector(
		0,
		1,
		0
	)
	local v2 = CFrame.fromAxisAngle(v, 1.5707963267948966) * vector2
	local unit = vector2:Cross(v2).Unit
	return
		cFrame * CFrame.fromMatrix(-vector2 * size / 2, v2, unit, vector2),
		(Vector2.new((size * v2).Magnitude, (size * unit).Magnitude))
end

return table.freeze({
	bindToSurfaceGui = function(parent)
		local camera = Instance.new("Camera")
		camera.Parent = parent
		local clone = viewportFrame:Clone()
		clone.CurrentCamera = camera
		clone.Parent = parent
		return table.freeze({
			camera = camera,
			viewportFrame = clone,
			surfaceGui = parent
		})
	end,
	render = function(data)
		local camera = data.camera
		local viewportFrame2 = data.viewportFrame
		local surfaceGui = data.surfaceGui
		local currentCamera = workspace.CurrentCamera
		local cFrame = currentCamera.CFrame
		local surfaceInfo, v = getSurfaceInfo(surfaceGui)
		local Y = currentCamera.ViewportSize.Y
		local pointToObjectSpace = surfaceInfo:PointToObjectSpace(cFrame.Position)
		local v2 = pointToObjectSpace.X / v.X
		local v3 = pointToObjectSpace.Y / v.Y
		local v4 = math.abs(v2) * 2 + 1
		local v5 = math.abs(v3) * 2 + 1
		local v6 = math.sqrt(v4 * v4 + v5 * v5)
		local dot = (cFrame.Position - surfaceInfo.Position):Dot(surfaceInfo.LookVector)
		local v7 = math.atan2(v.Y / 2, dot) * 2
		local fieldOfView = math.clamp(math.deg(v7), 1, 120)
		local v9 = dot / (v.Y / 2 / math.tan(math.rad(fieldOfView) / 2))
		local v10 = (v7 > 2.0943951023931953 and v9 or 1) / v6
		local cframe = CFrame.new(0, 0, 0, v10, 0, 0, 0, v10, 0, 0, 0, 1)
		viewportFrame2.Position = UDim2.new(viewportFrame2.AnchorPoint.X - v2, 0, viewportFrame2.AnchorPoint.Y - v3, 0)
		viewportFrame2.Size = UDim2.new(v6, 0, v6, 0)
		surfaceGui.CanvasSize = Vector2.new(Y * (v.X / v.Y), Y)
		camera.FieldOfView = fieldOfView
		camera.CFrame = CFrame.new(cFrame.Position) * (surfaceInfo - surfaceInfo.Position) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		) * cframe
	end
})