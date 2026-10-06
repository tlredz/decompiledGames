local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.new(1, 1, 1)
return {
	Create = function(p)
		if typeof(p) ~= "table" then
			return
		end

		local clone = table.clone(p)

		if not (module.Data.Settings["Chat Notifications"] ~= false and typeof(clone.Message) == "string") then
			return
		end

		if typeof(clone.Color) ~= "Color3" then
			clone.Color = color
		end

		local textChannels = module.Services.TextChatService:WaitForChild("TextChannels", 10)
		local announcements = textChannels and textChannels:WaitForChild("Announcements", 10)

		if not announcements then
			return
		end

		announcements:DisplaySystemMessage((string.format(
			"<b><font color='#%*'>%*</font></b>",
			clone.Color:ToHex(),
			module.Shared.Notifications.Escape(clone.Message)
		)))
	end
}