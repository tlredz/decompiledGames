local PositionUtil = {}

function PositionUtil.Vector3ToString(vector: Vector3)
	return (`{vector.X}/{vector.Y}/{vector.Z}`)
end

function PositionUtil.CFrameToString(cframe: CFrame)
	local position = cframe.Position
	local orientation, v, v2 = cframe:ToOrientation()
	return (`{position.X}/{position.Y}/{position.Z}/{orientation}/{v}/{v2}`)
end

function PositionUtil.StringToVector3(value: string)
	local v = string.split(value, "/")

	if #v < 3 then
		return nil
	end

	local v2 = tonumber(v[1])
	local v3 = tonumber(v[2])
	local v4 = tonumber(v[3])

	if v2 == nil or v3 == nil or v4 == nil then
		return nil
	end

	return (Vector3.new(v2, v3, v4))
end

function PositionUtil.StringToCFrame(value: string)
	local v = string.split(value, "/")

	if #v < 6 then
		return nil
	end

	local v2 = tonumber(v[1])
	local v3 = tonumber(v[2])
	local v4 = tonumber(v[3])
	local v5 = tonumber(v[4])
	local v6 = tonumber(v[5])
	local v7 = tonumber(v[6])

	if v2 == nil or v3 == nil or v4 == nil or v5 == nil or v6 == nil or v7 == nil then
		return nil
	end

	return CFrame.fromOrientation(v5, v6, v7) + Vector3.new(v2, v3, v4)
end

return PositionUtil