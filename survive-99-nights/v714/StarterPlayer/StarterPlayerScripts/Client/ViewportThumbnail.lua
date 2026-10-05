local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ViewportThumbnail = {}

local function normaliseBallParts(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if not (part:IsA("Part") and part.Shape == Enum.PartType.Ball) then
			continue
		end

		local size = part.Size
		local v = math.min(size.X, size.Y, size.Z)
		part.Size = Vector3.new(v, v, v)
	end
end

local function newViewportFrame(p)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0
	viewportFrame.Ambient = p.Ambient or Color3.fromRGB(200, 200, 200)
	viewportFrame.LightColor = p.LightColor or Color3.fromRGB(255, 255, 255)
	return viewportFrame
end

function ViewportThumbnail:PopulateViewport(instance, options)
	if not (self and instance) then
		return
	end

	local v = options or {}
	local clone = instance:Clone()
	clone.Parent = self
	normaliseBallParts(clone)
	local camera = Instance.new("Camera")
	camera.FieldOfView = v.FieldOfView or 50
	camera.Parent = self
	self.CurrentCamera = camera
	local boundingBox, v2 = clone:GetBoundingBox()
	local v3 = math.max(v2.X, v2.Y, v2.Z) * (v.Zoom or 1.4)
	local v4 = v3 < 1 and 10 or v3
	local vectorToWorldSpace = CFrame.Angles(0, 3.141592653589793, 0):VectorToWorldSpace((createVector(0.7, 0.5, 0.7)).Unit)
	camera.CFrame = CFrame.lookAt(boundingBox.Position + vectorToWorldSpace * v4, boundingBox.Position)
	return clone, camera
end

function ViewportThumbnail.CreateViewport(p, options)
	if not p then
		return nil
	end

	local v = options or {}
	local v2 = newViewportFrame(v)
	ViewportThumbnail.PopulateViewport(v2, p, v)
	return v2
end

function ViewportThumbnail.CreateFromName(childName, p)
	local furnitureThumbnail = ReplicatedStorage.Assets:FindFirstChild("FurnitureThumbnail")
	local child = furnitureThumbnail and furnitureThumbnail:FindFirstChild(childName)

	if child then
		return ViewportThumbnail.CreateViewport(child, p)
	end

	return nil
end

function ViewportThumbnail.AddToButton(parent, p, options)
	if not parent then
		return nil
	end

	local v = options or {}
	local name = v.Name or "ViewportFrame"
	local child = parent:FindFirstChild(name)

	if child then
		child:Destroy()
	end

	local v2 = newViewportFrame(v)
	v2.Name = name
	v2.Size = v.Size or UDim2.new(0.8, 0, 0.8, 0)
	v2.Position = v.Position or UDim2.new(0.1, 0, 0.1, 0)
	v2.Parent = parent

	if p then
		ViewportThumbnail.PopulateViewport(v2, p, v)
	end

	return v2
end

return ViewportThumbnail