local createVector = vector.create
local BasePartUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RegionUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("RegionUtil"))
local VectorUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("VectorUtil"))
local v = {
	createVector(0.5, 0.5, 0.5),
	createVector(0.5, -0.5, 0.5),
	createVector(-0.5, 0.5, 0.5),
	createVector(-0.5, -0.5, 0.5),
	createVector(0.5, 0.5, -0.5),
	createVector(0.5, -0.5, -0.5),
	createVector(-0.5, 0.5, -0.5),
	createVector(-0.5, -0.5, -0.5)
}

function BasePartUtil.getGlobalExtentsSize(instance, cframe: CFrame?)
	local rotation

	if cframe then
		rotation = cframe.Rotation
	else
		rotation = CFrame.new()
	end

	local cFrame = instance.CFrame
	local size = instance.Size
	local v2 = {}

	for _, v3 in { "X", "Y", "Z" } do
		local v4 = 1e999
		local v5 = -1e999

		for _, v6 in pairs(v) do
			local v7 = rotation:PointToObjectSpace(cFrame:PointToWorldSpace(size * v6))[v3]

			if v7 < v4 then
				v4 = v7
			end

			if v5 < v7 then
				v5 = v7
			end
		end

		v2[v3] = v5 - v4
	end

	return (Vector3.new(v2.X, v2.Y, v2.Z))
end

function BasePartUtil.getSurfacePosition(instance, vector2: Vector3)
	local size = instance.Size
	return instance.CFrame:PointToWorldSpace(size / 2 * vector2 * createVector(1, 1, -1))
end

function BasePartUtil.getGlobalSurfaceExtentSize(instance, vector2: Vector3, cframe: CFrame?)
	local size = instance.Size
	return BasePartUtil.getGlobalExtentsSize({
		Size = size * Vector3.new(1 - math.abs(vector2.X), 1 - math.abs(vector2.Y), 1 - math.abs(vector2.Z)),
		CFrame = instance.CFrame:ToWorldSpace(CFrame.new(size / 2 * vector2 * createVector(1, 1, -1)))
	}, cframe)
end

local function getBoxClosestPoint(instance, vector2: Vector3)
	local cFrame = instance.CFrame
	local pointToObjectSpace = cFrame:PointToObjectSpace(vector2)
	local halfSize = instance.Size / 2
	return cFrame:PointToWorldSpace(pointToObjectSpace - VectorUtil.max(
		VectorUtil.abs(pointToObjectSpace) - halfSize,
		(Vector3.new())
	) * VectorUtil.sign(pointToObjectSpace))
end

function BasePartUtil.closestPoint(p, instance)
	local position = p.CFrame.Position
	local size = instance.Size
	local cFrame = instance.CFrame
	local v2 = 1e999
	local v3 = nil

	for _, v4 in pairs(v) do
		local boxClosestPoint = getBoxClosestPoint(p, cFrame:PointToWorldSpace(size * v4))
		local magnitude = (boxClosestPoint - position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = boxClosestPoint
		v2 = magnitude
	end

	return v3
end

function BasePartUtil.drawPartBetweenPoints(vector2: Vector3, vector3: Vector3, _: number?)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	local v2 = vector3 - vector2
	part.CFrame = CFrame.new(vector2, vector3)
	part.Position = vector2 + v2 / 2
	part.Size = Vector3.new(0.5, 0.5, v2.Magnitude)
	return part
end

function BasePartUtil.getRandomPointInPart(instance)
	return (instance.CFrame * CFrame.new(
		math.random(-instance.Size.X / 2, instance.Size.X / 2),
		math.random(instance.Size.Y / 2, instance.Size.Y / 2),
		math.random(-instance.Size.Z / 2, instance.Size.Z / 2)
	)).Position
end

function BasePartUtil.MoveModelAndWeld(instance, p, p2)
	local cframe = instance:GetPivot():ToObjectSpace(p.CFrame)
	instance:PivotTo(p2.CFrame * cframe:Inverse())
	return BasePartUtil.weld(p, p2, instance, "WeldConstraint")
end

function BasePartUtil.weld(part, part2, p, value: string?)
	local instance = Instance.new(value or "WeldConstraint")
	instance.Name = `{part2.Name} - {part.Name}`
	instance.Part0 = part
	instance.Part1 = part2
	instance.Parent = p or part
	return instance
end

function BasePartUtil.weldModel(folder, p, p2: string?)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			BasePartUtil.weld(p, part, p, p2)
		end
	end
end

local function isPointInCylinder(vector2: Vector3, part)
	local v2 = math.min(part.Size.Z, part.Size.Y) * 0.5
	local X = part.Size.X
	local v3 = vector2 - part.Position
	local dot = part.CFrame.RightVector:Dot(v3)
	return (v3 - part.CFrame.RightVector * dot).Magnitude <= v2 and math.abs(dot) <= X * 0.5
end

function BasePartUtil.isPointInPart(part, vector2: Vector3)
	local shape = part:IsA("Part") and part.Shape or Enum.PartType.Block
	local pointToObjectSpace = part.CFrame:PointToObjectSpace(vector2)
	local size = part.Size

	if shape == Enum.PartType.Block then
		return math.abs(pointToObjectSpace.X) <= size.X / 2 and math.abs(pointToObjectSpace.Y) <= size.Y / 2 and math.abs(pointToObjectSpace.Z) <= size.Z / 2
	else
		if shape == Enum.PartType.Ball then
			return math.min(size.X / 2, (math.min(size.Y / 2, size.Z / 2))) >= pointToObjectSpace.Magnitude
		end

		if shape == Enum.PartType.Cylinder then
			return (isPointInCylinder(vector2, part))
		end

		error(("Lacking API; no check for Part of shape %q (%s)"):format(shape.Name, debug.traceback()))
	end
end

function BasePartUtil.getCorners(instance)
	local cFrame = instance.CFrame
	local size = instance.Size
	return RegionUtil.getCorners(cFrame, size)
end

return BasePartUtil