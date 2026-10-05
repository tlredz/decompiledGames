local createVector = vector.create
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
return function(folder, cframe: CFrame?, flag: boolean?)
	if cframe then
		folder:PivotTo(cframe)
	end

	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute("Ground")) then
			continue
		end

		local raycastResult = workspace:Raycast(
			part.Position + createVector(0, 2, 0),
			createVector(-0, -10, -0),
			raycastParams
		)

		if raycastResult or not flag then
			if raycastResult then
				part.CFrame = part.CFrame - part.Position + raycastResult.Position
			else
				result[part] = raycastResult ~= nil
			end
		else
			part:Destroy()
		end
	end

	return folder, result
end