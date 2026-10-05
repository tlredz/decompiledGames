require(script.Parent.Buffer.Reader)
require(script.Parent.Buffer.Writer)
local Vlq = {}

function Vlq.encode(p, p2: number)
	repeat
		local v = bit32.band(p2, 127)
		p2 = bit32.rshift(p2, 7)

		if p2 > 0 then
			v = bit32.bor(v, 128)
		end

		p.writeu8(v)
	until p2 == 0
end

function Vlq.decode(p)
	local total = 0
	local v = 0

	repeat
		local readu8 = p.readu8()
		v = bit32.bor(v, (bit32.lshift(bit32.band(readu8, 127), total)))
		total += 7
	until bit32.band(readu8, 128) == 0

	return v
end

return Vlq