local TimeUtils = {}

function TimeUtils.A(_, p: number)
	local v = math.floor(p / 86400)
	local v2 = p % 86400
	local v3 = math.floor(v2 / 3600)
	local v4 = v2 % 3600
	local v5 = math.floor(v4 / 60)
	local v6 = v4 % 60
	local v7 = ""

	if v >= 1 then
		v7 ..= `{v}d `
	end

	if v >= 1 or v3 >= 1 then
		v7 ..= `{v3}h `
	end

	if v3 >= 1 or v5 >= 1 then
		v7 ..= `{v5}m `
	end

	if v3 <= 0 and v5 <= 0 and v <= 0 then
		return v7 .. `{v6}s`
	end

	return v7
end

function TimeUtils.B(_, p: number)
	local v = math.floor(p / 60)
	local v2 = p % 60
	return (`{string.format("%01d", v)}m {string.format("%02d", v2)}s`)
end

return TimeUtils