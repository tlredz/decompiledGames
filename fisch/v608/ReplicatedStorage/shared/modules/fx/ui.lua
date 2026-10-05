return {
	Comma = function(_, p: number)
		local v = math.ceil(p)

		repeat
			local v2
			v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
		until v2 == 0

		return v
	end
}