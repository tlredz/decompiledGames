require(script.Parent.QuickZone)

local function samplePointInCylinderZone(cFrame: CFrame, size: Vector3, object)
	local v = size * 0.5
	local X = v.X
	local v2 = v.Y * 0.85
	local rightVector = cFrame.RightVector
	local v3 = cFrame.Position - rightVector * X
	local v4 = object:NextNumber() * (X * 2)
	local v5 = object:NextNumber() * 3.141592653589793 * 2
	local v6 = math.sqrt((object:NextNumber())) * v2
	return v3 + rightVector * v4 + (cFrame.UpVector * (math.cos(v5) * v6) + cFrame.LookVector * (math.sin(v5) * v6))
end

local QuickZoneSampling = {
	samplePointInZone = function(object, object2)
		local cFrame = object:getCFrame()
		local size = object:getSize()
		local v = size * 0.5
		local shape = object:getShape()

		if shape == "Cylinder" then
			return (samplePointInCylinderZone(cFrame, size, object2))
		end

		if shape == "Ball" then
			local v2 = v.X * 0.85
			local vector = Vector3.new(
				object2:NextNumber() - 0.5,
				object2:NextNumber() - 0.5,
				object2:NextNumber() - 0.5
			)

			if vector.Magnitude > 0 then
				vector = vector.Unit * (object2:NextNumber() * v2)
			end

			return (cFrame * CFrame.new(vector)).Position
		else
			local v2 = (object2:NextNumber() - 0.5) * size.X * 0.85
			local v3 = (object2:NextNumber() - 0.5) * size.Y * 0.85
			local v4 = (object2:NextNumber() - 0.5) * size.Z * 0.85
			return (cFrame * CFrame.new(v2, v3, v4)).Position
		end
	end
}

function QuickZoneSampling.sampleRandomPoint(list, callback, object)
	if #list == 0 then
		return nil
	end

	for _ = 1, 32 do
		local v = list[object:NextInteger(1, #list)]
		local pointInZone = QuickZoneSampling.samplePointInZone(v, object)

		if callback(pointInZone) then
			return pointInZone
		end
	end

	for _, v in list do
		local position = v:getPosition()

		if callback(position) then
			return position
		end
	end

	return QuickZoneSampling.samplePointInZone(list[1], object)
end

function QuickZoneSampling.sampleRandomPointFromCollection(object, p)
	local zones = object:getZones()
	return QuickZoneSampling.sampleRandomPoint(zones, function(vector: Vector3)
		return object:isPointInside(vector)
	end, p)
end

return QuickZoneSampling