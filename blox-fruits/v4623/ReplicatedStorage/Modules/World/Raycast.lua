local Raycast = require(game.ReplicatedStorage.Modules.Debug.Raycast)
return function(data)
	local raycastParams = data.raycastParams or RaycastParams.new()
	local position = data.origin.Position
	local raycastResult = workspace:Raycast(position, data.direction, raycastParams)
	local position2 = raycastResult and raycastResult.Position or position + data.direction

	if raycastResult and data.filter and data.filter(raycastResult) then
		raycastResult = nil
	end

	if data.visualize then
		task.spawn(Raycast, {
			visualize = data.visualize,
			origin = position,
			goal = position2
		})
	end

	return raycastResult
end