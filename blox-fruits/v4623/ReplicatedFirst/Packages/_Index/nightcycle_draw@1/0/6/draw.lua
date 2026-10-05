local createVector = vector.create
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local terrain = Workspace.Terrain
local color = Color3.new(1, 0, 0)

function getDefaultParent()
	if not RunService:IsRunning() then
		return Workspace.CurrentCamera
	end

	if RunService:IsServer() then
		return Workspace
	end

	return Workspace.CurrentCamera
end

function point(p: Vector3, color2: Color3?, p2, value: number?)
	if typeof(p) == "CFrame" then
		p = p.p
	end

	assert(typeof(p) == "Vector3", "Bad position")
	local color3 = color2 or color
	local parent = p2 or getDefaultParent()
	local v3 = value or 1
	local v4

	if color3 == nil or parent == nil then
		v4 = false
	else
		v4 = v3 ~= nil
	end

	assert(v4)
	local part = Instance.new("Part")
	part.Material = Enum.Material.ForceField
	part.Anchored = true
	part.Archivable = false
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(p)
	part.Color = color3
	part.Name = "DebugPoint"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(v3, v3, v3)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.5
	local sphereHandleAdornment = Instance.new("SphereHandleAdornment")
	sphereHandleAdornment.Archivable = false
	sphereHandleAdornment.Radius = v3 / 4
	sphereHandleAdornment.Color3 = color3
	sphereHandleAdornment.AlwaysOnTop = true
	sphereHandleAdornment.Adornee = part
	sphereHandleAdornment.ZIndex = 2
	sphereHandleAdornment.Parent = part
	part.Parent = parent
	return part
end

function _ray(ray: Ray, color2: Color3?, p, value: number?, value2: number?)
	assert(typeof(ray) == "Ray", "Bad typeof(ray) for Ray")
	local color3 = color2 or color
	local parent = p or getDefaultParent()
	local v3 = value or 0.2
	local v4 = value2 or 0.2
	local v5

	if v3 == nil or v4 == nil or parent == nil then
		v5 = false
	else
		v5 = color3 ~= nil
	end

	assert(v5)
	local v6 = ray.Origin + ray.Direction / 2
	local part = Instance.new("Part")
	part.Material = Enum.Material.ForceField
	part.Anchored = true
	part.Archivable = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(v6, ray.Origin + ray.Direction) * CFrame.Angles(1.5707963267948966, 0, 0)
	part.Color = color3
	part.Name = "DebugRay"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(v4, ray.Direction.Magnitude, v4)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.5
	local part2 = Instance.new("Part")
	part2.Name = "RotatedPart"
	part2.Anchored = true
	part2.Archivable = false
	part2.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part2.CastShadow = false
	part2.CFrame = CFrame.new(ray.Origin, ray.Origin + ray.Direction)
	part2.Transparency = 1
	part2.Size = createVector(1, 1, 1)
	part2.Parent = part
	local lineHandleAdornment = Instance.new("LineHandleAdornment")
	lineHandleAdornment.Name = "DrawRayLineHandleAdornment"
	lineHandleAdornment.Length = ray.Direction.Magnitude
	lineHandleAdornment.Thickness = 5 * v4
	lineHandleAdornment.ZIndex = 3
	lineHandleAdornment.Color3 = color3
	lineHandleAdornment.AlwaysOnTop = true
	lineHandleAdornment.Transparency = 0
	lineHandleAdornment.Adornee = part2
	lineHandleAdornment.Parent = part2
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.Name = "DrawRayMesh"
	specialMesh.Scale = createVector(0, 1, 0) + Vector3.new(v3, 0, v3) / v4
	specialMesh.Parent = part
	part.Parent = parent
	return part
end

function cframe(cframe2: CFrame)
	local model = Instance.new("Model")
	model.Name = "DebugCFrame"
	local position = cframe2.Position
	point(position, nil, model, 0.1)
	local _ray_2 = _ray(Ray.new(position, cframe2.XVector), Color3.new(0.75, 0.25, 0.25), model, 0.1)
	_ray_2.Name = "XVector"
	local _ray_3 = _ray(Ray.new(position, cframe2.YVector), Color3.new(0.25, 0.75, 0.25), model, 0.1)
	_ray_3.Name = "YVector"
	local _ray_4 = _ray(Ray.new(position, cframe2.ZVector), Color3.new(0.25, 0.25, 0.75), model, 0.1)
	_ray_4.Name = "ZVector"
	model.Parent = getDefaultParent()
	return model
end

local Draw = {
	_defaultColor = color,
	cframe = cframe,
	getDefaultParent = getDefaultParent,
	ray = _ray,
	point = point,
	updateRay = function(instance, ray: Ray, color2: Color3?)
		local color3 = color2 or instance.Color
		assert(color3 ~= nil)
		local X = instance.Size.X
		local v2 = ray.Origin + ray.Direction / 2
		instance.CFrame = CFrame.new(v2, ray.Origin + ray.Direction) * CFrame.Angles(1.5707963267948966, 0, 0)
		instance.Size = Vector3.new(X, ray.Direction.Magnitude, X)
		instance.Color = color3
		local rotatedPart = instance:FindFirstChild("RotatedPart")

		if rotatedPart then
			rotatedPart.CFrame = CFrame.new(ray.Origin, ray.Origin + ray.Direction)
		end

		local drawRayLineHandleAdornment = rotatedPart and rotatedPart:FindFirstChild("DrawRayLineHandleAdornment")

		if drawRayLineHandleAdornment then
			drawRayLineHandleAdornment.Length = ray.Direction.Magnitude
			drawRayLineHandleAdornment.Thickness = 5 * X
			drawRayLineHandleAdornment.Color3 = color3
		end

		return nil
	end
}

function Draw.text(worldPosition, p: string, color2: Color3?)
	local v = color2 or color
	assert(v ~= nil)

	if typeof(worldPosition) == "Vector3" then
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = worldPosition
		attachment.Parent = terrain
		attachment.Name = "DebugTextAttachment"
		Draw._textOnAdornee(attachment, p, v)
		return attachment
	else
		if typeof(worldPosition) == "Instance" then
			return Draw._textOnAdornee(worldPosition, p, v)
		end

		error("Bad adornee")
	end
end

function Draw._textOnAdornee(p, p2: string, color2: Color3?)
	local v = color2 or color
	assert(v ~= nil)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "DebugBillboardGui"
	billboardGui.SizeOffset = Vector2.new(0, 0.5)
	billboardGui.ExtentsOffset = createVector(0, 1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = p
	billboardGui.StudsOffset = createVector(0, 0, 0.01)
	local frame = Instance.new("Frame")
	frame.Name = "Background"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0.5, 0, 1, 0)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = v or color
	frame.Parent = billboardGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = tostring(p2)
	textLabel.TextScaled = true
	textLabel.TextSize = 32
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Parent = frame

	if tonumber(p2) then
		textLabel.Font = Enum.Font.Code
	else
		textLabel.Font = Enum.Font.GothamMedium
	end

	local textSize = TextService:GetTextSize(
		textLabel.Text,
		textLabel.TextSize,
		textLabel.Font,
		Vector2.new(1024, 1000000)
	)
	local v2 = textSize.y / textLabel.TextSize
	local v3 = textLabel.TextSize * 0.5
	local v4 = textSize.y + 2 * v3
	local v5 = textSize.x + 2 * v3
	local aspectRatio = v5 / v4
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = aspectRatio
	uIAspectRatioConstraint.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingBottom = UDim.new(v3 / v4, 0)
	uIPadding.PaddingTop = UDim.new(v3 / v4, 0)
	uIPadding.PaddingLeft = UDim.new(v3 / v5, 0)
	uIPadding.PaddingRight = UDim.new(v3 / v5, 0)
	uIPadding.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(v3 / v4 / 2, 0)
	uICorner.Parent = frame
	local v7 = v2 * 2 * 2 * 0.5
	billboardGui.Size = UDim2.new(v7 * aspectRatio, 0, v7, 0)
	billboardGui.Parent = p
	return billboardGui
end

function Draw.sphere(vector2: Vector3, p: number, color2: Color3?, p2)
	return Draw.point(vector2, color2, p2, p * 2)
end

function Draw.labelledPoint(position, p: string, color2: Color3?, p2)
	if typeof(position) == "CFrame" then
		position = position.Position
	end

	assert(typeof(position) == "Vector3")
	local v = color2 or color
	local point2 = Draw.point(position, v, p2)
	Draw.text(point2, p, v)
	return point2
end

function Draw.box(cframe2, size: Vector3, color2: Color3?)
	local color3 = color2 or color

	if typeof(cframe2) == "Vector3" then
		cframe2 = CFrame.new(cframe2) or cframe2
	end

	local v2

	if typeof(cframe2) == "CFrame" then
		v2 = color3 ~= nil
	else
		v2 = false
	end

	assert(v2)
	local part = Instance.new("Part")
	part.Color = color3
	part.Material = Enum.Material.ForceField
	part.Name = "DebugPart"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Archivable = false
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0.75
	part.Size = size
	part.CFrame = cframe2
	local boxHandleAdornment = Instance.new("BoxHandleAdornment")
	boxHandleAdornment.Adornee = part
	boxHandleAdornment.Size = size
	boxHandleAdornment.Color3 = color3
	boxHandleAdornment.AlwaysOnTop = true
	boxHandleAdornment.Transparency = 0.75
	boxHandleAdornment.ZIndex = 1
	boxHandleAdornment.Parent = part
	part.Parent = Draw.getDefaultParent()
	return part
end

function Draw.region3(instance, color2: Color3?)
	return Draw.box(instance.CFrame, instance.Size, color2)
end

function Draw.terrainCell(vector2: Vector3, color2: Color3?)
	local v = color2 or color
	assert(v ~= nil)
	local worldToCell = terrain:WorldToCell(vector2)
	local cellCenterToWorld = terrain:CellCenterToWorld(worldToCell.x, worldToCell.y, worldToCell.z)
	local box = Draw.box(CFrame.new(cellCenterToWorld), createVector(4, 4, 4), v)
	box.Name = "DebugTerrainCell"
	return box
end

function Draw.vector(vector2: Vector3, vector3: Vector3, color2: Color3?, p, p2: number?)
	return Draw.ray(Ray.new(vector2, vector3), color2, p, p2, nil)
end

return Draw