local localPlayer = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
require(game.ReplicatedStorage.Modules.Network)
local jSONEncode = HttpService:JSONEncode({
	senderUserID = localPlayer.UserId
})
local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
experienceInviteOptions.LaunchData = jSONEncode
experienceInviteOptions.PromptMessage = "Invite a friend for 10 credits"

local function canSendGameInvite(p)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p)
	end)
	return success and result
end

if canSendGameInvite then
	function _G.OpenInvitePrompt()
		local success, result = pcall(function()
			SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
		end)

		if not success then
			print("invite_prompt err:", result)
		end
	end
end

game.Players.PlayerAdded:connect(function(instance)
	local success, result = pcall(function()
		return instance:IsFriendsWith(localPlayer.UserId)
	end)

	if not success then
		warn("Friend Check failed:", result)
	elseif result then
		_G.DisplayText(
			"Your friend " .. (localPlayer:GetAttribute("StreamerMode") and "[HIDDEN]" or instance.DisplayName .. " (@" .. instance.Name .. ")") .. " has joined the server!",
			5
		)
		script.FriendJoined:Play()
		instance:SetAttribute("Friend", true)
	end
end)

for _, v in game.Players:GetPlayers() do
	if v == localPlayer then
		continue
	end

	local v2 = v
	local success, result = pcall(function()
		return v2:IsFriendsWith(localPlayer.UserId)
	end)

	if success and result then
		v:SetAttribute("Friend", true)
	end
end