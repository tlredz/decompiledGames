return {
	GetDirections = function(p: number)
		local vectors = {}

		for i = 0, p - 1 do
			local v = math.acos(1 - i / p * 2)
			local v2 = 10.166407384630519 * i
			local v3 = math.sin(v) * math.cos(v2)
			local v4 = math.sin(v) * math.sin(v2)
			local v5 = math.cos(v)
			table.insert(vectors, (Vector3.new(-v3, -v4, -v5)))
		end

		return vectors
	end
}