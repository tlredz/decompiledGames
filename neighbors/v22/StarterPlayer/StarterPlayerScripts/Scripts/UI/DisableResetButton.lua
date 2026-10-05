local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
Players.LocalPlayer:GetAttributeChangedSignal("InterrogatedState"):Connect(function()
	if Players.LocalPlayer:GetAttribute("InterrogatedState") then
		StarterGui:SetCore("ResetButtonCallback", false)
	else
		StarterGui:SetCore("ResetButtonCallback", true)
	end
end)