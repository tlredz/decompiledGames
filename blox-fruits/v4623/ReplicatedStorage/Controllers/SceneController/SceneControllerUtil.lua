local createVector = vector.create
local SceneControllerUtil = {}
require(game.ReplicatedStorage.Controllers.CameraController.Types)
local TestRigUtil = require(game.ReplicatedStorage.Modules.Rig.TestRigUtil)
local v = {}

function SceneControllerUtil.prewarmVFX(items)
	for _, childName in pairs(items) do
		if v[childName] then
			continue
		end

		v[childName] = true
		local FX = require(game.ReplicatedStorage.FX)
		FX:WaitForChild(childName)
	end
end

function SceneControllerUtil.solveFillDistanceForViewport(vector2: Vector3, p: number, point: Vector2, point2: Vector2?, value: number?)
	local GuiService = game:GetService("GuiService")
	local Y = GuiService:GetGuiInset().Y
	local v2 = point + Vector2.new(0, Y)
	local X = v2.X
	local v3 = X / v2.Y
	local v4 = math.rad(p)
	local v5 = math.atan(math.tan(v4 * 0.5) * v3) * 2
	local vector3 = vector2 * 0.5
	local v6 = X / math.max(1, X - math.abs((X - (point2 or Vector2.new()).X * (value or 0)) * 0.5 - X * 0.5) * 2)
	return math.max(vector3.X * v6 / math.tan(v5 * 0.5), vector3.Y / math.tan(v4 * 0.5)) + vector3.Z
end

function SceneControllerUtil.solveInspectionCF(p, data)
	local origin = data.Origin
	local zero = Vector2.zero

	if data.ComputeScreenOffsetSize then
		zero = data.ComputeScreenOffsetSize() or zero
	end

	local distance = data.Distance

	if distance == nil then
		assert(data.Size, "Size is required when Distance is not provided.")
		distance = SceneControllerUtil.solveFillDistanceForViewport(
			data.Size,
			p.FieldOfView,
			p.ViewportSize,
			zero,
			data.ViewportOffset
		)
	end

	assert(distance)
	local v2 = distance * (data.Zoom or 1)
	local GuiService = game:GetService("GuiService")
	local Y = GuiService:GetGuiInset().Y
	local v3 = p.ViewportSize + Vector2.new(0, Y)
	local X = v3.X
	local v4 = (X - zero.X * (data.ViewportOffset or 0)) * 0.5 - X * 0.5
	local v5 = v3 * 0.5 + Vector2.new(v4, 0)
	local position = (CFrame.new(origin) * CFrame.new(0, 0, 1)).Position
	local cframe = CFrame.new(origin, position) * CFrame.new(0, 0, v2)
	local v6 = v3.X / v3.Y
	local fieldOfView = math.rad(p.FieldOfView)
	local v7 = math.atan(math.tan(fieldOfView * 0.5) * v6) * 2
	local v8 = (v5.X / v3.X - 0.5) * 2
	local v9 = (0.5 - v5.Y / v3.Y) * 2
	local vectorToWorldSpace = cframe:VectorToWorldSpace(Vector3.new(
		v8 * math.tan(v7 * 0.5),
		v9 * math.tan(fieldOfView * 0.5),
		-1
	).Unit)
	local cframe2 = CFrame.lookAt(cframe.Position, cframe.Position + vectorToWorldSpace)

	if data.Lerp == nil or data.Lerp.LastCF == nil or data.Lerp.Dt == nil then
		return cframe2
	end

	return data.Lerp.LastCF:Lerp(cframe2, data.Lerp.Dt * (data.Lerp.Speed or 0.5))
end

function SceneControllerUtil.getFacingCameraCF(cframe: CFrame, p: number?)
	local cFrame = workspace.CurrentCamera.CFrame
	local unit = (Vector3.new(cFrame.Position.X, cframe.Position.Y, cFrame.Position.Z) - cframe.Position).Unit
	local cframe2 = CFrame.lookAt(cframe.Position, cframe.Position + unit)

	if p then
		cframe2 *= CFrame.Angles(0, math.rad(p), 0)
	end

	return cframe2
end

function SceneControllerUtil.getLerpSpeed(instance, data)
	local minDistance = data.MinDistance
	local maxDistance = data.MaxDistance
	local minSpeed = data.MinSpeed
	local maxSpeed = data.MaxSpeed
	local v2 = math.clamp(
		((instance:GetPivot().Position - workspace.CurrentCamera.CFrame.Position).Magnitude - minDistance) / (maxDistance - minDistance),
		0,
		1
	)
	return minSpeed + (maxSpeed - minSpeed) * v2
end

function SceneControllerUtil.solveViewModelCF(p, data)
	local extents, v2 = TestRigUtil.getExtents(p)

	if data.Offset then
		extents *= data.Offset
	end

	local position = extents.Position
	local lookVector

	if data.LookVector then
		lookVector = data.LookVector
	else
		lookVector = not data.FollowRotation and createVector(-0, -0, -1) or extents.LookVector
	end

	local v3 = data.Magnitude and math.clamp(v2.Magnitude, data.Magnitude.Min, data.Magnitude.Max) or v2.Magnitude
	local v4 = position + lookVector * v3 * (data.DistanceMul or 1)

	if not data.Magnitude and v3 > 100 then
		print("size is large", v2.Magnitude)
	end

	local cframe = CFrame.lookAt(v4, position)

	if not data.Lerp then
		return cframe
	end

	local lerpSpeed = SceneControllerUtil.getLerpSpeed(p, {
		MinDistance = data.Lerp.MinDistance or 0,
		MaxDistance = data.Lerp.MaxDistance or 50,
		MinSpeed = data.Lerp.MinSpeed or 5,
		MaxSpeed = data.Lerp.MaxSpeed or 20
	})
	return (workspace.CurrentCamera.CFrame:Lerp(cframe, lerpSpeed * data.dt))
end

return SceneControllerUtil