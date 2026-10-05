local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdvertisementsConstants = require(ReplicatedStorage.Modules.Shared.Advertisements.AdvertisementsConstants)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local IncentivesRewardClaimController = {}

function IncentivesRewardClaimController.FrameworkInit() end

function IncentivesRewardClaimController.FrameworkStart() end

function IncentivesRewardClaimController:Show()
	self.duration = self.duration or AdvertisementsConstants.REWARD_DURATION

	if PanelController.IsOpen("NoResetGUIHandler", "RewardClaim") then
		return
	end

	if Janitor.Is(v) then
		v:Destroy()
	end

	v = Janitor.new()
	local v2 = PanelController.WaitForPanel("NoResetGUIHandler", "RewardClaim")
	v2:RegisterListener(v2, v2.Events.Closing, function(_)
		v:Destroy()
	end)
	local contentBox = v2:GetInstance():WaitForChild("OuterBox"):WaitForChild("ContentBox")
	local description = contentBox:WaitForChild("Body"):WaitForChild("Description")
	local rewardIcon = contentBox:WaitForChild("IconContainer"):WaitForChild("RewardIcon")

	if self.rewardIcon then
		rewardIcon.Image = self.rewardIcon
	else
		rewardIcon.Image = ""
	end

	description.Text = string.format(AdvertisementsConstants.PROMPT_MESSAGES.Claimed, self.duration)

	if self.helipad then
		description.Text ..= [[


Visit a helipad to spawn it!]]
		Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
			createVector(-142.246, 47.487, 30.421),
			createVector(0, -90, 0)
		)
	end

	PanelController.Open("NoResetGUIHandler", "RewardClaim")
end

return IncentivesRewardClaimController