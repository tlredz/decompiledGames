return {
	crc32 = function(p: string)
		local v = 4294967295

		for i = 1, #p do
			v = bit32.bxor(v, (p.byte(p, i)))

			for _ = 1, 8 do
				if bit32.band(v, 1) == 0 then
					v = bit32.rshift(v, 1)
				else
					v = bit32.bxor(bit32.rshift(v, 1), 3988292384)
				end
			end
		end

		return (bit32.bxor(v, 4294967295))
	end
}