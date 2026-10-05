local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Promise)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v7 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v8 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v9 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v10 = require3(ReplicatedStorage2.Shared.Policy)
local v11 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v12 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v13 = require3(ReplicatedStorage2.Shared.DuoPassData)
require3(ReplicatedStorage2.Common.RewardInfo)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local duoPassMenu = playerGui:WaitForChild("DuoPassMenu")
local duoPassHud = playerGui:WaitForChild("DuoPassHud")
local template = duoPassMenu.InviteList.ScrollingFrame.Template
template.Parent = nil
local invitePrompt = duoPassHud.InvitePrompt
invitePrompt.Parent = nil
local template2 = duoPassMenu.MainFrame.Pass.Rewards.ScrollingFrame.Template
template2.Parent = nil
local template3 = duoPassMenu.MainFrame.Leaderboard.ScrollingFrame.Template
template3.Parent = nil
local v14 = {
	InviteList = {
		Menu = duoPassMenu.InviteList,
		UseMainFrame = false,
		IsRestrictedPage = false
	},
	Invite = {
		Menu = duoPassMenu.InviteFriendsFrame,
		UseMainFrame = false,
		IsRestrictedPage = false
	},
	Welcome = {
		Menu = duoPassMenu.MainFrame.Welcome,
		UseMainFrame = true,
		IsRestrictedPage = false
	},
	Main = {
		Menu = duoPassMenu.MainFrame.Pass,
		UseMainFrame = true,
		IsRestrictedPage = true
	},
	Gift = {
		Menu = duoPassMenu.MainFrame.GiftShop,
		UseMainFrame = true,
		IsRestrictedPage = true
	},
	Leaderboard = {
		Menu = duoPassMenu.MainFrame.Leaderboard,
		UseMainFrame = true,
		IsRestrictedPage = true
	},
	LeaveDuo = {
		Menu = duoPassMenu.ConfirmationFrame,
		UseMainFrame = false,
		IsRestrictedPage = true
	}
}
local promisify = v.promisify(function(object, userId)
	if typeof(userId) == "Instance" then
		userId = userId.UserId
	end

	return object:IsFriendsWith(userId)
end)
local DuoPassController = {}
DuoPassController.OnPageChange = v3.new()
DuoPassController.IsEnabled = false
DuoPassController.EnabledSignal = v3.new()

function DuoPassController:GetCurrentPage()
	for k, v15 in v14 do
		if v15.Menu.Visible then
			return k
		end
	end

	return nil
end

function DuoPassController:SetPage(p: string)
	self:GetCurrentPage()
	local replion = v2.Client:GetReplion("Data")
	local v15 = v14[p] and v14[p].IsRestrictedPage == false and replion and replion:Get("DuoPass.DuoId") and "Main" or p
	local visible = false

	for k, v17 in v14 do
		visible = v17.UseMainFrame and v15 == k and true or visible
		v17.Menu.Visible = v15 == k
	end

	duoPassMenu.MainFrame.Visible = visible
	v13.Remotes.SetReplication:FireServer(v15 == "Leaderboard")
	self.OnPageChange:Fire(v15)
end

function DuoPassController:Start()
	local function pageButton(p: string)
		return function()
			self:SetPage(p)
		end
	end

	local formatted = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
	duoPassHud.Enabled = true
	self:SetPage("Welcome")
	local v15 = v2.Client:WaitReplion("Data")
	v9:OnGuiOpen(duoPassMenu.Name, function()
		if v15:Get("DuoPass.DuoId") then
			self:SetPage("Main")
		else
			self:SetPage("Welcome")
		end
	end)
	v9:OnGuiClose(duoPassMenu.Name, function()
		v13.Remotes.SetReplication:FireServer(false)
	end)

	local function updateFlags()
		local isEnabled = self.IsEnabled
		self.IsEnabled = v8:GetKey(v13.GetFFlagKey("Enabled")) == true and workspace:GetServerTimeNow() < (v8:GetKey(v13.GetFFlagKey("EndTime")) or 0)

		if self.IsEnabled ~= isEnabled then
			self.EnabledSignal:Fire(self.IsEnabled)
		end
	end

	v5.Thread.Every(1, updateFlags)
	v8.DataUpdatedEvent:Connect(updateFlags)
	task.spawn(updateFlags)
	v14.Welcome.Menu.Close.Activated:Connect(function()
		v9:Close(duoPassMenu.Name)
	end)
	v14.Welcome.Menu.PlayButton.Activated:Connect(function()
		self:SetPage("Invite")
	end)
	v14.Invite.Menu.YourTeam.YourTeam.ProfilePicture.Headshot.Image = formatted
	v14.Invite.Menu.Close.Activated:Connect(function()
		v9:Close(duoPassMenu.Name)
	end)
	v14.Invite.Menu.Invite.Activated:Connect(function()
		self:SetPage("InviteList")
	end)
	v14.InviteList.Menu.Message.Visible = true
	v14.InviteList.Menu.Close.Activated:Connect(function()
		v9:Close(duoPassMenu.Name)
	end)
	local v16 = {}

	local function onPlayerAdded(instance)
		if instance == localPlayer then
			return
		end

		local maid = v4.new()
		v14.InviteList.Menu.Message.Visible = false
		maid:Add(function()
			v14.InviteList.Menu.Message.Visible = #Players:GetPlayers() - 1 <= 0
		end)
		local clone = maid:Clone(template)
		clone.Username.Text = instance.Name
		clone.PlayerPortrait.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=100&h=100`
		clone.Parent = v14.InviteList.Menu.ScrollingFrame
		local v17 = false

		local function updateInviteStatus()
			local isInDuo = instance:GetAttribute("IsInDuo")
			local canInvite = instance:GetAttribute("CanInvite")
			clone.Invite.ImageTransparency = (isInDuo == true or isInDuo == nil) and 0.8 or 0
			clone.Invite.Label.Text = isInDuo == true and "IN DUO" or isInDuo == nil and "LOADING" or v17 and "INVITED" or canInvite and "INVITE" or "CAN'T INVITE"
		end

		maid:Connect(instance:GetAttributeChangedSignal("CanInvite"), updateInviteStatus)
		maid:Connect(instance:GetAttributeChangedSignal("IsInDuo"), updateInviteStatus)
		task.spawn(updateInviteStatus)
		maid:Add(clone.Invite.Activated:Connect(function()
			if not instance:GetAttribute("CanInvite") then
				return
			end

			local v18, v19 = v13.Remotes.SendInvite:InvokeServer(instance, false)

			if v18 then
				v17 = true
				updateInviteStatus()
				task.delay(v19 - workspace:GetServerTimeNow(), function()
					v17 = false
					updateInviteStatus()
				end)
			end
		end))
		maid:Add(v13.Remotes.RemoveInvite.OnClientEvent:Connect(function(p)
			if p == instance and v17 then
				v17 = false
				updateInviteStatus()
			end
		end))
		v16[instance] = maid
	end

	local maid = v4.new()
	local v17 = false
	v13.Remotes.InviteReceived.OnClientEvent:Connect(function(p, p2: number?)
		while localPlayer.Character.Parent ~= workspace.Dead do
			task.wait()
		end

		while maid._cleaning do
			task.wait()
		end

		local v18 = v17
		maid:Clean()
		v17 = true

		if not p then
			return
		end

		maid:Add(function()
			v13.Remotes.RemoveInvite:FireServer(p)
		end)
		maid:Add(task.delay(p2 - workspace:GetServerTimeNow(), function()
			maid:Clean()
		end))
		local clone = invitePrompt:Clone()
		clone.Invite.Text = `{p.Name} Invited You to join their Duo!`
		clone.Position = UDim2.fromScale(-0.23, 0.959)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, v18 and 0.27 or 0),
			{
				Position = UDim2.fromScale(0.018, 0.959)
			}
		)
		tween:Play()
		clone.Parent = duoPassHud
		maid:Add(function()
			v17 = false
			clone.ReadyButton.Active = false
			clone.DeclineButton.Active = false

			if tween.PlaybackState == Enum.PlaybackState.Playing or tween.PlaybackState == Enum.PlaybackState.Delayed then
				tween.Completed:Wait()
			end

			tween:Destroy()
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.018, 1.22)
			}):Play()
			task.delay(0.3, function()
				clone:Destroy()
			end)
		end)
		maid:Add(clone.ReadyButton.Activated:Connect(function()
			if v13.Remotes.SendInvite:InvokeServer(p, true) then
				maid:Clean()
				v9:Open(duoPassMenu.Name)
			end
		end))
		maid:Add(clone.DeclineButton.Activated:Connect(function()
			maid:Clean()
		end))
	end)
	Players.PlayerRemoving:Connect(function(player)
		local v18 = v16[player]

		if v18 then
			v18:Destroy()
			v16[player] = nil
		end
	end)
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v18 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v18)
	end

	local v18 = "Leaderboard"
	v14.Main.Menu.TopButtons.Leaderboard.Activated:Connect(function()
		self:SetPage(v18)
	end)
	local v19 = "Gift"
	v14.Main.Menu.TopButtons.GiftShop.Activated:Connect(function()
		self:SetPage(v19)
	end)
	local v20 = "Leaderboard"
	v14.Gift.Menu.TopButtons.Leaderboard.Activated:Connect(function()
		self:SetPage(v20)
	end)
	local v21 = "Main"
	v14.Gift.Menu.TopButtons.DuoKillsPass.Activated:Connect(function()
		self:SetPage(v21)
	end)
	local v22 = "Gift"
	v14.Leaderboard.Menu.TopButtons.GiftShop.Activated:Connect(function()
		self:SetPage(v22)
	end)
	local v23 = "Main"
	v14.Leaderboard.Menu.TopButtons.DuoKillsPass.Activated:Connect(function()
		self:SetPage(v23)
	end)
	task.spawn(function()
		local policyInfo = v10:GetPolicyInfo()

		if policyInfo and policyInfo.ArePaidRandomItemsRestricted then
			v14.Main.Menu.TopButtons.GiftShop.Visible = false
			v14.Leaderboard.Menu.TopButtons.GiftShop.Visible = false
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		v9:Close(duoPassMenu.Name)
	end

	local function updateIsEnabled()
		if v9:IsOpen(duoPassMenu.Name) and not self.IsEnabled then
			close() -- equivalent call inferred; original call site unknown
		end
	end

	self.EnabledSignal:Connect(updateIsEnabled)
	task.spawn(updateIsEnabled)
	v14.Main.Menu.Close.Activated:Connect(close)
	v14.Gift.Menu.Close.Activated:Connect(close)
	v14.Leaderboard.Menu.Close.Activated:Connect(close)
	local confirmationFrame = duoPassMenu.ConfirmationFrame
	local v24 = nil
	confirmationFrame.Leave.Activated:Connect(function()
		if v13.Remotes.Disband:InvokeServer() then
			self:SetPage("Welcome")
			return
		end

		SoundService.UI.error:Play()
		self:SetPage(v24 or "Main")
		v24 = nil
	end)
	confirmationFrame.Stay.Activated:Connect(function()
		self:SetPage(v24 or "Main")
		v24 = nil
	end)
	confirmationFrame.Close.Activated:Connect(function()
		self:SetPage(v24 or "Main")
		v24 = nil
	end)

	local function leaveDuo()
		local currentPage = self:GetCurrentPage()

		if currentPage == "LeaveDuo" then
			currentPage = nil
		end

		v24 = currentPage
		self:SetPage("LeaveDuo")
	end

	v14.Main.Menu.Leave.Activated:Connect(leaveDuo)
	v14.Gift.Menu.Leave.Activated:Connect(leaveDuo)
	v14.Leaderboard.Menu.Leave.Activated:Connect(leaveDuo)
	local menu = v14.Main.Menu
	menu.PlayerOne.Counter.ProfilePicture.Headshot.Image = formatted
	menu.PlayerTwo.AddFriend.Activated:Connect(function()
		local v25 = v15:Get("DuoPass.DuoId")
		local playerByUserId = v25 and Players:GetPlayerByUserId(v25)

		if playerByUserId then
			pcall(function()
				StarterGui:SetCore("PromptSendFriendRequest", playerByUserId)
			end)
		end
	end)

	local function onDuoUpdate()
		local v25 = v15:Get("DuoPass.DuoId")
		local currentPage = self:GetCurrentPage()

		if currentPage and v14[currentPage].IsRestricted or not v25 then
			if not v25 and (not currentPage or v14[currentPage].IsRestricted) then
				self:SetPage("Welcome")
			end
		else
			self:SetPage("Main")
		end

		if v25 then
			menu.PlayerTwo.Counter.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v25}&w=100&h=100`
		else
			menu.PlayerTwo.Counter.ProfilePicture.Headshot.Image = ""
		end

		if v25 then
			local playerByUserId = Players:GetPlayerByUserId(v25)
			menu.PlayerTwo.Counter.Offlineframe.Visible = not playerByUserId
			promisify(localPlayer, v25):andThen(function(flag: boolean)
				playerByUserId = Players:GetPlayerByUserId(v25)
				menu.PlayerTwo.AddFriend.Visible = not flag and playerByUserId
				menu.PlayerTwo.Counter.Offlineframe.Visible = not playerByUserId
			end)
		else
			menu.PlayerTwo.AddFriend.Visible = false
			menu.PlayerTwo.Counter.Offlineframe.Visible = false
		end
	end

	v15:OnChange("DuoPass.DuoId", onDuoUpdate)

	local function onPlayerUpdate(p)
		local v25 = v15:Get("DuoPass.DuoId")

		if v25 and p.UserId == v25 then
			onDuoUpdate()
		end
	end

	Players.PlayerAdded:Connect(onPlayerUpdate)
	Players.PlayerRemoving:Connect(onPlayerUpdate)

	for _, v25 in Players:GetPlayers() do
		task.spawn(onPlayerUpdate, v25)
	end

	task.spawn(onDuoUpdate)
	local v25 = 0

	for k in v13.RewardsPerKills do
		if v25 < k then
			v25 = k
		end
	end

	local v26 = {}

	for k, rewardsPerKill in v13.RewardsPerKills do
		local grandReward

		if k == v25 then
			grandReward = menu.Rewards.GrandReward
		else
			grandReward = template2:Clone()
		end

		if v6:CanPreview(rewardsPerKill) then
			local v27 = rewardsPerKill
			grandReward.Inspect.Activated:Connect(function()
				v6:PreviewReward(v27, nil, nil)
			end)
		else
			grandReward.Inspect.Visible = false
		end

		grandReward.LayoutOrder = k
		grandReward.ClaimedFrame.Visible = false
		grandReward.Label.Text = rewardsPerKill.DisplayName
		grandReward.Vector.Image = rewardsPerKill.Icon or v5.Icons:GetIcon("DEFAULT_MISSING")

		if not grandReward.Parent then
			grandReward.Parent = menu.Rewards.ScrollingFrame
		end

		v26[k] = {
			Reward = rewardsPerKill,
			Frame = grandReward
		}
	end

	local function onKillsUpdate()
		local expect = v15:GetExpect("DuoPass.Kills")
		local expect2 = v15:GetExpect("DuoPass.DuoKills")
		local v27 = expect + expect2
		menu.TotalKills.Counter.Amount.Text = v5.ValueConvertor:AddCommas(v27)
		menu.PlayerOne.Counter.Amount.Text = v5.ValueConvertor:AddCommas(expect)
		menu.PlayerTwo.Counter.Amount.Text = v5.ValueConvertor:AddCommas(expect2)

		for k, v28 in v26 do
			local v29 = math.min(v27, k)
			local v30 = math.min(1 - v29 / k, 1)
			v28.Frame.ProgressBar.Holder:TweenPosition(
				UDim2.fromScale(-v30, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Sine,
				0.4,
				true
			)
			v28.Frame.ProgressBar.Holder.Fill:TweenPosition(
				UDim2.fromScale(v30, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Sine,
				0.4,
				true
			)
			v28.Frame.ProgressBar.Label.Text = `{v5.ValueConvertor:AddCommas(v29)}/{v5.ValueConvertor:AddCommas(k)}`
			v28.Frame.ClaimedFrame.Visible = k <= v27
		end
	end

	v15:OnChange("DuoPass.Kills", onKillsUpdate)
	v15:OnChange("DuoPass.DuoKills", onKillsUpdate)
	task.spawn(onKillsUpdate)
	local menu2 = v14.Gift.Menu
	local normalPresent = nil

	local function setOdds(normalPresent2)
		local v27 = {}

		for k, item in normalPresent2 do
			table.insert(v27, {
				Chance = item,
				Reward = k
			})
		end

		table.sort(v27, function(a, b)
			return a.Chance > b.Chance
		end)
		local v28 = {}

		for k, item in normalPresent2 do
			local v29 = nil

			for k2, v31 in v27 do
				if v31.Reward ~= k then
					continue
				end

				v29 = k2
				break
			end

			if not v29 then
				continue
			end

			local child = menu2.OddsList.RewardsList:FindFirstChild(v29)
			child.Vector.Image = k.Icon or v5.Icons:GetIcon("DEFAULT_MISSING")
			child.Percentage.Text = `{math.floor(item * 100) / 100}%`
			v28[v29] = true
		end

		for i = 1, 6 do
			local child = menu2.OddsList.RewardsList:FindFirstChild(i)

			if child then
				child.Visible = v28[i] ~= nil
			end
		end
	end

	menu2.GiftsList.GiftOne.ButtonsBottom.Buy.Activated:Connect(function()
		if v13.NormalPresentCredits > v15:GetExpect("Credits") then
			SoundService.UI.error:Play()
		else
			v13.Remotes.PurchaseNormalGift:InvokeServer()
		end
	end)
	menu2.GiftsList.GiftOne.InfoButton.Activated:Connect(function()
		if normalPresent == v13.NormalPresent and menu2.OddsList.Visible then
			menu2.OddsList.Visible = false
			return
		end

		normalPresent = v13.NormalPresent
		setOdds(normalPresent)
		menu2.OddsList.Visible = true
	end)
	normalPresent = v13.NormalPresent
	setOdds(normalPresent)

	local function updateRobuxPresents()
		local v27 = v15:Get("DuoPass.RobuxPresents") or 0

		if v27 > 0 then
			menu2.GiftsList.GiftTwo.ButtonsBottom.Buy.Amount.Text = `Open {v27} for Free`
		else
			local success, result = pcall(function()
				return v11:GetProductInfo(1754670954, Enum.InfoType.Product)
			end)
			menu2.GiftsList.GiftTwo.ButtonsBottom.Buy.Amount.Text = not (success and result and result.PriceInRobux) and "Failed to load" or ` {result.PriceInRobux}`
		end

		while not self.IsEnabled and not ((v15:Get("DuoPass.RobuxPresents") or 0) <= 0) and v13.Remotes.OpenRobuxGift:InvokeServer() do

		end
	end

	self.EnabledSignal:Connect(updateRobuxPresents)
	v15:OnChange("DuoPass.RobuxPresents", updateRobuxPresents)
	task.spawn(updateRobuxPresents)
	menu2.GiftsList.GiftTwo.ButtonsBottom.Buy.Activated:Connect(function()
		if (v15:Get("DuoPass.RobuxPresents") or 0) > 0 then
			v13.Remotes.OpenRobuxGift:InvokeServer()
		else
			v12:PromptPurchase(1754670954, Enum.InfoType.Product)
		end
	end)
	menu2.GiftsList.GiftTwo.InfoButton.Activated:Connect(function()
		if normalPresent == v13.RobuxPresent and menu2.OddsList.Visible then
			menu2.OddsList.Visible = false
			return
		end

		normalPresent = v13.RobuxPresent
		setOdds(normalPresent)
		menu2.OddsList.Visible = true
	end)
	menu2.GiftsList.GiftTwo.ButtonsBottom.Gift.Activated:Connect(function()
		v7:SetGift("DuoPass Golden Present")
	end)
	local v27 = v2.Client:WaitReplion("DuoPassLeaderboard")
	local v28 = v4.new()

	local function updateLeaderboard()
		v28:Clean()

		for k, v29 in v27:GetExpect("Leaderboard") do
			local clone = v28:Clone(template3)
			clone.Placement.Text = `{k}.`

			for _, leaderboardReward in v13.LeaderboardRewards do
				if not (k <= leaderboardReward.Rank) then
					continue
				end

				local createRewardFrame
				local createRewardFrame2 = createRewardFrame
				local v30 = clone

				createRewardFrame = function(reward)
					if reward.Type == "List" then
						for k2, v31 in reward.Value do
							createRewardFrame2(v31)
						end
					else
						local clone2 = v30.Items.UIListLayout.Template:Clone()
						clone2.Image = reward.Icon or v5.Icons:GetIcon("DEFAULT_MISSING")
						clone2.Visible = true
						clone2.Parent = v30.Items
					end
				end

				createRewardFrame(leaderboardReward.Reward)
			end

			clone.Holder.KillsCounter.Amount.Text = v5.ValueConvertor:AddCommas(v29.Points.TotalKills)
			clone.Holder.PlayerUsername.Text = string.gsub(v29.Name, "/", " & ")
			clone.Holder.Players.Player1.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v29.Id}&w=100&h=100`
			clone.Holder.Players.Player2.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v29.DuoId}&w=100&h=100`
			clone.Parent = v14.Leaderboard.Menu.ScrollingFrame
		end
	end

	v27:OnChange("Leaderboard", updateLeaderboard)
	task.spawn(updateLeaderboard)
end

return DuoPassController