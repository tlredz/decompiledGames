local Utilities = {}

function Utilities.isStringNullOrEmpty(_, list)
	return not list or #list == 0
end

function Utilities.stringArrayContainsString(_, list, p)
	if #list == 0 then
		return false
	end

	for _, v in ipairs(list) do
		if v == p then
			return true
		end
	end

	return false
end

return Utilities