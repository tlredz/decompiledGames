local TimeUtils = {}

function TimeUtils.A(_, p: number)
	local v = math.ceil(p)
	local v2 = math.floor(v / 86400)
	local v3 = v % 86400
	local v4 = math.floor(v3 / 3600)
	local v5 = v3 % 3600
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	local v8 = ""

	if v2 >= 1 then
		v8 ..= `{v2}d `
	end

	if v2 >= 1 or v4 >= 1 then
		v8 ..= `{v4}h `
	end

	if v4 >= 1 or v6 >= 1 then
		v8 ..= `{v6}m `
	end

	if v4 <= 0 and v6 <= 0 and v2 <= 0 then
		return v8 .. `{v7}s`
	end

	return v8
end

function TimeUtils.B(_, p: number)
	local v = math.ceil(p)
	local v2 = math.floor(v / 86400)
	local v3 = v % 86400
	local v4 = math.floor(v3 / 3600)
	local v5 = v3 % 3600
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	local v8 = ""

	if v2 >= 1 then
		v8 ..= string.format("%d:", v2)
	end

	if v2 >= 1 or v4 >= 1 then
		v8 ..= string.format("%02d:", v4)
	end

	if v4 >= 1 or v6 >= 1 or v2 >= 1 then
		v8 ..= string.format("%02d:", v6)
	end

	return v8 .. string.format("%02d", v7)
end

function TimeUtils.C(_, p: number)
	local v = math.max(0, (math.floor((math.ceil(p)))))
	return (string.format("%ds", v))
end

function TimeUtils.D(_, p: number)
	local v = math.max(0, (math.floor((math.ceil(p)))))
	local v2 = math.floor(v / 86400)
	local v3 = v % 86400
	local v4 = math.floor(v3 / 3600)
	local v5 = v3 % 3600
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	local v8 = ""

	if v2 > 0 then
		return ((v8 .. `{v2}d `) .. `{v4}h `) .. `{v6}m`
	end

	if v4 > 0 then
		return ((v8 .. `{v4}h `) .. `{v6}m `) .. `{v7}s`
	end

	if v6 > 0 then
		return (v8 .. `{v6}m `) .. `{v7}s`
	end

	return v8 .. `{v7}s`
end

function TimeUtils.E(_, p: number)
	local v = p < 0 and 0 or p // 1
	local v2 = v // 86400
	local v3 = v % 86400
	local v4 = v3 // 3600
	local v5 = v3 % 3600
	local v6 = v5 // 60
	local v7 = v5 % 60
	local v8 = ""
	local v9

	if v2 > 0 then
		v9 = v8 .. `{v2}d`

		if v4 > 0 then
			return v9 .. ` {v4}h`
		end
	elseif v4 > 0 then
		v9 = v8 .. `{v4}h`

		if v6 > 0 then
			return v9 .. ` {v6}m`
		end
	else
		if not (v6 > 0) then
			return v8 .. `{v7}s`
		end

		v9 = v8 .. `{v6}m`

		if v7 > 0 then
			return v9 .. ` {v7}s`
		end
	end

	return v9
end

return TimeUtils