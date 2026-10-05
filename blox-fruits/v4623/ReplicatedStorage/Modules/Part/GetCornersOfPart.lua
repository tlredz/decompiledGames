return function(instance)
	local v = instance.Size * 0.5
	local cframes = {}

	for _, v2 in {
		Vector3.new(-v.X, -v.Y, -v.Z),
		Vector3.new(v.X, -v.Y, -v.Z),
		Vector3.new(-v.X, -v.Y, v.Z),
		Vector3.new(v.X, -v.Y, v.Z),
		Vector3.new(-v.X, v.Y, -v.Z),
		Vector3.new(v.X, v.Y, -v.Z),
		Vector3.new(-v.X, v.Y, v.Z),
		(Vector3.new(v.X, v.Y, v.Z))
	} do
		local pointToWorldSpace = instance.CFrame:PointToWorldSpace(v2)
		table.insert(cframes, (CFrame.new(pointToWorldSpace)))
	end

	return cframes
end