local function Unpack64(p: number)
	if p < 0 then
		local v = -1 - p
		return bit32.bnot(v // 4294967296), (bit32.bnot(v))
	else
		return bit32.bor(p // 4294967296, 0), (bit32.bor(p, 0))
	end
end

return Unpack64