local HttpService = game:GetService("HttpService")
return function(registry)
	registry:RegisterType("json", {
		Validate = function(p)
			return pcall(HttpService.JSONDecode, HttpService, p)
		end,
		Parse = function(json)
			return HttpService:JSONDecode(json)
		end
	})
end