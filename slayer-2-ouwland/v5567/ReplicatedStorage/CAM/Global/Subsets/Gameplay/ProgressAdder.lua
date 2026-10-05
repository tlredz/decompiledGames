return function(p, p2, max: number, p3: number, p4: number)
	local v = 0

	if max >= 0 then
		while max > 0 do
			local v2 = math.clamp(p2.Value - p.Value, 1, max)
			p.Value += v2

			if p.Value >= p2.Value then
				if p4 ~= nil and p2.Value == p4 then
					return v
				end

				p.Value = 0
				p2.Value += p3
				v += 1
			end

			max -= v2
		end
	else
		while max < 0 do
			if p.Value > 0 then
				local v2 = math.min(p.Value, -max)
				p.Value -= v2
				max += v2
			else
				if p2.Value <= p3 then
					break
				end

				p2.Value -= p3
				p.Value = p2.Value
				v -= 1
			end
		end
	end

	return v
end