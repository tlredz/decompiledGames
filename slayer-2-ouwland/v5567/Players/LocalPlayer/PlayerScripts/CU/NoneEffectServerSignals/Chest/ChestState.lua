local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChestController = require(ReplicatedStorage.CAM.Client.Controllers.ChestController)
require(ReplicatedStorage.CAM.Global.Types.ChestTypes)
return function(p)
	ChestController.handleState(p)
end