local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
script:GetActor():BindToMessageParallel("Ray", function(instance)
	if not instance.Parent then
		return
	end

	local RT = instance:GetAttribute("RT")
	local cFrame = instance.CFrame
	local upVector = cFrame.UpVector
	local raycastResult = workspace:Raycast(cFrame.Position + upVector, -upVector * 3, raycastParams)
	local v

	if raycastResult then
		local v2 = CFrame.lookAlong(raycastResult.Position + raycastResult.Normal * 0.1, raycastResult.Normal) * cframe * CFrame.Angles(
			0,
			RT,
			0
		)
		v = { raycastResult.Instance.CFrame:ToObjectSpace(v2), raycastResult.Instance }
	else
		v = true
	end

	if v == true then
		task.synchronize()
		instance:Destroy()
	elseif v ~= nil then
		task.synchronize()
		instance:SetAttribute("CF", v[1])
		instance.Ref.Value = v[2]
		instance.CFrame = v[2].CFrame:ToWorldSpace(v[1])
		instance.Locked = false
	end
end)