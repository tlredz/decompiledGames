return function(list, p: number, p2, p3, flag: boolean?)
	local clone = p2 and table.clone(p2) or {}
	local clone2 = p3 and table.clone(p3) or {}
	local v

	if typeof(list) == "table" then
		v = list[1] or list
	else
		v = list
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = clone2
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(v, p, overlapParams)

	for _, v2 in next, partBoundsInRadius, nil do
		clone2[#clone2 + 1] = v2
		local v3 = flag and v2 or v2.Parent

		if clone[v3] or v3:GetAttribute("DoNotTarget") or not (flag or v3:FindFirstChild("Humanoid")) then
			continue
		end

		clone2[#clone2 + 1] = v3
		clone[v3] = true
	end

	if typeof(list) ~= "table" then
		return clone, clone2
	end

	local v2 = list[2]

	while true do
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = clone2
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local spherecast = workspace:Spherecast(v, p, v2 - v, raycastParams)

		if not spherecast then
			break
		end

		local instance = spherecast.Instance
		clone2[#clone2 + 1] = instance
		local v3 = flag and instance or instance.Parent

		if clone[v3] or v3:GetAttribute("DoNotTarget") or not (flag or v3:FindFirstChild("Humanoid")) then
			continue
		end

		clone2[#clone2 + 1] = v3
		clone[v3] = true
	end

	return clone, clone2
end