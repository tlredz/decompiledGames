local v = {
	["\""] = "\"",
	["\\"] = "\\",
	["/"] = "/",
	n = "\n",
	t = "\t",
	r = "\r",
	b = "\8",
	f = "\f"
}

local function readString(value: string, p: number)
	local v2 = p + 1
	local v3 = string.find(value, "\"", v2, true)
	local v4 = string.find(value, "\\", v2, true)

	if not v4 or v3 < v4 then
		return string.sub(value, v2, v3 - 1), v3 + 1
	end

	local v5 = v2

	while true do
		local v6 = string.byte(value, v2)

		if v6 == 34 then
			break
		end

		if v6 == 92 then
			v2 += 2
		else
			v2 += 1
		end
	end

	local v6 = string.sub(value, v5, v2 - 1)
	return string.gsub(v6, "\\(.)", v), v2 + 1
end

local readValue

local function readDict(value: string, p: number)
	local result = {}
	local v2 = p + 1

	if string.byte(value, v2) == 93 then
		return result, v2 + 1
	end

	while string.byte(value, v2) == 91 do
		local v4, v5 = readString(value, v2 + 1)
		local v6 = v5 + 1
		local v7, v8 = readValue(value, v6)
		result[v4] = v7
		local v9 = v8 + 1

		if string.byte(value, v9) == 93 then
			v2 = v9 + 1
			break
		else
			v2 = v9 + 1
		end
	end

	return result, v2
end

local function readArray(value: string, count: number)
	local v2 = count + 1
	local result = {}
	local count2 = 0

	while string.byte(value, v2) ~= 93 do
		count2 += 1
		local v3
		v3, v2 = readValue(value, v2)
		result[count2] = v3

		if string.byte(value, v2) == 44 then
			v2 += 1
		end
	end

	return result, v2 + 1
end

readValue = function(value: string, count: number)
	local v2 = string.byte(value, count)

	if v2 == 34 then
		return readString(value, count)
	end

	if v2 == 91 then
		if string.byte(value, count + 1) == 91 and string.byte(value, count + 2) == 34 then
			return readDict(value, count)
		end

		return readArray(value, count)
	else
		if v2 == 116 then
			return true, count + 4
		elseif v2 == 102 then
			return false, count + 5
		elseif v2 == 110 then
			return nil, count + 4
		end

		local v3 = count

		while true do
			local v4 = string.byte(value, count)

			if v4 == 44 or v4 == 93 then
				break
			end

			count += 1
		end

		return tonumber((string.sub(value, v3, count - 1))), count
	end
end

return {
	decode = function(list: string)
		if #list <= 2 then
			return {}
		end

		return (readDict(list, 1))
	end
}