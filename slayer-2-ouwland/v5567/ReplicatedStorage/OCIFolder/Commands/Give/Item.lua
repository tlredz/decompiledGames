local ServerStorage = game:GetService("ServerStorage")
local Item = require(ServerStorage.SAM.Services.Adders.Item)
return function(p, p2, p3)
	if p then
		Item(p, p2, (tonumber(p3)))
	end
end