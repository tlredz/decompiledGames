local module = require("@game/ReplicatedStorage/Omni")
return {
	PromptToJoin = function()
		local success, result = pcall(function()
			return module.Services.GroupService:PromptJoinAsync(module.Settings.GroupId)
		end)

		if success and result == Enum.GroupMembershipStatus.Joined then
			module.Signal:Fire("General", "Group", "Set")
		end
	end
}