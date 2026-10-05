local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local textChannel

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
	textChannel = Instance.new("TextChannel")
	textChannel.Name = "ServerMessageChannel"
	textChannel.Parent = TextChatService:WaitForChild("TextChannels")
else
	textChannel = nil
end

return function(state)
	assert(typeof(state) == "table", "Argument 1 invalid, expected a table, got " .. tostring(state))

	if ComplianceController:IsChina() then
		return
	end

	if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
		state.Text = state.Text or string.rep("?", 16)
		state.Color = state.Color or Color3.fromRGB(0, 0, 0)
		state.Font = state.Font or Enum.Font.GothamMedium
		state.TextSize = state.TextSize or 14
		StarterGui:SetCore("ChatMakeSystemMessage", state)
	elseif TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		state.Text = state.Text or "NO CHAT_DATA.TEXT"
		state.Font = state.Font or Enum.Font.GothamBold
		state.TextSize = state.TextSize or 14
		state.Color = typeof(state.Color) == "Color3" and state.Color or typeof(state.Color) == "string" and Color3.fromHex(state.Color) or Color3.new()
		local v = "<font"

		if state.Color then
			v ..= " color=\"rgb(" .. math.floor(state.Color.R * 255) .. "," .. math.floor(state.Color.G * 255) .. "," .. math.floor(state.Color.B * 255) .. ")\""
		end

		if state.Font then
			local v2

			if typeof(state.Font) == "EnumItem" then
				v2 = state.Font.Name
			else
				v2 = tostring(state.Font)
			end

			v ..= " face=\"" .. v2 .. "\""
		end

		if state.TextSize then
			v ..= " size=\"" .. state.TextSize .. "\""
		end

		textChannel:DisplaySystemMessage((v .. ">") .. state.Text .. "</font>")
	end
end