local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("SocialService")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SocialController"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local v = {
	HoverRatio = 1.05,
	ReleaseRatio = 1.05
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.InviteFrame = self.Container:WaitForChild("Invite")
	self.InviteRewardFrame = self.InviteFrame:WaitForChild("Reward")
	self.InviteRewardButton = self.InviteFrame:WaitForChild("Button")
	self.FavoriteFrame = self.Container:WaitForChild("Favorite")
	self.FavoriteRewardClaimed = self.FavoriteFrame:WaitForChild("Claimed")
	self.FavoriteRewardFrame = self.FavoriteFrame:WaitForChild("Reward")
	self.FavoriteRewardButton = self.FavoriteFrame:WaitForChild("Button")
	self.NotificationsFrame = self.Container:WaitForChild("Notifications")
	self.NotificationsRewardClaimed = self.NotificationsFrame:WaitForChild("Claimed")
	self.NotificationsRewardFrame = self.NotificationsFrame:WaitForChild("Reward")
	self.NotificationsRewardButton = self.NotificationsFrame:WaitForChild("Button")
	self.LikeFrame = self.Container:WaitForChild("Like")
	self.LikeRewardFrame = self.LikeFrame:WaitForChild("Reward")
	self.LikeRewardClaimed = self.LikeFrame:WaitForChild("Claimed")
	self.LikeRewardButton = self.LikeFrame:WaitForChild("Button")
	self.LikeRewardReadyFrame = self.LikeRewardButton:WaitForChild("Ready")
	self.LikeRewardCountdownFrame = self.LikeRewardButton:WaitForChild("Countdown")
	self.LikeRewardCountdownText = self.LikeRewardCountdownFrame:WaitForChild("Title")
	self.GroupFrame = self.Container:WaitForChild("Group")
	self.GroupRewardFrame = self.GroupFrame:WaitForChild("Reward")
	self.GroupRewardClaimed = self.GroupFrame:WaitForChild("Claimed")
	self.GroupRewardButton = self.GroupFrame:WaitForChild("Button")
	self.GroupRewardReadyFrame = self.GroupRewardButton:WaitForChild("Ready")
	self.GroupRewardCountdownFrame = self.GroupRewardButton:WaitForChild("Countdown")
	self.GroupRewardJoinFrame = self.GroupRewardButton:WaitForChild("Join")
	self.GroupRewardCountdownText = self.GroupRewardCountdownFrame:WaitForChild("Title")
	self.CodesFrame = self.Container:WaitForChild("Codes")
	self.CodesVerifiedFrame = self.CodesFrame:WaitForChild("Verified")
	self.CodesVerifiedInputFrame = self.CodesVerifiedFrame:WaitForChild("Input")
	self.CodesVerifiedBox = self.CodesVerifiedInputFrame:WaitForChild("Box")
	self.CodesVerifiedButton = self.CodesVerifiedInputFrame:WaitForChild("Button")
	self.CodesVerifiedButtonReadyFrame = self.CodesVerifiedButton:WaitForChild("Ready")
	self.CodesVerifiedButtonCountdownFrame = self.CodesVerifiedButton:WaitForChild("Countdown")
	self.CodesVerifiedButtonCountdownText = self.CodesVerifiedButtonCountdownFrame:WaitForChild("Title")
	self.CodesUnverifiedFrame = self.CodesFrame:WaitForChild("Unverified")
	self.CodesUnverifiedButton = self.CodesUnverifiedFrame:WaitForChild("Input"):WaitForChild("Button")
	self.CodesUnverifiedButtonReadyFrame = self.CodesUnverifiedButton:WaitForChild("Ready")
	self.CodesUnverifiedButtonCountdownFrame = self.CodesUnverifiedButton:WaitForChild("Countdown")
	self.CodesUnverifiedButtonCountdownText = self.CodesUnverifiedButtonCountdownFrame:WaitForChild("Title")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._open_animation_disabled = true
	self._group_reward_countdown_hash = 0
	self._like_reward_countdown_hash = 0
	self._codes_verify_countdown_hash = 0
	self._window_focus_connection = nil
	self._is_enabling_notifications = false
	self._is_favoriting = false
	self._can_verify = false
	self._previous_verified_status = nil
	self._redirect_on_close = nil
	self:_Init()
	return self
end

function object.CloseRequest(p)
	local statistic = PlayerDataController:GetStatistic("StatisticDuelsPlayed")
	local statistic2 = PlayerDataController:GetStatistic("StatisticDuelsWon")

	if statistic >= 5 and statistic2 < 10 then
		Page.CloseRequest(p)
	else
		p.OpenPage:Fire("Shop", true)
	end
end

function object:_UpdateCodesVerified()
	local codesVerified = PlayerDataController:Get("CodesVerified")

	if self._previous_verified_status == false and codesVerified then
		Utility:CreateSound("rbxassetid://7715210658", 1, 1, script, true, 5)
	end

	self._previous_verified_status = codesVerified
	self.CodesVerifiedFrame.Visible = codesVerified
	self.CodesUnverifiedFrame.Visible = not codesVerified
end

function object:_CountdownCodesVerify()
	self._codes_verify_countdown_hash += 1
	local _codes_verify_countdown_hash = self._codes_verify_countdown_hash
	self.CodesUnverifiedButtonCountdownFrame.Visible = true
	self.CodesUnverifiedButtonReadyFrame.Visible = false
	task.spawn(function()
		for i = 15, 1, -1 do
			self.CodesUnverifiedButtonCountdownText.Text = i
			wait(1)

			if _codes_verify_countdown_hash ~= self._codes_verify_countdown_hash then
				return
			end
		end

		self.CodesUnverifiedButtonCountdownFrame.Visible = false
		self.CodesUnverifiedButtonReadyFrame.Visible = true
	end)
end

function object:_UpdateNotificationsReward()
	local claimedNotificationsReward = PlayerDataController:Get("ClaimedNotificationsReward")
	self.NotificationsRewardClaimed.Visible = claimedNotificationsReward
	self.NotificationsRewardButton.Visible = not claimedNotificationsReward
end

function object:_UpdateFavoriteReward()
	local claimedFavoriteReward = PlayerDataController:Get("ClaimedFavoriteReward")
	self.FavoriteRewardClaimed.Visible = claimedFavoriteReward
	self.FavoriteRewardButton.Visible = not claimedFavoriteReward
end

function object:_UpdateLikeReward()
	local claimedLikeReward = PlayerDataController:Get("ClaimedLikeReward")
	self.LikeRewardClaimed.Visible = claimedLikeReward
	self.LikeRewardButton.Visible = not claimedLikeReward

	if claimedLikeReward then
		self._like_reward_countdown_hash += 1
	end
end

function object:_CountdownLikeReward()
	self._like_reward_countdown_hash += 1
	local _like_reward_countdown_hash = self._like_reward_countdown_hash
	self.LikeRewardCountdownFrame.Visible = true
	self.LikeRewardReadyFrame.Visible = false
	task.spawn(function()
		for i = 20, 1, -1 do
			self.LikeRewardCountdownText.Text = i
			wait(1)

			if _like_reward_countdown_hash ~= self._like_reward_countdown_hash then
				return
			end
		end

		self.LikeRewardCountdownFrame.Visible = false
		self.LikeRewardReadyFrame.Visible = true
	end)
end

function object:_UpdateGroupReward()
	local claimedGroupReward = PlayerDataController:Get("ClaimedGroupReward")
	self.GroupRewardClaimed.Visible = claimedGroupReward
	self.GroupRewardButton.Visible = not claimedGroupReward

	if claimedGroupReward then
		self._group_reward_countdown_hash += 1
	end
end

function object:_CountdownGroupReward()
	self._group_reward_countdown_hash += 1
	local _group_reward_countdown_hash = self._group_reward_countdown_hash
	self.GroupRewardCountdownFrame.Visible = true
	self.GroupRewardReadyFrame.Visible = false
	task.spawn(function()
		for i = 60, 1, -1 do
			self.GroupRewardCountdownText.Text = i
			wait(1)

			if _group_reward_countdown_hash ~= self._group_reward_countdown_hash then
				return
			end
		end

		self.GroupRewardCountdownFrame.Visible = false
		self.GroupRewardReadyFrame.Visible = true
	end)
end

function object:_UpdateInviteFrame()
	self.InviteFrame.Visible = SocialController.CanSendGameInvite
end

function object:_Setup()
	for _, childName in pairs({ "Group", "Nosniy", "SenseiWarrior" }) do
		local child = self.CodesFrame:WaitForChild(childName)

		for _, childName2 in pairs({ "X", "Discord", "YouTube" }) do
			local child2 = child:WaitForChild("Details"):FindFirstChild(childName2)

			if child2 then
				child2.Visible = ComplianceController:IsExternalReferencesAllowed(childName2)
			end
		end
	end

	RewardSlot.new({
		Name = "Cream",
		Weapon = "IsRandom"
	}):SetParent(self.InviteRewardFrame)
	RewardSlot.new({
		Name = "Shooting Star",
		Weapon = "IsUniversal"
	}):SetParent(self.FavoriteRewardFrame)
	RewardSlot.new({
		Name = "Bell",
		Weapon = "IsUniversal"
	}):SetParent(self.NotificationsRewardFrame)
	RewardSlot.new({
		Name = "Nosniy Games",
		Weapon = "IsUniversal"
	}):SetParent(self.GroupRewardFrame)
	RewardSlot.new({
		Name = "RIVALS",
		Weapon = "IsUniversal"
	}):SetParent(self.LikeRewardFrame)
	local v2 = RewardSlot.new({
		Name = "Key",
		Quantity = 3
	})
	v2:SetParent(self.LikeRewardFrame)
	v2.Frame.Position = UDim2.new(-0.5, 0, 0.5, 0)
	task.spawn(function()
		self.NotificationsFrame.Visible = false
		local success, result = pcall(ExperienceNotificationService.CanPromptOptInAsync, ExperienceNotificationService)
		self.NotificationsFrame.Visible = success and result
	end)
end

function object:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.GroupRewardButton.MouseButton1Click:Connect(function()
		if self.GroupRewardJoinFrame.Visible then
			self.GroupRewardJoinFrame.Visible = false
			self.GroupRewardReadyFrame.Visible = true
			local success, result = pcall(GroupService.PromptJoinAsync, GroupService, CONSTANTS.GROUP_ID)

			if not success then
				self.PromptSystem:Open("ErrorMessage", "Whoops!", "Failed to join, please try again another time!")
				warn("Failed to prompt group join, error:", result)
			end
		elseif self.GroupRewardReadyFrame.Visible then
			self:_CountdownGroupReward()

			if not ReplicatedStorage.Remotes.Data.ClaimGroupReward:InvokeServer() then
				self.PromptSystem:Open(
					"ErrorMessage",
					"Whoops!",
					"Failed to verify, join the group before claiming your reward!"
				)
			end
		end
	end)
	self.LikeRewardButton.MouseButton1Click:Connect(function()
		if self.LikeRewardReadyFrame.Visible then
			if self._window_focus_connection then
				self._window_focus_connection:Disconnect()
				self._window_focus_connection = nil
				self.PromptSystem:Open(
					"ErrorMessage",
					"Whoops!",
					"Failed to verify, like the game before claiming your reward!"
				)
				self:_CountdownLikeReward()
			else
				ReplicatedStorage.Remotes.Data.ClaimLikeReward:FireServer()
			end
		end
	end)
	self.FavoriteRewardButton.MouseButton1Click:Connect(function()
		AvatarEditorService:PromptSetFavorite(CONSTANTS.HUB_PLACE_ID, Enum.AvatarItemType.Asset, true)

		if not self._is_favoriting then
			self._is_favoriting = true
			wait(10)
			ReplicatedStorage.Remotes.Data.ClaimFavoriteReward:FireServer()
		end
	end)
	self.InviteRewardButton.MouseButton1Click:Connect(function()
		SocialController:PromptFriendInvite()
	end)
	self.NotificationsRewardButton.MouseButton1Click:Connect(function()
		ExperienceNotificationService:PromptOptIn()

		if not self._is_enabling_notifications then
			self._is_enabling_notifications = true
			wait(10)
			ReplicatedStorage.Remotes.Data.ClaimNotificationsReward:FireServer()
		end
	end)
	self.CodesUnverifiedButton.MouseButton1Click:Connect(function()
		if not self.CodesUnverifiedButtonReadyFrame.Visible then
			return
		end

		if self._can_verify then
			ReplicatedStorage.Remotes.Data.VerifyCodes:FireServer()
			return
		end

		self._can_verify = true
		self.PromptSystem:Open("ErrorMessage", "Whoops!", "Failed to verify, follow the developers before verifying!")
		self:_CountdownCodesVerify()
	end)
	self.CodesVerifiedButton.MouseButton1Click:Connect(function()
		local v2 = ReplicatedStorage.Remotes.Data.RedeemCode:InvokeServer(string.lower(self.CodesVerifiedBox.Text)) or "Something went wrong"

		if v2 ~= "Success" then
			self.PromptSystem:Open("ErrorMessage", "Whoops!", "Failed to redeem code: " .. v2)
		end
	end)
	self._window_focus_connection = UserInputService.WindowFocusReleased:Connect(function()
		self._window_focus_connection:Disconnect()
		self._window_focus_connection = nil
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedGroupReward"):Connect(function()
		self:_UpdateGroupReward()
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedLikeReward"):Connect(function()
		self:_UpdateLikeReward()
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedFavoriteReward"):Connect(function()
		self:_UpdateFavoriteReward()
	end)
	PlayerDataController:GetDataChangedSignal("ClaimedNotificationsReward"):Connect(function()
		self:_UpdateNotificationsReward()
	end)
	PlayerDataController:GetDataChangedSignal("CodesVerified"):Connect(function()
		self:_UpdateCodesVerified()
	end)
	SocialController.CanSendGameInviteChanged:Connect(function()
		self:_UpdateInviteFrame()
	end)
	self:_Setup()
	self:_UpdateInviteFrame()
	self:_UpdateLikeReward()
	self:_UpdateGroupReward()
	self:_UpdateFavoriteReward()
	self:_UpdateNotificationsReward()
	self:_UpdateCodesVerified()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.InviteRewardButton, nil, v)
	ButtonEffect:Add(self.FavoriteRewardButton, nil, v)
	ButtonEffect:Add(self.NotificationsRewardButton, nil, v)
	ButtonEffect:Add(self.LikeRewardButton, nil, v)
	ButtonEffect:Add(self.GroupRewardButton, nil, v)
	ButtonEffect:Add(self.CodesVerifiedButton, nil, v)
	ButtonEffect:Add(self.CodesUnverifiedButton, nil, v)
end

return object._new()