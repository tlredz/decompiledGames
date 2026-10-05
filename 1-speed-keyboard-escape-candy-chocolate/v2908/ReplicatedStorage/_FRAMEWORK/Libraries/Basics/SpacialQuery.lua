local SpacialQuery = {
	isPointInVolume = function(vector: Vector3, cframe: CFrame, vector2: Vector3, flag: boolean?)
		local pointToObjectSpace = cframe:PointToObjectSpace(vector)
		local v

		if pointToObjectSpace.X >= -vector2.X / 2 then
			v = pointToObjectSpace.X <= vector2.X / 2
		else
			v = false
		end

		local v2

		if flag == true then
			v2 = true
		elseif pointToObjectSpace.Y >= -vector2.Y / 2 then
			v2 = pointToObjectSpace.Y <= vector2.Y / 2
		else
			v2 = false
		end

		return v and v2 and pointToObjectSpace.Z >= -vector2.Z / 2 and pointToObjectSpace.Z <= vector2.Z / 2
	end
}

function SpacialQuery.isPositionInPart(vector: Vector3, instance, flag: boolean?)
	return SpacialQuery.isPointInVolume(vector, instance.CFrame, instance.Size, flag)
end

return SpacialQuery