local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.packages.Net)
local playerGui = Players.LocalPlayer.PlayerGui
local _ = playerGui.hud.safezone
local remoteEvent = Net:RemoteEvent("Boats/Close", -1)
script.Parent.Activated:Connect(function()
	script.Parent.Parent.Visible = false
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.client.legacyControllers.InputController):Get("Gamepad").ButtonDown:Connect(function(p, flag: boolean?)
	if not (flag ~= true and p == Enum.KeyCode.ButtonB) then
		return
	end

	if script.Parent.Parent.Visible == true then
		script.Parent.Parent.Visible = false
	end
end)
script.Parent.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not (script.Parent.Parent.Visible or script.Parent.Parent:GetAttribute("DontClose")) then
		playerGui.backpack.Enabled = true
		remoteEvent:FireServer()
	end
end)