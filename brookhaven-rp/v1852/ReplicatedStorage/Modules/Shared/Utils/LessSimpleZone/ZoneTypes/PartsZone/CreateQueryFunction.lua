return function(p)
	return function(p2, p3)
		local result = {}
		local v = {}
		p.traverseBVH(p2._volume.bvh, function(data)
			if data.right or data.left then
				if #workspace:GetPartBoundsInBox(data.cframe, data.size, p3) > 0 then
					return true
				end
			else
				local partsInPart = workspace:GetPartsInPart(data.part, p3)

				for _, v2 in partsInPart do
					if v[v2] then
						continue
					end

					v[v2] = true
					result[#result + 1] = v2
				end
			end
		end)
		return result
	end
end