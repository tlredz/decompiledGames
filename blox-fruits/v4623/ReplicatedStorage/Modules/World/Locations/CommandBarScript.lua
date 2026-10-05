local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false)
local locations = workspace._WorldOrigin.Locations
local v = {}

local function locationAdded(child)
	local mesh = child:FindFirstChild("Mesh")
	local v2 = child.Size.X * mesh.Scale.X * 0.5
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = locations:GetChildren()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	local name = child.Name
	v[name] = {}
	local cFrame = child.CFrame
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(cFrame.Position, v2, overlapParams) or {}

	for _, v3 in pairs(partBoundsInRadius) do
		if v3.Name == child.Name or table.find(v[name], v3.Name) then
			continue
		end

		table.insert(v[name], v3.Name)
	end

	if #v[name] == 0 then
		v[name] = nil
	end
end

for _, child in pairs(locations:GetChildren()) do
	child:SetAttribute("_CanQuery", child.CanQuery == true)
	child.CanQuery = true
end

for _, child in pairs(locations:GetChildren()) do
	locationAdded(child)
end

for _, child in pairs(locations:GetChildren()) do
	child.CanQuery = child:GetAttribute("_CanQuery") or false
	child:GetAttribute("_CanQuery", nil)
end

warn(v)