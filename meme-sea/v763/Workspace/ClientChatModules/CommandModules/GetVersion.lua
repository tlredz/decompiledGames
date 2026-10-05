local Util = require(script.Parent:WaitForChild("Util"))
local ChatConstants = require(script.Parent.Parent:WaitForChild("ChatConstants"))

function ProcessMessage(value, object, _)
	if string.sub(value, 1, 8):lower() ~= "/version" and string.sub(value, 1, 9):lower() ~= "/version " then
		return false
	end

	Util:SendSystemMessageToSelf(
		string.format(
			"This game is running chat version [%d.%d].",
			ChatConstants.MajorVersion,
			ChatConstants.MinorVersion
		),
		object:GetCurrentChannel(),
		{}
	)
	return true
end

return {
	[Util.KEY_COMMAND_PROCESSOR_TYPE] = Util.COMPLETED_MESSAGE_PROCESSOR,
	[Util.KEY_PROCESSOR_FUNCTION] = ProcessMessage
}