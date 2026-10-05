local TeleportService = game:GetService("TeleportService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
TeleportService:SetTeleportGui(parent)

local function updateTeleportingUI()
	if localPlayer:GetAttribute("ShowTeleportingUI") then
		task.spawn(pcall, function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			StarterGui:SetCore("TopbarEnabled", false)
		end)
		parent.Parent = playerGui
	else
		task.spawn(pcall, function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			StarterGui:SetCore("TopbarEnabled", true)
		end)
		parent.Parent = ReplicatedFirst
	end
end

localPlayer:GetAttributeChangedSignal("ShowTeleportingUI"):Connect(updateTeleportingUI)
updateTeleportingUI()