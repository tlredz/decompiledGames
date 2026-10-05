local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = require(ReplicatedStorage.Packages.Input)
local PlacedEggRenderer = require(script.Parent.PlacedEggRenderer)
local t = require(ReplicatedStorage.Packages.t)
local mouse = Input.Mouse.new()

local function placementRaycastParams(p, p2: number)
	local filterDescendantsInstances = { p }
	PlacedEggRenderer.AppendRaycastTargets(filterDescendantsInstances, p2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = true
	return raycastParams
end

return {
	Raycast = function(self, p2: number)
		t.strict(t.instanceIsA("BasePart"))(self)
		t.strict(t.number)(p2)
		return mouse:Raycast(placementRaycastParams(self, p2), 500)
	end
}