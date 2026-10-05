local createVector = vector.create
game:GetService("MarketplaceService")
game:GetService("HttpService")
local camera = Instance.new("Camera")
camera.FieldOfView = 20
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.BackgroundColor3 = Color3.new()
viewportFrame.BackgroundTransparency = 1
viewportFrame.LightDirection = createVector(0, 1, 0)
viewportFrame.Ambient = Color3.new(1, 1, 1)
viewportFrame.Size = UDim2.new(0, 100, 0, 100)
local decal = Instance.new("Decal")
decal.Face = Enum.NormalId.Top
local _ = Vector3.new
local match = string.match
local max = math.max
local cframe = CFrame.new(0, -0.1, 0)
return {
	new = function(texture, childName)
		local v

		if texture then
			if type(texture) == "string" then
				v = match(texture, "%d+")
			else
				v = false
			end
		else
			v = texture
		end

		assert(v, "Invalid Image ID: " .. texture)
		local child

		if childName then
			if type(childName) == "string" then
				child = script:FindFirstChild(childName)
			else
				child = false
			end
		else
			child = childName
		end

		assert(child, "Invalid Clipper Type: " .. childName)
		local clone = script:FindFirstChild(childName):Clone()
		clone.Size = createVector(1, 0.1, 1)
		clone.CFrame = cframe
		clone.Transparency = 1
		local clone2 = decal:Clone()
		clone2.Texture = texture
		local clone3 = camera:Clone()
		local X = clone.Size.X
		local Z = clone.Size.Z
		clone3.CFrame = CFrame.new(Vector3.new(0, max(X, Z) / 2 / 0.17, 0), (Vector3.new())) * CFrame.Angles(
			0,
			0,
			-1.5707963267949
		)
		local clone4 = viewportFrame:Clone()
		clone4.CurrentCamera = clone3
		clone2.Parent = clone
		clone.Parent = clone4
		clone3.Parent = clone4
		return clone4, clone
	end
}