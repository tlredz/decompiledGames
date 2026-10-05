local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.character)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
experienceInviteOptions.PromptMessage = "Gain a +5% XP bonus if a friend plays with you!"

-- equivalent calls inferred from this helper; original call sites unknown
local function eligibleToSendInvite()
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(localPlayer)
	end)
	return success and result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateFriendBoostClient()
	parent.Visible = true
	local friendsInServer = localPlayer:GetAttribute("friendsInServer") or 0
	parent.Percent.Text = `+{math.clamp(5 * friendsInServer, 0, 50)}% XP`
	parent.Multiplier.Text = friendsInServer <= 0 and "Invite" or `×{math.clamp(friendsInServer, 0, 10)}`
end

local success, result = pcall(function()
	return SocialService:CanSendGameInviteAsync(localPlayer)
end)
parent.Interactable = success and result
parent.MouseButton1Click:Connect(function()
	if eligibleToSendInvite() then
		SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
	end
end)
updateFriendBoostClient() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("friendsInServer"):Connect(updateFriendBoostClient)