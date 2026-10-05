local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
experienceInviteOptions.PromptMessage = "Invite a friend!"

-- equivalent calls inferred from this helper; original call sites unknown
local function canSendGameInvite(p)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p)
	end)
	return success and result
end

local function openInvites()
	if canSendGameInvite(localPlayer) then
		local _, _ = pcall(function()
			SocialService:PromptGameInvite(localPlayer)
		end)
	end
end

script.Parent.Title.Invite.Activated:Connect(openInvites)