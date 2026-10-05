local Util = require(script.Parent:WaitForChild("Util"))
local ChatLocalization = nil
pcall(function()
	local Chat = game:GetService("Chat")
	ChatLocalization = require(Chat.ClientChatModules.ChatLocalization)
end)

if ChatLocalization == nil then
	ChatLocalization = {
		Get = function(self, p)
			return p
		end
	}
end

function ProcessMessage(value, object, p)
	if string.sub(value, 1, 3):lower() ~= "/c " then
		return false
	end

	local v = string.sub(value, 4)
	local channel = object:GetChannel(v)

	if channel then
		object:SwitchCurrentChannel(v)

		if not p.ShowChannelsBar and object:GetCurrentChannel() then
			Util:SendSystemMessageToSelf(
				string.gsub(
					ChatLocalization:Get(
						"GameChat_SwitchChannel_NowInChannel",
						string.format("You are now chatting in channel: '%s'", v)
					),
					"{RBX_NAME}",
					v
				),
				channel,
				{}
			)
		end
	else
		local currentChannel = object:GetCurrentChannel()

		if currentChannel then
			Util:SendSystemMessageToSelf(
				string.gsub(
					ChatLocalization:Get(
						"GameChat_SwitchChannel_NotInChannel",
						string.format("You are not in channel: '%s'", v)
					),
					"{RBX_NAME}",
					v
				),
				currentChannel,
				{
					ChatColor = Color3.fromRGB(245, 50, 50)
				}
			)
		end
	end

	return true
end

return {
	[Util.KEY_COMMAND_PROCESSOR_TYPE] = Util.COMPLETED_MESSAGE_PROCESSOR,
	[Util.KEY_PROCESSOR_FUNCTION] = ProcessMessage
}