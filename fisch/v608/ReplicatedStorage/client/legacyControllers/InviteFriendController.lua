local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage2.packages.Trove)
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage3.packages.Promise)
local localPlayer = Players.LocalPlayer
local invitefriend = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("invitefriend")
local v = nil
local maid = nil
local friendslist = invitefriend:WaitForChild("friendslist"):WaitForChild("friendslist")
local template = friendslist:WaitForChild("Template")
local close = invitefriend:WaitForChild("Close")
local InviteFriendController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function CanSendGameInvite(p)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p)
	end)
	return success and result
end

function InviteFriendController:OpenInvitePage(inviteUser: number)
	local jSONEncode = HttpService:JSONEncode({
		senderUserID = localPlayer.UserId
	})
	local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
	experienceInviteOptions.LaunchData = jSONEncode
	experienceInviteOptions.InviteUser = inviteUser

	if CanSendGameInvite(localPlayer) then
		SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
	end
end

function InviteFriendController:Start()
	Net:RemoteEvent("InviteFriendController/Prompt").OnClientEvent:Connect(function()
		self:Prompt()
	end)
	close.Activated:Connect(function()
		invitefriend.Visible = false
	end)
end

function InviteFriendController:RefreshList()
	return Promise.new(function(callback, _, _)
		if maid then
			maid:Destroy()
		end

		maid = Trove.new()

		for _, v2 in localPlayer:GetFriendsOnline() do
			local clone = template:Clone()
			clone.Visible = true
			clone.Parent = friendslist
			clone.Name = v2.VisitorId
			local v4 = v2
			local success, _ = pcall(function()
				local title = clone:WaitForChild("title")
				title.Text = v4.DisplayName
				local headshot = clone:WaitForChild("playerimage"):WaitForChild("Headshot")
				headshot.Image = Players:GetUserThumbnailAsync(
					v4.VisitorId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size420x420
				)
			end)

			if success then
				maid:Add(clone)
				local v5 = clone
				maid:Add(clone:WaitForChild("Invite").Activated:Connect(function()
					InviteFriendController:OpenInvitePage((tonumber(v5.Name)))
				end))
			else
				clone:Destroy()
			end
		end

		callback()
	end)
end

function InviteFriendController:Prompt()
	local now = os.clock()

	if v == nil then
		v = now
		InviteFriendController:RefreshList()
	elseif now - v >= 60 then
		v = now
		InviteFriendController:RefreshList()
	end

	invitefriend.Visible = true
end

return InviteFriendController