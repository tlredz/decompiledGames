local HttpService = game:GetService("HttpService")
local LineUtils = {
	extractLineWithoutTime = function(list)
		local v = {}
		table.move(list, 2, #list, 1, v)
		return v
	end
}

function LineUtils.compareLine(p, p2)
	if p and p2 then
		local success, result = pcall(function()
			return HttpService:JSONEncode(LineUtils.extractLineWithoutTime(p))
		end)
		local success2, result2 = pcall(function()
			return HttpService:JSONEncode(LineUtils.extractLineWithoutTime(p2))
		end)
		return success and success2 and result == result2
	else
		return false
	end
end

function LineUtils.getNumRepeatsForLine(p)
	local metatable = getmetatable(p)

	if metatable and metatable.repeats then
		return metatable.repeats
	end

	return 0
end

function LineUtils.incrementNumRepeatsForLine(p)
	local metatable = getmetatable(p) or getmetatable((setmetatable(p, {
		repeats = 1
	})))
	metatable.repeats += 1
	return metatable
end

return LineUtils