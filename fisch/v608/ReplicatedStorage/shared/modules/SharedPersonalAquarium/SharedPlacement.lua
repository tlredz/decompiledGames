local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local v = nil

local function getQueryPart(cFrame: CFrame, size: Vector3)
	local v2 = v

	if not (v2 and v2.Parent) then
		v2 = Instance.new("Part")
		v2.Name = "__placementquery__"
		v2.Anchored = true
		v2.CanCollide = false
		v2.CanQuery = false
		v2.CanTouch = false
		v2.Transparency = 1
		v2.Parent = Workspace
		v = v2
	end

	v2.Size = size
	v2.CFrame = cFrame
	return v2
end

local SharedPlacement = {
	MAX_PLACED_FURNITURE = 50,
	getTagHolder = function(parent, tag: string)
		while parent and not parent:IsA("Workspace") do
			if CollectionService:HasTag(parent, tag) then
				return parent
			else
				parent = parent.Parent
			end
		end

		return nil
	end
}

function SharedPlacement.hasTagInAncestry(p, p2: string)
	return SharedPlacement.getTagHolder(p, p2) ~= nil
end

function SharedPlacement.getFurnitureBox(vector: Vector3, vector2: Vector3, p, p2: number)
	local v2 = p.CFrame - p.CFrame.Position
	return CFrame.new(vector + Vector3.new(0, vector2.Y / 2, 0)) * v2 * CFrame.Angles(0, p2, 0), vector2 * 0.9
end

function SharedPlacement.overlapsFurniture(p, cframe: CFrame, vector: Vector3, p2)
	if not p then
		return false
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { p }
	local partBoundsInBox = Workspace:GetPartBoundsInBox(cframe, vector, overlapParams)

	for _, v2 in ipairs(partBoundsInBox) do
		local model = v2:FindFirstAncestorOfClass("Model")

		while model do
			if model:GetAttribute("PlacedUid") then
				if model == p2 then
					break
				else
					return true
				end
			else
				model = model:FindFirstAncestorOfClass("Model")
			end
		end
	end

	return false
end

function SharedPlacement.getBlockingParts(p, cFrame: CFrame, size: Vector3)
	local result = {}

	if not p then
		return result
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { p }
	local partBoundsInBox = Workspace:GetPartBoundsInBox(cFrame, size, overlapParams)
	local v2 = false

	for _, v4 in ipairs(partBoundsInBox) do
		if not SharedPlacement.hasTagInAncestry(v4, "AquariumBlocker") then
			continue
		end

		v2 = true
		break
	end

	if not v2 then
		return result
	end

	local v4 = v

	if not (v4 and v4.Parent) then
		v4 = Instance.new("Part")
		v4.Name = "__placementquery__"
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanQuery = false
		v4.CanTouch = false
		v4.Transparency = 1
		v4.Parent = Workspace
		v = v4
	end

	v4.Size = size
	v4.CFrame = cFrame
	local partsInPart = Workspace:GetPartsInPart(v4, overlapParams)

	for _, v5 in ipairs(partsInPart) do
		if SharedPlacement.hasTagInAncestry(v5, "AquariumBlocker") then
			table.insert(result, v5)
		end
	end

	return result
end

function SharedPlacement.overlapsBlockers(p, cframe: CFrame, vector: Vector3)
	return #SharedPlacement.getBlockingParts(p, cframe, vector) > 0
end

return SharedPlacement