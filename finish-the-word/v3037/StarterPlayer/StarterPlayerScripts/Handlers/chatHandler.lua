_G.import("global")
_G.import("event")
_G.import("itemModules")
local TextChatService = game:GetService("TextChatService")
local _ = game.Players.LocalPlayer

local function vipTag(p)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")

	if not p.TextSource then
		return textChatMessageProperties
	end

	if game.Players:FindFirstChild(p.TextSource.Name):GetAttribute("VIP") then
		local color = Color3.fromRGB(239, 191, 4)
		local v = string.format("%d, %d, %d", color.R * 255, color.G * 255, color.B * 255)
		textChatMessageProperties.PrefixText = string.format(
			"<font color=\"rgb(%s)\">[%s]</font> %s",
			v,
			"VIP",
			p.PrefixText
		)
	end

	return textChatMessageProperties
end

return {
	Priority = 1,
	Run = function()
		TextChatService.OnIncomingMessage = vipTag
	end
}