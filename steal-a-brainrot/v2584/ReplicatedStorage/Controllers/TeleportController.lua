local TeleportService = game:GetService("TeleportService")
return {
	TeleportInitFailed = TeleportService.TeleportInitFailed,
	GetLocalPlayerTeleportData = function(self)
		return TeleportService:GetLocalPlayerTeleportData()
	end
}