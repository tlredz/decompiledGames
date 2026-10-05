local createVector = vector.create
local Spacial = {
	IsBlocked = function(_, vector2: Vector3, vector3: Vector3, filterDescendantsInstances)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true
		return workspace:Raycast(vector2, (vector3 - vector2).Unit * (vector3 - vector2).Magnitude, raycastParams) ~= nil
	end,
	BackIsFacing = function(_, p, p2)
		return (p2.Position - p.Position).Unit:Dot(p2.LookVector) > 0
	end,
	GetGroundPosition = function(_, cframe: CFrame, options)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = options or {}
		local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -5, 0), raycastParams)
		return raycastResult and raycastResult.Position or cframe.Position
	end,
	GetCharactersInHitbox = function(_, p, options)
		local exclusions = (options or {}).Exclusions or {}
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = exclusions
		local partsInPart = workspace:GetPartsInPart(p, overlapParams)
		local parents = {}

		for _, v in ipairs(partsInPart) do
			if v.Transparency == 1 then
				continue
			end

			local humanoid = v.Parent:FindFirstChild("Humanoid")

			if not (humanoid and humanoid.Health > 0) then
				continue
			end

			local parent = humanoid.Parent

			if not table.find(parents, parent) then
				table.insert(parents, parent)
			end
		end

		return parents
	end
}

function Spacial.GetRandomFloatingPositionAbovePart(_, p, options)
	local v = options or {}
	local minHeight = v.MinHeight or 25
	local maxHeight = v.MaxHeight or 50
	local position = Spacial:GetRandomCFrameOnTopOfPart(p).Position
	return (Vector3.new(position.X, math.random(minHeight, maxHeight), position.Z))
end

function Spacial.RadialSpawn(_, player, vector2: Vector3, p)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v = math.rad((math.random(0, 360)))
	local vector3 = Vector3.new(vector2.X + math.cos(v) * p, vector2.Y, vector2.Z + math.sin(v) * p)
	humanoidRootPart.CFrame = CFrame.new(vector3)
	humanoidRootPart.CFrame = CFrame.lookAt(vector3, vector2)
end

function Spacial.MakePlayerLookAt(_, player, p)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position
	local position2 = p.Position
	local vector2 = Vector3.new(position.X, 0, position.Z)
	local vector3 = Vector3.new(position2.X, 0, position2.Z)
	local cframe = CFrame.lookAt(vector2, vector3)
	humanoidRootPart.CFrame = CFrame.new(position) * CFrame.Angles(0, cframe.LookVector:Angle(createVector(0, 0, 1)), 0)
end

function Spacial:GetRandomCFrameOnTopOfPart(instance, options)
	local v = options or {}
	local axisRestriction = v.AxisRestriction
	local padding = v.Padding or 0
	local size = instance.Size
	local cFrame = instance.CFrame
	local vector2

	if instance.Shape == Enum.PartType.Cylinder then
		local v2 = math.min(size.Y, size.Z) / 2 - padding
		local v3 = v2 < 0 and 0 or v2
		local v4 = math.random() * 2 * 3.141592653589793
		local v5 = math.sqrt((math.random())) * v3
		local v6 = v5 * math.cos(v4)
		local v7 = v5 * math.sin(v4)
		local v8 = axisRestriction == "Y" and 0 or v6
		local v9 = axisRestriction == "Z" and 0 or v7
		vector2 = Vector3.new(size.X / 2, v8, v9)
	else
		local v2 = size.X / 2
		local v3 = size.Z / 2
		local v4 = -v2 + padding
		local v5 = v2 - padding
		local v6 = -v3 + padding
		local v7 = v3 - padding
		local v8 = math.random() * (v5 - v4) + v4
		local v9 = math.random() * (v7 - v6) + v6
		local v10 = axisRestriction == "X" and 0 or v9
		vector2 = Vector3.new(axisRestriction == "Z" and 0 or v8, size.Y / 2, v10)
	end

	local pointToWorldSpace = cFrame:PointToWorldSpace(vector2)
	return CFrame.new(pointToWorldSpace) * CFrame.Angles(cFrame:ToEulerAnglesXYZ())
end

function Spacial.TeleportObjectOnTopOfPart(_, model, p, p2)
	local position = Spacial:GetRandomCFrameOnTopOfPart(p, p2).Position

	if not model:IsA("Model") then
		model.Position = position + Vector3.new(0, model.Position.Y, 0) - Vector3.new(0, position.Y, 0)
		return
	end

	local Y = model.PrimaryPart.Position.Y
	model:PivotTo(CFrame.new(position + Vector3.new(0, Y, 0) - Vector3.new(0, position.Y, 0)))
end

function Spacial.TeleportPlayerToRandomPosOnTopOfPart(_, player, p, p2)
	local character = player.Character or player.CharacterAdded:Wait()
	local randomCFrameOnTopOfPart = Spacial:GetRandomCFrameOnTopOfPart(p, p2)

	if p.Shape == Enum.PartType.Cylinder then
		local v = randomCFrameOnTopOfPart * CFrame.Angles(0, 0, -1.5707963267948966)
		randomCFrameOnTopOfPart = CFrame.lookAt(v.Position, p.Position)
	end

	character:PivotTo(randomCFrameOnTopOfPart + createVector(0, 1, 0))
end

function Spacial.RaycastFromMiddleOfScreen(_, value, options)
	local GuiService = game:GetService("GuiService")
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = options or {}
	local viewportSize = currentCamera.ViewportSize
	local guiInset = GuiService:GetGuiInset()
	local vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2 - guiInset.Y)
	local screenPointToRay = currentCamera:ScreenPointToRay(vector2.X, vector2.Y)
	return (workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * (value or 1000), raycastParams))
end

function Spacial.GetMouseTarget(_, _)
	local currentCamera = workspace.CurrentCamera
	local UserInputService = game:GetService("UserInputService")
	local mouseLocation = UserInputService:GetMouseLocation()
	local screenPointToRay = currentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)
	local origin = screenPointToRay.Origin
	local v = screenPointToRay.Direction * 1000
	local raycastResult = workspace:Raycast(origin, v)
	return raycastResult and raycastResult.Instance or nil
end

return Spacial