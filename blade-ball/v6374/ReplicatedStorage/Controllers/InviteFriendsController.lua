local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage2.Packages
local shared = ReplicatedStorage2.Shared
local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
experienceInviteOptions.PromptMessage = "Earn rewards by playing with friends!"
experienceInviteOptions.InviteMessageId = "d11a2b99-e187-3845-8e1b-1aad0e1309ff"
require3(shared.FastUtils)
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(shared.InviteFriendInfo)
local v3 = require3(packages.Net)
local v4 = require3(packages.Observers)
local v5 = require3(packages.Replion)
local v6 = require3(packages.Trove)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v9 = require3(packages.Reliever)
local remoteEvent = v3:RemoteEvent("FriendsList/CollectReward")
local remoteEvent2 = v3:RemoteEvent("FriendsList/UpdateSeconds")
local frame = localPlayer.PlayerGui:WaitForChild("FriendsList").Frame

local function secondsConverter(value: number, p: string?, flag: boolean?)
	if typeof(value) ~= "number" then
		return
	end

	if value >= 86400 or p == "Days" then
		if flag then
			return value / 3600 / 24, value / 3600 % 24, value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i:%02i:%02i", value / 3600 / 24, value / 3600 % 24, value / 60 % 60, value % 60)
	elseif value >= 3600 and value < 86400 or p == "Hours" then
		if flag then
			return value / 3600 % 24, value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i:%02i", value / 3600 % 24, value / 60 % 60, value % 60)
	elseif value < 3600 then
		if flag then
			return value / 60 % 60, value % 60
		end

		return string.format("%02i:%02i", value / 60 % 60, value % 60)
	end
end

local InviteFriendsController = {}

function InviteFriendsController.CanSendGameInvite(p)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(p)
	end)
	return success and result
end

function InviteFriendsController:CreatePlayerFrame(p2: number, value: string)
	local clone = script.FriendTemplate:Clone()
	clone.Username.Text = value or ""
	clone.Status.Text = "Offline"
	clone.Status.TextColor3 = Color3.fromRGB(253, 0, 0)
	clone.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={p2}&w=60&h=60`
	clone.LayoutOrder = 3
	clone.Name = p2
	clone.Parent = frame.FriendListLeft.ScrollingFrame
	clone.Invite.Activated:Connect(function()
		if self.CanSendGameInvite(localPlayer) then
			pcall(function()
				experienceInviteOptions.InviteUser = p2
				SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
			end)
		else
			print("Player cannot invite!")
		end
	end)
	return clone
end

function InviteFriendsController.ChangeRewardStatus(childName: string, p: string)
	local child = frame.RewardProgress.RewardSlots:FindFirstChild(childName)

	if not child then
		return
	end

	local child2 = frame.RewardProgress.Bar:FindFirstChild(childName)

	if child2 then
		if p == "Collected" or p == "ToCollect" then
			child2.BackgroundColor3 = Color3.fromRGB(120, 255, 110)
			child2.TextLabel.TextColor3 = Color3.fromRGB(120, 255, 110)
		else
			child2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			child2.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	child.Collected.Visible = p == "Collected"
	child.ClickToCollect.Visible = p == "ToCollect"
end

function InviteFriendsController.LoadRewards()
	for k, reward in v2.Rewards do
		local child = frame.RewardProgress.RewardSlots:FindFirstChild("Reward" .. k)

		if not child then
			continue
		end

		local v10 = k
		v7.GuiUtils.getActivatedSignal(child):Connect(function()
			remoteEvent:FireServer(v10)
		end)
		child.Amount.Text = `x{tostring(reward.reward.Value or 0)}`
		child.Vector.Image = reward.reward.Icon or "rbxassetid://0"
	end
end

function InviteFriendsController:Construct(items)
	local v10 = v5.Client:WaitReplion("InviteFriends")

	for _, item in items do
		self:CreatePlayerFrame(item.Id, item.DisplayName)
		v9.relieve()
	end

	self.LoadRewards()
	self.ChangeRewardStatus("Reward1", v10:Find("RewardsCollected", 1) and "Collected" or "InProgress")
	self.ChangeRewardStatus("Reward2", v10:Find("RewardsCollected", 2) and "Collected" or "InProgress")
	self.ChangeRewardStatus("Reward3", v10:Find("RewardsCollected", 3) and "Collected" or "InProgress")
	v10:OnChange("RewardsCollected", function(list, list2)
		for k, _ in v2.Rewards do
			local v11 = table.find(list2, k) ~= nil
			local v12 = table.find(list, k) ~= nil

			if v11 ~= v12 and frame.RewardProgress.RewardSlots:FindFirstChild("Reward" .. k) then
				self.ChangeRewardStatus("Reward" .. k, v12 and "Collected" or "InProgress")
			end
		end
	end)
	local count = 0

	local function updateElibibleFriends()
		count = 0

		for _, v11 in v10:Get("Friends") or {} do
			if not v10:Get((`FriendsCooldown.{v11}`)) then
				count += 1
			end
		end
	end

	updateElibibleFriends()
	v10:OnChange("Friends", function(_)
		updateElibibleFriends()
	end)
	local v11 = {}

	local function updateCooldownFriends()
		for k, _ in v11 do
			k.Ineligible.Visible = false
		end

		table.clear(v11)

		for childName, v12 in v10:Get("FriendsCooldown") or {} do
			local child = frame.FriendListLeft.ScrollingFrame:FindFirstChild(childName)

			if not child then
				continue
			end

			v11[child] = v12
			local v13 = child
			child.Destroying:Connect(function()
				v11[v13] = nil
			end)
		end
	end

	updateCooldownFriends()
	v10:OnChange("FriendsCooldown", function(_)
		updateCooldownFriends()
		updateElibibleFriends()
	end)
	local total = 0
	RunService.RenderStepped:Connect(function(dt: number)
		if total <= 0.6666666666666666 then
			total += dt
			return
		end

		total = 0
		local serverTimeNow = workspace:GetServerTimeNow()
		local v12 = (v10:Get("NextRewardCooldown") or 0) - serverTimeNow

		if v12 <= 0 then
			frame.RewardProgress.Locked.Visible = false
		else
			frame.RewardProgress.Bar.Fill.UIGradient.Offset = Vector2.new(0, 0)
			frame.RewardProgress.Header.Text = ""
			frame.RewardProgress.Locked.Visible = true
			frame.RewardProgress.Locked.Timer.Text = `🕓 {v8:FormatTimeHHMMSS(v12)}`
		end

		for k, v13 in v11 do
			local v14 = v13 - serverTimeNow
			local visible = v14 > 0
			k.Ineligible.Visible = visible
			k.Ineligible.Text = `Ineligible friend: {v8:FormatShortTime(v14)}`
		end
	end)
	local duration = v2.Rewards[3].duration
	remoteEvent2.OnClientEvent:Connect(function(p)
		local serverTimeNow = workspace:GetServerTimeNow()
		local v12 = (v10:Get("NextRewardCooldown") or 0) - serverTimeNow

		if p <= duration and v12 <= 0 then
			frame.RewardProgress.Header.Text = `{secondsConverter(p)} ● {tostring(count)} eligible friend{count == 1 and "" or "s"} in-game`
			frame.RewardProgress.Bar.Fill.UIGradient.Offset = Vector2.new(0, 1 - p / duration)
		end

		for k, reward in v2.Rewards do
			if p < reward.duration or v10:Find("RewardsCollected", k) or not frame.RewardProgress.RewardSlots:FindFirstChild("Reward" .. k) then
				continue
			end

			self.ChangeRewardStatus("Reward" .. k, "ToCollect")
		end
	end)
	task.spawn(function()
		local maid = v6.new()

		while true do
			maid:Clean()
			local v12 = {}
			local success, result = pcall(function()
				return localPlayer:GetFriendsOnline()
			end)

			if success then
				v12 = result or v12
			end

			local friendsCooldown = v10:Get("FriendsCooldown") or {}

			for _, v13 in v12 do
				local v14 = frame.FriendListLeft.ScrollingFrame:FindFirstChild(v13.VisitorId) or maid:Add(self:CreatePlayerFrame(
					v13.VisitorId,
					v13.DisplayName
				))
				local v15 = friendsCooldown[tonumber(v14.Name) or 0]

				if v15 and not v11[v14] then
					v11[v14] = v15
				end

				if v13 and v13.IsOnline then
					v14.LayoutOrder = 2
					v14.Status.Text = "Online"
					v14.Status.TextColor3 = Color3.fromRGB(0, 255, 0)

					if v13.PlaceId == 13772394625 or v13.PlaceId == game.PlaceId then
						v14.LayoutOrder = 1
						v14.Status.Text = "In-Game"
						v14.Status.TextColor3 = Color3.fromRGB(170, 255, 255)
					end
				else
					v14.LayoutOrder = 3
					v14.Status.Text = "Offline"
					v14.Status.TextColor3 = Color3.fromRGB(253, 0, 0)
				end

				v9.relieve()
			end

			task.wait(30)
		end
	end)
end

function InviteFriendsController:Start()
	v7.GuiUtils.getActivatedSignal(frame.Close):Connect(function()
		v:Close("FriendsList")
	end)
	local v10 = v5.Client:WaitReplion("Data")

	if not v10 then
		return
	end

	local v11 = v5.Client:WaitReplion("InviteFriends")

	if not v11 then
		print("Invite friends replion not found!")
		return
	end

	local allFriends = v11:Get("AllFriends") or {}

	if not allFriends or #allFriends == 0 then
		print(allFriends, allFriends and #allFriends, "Player has 0 friends!")
		return
	end

	self:Construct(allFriends)
	local clone = nil
	local v12 = {}

	local function updateVisibility()
		local v13 = v10:Get("claimedGroupReward") and #allFriends > 0

		if clone and not v13 then
			clone:Destroy()
		else
			local v14 = (not clone and v13 and true or false) and CollectionService:GetTagged("FriendCratePosition")[1]

			if v14 then
				clone = ReplicatedStorage2.Assets.FriendCrate:Clone()
				clone:PivotTo(v14:GetPivot())
				clone.Parent = workspace
				local proximityPrompt = clone.Lock:FindFirstChild("ProximityPrompt")

				if proximityPrompt then
					proximityPrompt.Triggered:Connect(function(player)
						if player ~= localPlayer then
							return
						end

						v:Open("FriendsList")
					end)
				end
			end
		end

		for _, v14 in v12 do
			v14:SetAttribute("EndTime", v13 and clone and 0 or nil)
		end
	end

	v4.observeTag("GroupCrate", function(p)
		if not table.find(v12, p) then
			table.insert(v12, p)
		end

		updateVisibility()
		return function()
			local index = table.find(v12, p)

			if index then
				table.remove(v12, index)
			end
		end
	end)
	v10:OnChange("claimedGroupReward", function()
		updateVisibility()
	end)
	updateVisibility()
end

return InviteFriendsController