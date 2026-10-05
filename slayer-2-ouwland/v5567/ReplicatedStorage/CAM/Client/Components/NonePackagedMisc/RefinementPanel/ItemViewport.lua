local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
require(ReplicatedStorage.Packages.faye)
return function(object, p: string)
	local viewmodelSettings = Items[p].ViewmodelSettings or {}
	return object:Create("ViewportFrame")({
		Name = "Preview",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.92),
		BackgroundTransparency = 1,
		function(parent)
			local v = ItemModels.Get(p)

			if v == nil then
				return
			end

			local clone = v:Clone()

			if clone:IsA("BasePart") then
				clone.Anchored = true
			end

			for _, v2 in clone:QueryDescendants("BasePart") do
				v2.Anchored = true
			end

			clone.Parent = parent
			local cframe = CFrame.new()
			local position

			if typeof(viewmodelSettings.CFrameOffset) == "CFrame" then
				cframe = viewmodelSettings.CFrameOffset.Rotation
				position = viewmodelSettings.CFrameOffset.Position
			else
				position = createVector(0, 0, 0)
			end

			clone:PivotTo(cframe)
			local boundingBox, size

			if clone:IsA("Model") then
				boundingBox, size = clone:GetBoundingBox()
			else
				boundingBox = clone.CFrame
				size = clone.Size
			end

			local v2 = CFrame.new(-boundingBox.Position) * cframe
			local camera = Instance.new("Camera")
			camera.Parent = parent
			parent.CurrentCamera = camera
			local halfMagnitude = size.Magnitude / 2
			local v4 = halfMagnitude / math.tan((math.rad(camera.FieldOfView / 2))) + halfMagnitude - 1 + (tonumber(viewmodelSettings.CameraOffset) or 0)
			camera.CFrame = CFrame.new(Vector3.new(0, 0, v4), createVector(0, 0, 0))
			local total = 0
			local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += 120 * dt
				clone:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(total), 0) * v2)
			end)
			parent.Destroying:Connect(function()
				renderSteppedConnection:Disconnect()
			end)
		end
	})
end