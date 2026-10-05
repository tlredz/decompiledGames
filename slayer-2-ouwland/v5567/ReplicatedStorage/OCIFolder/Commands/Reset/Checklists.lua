local ServerStorage = game:GetService("ServerStorage")
local Checklists = require(ServerStorage.SAM.Services.Checklists)
return function(items)
	for _, item in items do
		Checklists.Reset(item)
	end
end