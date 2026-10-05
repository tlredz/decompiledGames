local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Treadmills = require(ReplicatedStorage:WaitForChild("Treadmill"):WaitForChild("Treadmills"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local v = {}

local function rebuildFilter()
	local filterDescendantsInstances = {}

	for k in pairs(v) do
		filterDescendantsInstances[#filterDescendantsInstances + 1] = k
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end

for _, tag in Treadmills do
	for _, v2 in CollectionService:GetTagged(tag) do
		v[v2] = true
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
		v[p] = true
		raycastParams:AddToFilter({ p })
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
		v[p] = nil
		rebuildFilter()
	end)
end

rebuildFilter()
return {
	getTreadmillFilter = function()
		return raycastParams
	end
}