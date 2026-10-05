local HttpService = game:GetService("HttpService")
local t = require(script.t)

local function validateText(value: string, charpattern)
	local v = #value
	local v2 = 1

	while v2 <= v do
		if string.find(value, charpattern, v2) ~= v2 then
			return false
		end

		v2 += 1
	end

	return true
end

function t.utf8(p)
	return t.string(p) and validateText(p, utf8.charpattern)
end

function t.utf8withLen(p)
	return t.string(p) and utf8.len(p) ~= nil
end

function t.json(json)
	return t.utf8(json) and pcall(function()
		return HttpService:JSONDecode(json)
	end)
end

function t.utf8withLenJson(json)
	return t.utf8withLen(json) and pcall(function()
		return HttpService:JSONDecode(json)
	end)
end

return t