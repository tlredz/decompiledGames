return {
	DoesCodeLookValid = function(value: string)
		local v = string.sub(value, 1, 6) == "BH-AE-"
		local v2 = string.len(value) == 38
		return v and v2
	end
}