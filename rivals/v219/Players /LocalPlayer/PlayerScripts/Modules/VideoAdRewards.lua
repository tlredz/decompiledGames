local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdService = game:GetService("AdService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local videoAdRewards = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("VideoAdRewards")
local videoAdRewardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("VideoAdRewardSlot")
local VideoAdRewards = {}
VideoAdRewards.__index = VideoAdRewards

function VideoAdRewards.new(_)
	local self = setmetatable({}, VideoAdRewards)
	self.PlayedAd = Signal.new()
	self.AvailabilityChanged = Signal.new()
	self.Frame = videoAdRewards:Clone()
	self.Container = self.Frame:WaitForChild("Container")
	self.Background = self.Container:WaitForChild("Background")
	self.WaitingFrame = self.Container:WaitForChild("Waiting")
	self.WaitingDotsFrame = self.WaitingFrame:WaitForChild("Dots")
	self.UnavailableFrame = self.Container:WaitForChild("Unavailable")
	self.UnavailableTitle = self.UnavailableFrame:WaitForChild("Title")
	self.UnavailableDescription = self.UnavailableFrame:WaitForChild("Description")
	self.UnavailableImage = self.UnavailableFrame:WaitForChild("ImageLabel")
	self.AvailableFrame = self.Container:WaitForChild("Available")
	self.AvailableTitle = self.AvailableFrame:WaitForChild("Title")
	self.AvailableDescription = self.AvailableFrame:WaitForChild("Description")
	self.RewardsFrame = self.AvailableFrame:WaitForChild("Rewards")
	self._connections = {}
	self._cleanup = {}
	self._update_hash = 0
	self._auto_update_task = nil
	self._buttons_position = nil
	self:_Init()
	return self
end

function VideoAdRewards.IsAvailable(p)
	return p.AvailableFrame.Visible
end

function VideoAdRewards:SetButtonsPositionY(buttons_position_y)
	self._buttons_position_y = buttons_position_y
end

function VideoAdRewards.SetRewardsSize(p, p2)
	p.RewardsFrame.Size = UDim2.new(0.9, 0, p2, 0)
end

function VideoAdRewards.SetBackgroundVisible(p, visible)
	p.Background.Visible = visible
end

function VideoAdRewards.SetWhiteColor(data, p)
	data.AvailableTitle.TextColor3 = p
	data.AvailableDescription.TextColor3 = p
	data.UnavailableTitle.TextColor3 = p
	data.UnavailableDescription.TextColor3 = p
	data.UnavailableImage.ImageColor3 = p

	for _, image in pairs(data.WaitingDotsFrame:GetChildren()) do
		if image:IsA("ImageLabel") then
			image.ImageColor3 = p
		end
	end
end

function VideoAdRewards:AutoUpdate(value)
	self._auto_update_task = task.spawn(function()
		while true do
			self:Update()
			wait(value or 60)
		end
	end)
end

function VideoAdRewards:Update()
	task.spawn(self._Update, self)
end

function VideoAdRewards:WeakUpdate()
	if self.AvailableFrame.Visible then
		return
	end

	self:Update()
end

function VideoAdRewards:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	if self._auto_update_task then
		task.cancel(self._auto_update_task)
	end

	self.AvailabilityChanged:Destroy()
	self.PlayedAd:Destroy()
end

function VideoAdRewards:_Update()
	for _, v in pairs(self._cleanup) do
		v:Destroy()
	end

	self._cleanup = {}
	self._update_hash += 1
	local _update_hash = self._update_hash
	self.WaitingFrame.Visible = true
	self.WaitingDotsFrame:AddTag("UILoadingDots")
	self.UnavailableFrame.Visible = false
	self.AvailableFrame.Visible = false
	local success, adAvailabilityNowAsync = pcall(
		AdService.GetAdAvailabilityNowAsync,
		AdService,
		Enum.AdFormat.RewardedVideo
	)

	if _update_hash ~= self._update_hash then
		return
	end

	local visible = success and adAvailabilityNowAsync.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
	self.WaitingFrame.Visible = false
	self.WaitingDotsFrame:RemoveTag("UILoadingDots")
	self.UnavailableFrame.Visible = not visible
	self.AvailableFrame.Visible = visible

	if not visible then
		return
	end

	local count = 0

	for i = 1, #MonetizationLibrary.VideoAdRewards do
		local v2 = PlayerDataController:Get("VideoAdRewardsClaimed") % #MonetizationLibrary.VideoAdRewards + i
		local v3 = math.min(
			MonetizationLibrary.VIDEO_AD_REWARDS_MAX_SCALE_FACTOR,
			(math.ceil((PlayerDataController:Get("VideoAdRewardsClaimed") + i) / #MonetizationLibrary.VideoAdRewards))
		)
		local videoAdReward = MonetizationLibrary.VideoAdRewards[(v2 - 1) % #MonetizationLibrary.VideoAdRewards + 1]
		local visible2 = i == 1

		if i > 1 then
			local _CreateArrow = self:_CreateArrow()
			_CreateArrow.LayoutOrder = count
			_CreateArrow.Parent = self.RewardsFrame
			table.insert(self._cleanup, _CreateArrow)
			count += 1
		end

		local preRepetitionRewardDatas = { videoAdReward.RewardDatas }

		if PlayerDataController:Get("VideoAdRewardsClaimed") + i <= #MonetizationLibrary.VideoAdRewards then
			table.insert(preRepetitionRewardDatas, videoAdReward.PreRepetitionRewardDatas)
		end

		local total = 0

		for _, v5 in pairs(preRepetitionRewardDatas) do
			total += #v5
		end

		local count2 = 0

		for _, v5 in pairs(preRepetitionRewardDatas) do
			for _, v6 in pairs(v5) do
				count2 += 1
				count += 1
				local table2 = Utility:CloneTable(v6)
				table2.Quantity = (table2.Quantity or 1) * v3
				local clone = videoAdRewardSlot:Clone()
				clone.Button.Visible = count2 == 1
				clone.Button.Position = UDim2.new(total * 0.5, 0, self._buttons_position_y or 1.25, 0)
				clone.Button.Unlocked.Title.Text = string.format(
					"%s <font size=\"8\">/ %s</font>",
					PlayerDataController:Get("VideoAdsWatchedBeforeClaiming"),
					videoAdReward.NumAdsRequired
				)
				clone.Button.Unlocked.Visible = visible2
				clone.Button.Locked.Visible = not visible2
				clone.LayoutOrder = count
				clone.Parent = self.RewardsFrame
				table.insert(self._cleanup, clone)
				local v7 = RewardSlot.new(table2)
				v7:SetParent(clone)
				table.insert(self._cleanup, v7)

				local function update()
					clone.Button.Unlocked.Title.Position = UDim2.new(
						0.5,
						clone.Button.Unlocked.Title.Icon.AbsoluteSize.X * 0.4,
						0.5,
						0
					)
					clone.Button.Unlocked.Title.Icon.Position = UDim2.new(
						0.5,
						-clone.Button.Unlocked.Title.TextBounds.X / 2,
						0.5,
						0
					)
				end

				clone.Button.Unlocked.Title.Icon:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
				clone.Button.Unlocked.Title:GetPropertyChangedSignal("TextBounds"):Connect(update)
				update()

				if not visible2 then
					continue
				end

				local visible3 = visible2
				clone.Button.MouseButton1Click:Connect(function()
					if not visible3 then
						return
					end

					self.PlayedAd:Fire()
					ReplicatedStorage.Remotes.Misc.PlayVideoAdShopOffer:FireServer()
				end)
				ButtonEffect:Add(clone.Button)
			end
		end
	end
end

function VideoAdRewards:_CreateArrow()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://133426948634565"
	imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel.Size = UDim2.new(0.5, 0, 0.25, 0)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	return imageLabel
end

function VideoAdRewards:_Init()
	self.AvailableFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		self.AvailabilityChanged:Fire()
	end)
	table.insert(
		self._connections,
		PlayerDataController:GetDataChangedSignal("VideoAdRewardsClaimed"):Connect(function()
			self:Update()
		end)
	)
	table.insert(
		self._connections,
		PlayerDataController:GetDataChangedSignal("VideoAdsWatchedBeforeClaiming"):Connect(function()
			self:Update()
		end)
	)
end

return VideoAdRewards