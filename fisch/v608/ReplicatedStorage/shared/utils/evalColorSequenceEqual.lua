local function evalColorSequence(list, p: number)
	local count = #list

	if count == 0 then
		error("Sequence must contain at least one color.")
	elseif count == 1 then
		return list[1]
	end

	local v = p % 1
	local v2 = 1 / count

	for i = 1, count do
		local color = list[i]
		local color2 = list[i % count + 1]
		local v3 = (i - 1) * v2

		if v3 <= v and v < i * v2 then
			return color:Lerp(color2, (v - v3) / v2)
		end
	end

	return list[count]
end

return evalColorSequence