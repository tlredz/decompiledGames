local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {}

local function cframeInFrontOfRootClampedToArea(rootCFrame: CFrame, instance)
	local lookVector = rootCFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
	assert(vector.Magnitude > 0, "Asset front placement requires a horizontal root facing direction")
	local unit = vector.Unit
	local size = instance.Size
	local v2 = math.max(size.X * 0.5 - 1.75, 0)
	local v3 = math.max(size.Z * 0.5 - 1.75, 0)
	local v4 = rootCFrame.Position + unit * 6
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(v4)
	local vector2 = Vector3.new(
		math.clamp(pointToObjectSpace.X, -v2, v2),
		0,
		(math.clamp(pointToObjectSpace.Z, -v3, v3))
	)
	local position = (instance.CFrame * CFrame.new(vector2)).Position
	return CFrame.lookAt(position, position + unit)
end

local AssetPlacementHints = {}

function AssetPlacementHints.SetFrontPlacement(p: string, cframe: CFrame)
	t.strict(t.string)(p)
	t.strict(t.CFrame)(cframe)
	v[p] = {
		RootCFrame = cframe,
		ExpiresAt = os.clock() + 10
	}
end

function AssetPlacementHints.ConsumeFrontPlacement(p: string, p2)
	t.strict(t.string)(p)
	t.strict(t.instanceIsA("BasePart"))(p2)
	local v2 = v[p]
	v[p] = nil

	if v2 == nil or v2.ExpiresAt < os.clock() then
		return nil
	end

	return cframeInFrontOfRootClampedToArea(v2.RootCFrame, p2)
end

function AssetPlacementHints.ClearFrontPlacement(p: string)
	t.strict(t.string)(p)
	v[p] = nil
end

return AssetPlacementHints