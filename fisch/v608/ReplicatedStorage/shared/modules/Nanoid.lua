local v = string.split("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz-", "")
local count = #v
return function(value: number?)
	local v2 = ""

	for _ = 1, value or 21 do
		v2 ..= v[math.random(count)]
	end

	return v2
end