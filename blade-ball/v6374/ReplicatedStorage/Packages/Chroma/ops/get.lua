local Color = require(script.Parent.Parent:WaitForChild("Color"))

function Color.get(p, value: string)
	local v = string.split(value, ".")
	local v2 = v[1]
	local v3 = v[2]
	local v4 = p[v2](p)

	if not v3 or v3 == "" then
		return v4
	end

	local v5 = string.find(v2, v3, nil, true)
	local v6 = v5 and v5 - (string.sub(v2, 1, 2) == "ok" and 2 or 0)

	if v6 then
		return v4[v6]
	end

	error((`unknown channel {v3} in mode {v2}`))
end

return nil