local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankedController = require(ReplicatedStorage.CAM.Client.Controllers.RankedController)
return function(p)
	RankedController.handleBoard(p)
end