local StringUtils = {}

function StringUtils.ReadPath(_, child, value: string)
	if not value then
		return child
	end

	local v = string.split(value, ".")

	for i = 1, #v do
		if child == nil then
			return nil
		else
			child = child:FindFirstChild(v[i])
		end
	end

	return child
end

function StringUtils.hashStringEvenDistribution(value: string, p: number)
	local v = 0

	for i = 1, #value do
		local v2 = string.byte(value, i)
		v = (v * 31 + v2) % 4294967296
	end

	return v % p + 1
end

function StringUtils.ParseColor(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v = string.match(value, "^%s*(.-)%s*$")
	local v2 = string.match(v, "^#?(%x+)$")

	if v2 then
		return Color3.fromHex(v2):ToHex()
	end

	local v3, v4, v5 = string.match(v, "^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")

	if not v3 then
		return nil
	end

	local v6 = tonumber(v3)
	local v7 = tonumber(v4)
	local v8 = tonumber(v5)

	if v6 <= 255 and v7 <= 255 and v8 <= 255 then
		return Color3.fromRGB(v6, v7, v8):ToHex()
	end

	return nil
end

return StringUtils