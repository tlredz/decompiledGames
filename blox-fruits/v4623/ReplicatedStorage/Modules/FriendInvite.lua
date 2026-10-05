local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local localPlayer = Players.LocalPlayer
local v2 = {}
return table.freeze({
	PromptForUserId = function(inviteUser: number)
		if localPlayer == nil then
			return
		end

		local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer, inviteUser)

		if success and result then
			local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
			experienceInviteOptions.InviteUser = inviteUser
			SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
		end
	end,
	CanSendInviteToUserId = function(p: number)
		local v3 = v2[p]

		if v3 ~= nil then
			return v3
		end

		if localPlayer == nil then
			task.wait(0.5)
			return true
		end

		local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer, p)
		local v4 = success and result
		v2[p] = v4
		return v4
	end
})