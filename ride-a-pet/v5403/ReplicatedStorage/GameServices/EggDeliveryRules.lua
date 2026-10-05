local EggDeliveryRules = {}

function EggDeliveryRules.Contains(part, p)
	if not (part and part:IsA("BasePart")) then
		return false
	end

	local pointToObjectSpace = part.CFrame:PointToObjectSpace(p)
	return math.abs(pointToObjectSpace.X) <= part.Size.X / 2 + 2 and math.abs(pointToObjectSpace.Z) <= part.Size.Z / 2 + 2
end

function EggDeliveryRules.GraceForPing(value)
	return math.clamp(
		((type(value) ~= "number" or value ~= value or math.abs(value) == 1e999) and 0 or value) * 2,
		0,
		1
	) + 0.5
end

function EggDeliveryRules.ClaimDeadline(value, p, p2, p3, p4)
	if type(value) ~= "number" or value ~= value or math.abs(value) == 1e999 then
		return nil
	end

	if not (p2 and p3) or p + 1 < value then
		return nil
	end

	local v = math.min(value, p)

	if v < p2 or p4 < p - v or (p3 + 0.5 < v or p3 + p4 < p) then
		return nil
	end

	return (math.min(p + 0.5, p3 + p4 + 0.5))
end

return EggDeliveryRules