local function getYXZAngles(data)
	local lookVector = data.lookVector
	local rightVector = data.rightVector
	local upVector = data.upVector
	return
		math.atan2(lookVector.x, lookVector.z) + 3.141592653589793,
		-math.atan2(-lookVector.y, (math.sqrt(lookVector.x ^ 2 + lookVector.z ^ 2))),
		(math.atan2(rightVector.y, upVector.y))
end

return getYXZAngles