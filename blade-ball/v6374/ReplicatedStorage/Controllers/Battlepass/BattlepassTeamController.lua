local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v5 = require3(ReplicatedStorage2.Packages.Observers)
require3(ReplicatedStorage2.Shared.Battlepass.BattlepassShopData)
require3(ReplicatedStorage2.Common.RewardInfo)
local v6 = require3(script.Parent.BattlepassViewController)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v9 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v10 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassMyTeam

if v9 == "Window" then
	battlepassMyTeam = playerGui:WaitForChild("BattlepassMyTeam")
else
	battlepassMyTeam = nil
end

local myTeam

if battlepassMyTeam then
	myTeam = battlepassMyTeam.Main.MyTeam
else
	myTeam = battlepass.Main.Background.Views.MyTeam
end

local bottom = myTeam.Bottom
local playersList = myTeam.Label.PlayersList
local text2 = 0
local _ = bottom.DailyRewards
local _ = bottom.TeamRewards
local _ = bottom.XpMulti
local sendShells = myTeam.SendShells
local invite = myTeam.Invite
local v12 = {
	playersList.Player1,
	playersList.Player2,
	playersList.Player3,
	playersList.Player4
}
local seasonPassTeam = {
	members = 0
}
seasonPassTeam.members = {}
local v13 = {
	leave = {
		Image = "rbxassetid://111383574447189",
		Hover = "rbxassetid://125207365028772",
		Text = "Leave Team",
		UIStrokeColor = Color3.fromRGB(104, 0, 0)
	},
	send = {
		Image = "rbxassetid://123918873632005",
		Hover = "rbxassetid://110366677313707",
		Text = `Send {v10.SeasonData.Currency.Name}`,
		UIStrokeColor = Color3.fromRGB(1, 71, 1)
	},
	friend = {
		Image = "rbxassetid://75609042659001",
		Hover = "rbxassetid://103016085099214",
		Text = "Add Friend",
		UIStrokeColor = Color3.fromRGB(1, 71, 1)
	}
}
local remoteEvent = v3:RemoteEvent("SeasonPassTeamInviteNotification")
local v14 = nil
local BattlepassTeamController = {}

function BattlepassTeamController:ResetMembers()
	local v15 = #seasonPassTeam.members

	for k, v16 in v12 do
		if k <= v15 then
			continue
		end

		v16.Button.Visible = false
		v16.Headshot.Image = ""
		v16.NotInServer.Visible = false
		v16.XpLabel.Visible = false
		v16.NotFriends.Visible = false
		v16.PlayerName.Text = ""
		v16:SetAttribute("UserId", nil)
	end

	invite.Visible = false
end

function BattlepassTeamController:UpdateMembers(p)
	seasonPassTeam = v14:Get("SeasonPassTeam") or {
		members = { localPlayer.UserId }
	}

	if p and not table.find(seasonPassTeam.members, p.UserId) then
		return
	end

	local members = seasonPassTeam.members
	local v15 = #members
	table.sort(members, function(a: number, _: number)
		return a == localPlayer.UserId
	end)

	if v15 < 4 then
		self:ResetMembers()
	end

	local total = 0

	for k, member in members do
		local v16 = k
		local v17 = member
		task.spawn(function()
			local v18 = v12[v16]
			local playerByUserId = Players:GetPlayerByUserId(v17)
			local v19 = false

			if v16 ~= 1 then
				local success, result = pcall(function()
					return localPlayer:IsFriendsWith(v17)
				end)

				if success then
					v19 = result
				end
			end

			local v20 = v19 and "send" or "friend"
			v18.PlayerName.Text = "[???]"
			v4:GetUsername(v17):andThen(function(text: string)
				v18.PlayerName.Text = text
			end)
			v18.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v17}&w=150&h=150`
			v18.Button.Visible = true
			v18:SetAttribute("UserId", v17)

			if v16 == 1 then
				v18.Button.Image = v13.leave.Image
				v18.Button.HoverImage = v13.leave.Hover
				v18.Button.Title.Text = v13.leave.Text
				v18.Button.Title.UIStroke.Color = v13.leave.UIStrokeColor
				v18.Button.Visible = v14:Get("SeasonPassTeam") ~= nil
			else
				v18.Button.Image = v13[v20].Image
				v18.Button.HoverImage = v13[v20].Hover
				v18.Button.Title.Text = v13[v20].Text
				v18.Button.Title.UIStroke.Color = v13[v20].UIStrokeColor
				v18.XpLabel.Visible = v19 and playerByUserId
				v18.NotInServer.Visible = not playerByUserId and v19
				v18.NotFriends.Visible = not v19
				v18.Button.Visible = v20 == "send" or playerByUserId ~= nil

				if v19 and playerByUserId then
					total += 0.5
					bottom.XpMulti.Label.Text = `+{total}x`
				end
			end
		end)
	end

	v12[2].AddPlayer.Visible = members[2] == nil
	v12[3].AddPlayer.Visible = members[3] == nil
	v12[4].AddPlayer.Visible = members[4] == nil
	bottom.XpMulti.Label.Text = `+{total}x`
end

function BattlepassTeamController:SetSendShell(instance)
	local seasonPassTeamHelpSent = v14:Get("SeasonPassTeamHelpSent")
	local _ = seasonPassTeamHelpSent and seasonPassTeamHelpSent.Amount

	if seasonPassTeamHelpSent then
		if seasonPassTeamHelpSent.Season == v10.Season then
			text2 = seasonPassTeamHelpSent.LastReset < 86400 + workspace:GetServerTimeNow() and 100 - seasonPassTeamHelpSent.Amount or 100
		end
	else
		text2 = 100
	end

	sendShells.Text.txt.Text = "Send " .. v10.SeasonData.Currency.Name
	sendShells.Text.Value.Text = text2
	sendShells.EnterFrame.TextBox.Text = ""
	sendShells.Text.PlayerName.Text = instance.PlayerName.Text
	sendShells.PlayerBox.Player.Image = instance.Headshot.Image
	sendShells.Visible = true
	sendShells:SetAttribute("TargetId", instance:GetAttribute("UserId"))
end

function BattlepassTeamController:SetUpInvite()
	local v15 = invite
	local players = v15.Players
	v5.observePlayer(function(p)
		if p == localPlayer then
			return function() end
		end

		local clone = players.UIListLayout.Player:Clone()
		clone.DisplayName.Text = p.DisplayName
		clone.PlayerName.Text = `@{p.Name}`
		clone.Name = p.Name
		clone.Parent = players
		local activatedConnection = clone.Activated:Connect(function()
			local v16, v17 = v3:Invoke("SeasonPassTeamInvite", p)

			if v16 then
				return
			end

			v2.Sounds:Play("error")
			v8:SendNotification(v17 or "Failed to send invite!")
		end)
		return function()
			clone:Destroy()
			activatedConnection:Disconnect()
		end
	end)
	local host = v15.TeammatesPanel.Host
	host.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=60&h=60`
	host.PlayerName.Text = `@{localPlayer.Name}`
	local battlepassTeamInvite = playerGui:WaitForChild("BattlepassTeamInvite")
	local v16 = nil
	battlepassTeamInvite.Main.DeclineButton.Activated:Connect(function()
		battlepassTeamInvite.Enabled = false
	end)
	battlepassTeamInvite.Main.ReadyButton.Activated:Connect(function()
		if v16 then
			local v17, v18 = v3:Invoke("SeasonPassTeamJoin", v16)

			if v17 then
				v16 = nil
			else
				v2.Sounds:Play("error")
				v8:SendNotification(v18 or "Failed to accept invite!")
				return
			end
		end

		battlepassTeamInvite.Enabled = false
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		v16 = p
		battlepassTeamInvite.Main.Invite.Text = `@{p.Name} Invited You to a Battlepass Team!`
		battlepassTeamInvite.Enabled = true
	end)
end

function BattlepassTeamController:Start()
	v14 = v.Client:WaitReplion("Data")
	self:UpdateMembers()
	self:SetUpInvite()
	sendShells.Close.Activated:Connect(function()
		sendShells.Visible = false
	end)

	for _, v15 in v12 do
		local v16 = v15
		v15.Button.Activated:Connect(function()
			if v16.Button.Image == v13.send.Image then
				self:SetSendShell(v16)
			elseif v16.Button.Image == v13.leave.Image then
				local v17, v18 = v3:Invoke("SeasonPassTeamLeave", localPlayer.UserId)

				if not v17 then
					v2.Sounds:Play("error")
					v8:SendNotification(v18 or "Failed to leave!")
				end
			else
				pcall(function()
					StarterGui:SetCore(
						"PromptSendFriendRequest",
						(Players:GetPlayerByUserId(v16:GetAttribute("UserId")))
					)
				end)
			end
		end)
	end

	for i = 2, 4 do
		v12[i].AddPlayer.Activated:Connect(function()
			invite.Visible = true
		end)
	end

	invite.CloseButton.Activated:Connect(function()
		invite.Visible = false
	end)
	v14:OnChange("SeasonPassTeamUUID", function()
		self:UpdateMembers()
	end)
	v14:OnChange("SeasonPassTeam", function()
		self:UpdateMembers()
	end)
	sendShells.SendBTN.Activated:Connect(function()
		local targetId = sendShells:GetAttribute("TargetId")
		local text = tonumber(sendShells.EnterFrame.TextBox.Text)
		local v15 = v14:Get("InfiniteBattlepass.Currency") or 0

		if not (text and targetId) then
			return
		end

		if text <= 0 then
			v2.Sounds:Play("error")
			v8:SendNotification("You can not send 0 or less!")
		elseif v15 < text then
			v2.Sounds:Play("error")
			v8:SendNotification((`You don't have enough {v10.SeasonData.Currency.Name}!`))
		elseif text2 < text then
			v2.Sounds:Play("error")
			v8:SendNotification("You can not send over your daily limit!")
		else
			local v16, _ = v3:Invoke("SeasonPassTeamGiveCurrency", targetId, text)

			if v16 then
				v8:SendNotification("Sent!")
			end

			sendShells.Visible = false
		end
	end)
	sendShells.EnterFrame.TextBox.Changed:Connect(function()
		sendShells.EnterFrame.TextBox.Text = sendShells.EnterFrame.TextBox.Text:gsub("%D", "")
	end)
	bottom.TeamRewards.ClaimedFrame.Visible = v14:Get((`SeasonPassTeamBonusInf{v10.Season}`))
	v14:OnChange(`SeasonPassTeamBonusInf{v10.Season}`, function(visible)
		bottom.TeamRewards.ClaimedFrame.Visible = visible
	end)
	pcall(function()
		StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(p)
			self:UpdateMembers(p)
		end)
	end)
	pcall(function()
		StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(p)
			self:UpdateMembers(p)
		end)
	end)
	Players.PlayerAdded:Connect(function(player)
		self:UpdateMembers(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:UpdateMembers(player)
	end)
	local timer = bottom.DailyRewards.Timer
	v2.Thread.Every(1, function()
		local seasonPassDailyReward = v14:Get("SeasonPassDailyReward")

		if seasonPassDailyReward and seasonPassDailyReward.LastTime and not seasonPassDailyReward.CanClaim then
			timer.Text = v2.ValueConvertor:FormatTimeHHMMSS(workspace:GetServerTimeNow() - seasonPassDailyReward.LastTime):upper()
		else
			timer.Text = "NOW"
		end
	end)
	v7:OnGuiOpen("Battlepass", function()
		self:UpdateMembers()
	end)

	if v9 == "Window" then
		battlepassMyTeam:GetPropertyChangedSignal("Enabled"):Connect(function()
			self:UpdateMembers()
		end)
	end

	v2.Thread.Every(60, function()
		local v15

		if battlepassMyTeam then
			v15 = battlepassMyTeam.Enabled
		else
			v15 = battlepass.Enabled
		end

		if v15 then
			self:UpdateMembers()
		end
	end)

	if battlepassMyTeam then
		battlepassMyTeam.Main.Close.Activated:Connect(function()
			v6:OpenView("Battlepass")
		end)
	end

	if battlepassMyTeam then
		local counter = battlepassMyTeam.Main.Counter
		counter.Icon.Image = v10.SeasonData.Currency.Icon

		local function updateCounter()
			local v15 = v14:Get("InfiniteBattlepass.Currency") or 0
			counter.Amount.Text = v2.ValueConvertor:AddCommas(v15)
			counter.Visible = not myTeam.Invite.Visible
		end

		if counter:FindFirstChild("Add") then
			counter.Add.Activated:Connect(function()
				if v9 == "ShowRoom" then
					battlepassCurrencyShop.Enabled = true
				else
					v7:Open(battlepassCurrencyShop.Name, nil, true)
				end
			end)
		end

		v14:OnChange("InfiniteBattlepass.Currency", updateCounter)
		myTeam.Invite:GetPropertyChangedSignal("Visible"):Connect(updateCounter)
		task.spawn(updateCounter)
	end
end

return BattlepassTeamController