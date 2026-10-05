local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaffSpectateController = require(ReplicatedStorage.CAM.Client.Controllers.StaffSpectateController)
return function(p)
	StaffSpectateController.handleWatch(p)
end