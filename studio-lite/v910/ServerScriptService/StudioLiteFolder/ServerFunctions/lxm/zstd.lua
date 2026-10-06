local HttpService = game:GetService("HttpService")
local b64 = require(script.Parent.b64)
return function(p: string)
	local jSONDecode = HttpService:JSONDecode((`\{"m": null, "t":"buffer", "zbase64":"{b64.encode(p)}"}`))
	return buffer.tostring(jSONDecode)
end