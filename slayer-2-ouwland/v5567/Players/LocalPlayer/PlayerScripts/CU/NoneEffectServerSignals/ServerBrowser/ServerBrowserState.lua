local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerBrowserController = require(ReplicatedStorage.CAM.Client.Controllers.ServerBrowserController)
return function(p)
	ServerBrowserController.applyState(p)
end