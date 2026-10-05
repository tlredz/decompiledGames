local FieldValueUtils = {}

function FieldValueUtils.FormatNumber(p: number)
	return (tostring(math.round(p * 1000) / 1000))
end

function FieldValueUtils.SplitNumberText(value: string)
	local result = {}

	for k in string.gmatch(value:gsub("%s+", ""), "([^,]+)") do
		local v = tonumber(k)

		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

return FieldValueUtils