local HttpService = game:GetService("HttpService")
return function(_, p)
	return HttpService:GetAsync(p)
end