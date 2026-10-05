local createVector = vector.create
local v = {}
local v2 = 0
local v3 = nil
local localPlayer = game.Players.LocalPlayer
local Effect = require(game.ReplicatedStorage.Effect)
local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = { workspace.Map }
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function isBlocked(cFrame)
	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	local partsInPart = workspace:GetPartsInPart(part, overlapParams)
	task.delay(0.1, function()
		part:Destroy()
	end)
	local flag = false

	for _, v4 in pairs(partsInPart) do
		if v4.CanCollide and v4.Parent ~= workspace.Map then
			flag = true
		end
	end

	if flag then
		_G.TestGamePrint("End pos inside of map, reflecting cf")
	end

	return flag
end

return function(data)
	local object = data.Object

	if not v[object] then
		v[object] = object.Size
	end

	object.Size = v[object] + createVector(5, -5, 5)
	object.CanCollide = false
	object.CanTouch = true
	local buildings = data.Buildings
	local buildingCount = data.BuildingCount
	local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

	local function teleportToRandomWall(proxy, humanoidRootPart2)
		local size = proxy.Size
		local pivot = proxy:GetPivot()
		local position = pivot.Position
		local v4 = math.random(1, 4)
		local vector2

		if v4 == 1 then
			vector2 = Vector3.new(math.random(-size.X / 3, size.X / 3), math.random(0, size.Y / 3), size.Z / 2)
		elseif v4 == 2 then
			vector2 = Vector3.new(math.random(-size.X / 3, size.X / 3), math.random(0, size.Y / 3), -size.Z / 2)
		elseif v4 == 3 then
			vector2 = Vector3.new(-size.X / 2, math.random(0, size.Y / 3), math.random(-size.Z / 3, size.Z / 3))
		else
			vector2 = Vector3.new(size.X / 2, math.random(0, size.Y / 3), math.random(-size.Z / 3, size.Z / 3))
		end

		local pointToWorldSpace = pivot:PointToWorldSpace(vector2)
		local unit = (pointToWorldSpace - position).Unit
		local cFrame = CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + unit) * CFrame.new(0, 0, -2)

		if isBlocked(cFrame) then
			cFrame = humanoidRootPart2.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -2)
		end

		humanoidRootPart2.CFrame = cFrame
		humanoidRootPart2.Velocity = unit * 150
		return humanoidRootPart2.CFrame
	end

	local touchedConnection = humanoidRootPart.Touched:Connect(function(otherPart)
		if otherPart ~= object or v2 > tick() then
			return
		end

		if v3 and v3.Parent then
			v3.Size = v[v3] + createVector(5, -5, 5)
			v3.CanCollide = false
			v3.CanTouch = true
		end

		v3 = object
		v2 = tick() + 0.1
		local v4 = math.random(1, buildingCount)
		local building = buildings[v4]

		if building == v3 then
			if buildings[v4 + 1] then
				building = buildings[v4 + 1]
			else
				building = buildings[v4 - 1]
			end
		end

		local proxy = building.Proxy
		Effect.new("Creation.SurfaceHit"):play({
			origin = humanoidRootPart.Position,
			Root = humanoidRootPart,
			Hit = otherPart,
			CFrame = humanoidRootPart.CFrame,
			Cube = object
		})
		local cframe = teleportToRandomWall(proxy, humanoidRootPart)
		local currentCamera = workspace.CurrentCamera
		local cFrame = currentCamera.CFrame
		local orientation, _, _ = (cFrame - cFrame.Position):ToOrientation()
		local _, v5, v6 = cframe:ToOrientation()
		local cframe2 = CFrame.fromOrientation(orientation, v5, v6)
		currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position) * cframe2
		Effect.new("Creation.SurfaceHit"):play({
			origin = humanoidRootPart.Position,
			Root = humanoidRootPart,
			Hit = otherPart,
			CFrame = cframe,
			Cube = object
		})
	end)
	task.delay(10, function()
		if touchedConnection then
			touchedConnection:Disconnect()
			touchedConnection = nil
		end

		if v3 and v3.Parent then
			v3.Size = v[v3] + createVector(5, -5, 5)
			v3.CanCollide = false
		end

		v2 = 0
		v3 = nil
		v[object] = nil
	end)
end