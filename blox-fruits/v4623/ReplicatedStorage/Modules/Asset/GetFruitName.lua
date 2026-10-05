return function(value: string, flag: boolean?)
	if value == "" then
		return "Fruitless"
	end

	local v = value:match("^Permanent %a+%-%a+") and not flag and "Permanent " or ""
	local v2 = string.match(value, "(((%u)%-?)([^-.]+))$")

	if v2 then
		return v .. v2
	end

	return value
end