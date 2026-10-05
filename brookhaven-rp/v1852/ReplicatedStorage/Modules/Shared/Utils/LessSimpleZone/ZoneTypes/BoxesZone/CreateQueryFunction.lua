return function(p)
	return function(p2, p3)
		local result = {}
		local v = {}
		p.traverseBVH(p2._volume.bvh, function(data)
			local partBoundsInBox = workspace:GetPartBoundsInBox(data.cframe, data.size, p3)

			if #partBoundsInBox == 0 then
				return false
			end

			if data.right or data.left then
				return true
			end

			for _, v2 in partBoundsInBox do
				if v[v2] then
					continue
				end

				v[v2] = true
				result[#result + 1] = v2
			end

			return false
		end)
		return result
	end
end