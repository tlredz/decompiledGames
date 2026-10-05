local Color = require(script.Parent.Parent:WaitForChild("Color"))

function Color:set(value: string, value2, flag: boolean?)
	local v = string.split(value, ".")
	local v2 = v[1]
	local v3 = v[2]
	local v4 = self[v2](self)

	if not v3 or v3 == "" then
		return v4
	end

	local v5 = string.find(v2, v3, nil, true)
	local v6 = v5 and v5 - (string.sub(v2, 1, 2) == "ok" and 2 or 0)

	if not v6 then
		error((`unknown channel {v3} in mode {v2}`))
		return
	end

	if type(value2) == "string" then
		local v7 = string.sub(value2, 1, 1)

		if v7 == "+" then
			v4[v6] += tonumber(value2)
		elseif v7 == "-" then
			v4[v6] += tonumber(value2)
		elseif v7 == "*" then
			v4[v6] *= tonumber((string.sub(value2, 2)))
		elseif v7 == "/" then
			v4[v6] /= tonumber((string.sub(value2, 2)))
		else
			v4[v6] = tonumber(value2)
		end
	elseif type(value2) == "number" then
		v4[v6] = value2
	else
		error("unsupported value for Color.set")
	end

	local v7 = Color.new(v4, v2)

	if not flag then
		return v7
	end

	self._rgb = v7._rgb
	return self
end

return nil