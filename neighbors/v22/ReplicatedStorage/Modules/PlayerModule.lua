local PlayerModule = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function PlayerModule:GetPlayerModule()
	local playerScripts = localPlayer:FindFirstChild("PlayerScripts")

	if playerScripts then
		return (playerScripts:FindFirstChild("PlayerModule"))
	end

	return nil
end

function PlayerModule:GetCameraModule()
	local playerModule = PlayerModule:GetPlayerModule()

	if playerModule then
		return (playerModule:FindFirstChild("CameraModule"))
	end

	return nil
end

function PlayerModule.SetCameraInputEnabled(_, flag: boolean)
	assert(typeof(flag) == "boolean", "isEnabled must be a boolean")
	local cameraModule = PlayerModule:GetCameraModule()

	if cameraModule then
		local CameraInput = require((cameraModule:FindFirstChild("CameraInput")))
		CameraInput.setInputEnabled(flag)
	end
end

return PlayerModule