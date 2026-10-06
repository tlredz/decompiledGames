local module = require("@game/ReplicatedStorage/Omni")
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CanInvitePlayersToGame()
	if v ~= nil then
		return v
	end

	local success, result = pcall(function()
		return module.Services.SocialService:CanSendGameInviteAsync(module.Player)
	end)
	local v2 = success and result

	if success then
		v = v2
	end

	return v2
end

return {
	PromptToInvite = function()
		-- equivalent call inferred; original call site unknown
		if CanInvitePlayersToGame() then
			module.Services.SocialService:PromptGameInvite(module.Player)
		else
			module.Signal:FireSelf(
				"General",
				"Notification",
				"Text",
				"You cannot invite players to the game.",
				5,
				Color3.new(1, 1, 0)
			)
		end
	end
}