local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SimonSaysController = require(ReplicatedStorage.CAM.Client.Controllers.SimonSaysController)
return function(p)
	SimonSaysController.handle(p)
end