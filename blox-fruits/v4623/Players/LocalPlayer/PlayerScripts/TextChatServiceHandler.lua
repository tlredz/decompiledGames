local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

TextChatService.OnIncomingMessage = function(p)
	local textSource = p.TextSource
	local playerByUserId = textSource and Players:GetPlayerByUserId(textSource.UserId)

	if not playerByUserId then
		return nil
	end

	local chatTagText = playerByUserId:GetAttribute("ChatTagText")
	local chatTagTextColor = playerByUserId:GetAttribute("ChatTagTextColor")
	local formatted = `<font color="#{playerByUserId.TeamColor.Color:ToHex()}">{playerByUserId.DisplayName}</font>:`
	local v = not (chatTagText and chatTagTextColor) and "" or `<font color="#{chatTagTextColor:ToHex()}">[{chatTagText}]</font> `
	local newMessageProperties = TextChatService.ChatWindowConfiguration:DeriveNewMessageProperties()
	newMessageProperties.PrefixText = `{v}{formatted}`
	return newMessageProperties
end