local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local v = {
	Mobile = 1.5,
	Xbox = 1.2,
	Playstation = 1.2
}
return function()
	return v[Platform_Handler.Platform.Value] or 1
end