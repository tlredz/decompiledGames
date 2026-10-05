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
game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Promise)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Controllers.GiftingController)
local v8 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v9 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Policy)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v10 = require3(ReplicatedStorage2.Shared.TrioPassData)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local trioPassMenu = playerGui:WaitForChild("TrioPassMenu")
local trioPassHud = playerGui:WaitForChild("TrioPassHud")
local template = trioPassMenu.InviteList.ScrollingFrame.Template
template.Parent = nil
local invitePrompt = trioPassHud.InvitePrompt
invitePrompt.Parent = nil
local template1 = trioPassMenu.MainFrame.Pass.Rewards.ScrollingFrame.Template1
template1.Parent = nil
local template2 = trioPassMenu.MainFrame.Pass.Rewards.ScrollingFrame.Template2
template2.Parent = nil
local template3 = trioPassMenu.MainFrame.Leaderboard.ScrollingFrame.Template
template3.Parent = nil
local v11 = {
	InviteList = {
		Menu = trioPassMenu.InviteList,
		UseMainFrame = false,
		IsRestrictedPage = false
	},
	Invite = {
		Menu = trioPassMenu.InviteFriendsFrame,
		UseMainFrame = false,
		IsRestrictedPage = false
	},
	Main = {
		Menu = trioPassMenu.MainFrame.Pass,
		UseMainFrame = true,
		IsRestrictedPage = true
	},
	Leaderboard = {
		Menu = trioPassMenu.MainFrame.Leaderboard,
		UseMainFrame = true,
		IsRestrictedPage = true
	},
	LeaveTrio = {
		Menu = trioPassMenu.ConfirmationFrame,
		UseMainFrame = false,
		IsRestrictedPage = true
	}
}
v.promisify(function(object, userId)
	if typeof(userId) == "Instance" then
		userId = userId.UserId
	end

	return object:IsFriendsWith(userId)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function decode(p: number)
	return {
		TotalKills = p % 1e18 // 1000000000000,
		SecondPlayerKills = p % 1000000000000 // 1000000,
		FirstPlayerKills = p % 1000000 // 1
	}
end

local TrioPassController = {}
TrioPassController.OnPageChange = v3.new()
TrioPassController.IsEnabled = false
TrioPassController.EnabledSignal = v3.new()

function TrioPassController:GetCurrentPage()
	for k, v12 in v11 do
		if v12.Menu.Visible then
			return k
		end
	end

	return nil
end

function TrioPassController:SortUserIds(items)
	local result = {}

	for _, item in items do
		table.insert(result, item)
	end

	table.sort(result, function(a: number, b: number)
		return math.abs(a) < math.abs(b)
	end)
	return result
end

function TrioPassController:SetPage(p: string)
	self:GetCurrentPage()
	local replion = v2.Client:GetReplion("Data")

	if v11[p] and v11[p].IsRestrictedPage == false and replion then
		p = #(replion:Get("TrioPass.Players") or {}) >= 3 and "Main" or p
	end

	local v12 = p == "Invite" and "Main" or p
	local visible = false

	for k, v14 in v11 do
		visible = v14.UseMainFrame and v12 == k and true or visible
		v14.Menu.Visible = v12 == k
	end

	trioPassMenu.MainFrame.Visible = visible
	local v14 = replion and #(replion:Get("TrioPass.Players") or {}) >= 3
	local menu = v11.Invite.Menu
	menu.Visible = v12 == "Main" and not v14
	trioPassMenu.InviteFriendsOverlay.Visible = v11.Invite.Menu.Visible
	v10.Remotes.SetReplication:FireServer(v12 == "Leaderboard")
	self.OnPageChange:Fire(v12)
end

function TrioPassController:Start()
	local function pageButton(p: string)
		return function()
			self:SetPage(p)
		end
	end

	trioPassHud.Enabled = true
	local v12 = v2.Client:WaitReplion("Data")
	self:SetPage("Main")
	v9:OnGuiOpen(trioPassMenu.Name, function()
		self:SetPage("Main")
	end)
	v9:OnGuiClose(trioPassMenu.Name, function()
		v10.Remotes.SetReplication:FireServer(false)
	end)

	local function updateFlags()
		local isEnabled = self.IsEnabled
		self.IsEnabled = v8:GetKey("SilentVeilTrioPassEnabled") == true and workspace:GetServerTimeNow() < (v8:GetKey("SilentVeilTrioPassEndTime") or 0)

		if self.IsEnabled ~= isEnabled then
			self.EnabledSignal:Fire(self.IsEnabled)
		end
	end

	v5.Thread.Every(1, updateFlags)
	v8.DataUpdatedEvent:Connect(updateFlags)
	task.spawn(updateFlags)
	v11.Invite.Menu.YourTeam["1"].Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
	v11.Invite.Menu.Close.Activated:Connect(function()
		v9:Close(trioPassMenu.Name)
	end)
	v11.Invite.Menu.Invite.Activated:Connect(function()
		self:SetPage("InviteList")
	end)
	v11.Invite.Menu.YourTeam["2"].Add.Activated:Connect(function()
		self:SetPage("InviteList")
	end)
	v11.Invite.Menu.YourTeam["3"].Add.Activated:Connect(function()
		self:SetPage("InviteList")
	end)
	v11.InviteList.Menu.Message.Visible = true
	v11.InviteList.Menu.Close.Activated:Connect(function()
		self:SetPage("Main")
	end)
	local v13 = {}

	local function onPlayerAdded(instance)
		if instance == localPlayer then
			return
		end

		local maid = v4.new()
		v11.InviteList.Menu.Message.Visible = false
		maid:Add(function()
			v11.InviteList.Menu.Message.Visible = #Players:GetPlayers() - 1 <= 0
		end)
		local clone = maid:Clone(template)
		clone.Username.Text = instance.Name
		clone.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={instance.UserId}&w=100&h=100`
		clone.Parent = v11.InviteList.Menu.ScrollingFrame
		local v14 = false

		local function updateInviteStatus()
			local isInTrio = instance:GetAttribute("IsInTrio")
			local canTrioInvite = instance:GetAttribute("CanTrioInvite")
			clone.Invite.ImageTransparency = (isInTrio == true or isInTrio == nil) and 0.8 or 0
			clone.Invite.Label.Text = isInTrio == true and "In Trio" or isInTrio == nil and "Loading" or v14 and "Invited" or canTrioInvite and "Invite" or "Can't Invite"
		end

		maid:Connect(instance:GetAttributeChangedSignal("CanTrioInvite"), updateInviteStatus)
		maid:Connect(instance:GetAttributeChangedSignal("IsInTrio"), updateInviteStatus)
		task.spawn(updateInviteStatus)
		maid:Add(clone.Invite.Activated:Connect(function()
			if not instance:GetAttribute("CanTrioInvite") or instance:GetAttribute("IsInTrio") then
				return
			end

			local v15, v16 = v10.Remotes.SendInvite:InvokeServer(instance, false)

			if v15 then
				v14 = true
				updateInviteStatus()
				task.delay(v16 - workspace:GetServerTimeNow(), function()
					v14 = false
					updateInviteStatus()
				end)
			end
		end))
		maid:Add(v10.Remotes.RemoveInvite.OnClientEvent:Connect(function(p)
			if p == instance and v14 then
				v14 = false
				updateInviteStatus()
			end
		end))
		v13[instance] = maid
	end

	local maid = v4.new()
	local v14 = false
	v10.Remotes.InviteReceived.OnClientEvent:Connect(function(p, p2: number?)
		while localPlayer.Character.Parent ~= workspace.Dead do
			task.wait()
		end

		while maid._cleaning do
			task.wait()
		end

		local v15 = v14
		maid:Clean()
		v14 = true

		if not p then
			return
		end

		maid:Add(function()
			v10.Remotes.RemoveInvite:FireServer(p)
		end)
		maid:Add(task.delay(p2 - workspace:GetServerTimeNow(), function()
			maid:Clean()
		end))
		local clone = invitePrompt:Clone()
		clone.Title.Text = "Trio Invite"
		clone.Invite.Text = `{p.Name} Invited You to join their Trio!`
		clone.Position = UDim2.fromScale(-0.23, 0.959)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, v15 and 0.27 or 0),
			{
				Position = UDim2.fromScale(0.018, 0.959)
			}
		)
		tween:Play()
		clone.Parent = trioPassHud
		maid:Add(function()
			v14 = false
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
			if v10.Remotes.SendInvite:InvokeServer(p, true) then
				maid:Clean()
				v9:Open(trioPassMenu.Name)
			end
		end))
		maid:Add(clone.DeclineButton.Activated:Connect(function()
			maid:Clean()
		end))
	end)
	Players.PlayerRemoving:Connect(function(player)
		local v15 = v13[player]

		if v15 then
			v15:Destroy()
			v13[player] = nil
		end
	end)
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v15 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v15)
	end

	local v15 = "Leaderboard"
	v11.Main.Menu.TopButtons.Leaderboard.Activated:Connect(function()
		self:SetPage(v15)
	end)
	local v16 = "Main"
	v11.Leaderboard.Menu.TopButtons.TrioKillsPass.Activated:Connect(function()
		self:SetPage(v16)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		v9:Close(trioPassMenu.Name)
	end

	local function updateIsEnabled()
		if v9:IsOpen(trioPassMenu.Name) and not self.IsEnabled then
			close() -- equivalent call inferred; original call site unknown
		end
	end

	self.EnabledSignal:Connect(updateIsEnabled)
	task.spawn(updateIsEnabled)
	v11.Main.Menu.Close.Activated:Connect(close)
	v11.Leaderboard.Menu.Close.Activated:Connect(close)
	local confirmationFrame = trioPassMenu.ConfirmationFrame
	local v17 = nil
	confirmationFrame.Leave.Activated:Connect(function()
		if v10.Remotes.Disband:InvokeServer() then
			self:SetPage("Main")
			return
		end

		SoundService.UI.error:Play()
		self:SetPage(v17 or "Main")
		v17 = nil
	end)
	confirmationFrame.Stay.Activated:Connect(function()
		self:SetPage(v17 or "Main")
		v17 = nil
	end)
	confirmationFrame.Close.Activated:Connect(function()
		self:SetPage(v17 or "Main")
		v17 = nil
	end)

	local function leaveTrio()
		local currentPage = self:GetCurrentPage()

		if currentPage == "LeaveTrio" then
			currentPage = nil
		end

		v17 = currentPage
		self:SetPage("LeaveTrio")
	end

	v11.Main.Menu.Leave.Activated:Connect(leaveTrio)
	v11.Leaderboard.Menu.Leave.Activated:Connect(leaveTrio)
	local menu = v11.Main.Menu
	menu.Players.LocalPlayer.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
	menu.Players.LocalPlayer.PlayerName.Text = localPlayer.Name

	local function onTrioUpdate()
		local v18 = v12:Get("TrioPass.Players")
		local clone

		if v18 then
			clone = table.clone(v18)
		end

		if v18 and #v18 == 0 then
			v18 = nil
		elseif v18 and #v18 < 3 then
			v18 = nil
		end

		local currentPage = self:GetCurrentPage()

		if not currentPage or currentPage == "InviteList" and v18 then
			self:SetPage("Main")
		end

		if v18 then
			v11.Invite.Menu.Visible = false
			trioPassMenu.InviteFriendsOverlay.Visible = v11.Invite.Menu.Visible
			local sortUserIds = self:SortUserIds(v18)

			for _, child in menu.Players:GetChildren() do
				local name = tonumber(child.Name)

				if not name then
					continue
				end

				local sortUserId = sortUserIds[name]
				child.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={math.abs(sortUserId)}&w=100&h=100`

				if sortUserId >= -3 then
					child.PlayerName.Text = "Loading..."

					if sortUserId > 0 then
						local v19 = child
						v6:GetUsername(sortUserId):andThen(function(text: string)
							v19.PlayerName.Text = text
						end)
					else
						child.PlayerName.Text = `Player{math.abs(sortUserId)}`
					end
				end

				child.UserLeft.Visible = sortUserId < -3
				child.Visible = true
			end

			menu.Players.LocalPlayer.Visible = false
		else
			menu.Players.LocalPlayer.Visible = true

			for _, child in menu.Players:GetChildren() do
				if tonumber(child.Name) then
					child.Visible = false
				end
			end
		end

		if v18 then
			v11.Main.Menu.Leave.Visible = true
			v11.Leaderboard.Menu.Leave.Visible = true
		else
			v11.Main.Menu.Leave.Visible = false
			v11.Leaderboard.Menu.Leave.Visible = false
		end

		if clone then
			local sortUserIds = self:SortUserIds(clone)
			local index = table.find(sortUserIds, localPlayer.UserId)

			if index then
				table.remove(sortUserIds, index)
			end

			for i = 1, 2 do
				local sortUserId = sortUserIds[i]
				local v19 = v11.Invite.Menu.YourTeam[i + 1]
				v19.Headshot.Image = not sortUserId and "" or `rbxthumb://type=AvatarHeadShot&id={math.abs(sortUserId)}&w=100&h=100`
				v19.HoverImage = "rbxassetid://131716186918910"
				v19.Image = "rbxassetid://80844669979306"
				v19.Add.Visible = not sortUserId
			end
		else
			local v19 = v11.Invite.Menu.YourTeam[2]
			v19.Headshot.Image = ""
			v19.HoverImage = "rbxassetid://87079562812709"
			v19.Image = "rbxassetid://81477580179569"
			v19.Add.Visible = true
			local v20 = v11.Invite.Menu.YourTeam[3]
			v20.Headshot.Image = ""
			v20.HoverImage = "rbxassetid://87079562812709"
			v20.Image = "rbxassetid://81477580179569"
			v20.Add.Visible = true
		end
	end

	v12:OnDescendantChange("TrioPass", onTrioUpdate)
	v12:OnChange("TrioPass.Players", onTrioUpdate)
	Players.PlayerAdded:Connect(onTrioUpdate)
	Players.PlayerRemoving:Connect(onTrioUpdate)
	task.spawn(onTrioUpdate)
	local v18 = 0

	for k in v10.RewardsPerKills do
		if v18 < k then
			v18 = k
		end
	end

	local v19 = {}
	local v20 = {}

	for k, rewardsPerKill in v10.RewardsPerKills do
		table.insert(v19, {
			Kills = k,
			Reward = rewardsPerKill
		})
	end

	table.sort(v19, function(a, b)
		return a.Kills < b.Kills
	end)

	for k, v21 in v19 do
		local kills = v21.Kills
		local reward = v21.Reward
		local grandReward

		if kills == v18 then
			grandReward = menu.Rewards.GrandReward
		elseif k % 2 == 0 then
			grandReward = template2:Clone()
		else
			grandReward = template1:Clone()
		end

		grandReward.LayoutOrder = kills
		grandReward.ClaimedFrame.Visible = false
		grandReward.Label.Text = reward.DisplayName
		grandReward.Vector.Image = reward.Icon or v5.Icons:GetIcon("DEFAULT_MISSING")

		if not grandReward.Parent then
			grandReward.Parent = menu.Rewards.ScrollingFrame
		end

		if v7:CanPreview(reward) then
			local reward2 = reward
			grandReward.Inspect.Activated:Connect(function()
				v7:PreviewReward(reward2, nil, nil)
			end)
		else
			grandReward.Inspect.Visible = false
		end

		v20[kills] = {
			Reward = reward,
			Frame = grandReward
		}
	end

	local function onKillsUpdate()
		local v22 = decode(v12:Get("TrioPass.EncodedKills") or 0) -- equivalent call inferred; original call site unknown
		local firstPlayerKills = v22.FirstPlayerKills
		local secondPlayerKills = v22.SecondPlayerKills
		local totalKills = v22.TotalKills
		local v23 = totalKills - secondPlayerKills - firstPlayerKills
		menu.TotalAmount.Text = v5.ValueConvertor:AddCommas(totalKills)
		menu.Players["1"].Amount.Text = v5.ValueConvertor:AddCommas(firstPlayerKills)
		menu.Players["2"].Amount.Text = v5.ValueConvertor:AddCommas(secondPlayerKills)
		menu.Players["3"].Amount.Text = v5.ValueConvertor:AddCommas(v23)

		for k, v24 in v20 do
			local v25 = math.min(totalKills, k)
			local v26 = math.min(v25 / k, 1)
			v24.Frame.ProgressBar.Fill:TweenSize(
				UDim2.fromScale(v26, 1),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Sine,
				0.4,
				true
			)
			v24.Frame.ProgressBar.Label.Text = `{v5.ValueConvertor:AddCommas(v25)}/{v5.ValueConvertor:AddCommas(k)}`
			v24.Frame.ClaimedFrame.Visible = k <= totalKills
		end
	end

	v12:OnChange("TrioPass.Kills", onKillsUpdate)
	v12:OnChange("TrioPass.EncodedKills", onKillsUpdate)
	task.spawn(onKillsUpdate)
	local v21 = v2.Client:WaitReplion("TrioPassLeaderboard")
	local v22 = v4.new()

	local function updateLeaderboard()
		v22:Clean()

		for k, v23 in v21:GetExpect("Leaderboard") do
			local clone = v22:Clone(template3)
			clone.Placement.Text = `{k}.`
			clone.Holder.Item2.Visible = k <= 3
			clone.Holder.Item1.Visible = k <= 50
			local v24 = string.split(v23.Name, "/")

			for i = #v24, 1, -1 do
				if v23.Players[i] <= 0 then
					table.remove(v24, i)
				end
			end

			clone.Holder.KillsCounter.Text = v5.ValueConvertor:AddCommas(v23.Points.TotalKills)
			clone.Holder.PlayerUsername.Text = table.concat(v24, " & ")

			for k2, player in v23.Players do
				clone.Holder.Players[k2].Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={math.abs(player)}&w=100&h=100`
				clone.Holder.Players[k2].Visible = player >= -3
			end

			clone.Parent = v11.Leaderboard.Menu.ScrollingFrame
		end
	end

	v21:OnChange("Leaderboard", updateLeaderboard)
	task.spawn(updateLeaderboard)
end

return TrioPassController