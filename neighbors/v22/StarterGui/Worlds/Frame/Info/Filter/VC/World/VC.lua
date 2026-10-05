local parent = script.Parent.Parent.Parent
local button = script.Parent.Button
local icon = script.Parent.Icon
local localPlayer = game.Players.LocalPlayer
local v = {
	Enabled = "rbxassetid://13537879459",
	Disabled = "rbxassetid://13538438723"
}

local function update()
	icon.Image = parent:GetAttribute("VC") and "rbxassetid://13537879459" or "rbxassetid://13538438723"
end

button.MouseButton1Click:connect(function()
	if not localPlayer:GetAttribute("VoiceChatEnabled") then
		return
	end

	parent:SetAttribute("VC", not parent:GetAttribute("VC"))
end)
parent:GetAttributeChangedSignal("VC"):connect(update)
icon.Image = parent:GetAttribute("VC") and v.Enabled or v.Disabled