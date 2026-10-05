local ServerStorage = game:GetService("ServerStorage")
local TitleService = require(ServerStorage.SAM.Services.TitleService)
return function(p, p2: string, p3)
	TitleService.AddProgress(p, p2, tonumber(p3) or 1)
end