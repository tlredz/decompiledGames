local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartBounds = require(ReplicatedStorage.Shared.Utils.PartBounds)

local function isBoxSubject(instance)
	return typeof(instance) == "Instance" and (instance:IsA("Model") or instance:IsA("Tool"))
end

local function opaqueParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(parts, part)
		end
	end

	return parts
end

return function(instance)
	local v

	if typeof(instance) == "Instance" then
		v = instance:IsA("Model") or instance:IsA("Tool")
	else
		v = false
	end

	assert(v, "ModelBounds needs a Model or a Tool")
	local customBoundingBox = instance:FindFirstChild("CustomBoundingBox", true)

	if customBoundingBox ~= nil and customBoundingBox:IsA("BasePart") then
		return customBoundingBox.CFrame, customBoundingBox.Size
	end

	local pivot = instance:GetPivot()
	local v2 = opaqueParts(instance)

	if #v2 == 0 then
		return pivot, createVector(0, 0, 0)
	end

	return PartBounds(v2, pivot.Rotation)
end