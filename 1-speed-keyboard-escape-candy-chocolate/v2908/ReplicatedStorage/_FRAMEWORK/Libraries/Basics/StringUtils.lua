local StringUtils = {}

function StringUtils.trim(value: string)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

function StringUtils.startsWith(value: string, list: string)
	return string.sub(value, 1, #list) == list
end

function StringUtils.endsWith(value: string, list: string)
	return list == "" or string.sub(value, -#list) == list
end

return StringUtils