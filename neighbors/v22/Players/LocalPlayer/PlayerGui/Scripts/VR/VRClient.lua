local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local _ = workspace.CurrentCamera
character:WaitForChild("Humanoid")

if not UserInputService.VREnabled then
	return
end

local function GetIdlePos()
	local idlePosition = localPlayer:GetAttribute("IdlePosition")

	if localPlayer:GetAttribute("PartyId") and localPlayer:GetAttribute("PartyId") ~= localPlayer.UserId then
		idlePosition = Players:GetPlayerByUserId(localPlayer:GetAttribute("PartyId")):GetAttribute("IdlePosition")
	end

	return idlePosition
end

localPlayer:GetAttributeChangedSignal("State"):connect(function()
	if localPlayer:GetAttribute("State") ~= 3 and localPlayer:GetAttribute("IdlePosition") then
		character:PivotTo(CFrame.new((GetIdlePos())))
		print("corrected")
	end
end)