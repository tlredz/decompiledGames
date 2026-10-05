local TeleportService = game:GetService("TeleportService")
game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local shutdownTeleportGui = script:WaitForChild("ShutdownTeleportGui")
local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

if localPlayerTeleportData and localPlayerTeleportData.isSoftShutdown then
	local clone = shutdownTeleportGui:Clone()
	clone.Parent = playerGui
	local shutdownGuiScript = clone:WaitForChild("ShutdownGuiScript")
	shutdownGuiScript.Enabled = true

	if localPlayer.Character then
		clone:Destroy()
	else
		localPlayer.CharacterAdded:Once(function()
			clone:Destroy()
		end)
	end
end

workspace:GetAttributeChangedSignal("SS2_ShuttingDown"):Wait()
pcall(function()
	while StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.All) do
		task.wait()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	end
end)
local shutdownGuiScript_2 = shutdownTeleportGui:WaitForChild("ShutdownGuiScript")
shutdownGuiScript_2.Enabled = true
local clone_2 = shutdownTeleportGui:Clone()
clone_2.Parent = playerGui
TeleportService:SetTeleportGui(shutdownTeleportGui)