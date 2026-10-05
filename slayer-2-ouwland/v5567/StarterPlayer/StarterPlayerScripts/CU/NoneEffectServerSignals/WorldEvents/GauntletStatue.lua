local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GauntletStatuesController = require(ReplicatedStorage.CAM.Client.Controllers.GauntletStatuesController)
return function(p)
	GauntletStatuesController.handle(p)
end