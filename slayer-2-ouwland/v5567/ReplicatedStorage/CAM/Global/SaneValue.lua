local sane

sane = function(data)
	local typeName = typeof(data)

	if typeName == "number" then
		return math.abs(data) < 1000000
	end

	if typeName == "Vector3" then
		return math.abs(data.X) < 1000000 and math.abs(data.Y) < 1000000 and math.abs(data.Z) < 1000000
	elseif typeName == "CFrame" then
		return sane(data.Position) and sane(data.XVector) and sane(data.YVector) and sane(data.ZVector)
	else
		return true
	end
end

return sane