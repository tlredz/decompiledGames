local Workspace = game:GetService("Workspace")
return function(vector: Vector3, vector2: Vector3, p, collisionGroup: string?)
	if typeof(collisionGroup) == "Instance" and collisionGroup:IsA("BasePart") then
		collisionGroup = collisionGroup.CollisionGroup
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { Workspace.CurrentCamera }

	if p then
		raycastParams:AddToFilter(p)
	end

	raycastParams.IgnoreWater = true

	if collisionGroup then
		raycastParams.CollisionGroup = collisionGroup
	end

	while true do
		local raycastResult = Workspace:Raycast(vector, vector2, raycastParams)

		if not raycastResult then
			break
		end

		local instance = raycastResult.Instance
		local position = raycastResult.Position

		if instance and not instance.CanCollide and (not instance:IsA("Seat") or not instance:IsA("VehicleSeat") or instance.Disabled) then
			raycastParams:AddToFilter(instance)
		else
			return instance, position
		end
	end

	return nil, vector + vector2
end