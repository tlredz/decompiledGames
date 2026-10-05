local v = {
	"d",
	"h",
	"m",
	"s"
}
local v2 = {
	86400,
	3600,
	60,
	1
}
return table.freeze({
	formatTime = function(p: number, value: number)
		local count = 0
		local v3 = ""
		local v4 = value or 2

		for k, v6 in v2 do
			if v6 <= p then
				count += 1
				v3 ..= math.floor(p / v6) .. v[k]
				p %= v6
			end

			if count == v4 then
				break
			end
		end

		if v3 == "" then
			return "0s"
		end

		return v3
	end,
	clockFormat = function(p: number)
		local v3 = ""

		for k, v4 in v2 do
			if not (v4 <= p) then
				continue
			end

			if k == 1 then
				v3 = string.format("%02d", p / v4)
			else
				v3 = string.format("%s:%02d", v3, p / v4)
			end

			p %= v4
		end

		return v3
	end,
	commify = function(p: number)
		if p >= 0 and p < 1000 then
			return (tostring(p))
		end

		local v3 = tostring(p)
		local v4 = -1

		while v4 ~= 0 do
			v3, v4 = string.gsub(v3, "^(-?%d+)(%d%d%d)", "%1,%2")
		end

		return v3
	end
})