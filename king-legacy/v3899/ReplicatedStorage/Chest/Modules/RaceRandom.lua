local v = {
	Human = {
		Rate = 1000,
		Appearance = 0
	},
	Mink = {
		Rate = 1000,
		Appearance = 4
	},
	Fish = {
		Rate = 1000,
		Appearance = 5
	},
	Sky = {
		Rate = 1000,
		Appearance = 1
	}
}
local v2 = {}

for k, v3 in pairs(v) do
	for _ = 1, v3.Rate do
		v2[#v2 + 1] = k
	end
end

return {
	Roll = function(p)
		local v3 = v2[math.random(1, #v2)]

		if p and v3 == p then
			repeat
				v3 = v2[math.random(1, #v2)]
			until v3 ~= p
		end

		return v3, v[v3].Appearance > 0 and math.random(1, v[v3].Appearance)
	end
}