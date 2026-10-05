local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InstanceUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("InstanceUtil"))
local BasePartUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Utils"):WaitForChild("BasePartUtil"))

local function getBoundingBox(instance)
	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	end

	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	error(("[ModelUtil getBoundingBox] Unsupported PVInstance type %s"):format(instance.ClassName))
end

local ModelUtil = {}

function ModelUtil.alignModelsOnFace(instance, instance2, p)
	if p ~= Enum.NormalId.Bottom then
		error(("[ModelUtil.alignModelsOnFace] Unsupported face %s"):format(p.Name))
		return
	end

	local boundingBox, size

	if instance:IsA("Model") then
		boundingBox, size = instance:GetBoundingBox()
	elseif instance:IsA("BasePart") then
		boundingBox = instance.CFrame
		size = instance.Size
	else
		error(("[ModelUtil getBoundingBox] Unsupported PVInstance type %s"):format(instance.ClassName))
	end

	local boundingBox2, size2

	if instance2:IsA("Model") then
		boundingBox2, size2 = instance2:GetBoundingBox()
	elseif instance2:IsA("BasePart") then
		boundingBox2 = instance2.CFrame
		size2 = instance2.Size
	else
		error(("[ModelUtil getBoundingBox] Unsupported PVInstance type %s"):format(instance2.ClassName))
	end

	local v = boundingBox - boundingBox.UpVector * (size.Y / 2)
	local objectSpace = (boundingBox2 - boundingBox2.UpVector * (size2.Y / 2)):ToObjectSpace(v)
	instance2:PivotTo(instance2:GetPivot() * objectSpace)
end

function ModelUtil.weld(folder)
	local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		error(("Model %s has no BaseParts to weld!"):format(folder:GetFullName()))
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primaryPart then
			BasePartUtil.weld(primaryPart, part)
		end
	end
end

function ModelUtil.unanchor(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end
end

function ModelUtil.anchor(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

function ModelUtil.canCollide(folder, canCollide: boolean)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = canCollide
		end
	end
end

function ModelUtil.hide(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		InstanceUtil.hide(descendant, p)
	end
end

function ModelUtil.show(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		InstanceUtil.show(descendant, p)
	end
end

function ModelUtil.snapModelToSurfaceDownward(instance, filterDescendantsInstances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = false
	local raycastResult = workspace:Raycast(instance:GetPivot().Position, createVector(0, -1000, 0), raycastParams)

	if raycastResult then
		local _, v = instance:GetBoundingBox()
		instance:PivotTo(CFrame.new(raycastResult.Position) * CFrame.new((Vector3.new(0, v.Y / 2, 0))) * instance:GetPivot().Rotation)
	end
end

return ModelUtil