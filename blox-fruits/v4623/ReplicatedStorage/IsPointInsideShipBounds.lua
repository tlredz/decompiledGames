local RotatedRegion3 = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("RotatedRegion3"))
local Trove = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Util"):WaitForChild("Trove"))
local v = {}

local function makeTracker()
	local part = Instance.new("Part")
	part.Transparency = 0.8
	part.CanQuery = false
	part.CanCollide = false
	part.CanTouch = false
	part.Parent = workspace._WorldOrigin
	return part
end

local function isInsideShipBounds(p, instance)
	if not v[instance] then
		local size = instance:GetAttribute("Size")
		local offset = instance:GetAttribute("Offset")

		if not (size and offset) then
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGamePrint(instance:GetFullName(), " doesn't have boundary attributes")
			local modelSize = instance:GetModelSize()
			local v2 = 100 + modelSize.Y * 0.5
			size = modelSize + Vector3.new(modelSize.X * 0.3, v2, modelSize.Z * 0.3)
			offset = CFrame.new(0, v2 / 2, 0)
			instance:SetAttribute("Size", size)
			instance:SetAttribute("Offset", offset)
		end

		local v2 = {
			trove = Trove.new(),
			size = size,
			offset = offset
		}
		v[instance] = v2
		v2.trove:Add(instance.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				v2.trove:Destroy()
				v[instance] = nil
			end
		end))
	end

	local v2 = v[instance]
	local boundingBox = instance:GetBoundingBox()
	return (RotatedRegion3.new(boundingBox * v2.offset, v2.size):CastPoint(p))
end

return isInsideShipBounds