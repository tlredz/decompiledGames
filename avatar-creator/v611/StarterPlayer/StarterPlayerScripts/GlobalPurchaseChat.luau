local TextChatService = game:GetService("TextChatService")
local v = {}

local function escape(text)
	return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
end

local v2 = {
	red = "#FF6666",
	green = "#65DE89",
	normal = "#FFD36B"
}
game.ReplicatedStorage:WaitForChild("GlobalPurchaseMessage").OnClientEvent:Connect(function(text, p)
	if type(text) == "string" and #text <= 700 then
		table.insert(v, {
			text = text,
			color = v2[p] or "#FFD36B"
		})
	end
end)
task.spawn(function()
	while true do
		local textChannels = TextChatService:FindFirstChild("TextChannels")
		local rBXGeneral = textChannels and (textChannels:FindFirstChild("RBXGeneral") or textChannels:FindFirstChild("RBXSystem"))

		if rBXGeneral and #v > 0 then
			local v4 = rBXGeneral
			local v5 = v[1]

			if pcall(function()
				v4:DisplaySystemMessage(
					"<font color=\"" .. v5.color .. "\">" .. escape(v5.text) .. "</font>",
					"GlobalPurchase"
				)
			end) then
				table.remove(v, 1)
			end
		end

		task.wait(0.2)
	end
end)