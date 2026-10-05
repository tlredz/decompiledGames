local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, result = pcall(function()
	local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
	CameraAuthority.startWatchdog()
end)

if not success then
	warn("[CameraAuthorityBoot] watchdog not armed:", result)
end