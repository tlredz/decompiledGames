local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TrimmedNumberString = require(ReplicatedStorage.UserGenerated.Strings.TrimmedNumberString)

local function Commas(value)
	if type(value) ~= "string" then
		value = TrimmedNumberString(value)
	end

	local v, v2, v3 = string.match(value, "^(.-)([0-9,]+)(.*)$")

	if not v2 then
		return value
	end

	local v4 = {}

	if v then
		table.insert(v4, v)
	end

	local v5 = string.gsub(v2, ",", "")
	local total = 1
	local v6 = #v5 % 3

	if v6 > 0 then
		table.insert(v4, (string.sub(v5, total, total + v6 - 1)))
		total += v6
	end

	while total <= #v5 do
		if total > 1 then
			table.insert(v4, ",")
		end

		table.insert(v4, (string.sub(v5, total, total + 2)))
		total += 3
	end

	if v3 then
		table.insert(v4, v3)
	end

	return table.concat(v4)
end

return Commas