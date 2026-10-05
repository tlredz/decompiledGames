local HttpService = game:GetService("HttpService")
return {
	safeDecodeJson = function(json)
		if type(json) ~= "string" or json == "" then
			return ""
		end

		local success, result = pcall(function()
			return HttpService:JSONDecode(json)
		end)

		if success then
			return result
		end

		return json
	end
}