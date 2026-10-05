local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return function(p)
	game.ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", p)
end