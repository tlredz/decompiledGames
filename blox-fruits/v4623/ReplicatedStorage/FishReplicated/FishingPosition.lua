local boats = workspace:WaitForChild("Boats")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams:AddToFilter(boats)
local FishingPosition = {
	getBoatFromDescendant = function(parent)
		while parent and parent.Parent ~= boats do
			parent = parent.Parent
		end

		if parent and parent:IsA("Model") then
			return parent
		end

		return nil
	end,
	getBoatFloor = function(cframe: CFrame, value: number?)
		local vector = Vector3.new(0, -(value or 15), 0)
		local raycastResult = workspace:Raycast(cframe.Position, vector, raycastParams)

		if raycastResult then
			return raycastResult.Instance
		end

		for i = -1, 4 do
			for i2 = -1, 1 do
				if not (i ~= 0 or i2 ~= 0) then
					continue
				end

				local v = cframe.Position + cframe.LookVector * -i + cframe.RightVector * -i2
				local raycastResult2 = workspace:Raycast(v, vector, raycastParams)

				if raycastResult2 then
					return raycastResult2.Instance
				end
			end
		end

		return nil
	end
}

function FishingPosition.new(vector: Vector3, p, vector2: Vector3?)
	local boatFromDescendant = FishingPosition.getBoatFromDescendant(p)
	local localPosition

	if boatFromDescendant then
		localPosition = vector2 or boatFromDescendant:GetPivot():PointToObjectSpace(vector)
	end

	return {
		WorldPosition = vector,
		Boat = boatFromDescendant,
		LocalPosition = localPosition
	}
end

function FishingPosition.fromValue(p)
	if typeof(p) == "Vector3" then
		return FishingPosition.new(p)
	end

	return p
end

function FishingPosition.hasBoat(p)
	return p.Boat ~= nil and p.LocalPosition ~= nil
end

function FishingPosition.getBoat(p)
	local boat = p.Boat

	if boat and boat.Parent == boats and p.LocalPosition then
		return boat
	end

	return nil
end

function FishingPosition.getReferenceWorldPosition(p)
	local boat = FishingPosition.getBoat(p)

	if boat then
		return boat:GetPivot():PointToWorldSpace(p.LocalPosition)
	end

	return p.WorldPosition
end

function FishingPosition.getWorldPosition(p)
	local referenceWorldPosition = FishingPosition.getReferenceWorldPosition(p)
	return (Vector3.new(referenceWorldPosition.X, p.WorldPosition.Y, referenceWorldPosition.Z))
end

return FishingPosition