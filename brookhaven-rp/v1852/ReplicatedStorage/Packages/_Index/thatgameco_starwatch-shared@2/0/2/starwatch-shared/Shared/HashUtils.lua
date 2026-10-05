local HttpService = game:GetService("HttpService")
local SHA256 = require(script.Parent:WaitForChild("SHA256"))
local SafeCall = require(script.Parent:WaitForChild("SafeCall"))
return {
	hashUserId = function(str)
		if typeof(str) == "number" then
			str = tostring(str)
		end

		local GUID = HttpService:GenerateGUID(false)
		local v = SafeCall(function()
			return SHA256(buffer.fromstring(str))
		end)()

		if typeof(v) ~= "string" or #v < 32 then
			return GUID
		end

		local v2 = v:sub(1, 12) .. "4" .. v:sub(14, 16)
		local v3 = tonumber(v:sub(17, 18), 16)

		if not v3 then
			return GUID
		end

		local v4 = bit32.bor(bit32.band(v3, 63), 128)
		local v5 = v2 .. string.format("%02x", v4) .. v:sub(19, 32)
		return string.format(
			"%s-%s-%s-%s-%s",
			v5:sub(1, 8),
			v5:sub(9, 12),
			v5:sub(13, 16),
			v5:sub(17, 20),
			v5:sub(21, 32)
		)
	end
}