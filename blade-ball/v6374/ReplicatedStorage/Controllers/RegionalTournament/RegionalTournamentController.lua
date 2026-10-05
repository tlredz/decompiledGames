local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Charm)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v7 = require3(ReplicatedStorage2.Shared.RegionalTournament.RegionalTournamentData)
local v8 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v9 = require3(ReplicatedStorage2.Shared.CountriesToRegions)
local v10 = require3("../NotificationController")
local remoteEvent = v2:RemoteEvent("RegionalTournamentStarted")
local remoteEvent2 = v2:RemoteEvent("RegionalTournament/Teleport")
local remoteEvent3 = v2:RemoteEvent("RegionalTournament/SetFocus")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local regionalTournament = playerGui.RegionalTournament
local regionalTournamentPopups = playerGui.RegionalTournamentPopups
local regionalTournamentEnd = playerGui.RegionalTournamentEnd
local startedTournament = regionalTournamentPopups.StartedTournament
local selectRegion = regionalTournament.SelectRegion
local invitePlayer = regionalTournament.InvitePlayer
local yourTeam = regionalTournament.YourTeam
local tournamentInfo = regionalTournamentPopups.TournamentInfo
local invite = regionalTournamentPopups.Invite
local thread = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = {}
local atom = v3.atom(nil)
local atom2 = v3.atom(nil)
local RegionalTournamentController = {}

function RegionalTournamentController:UpdatePlayersInParty(list)
	for i = 1, 2 do
		local v15 = list[i]
		local child = yourTeam.Middle.Party:FindFirstChild((`Player_{i}`))

		if not child then
			continue
		end

		local v16 = not v12 or v12:Get("owner") == localPlayer

		if i > 1 then
			child.PlayerIcon.Invite.Visible = v16 and not v15
			child.LeaveButton.Visible = v15 ~= nil
		end

		child.DisplayName.Title.Text = not v15 and "" or v15.DisplayName or ""
		child.Username.Title.Text = not v15 and "" or `@{v15.Name}` or ""
		child.PlayerIcon.Thumbnail.Image = v15 and `rbxthumb://type=AvatarHeadShot&id={v15.UserId}&w=100&h=100` or ""
	end
end

function RegionalTournamentController:UpdatePartyReplion(object2)
	if not object2 then
		return
	end

	v12 = object2
	v6.observeReplionPath(object2, "players", function(p)
		self:UpdatePlayersInParty(p)
	end)
	local v15 = object2:Get("owner") == localPlayer

	local function updateInQueue()
		local inQueue = object2:Get("inQueue")
		local regionalTournamentRegion = localPlayer:GetAttribute("RegionalTournamentRegion") or "???"
		yourTeam.Information.Leave.Visible = v15 and inQueue
		yourTeam.Information.Queue.Visible = v15 and not inQueue
		yourTeam.Middle.Party.Player_2.LeaveButton.Main.Text.Text = v15 and "Kick" or "Leave"
		local textLabel = yourTeam.Information.TextLabel
		local text

		if inQueue then
			text = `You have entered the {regionalTournamentRegion} Regional Tournament!`
		else
			text = `Join the {regionalTournamentRegion} Regional Tournament!`
		end

		textLabel.Text = text
	end

	v6.observeReplionPath(object2, "inQueue", updateInQueue)
	local regionalTournamentRegionChangedConnection = localPlayer:GetAttributeChangedSignal("RegionalTournamentRegion"):Connect(updateInQueue)
	object2:BeforeDestroy(function()
		regionalTournamentRegionChangedConnection:Disconnect()
	end)
end

function RegionalTournamentController:CreatePlayerFrame(player)
	if player == localPlayer or v14[player] then
		return
	end

	local maid = v4.new()
	v14[player] = maid
	maid:Add(function()
		v14[player] = nil
	end)
	local clone = maid:Clone(invitePlayer.ScrollingFrame.UIGridLayout.Template)
	clone.Name = player.Name
	clone.DisplayName.Title.Text = player.DisplayName
	clone.Username.Title.Text = `@{player.Name}`
	clone.ImageLabel.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=100&h=100`

	local function updateCardVisibility()
		local v15 = player:GetAttribute("RegionalTournamentRegion") == localPlayer:GetAttribute("RegionalTournamentRegion")
		local v16 = player:GetAttribute("InRegionalTournamentParty") ~= nil

		if v15 and not v16 then
			clone.Visible = true
		else
			clone.Visible = false
		end
	end

	localPlayer:GetAttributeChangedSignal("RegionalTournamentRegion"):Connect(updateCardVisibility)
	player:GetAttributeChangedSignal("InRegionalTournamentParty"):Connect(updateCardVisibility)
	player:GetAttributeChangedSignal("RegionalTournamentRegion"):Connect(updateCardVisibility)
	clone.Invite.Activated:Connect(function()
		if localPlayer:GetAttribute("InRegionalTournamentQueue") then
			v10:SendNotification("You need to leave the queue to invite a player!")
			ReplicatedStorage2.Misc.error:Play()
		elseif player:GetAttribute("InRegionalTournamentQueue") then
			v10:SendNotification("This player is already in the queue!")
			ReplicatedStorage2.Misc.error:Play()
		elseif player:GetAttribute("InRegionalTournamentParty") then
			v10:SendNotification("This player is already in a party!")
			ReplicatedStorage2.Misc.error:Play()
		else
			local v15, v16 = v2:Invoke("SendRegionalTournamentInvite", player)

			if not v15 then
				if v16 then
					v10:SendNotification(v16)
				end

				ReplicatedStorage2.Misc.error:Play()
			end
		end
	end)
	clone.Parent = invitePlayer.ScrollingFrame
end

function RegionalTournamentController:Hide()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, v15 in v14 do
		assert(v15, "LUAU")
		v15:Destroy()
	end

	v14 = {}
	v8:Close("RegionalTournament")
	atom2(nil)
	v11 = nil
end

function RegionalTournamentController:UpdateCountry(p)
	local v15 = v9[p] or "NA"

	if not table.find(v7.Regions, v15) then
		v15 = v7.RegionsRemap[v15] or "NA"
	end

	for _, button in selectRegion.Regions:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		button.Locked.Visible = button.Name ~= v15
		button.Active = button.Name == v15
	end
end

function RegionalTournamentController.Init(_) end

function RegionalTournamentController:Start()
	v3.effect(function()
		local v15 = atom()

		for _, child in regionalTournament:GetChildren() do
			child.Visible = child.Name == v15
		end
	end)
	v3.effect(function()
		local v15 = atom2()

		for _, child in regionalTournamentPopups:GetChildren() do
			child.Visible = child.Name == v15
		end
	end)
	startedTournament.No.Activated:Connect(function()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		atom2(nil)
		regionalTournament.Enabled = false
	end)
	startedTournament.Yes.Activated:Connect(function()
		atom2(nil)
		atom("SelectRegion")
		v8:Open("RegionalTournament", true)
	end)
	selectRegion.Header.Close.Activated:Connect(function()
		v8:Close("RegionalTournament")
	end)
	local flag = false

	local function invokeRemoteFunction(p: string, ...)
		if flag then
			ReplicatedStorage2.Misc.error:Play()
			return false
		end

		flag = true
		local v15, v16 = v2:Invoke(p, ...)
		flag = false

		if not v15 then
			ReplicatedStorage2.Misc.error:Play()

			if v16 then
				v10:SendNotification(v16)
			end
		end

		return v15, v16
	end

	for _, button in selectRegion.Regions:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		if table.find(v7.Regions, button.Name) then
			local v15 = button
			button.Activated:Connect(function()
				if v15.Locked.Visible then
					ReplicatedStorage2.Misc.error:Play()
					return
				end

				if not invokeRemoteFunction("RegionalTournament/SelectRegion", v15.Name) then
					return
				end

				self:UpdatePlayersInParty({ localPlayer })
				selectRegion.Visible = false
				yourTeam.Visible = true
			end)
		else
			button.Visible = false
		end
	end

	local function updatePlayerRegion()
		local regionalTournamentRegion = localPlayer:GetAttribute("RegionalTournamentRegion")
		v13 = regionalTournamentRegion

		if not regionalTournamentRegion then
			self:Hide()
			return
		end

		yourTeam.Information.TextLabel.Text = `Join the {regionalTournamentRegion} Regional Tournament!`
		yourTeam.TournamentInfo.Rules.Region.Text = `Region: {v7.RegionDisplayNames[regionalTournamentRegion] or regionalTournamentRegion}`
		tournamentInfo.TextLabel.Text = `Entered into: {regionalTournamentRegion} Regional Tournament`
	end

	yourTeam.TournamentInfo.Rules.Competitors.Text = "Competitors: ???"
	v.Client:AwaitReplion("RegionalTournamentCompetitors", function(object2)
		local function updateCompetitors()
			local regionalTournamentRegion = localPlayer:GetAttribute("RegionalTournamentRegion")

			if not regionalTournamentRegion then
				return
			end

			local v15 = object2:Get({ "Regions", regionalTournamentRegion })
			yourTeam.TournamentInfo.Rules.Competitors.Text = `Competitors: {not v15 and "???" or v5.ValueConvertor:AddCommas(v15) or "???"}`

			if v15 then
				yourTeam.TournamentInfo.Rules.Competitors.Visible = true
			end
		end

		object2:OnDescendantChange("Regions", updateCompetitors)
		localPlayer:GetAttributeChangedSignal("RegionalTournamentRegion"):Connect(updateCompetitors)
		task.spawn(updateCompetitors)
	end)
	updatePlayerRegion()
	localPlayer:GetAttributeChangedSignal("RegionalTournamentRegion"):Connect(updatePlayerRegion)
	localPlayer:GetAttributeChangedSignal("InRegionalTournamentParty"):Connect(function()
		if atom() == "InvitePlayer" then
			atom("YourTeam")
		end
	end)
	localPlayer:GetAttributeChangedSignal("InRegionalTournamentQueue"):Connect(function()
		if atom() == "InvitePlayer" then
			atom("YourTeam")
		end
	end)
	yourTeam.Header.Close.Activated:Connect(function()
		v8:Close("RegionalTournament")
	end)
	yourTeam.Information.Queue.Activated:Connect(function()
		invokeRemoteFunction("JoinRegionalTournamentQueue")
	end)
	yourTeam.Information.Leave.Activated:Connect(function()
		invokeRemoteFunction("LeaveRegionalTournamentQueue")
	end)
	v.Client:OnReplionAddedWithTag("RegionalTournamentParty", function(p)
		self:UpdatePartyReplion(p)
	end)
	v.Client:OnReplionRemovedWithTag("RegionalTournamentParty", function()
		yourTeam.Information.Queue.Visible = true
		yourTeam.Information.Leave.Visible = false
		yourTeam.Information.TextLabel.Text = `Join the {v13 or "???"} Regional Tournament!`
		v12 = nil
		self:UpdatePlayersInParty({ localPlayer })
	end)

	for _, frame in yourTeam.Middle.Party:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v15 = tonumber(string.match(frame.Name, "%d+"))

		if not v15 then
			continue
		end

		local invite2 = frame.PlayerIcon:FindFirstChild("Invite")

		if invite2 then
			invite2.Activated:Connect(function()
				if not localPlayer:GetAttribute("InRegionalTournamentParty") then
					atom("InvitePlayer")
					return
				end

				v10:SendNotification("You need to leave the queue to invite a player!")
				ReplicatedStorage2.Misc.error:Play()
			end)
		end

		local leaveButton = frame:FindFirstChild("LeaveButton")

		if not leaveButton then
			continue
		end

		local v16 = v15
		leaveButton.Activated:Connect(function()
			if not v12 then
				return
			end

			local v17 = v12:Get("owner") == localPlayer
			local players = v12:Get("players") or {}

			if v17 then
				local player = players[v16]

				if player then
					local v18, v19 = v2:Invoke("RegionalTournament/Kick", player)

					if not v18 then
						if v19 then
							v10:SendNotification(v19)
						end

						ReplicatedStorage2.Misc.error:Play()
					end
				else
					v10:SendNotification("Something went wrong...")
					ReplicatedStorage2.Misc.error:Play()
				end
			else
				local v18, v19 = v2:Invoke("LeaveRegionalTournamentParty")

				if not v18 then
					if v19 then
						v10:SendNotification(v19)
					end

					ReplicatedStorage2.Misc.error:Play()
				end
			end
		end)
	end

	local v15 = nil
	invitePlayer.Header.Close.Activated:Connect(function()
		atom("YourTeam")
	end)
	v2:Connect("RegionalTournamentInviteNotification", function(instance)
		if v15 == instance then
			return
		end

		local regionalTournamentRegion = instance:GetAttribute("RegionalTournamentRegion")

		if not regionalTournamentRegion then
			return
		end

		v15 = instance
		invite.Description.Text = `{instance.DisplayName} Invited you to join the {regionalTournamentRegion} Regional Tournament!`
		ReplicatedStorage2.Misc.pop:Play()
		atom2("Invite")
	end)
	invite.Yes.Activated:Connect(function()
		if not v15 then
			ReplicatedStorage2.Misc.error:Play()
			return
		end

		if localPlayer:GetAttribute("RegionalTournamentRegion") and not v8:IsOpen("RegionalTournament") then
			atom2("TournamentInfo")
		else
			atom2(nil)
		end

		local v16, v17 = v2:Invoke("JoinRegionalTournamentParty", v15)

		if not v16 then
			if v17 then
				v10:SendNotification(v17)
			end

			ReplicatedStorage2.Misc.error:Play()
		end

		v15 = nil
	end)
	invite.No.Activated:Connect(function()
		v15 = nil

		if localPlayer:GetAttribute("RegionalTournamentRegion") and not v8:IsOpen("RegionalTournament") then
			atom2("TournamentInfo")
		else
			atom2(nil)
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		if not v11 then
			return
		end

		self:CreatePlayerFrame(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		if player ~= v15 then
			return
		end

		v15 = nil

		if atom2() == "Invite" then
			atom2(nil)
		end
	end)
	tournamentInfo.ViewMore.Activated:Connect(function()
		v8:Open("RegionalTournament")
	end)
	v8:OnGuiOpen("RegionalTournament", function()
		remoteEvent3:FireServer(true)
	end)
	v8:OnGuiClose("RegionalTournament", function()
		remoteEvent3:FireServer(false)
	end)
	v8:OnGuiOpen("RegionalTournament", function()
		if (v13 or localPlayer:GetAttribute("InRegionalTournamentQueue")) and atom2() == "TournamentInfo" then
			atom2(nil)
		end
	end)
	v8:OnGuiClose("RegionalTournament", function()
		if not (v13 or localPlayer:GetAttribute("InRegionalTournamentQueue")) then
			return
		end

		if atom2() == nil then
			if v15 then
				atom2("Invite")
			else
				atom2("TournamentInfo")
			end
		end
	end)
	remoteEvent.OnClientEvent:Connect(function(data)
		if not data then
			self:Hide()
			return
		end

		if v11 and v11.startTimestamp == data.startTimestamp then
			return
		end

		for _, v16 in Players:GetPlayers() do
			if v16 ~= localPlayer then
				self:CreatePlayerFrame(v16)
			end
		end

		v8:Close("RegionalTournament")
		v11 = data
		yourTeam.Prize.RewardName.Title.Text = data.reward.name
		local icon = yourTeam.Prize.Vector.Icon
		local swordIcon

		if data.reward.type == "Sword" then
			swordIcon = v5.Icons:GetSwordIcon(data.reward.name)
		elseif data.reward.type == "Emote" then
			swordIcon = v5.Icons:GetEmoteIcon(data.reward.name)
		elseif data.reward.type == "Finisher" then
			swordIcon = v5.Icons:GetFinisherIcon(data.reward.name)
		elseif data.reward.type == "Ability" then
			swordIcon = v5.Icons:GetAbilityIcon(data.reward.name)
		elseif data.reward.type == "Explosion" then
			swordIcon = v5.Icons:GetExplosionIcon(data.reward.name)
		else
			swordIcon = v5.Icons:GetIcon("DEFAULT_MISSING")
		end

		icon.Image = swordIcon
		startedTournament.Description.Text = `@{data.host} Started a Regional Tournament<br/>Would you like to participate?`

		if thread then
			task.cancel(thread)
		end

		thread = task.spawn(function()
			while true do
				local serverTimeNow = workspace:GetServerTimeNow()
				local startTimestamp = data.startTimestamp

				if serverTimeNow < startTimestamp then
					local v16 = startTimestamp - serverTimeNow
					local formatTime = v5.ValueConvertor:FormatTime(v16)
					startedTournament.TextLabel.Text = `Limited Time Event  🕒 {formatTime}`
					yourTeam.TournamentInfo.StartingIn.Text = `Starting in: {formatTime}`
					tournamentInfo.Description.Text = `Hosted by: @{data.host}<br/>Starting in: {formatTime}`
					invite.TextLabel.Text = `Limited Time Event  🕒 {formatTime}`
				elseif startTimestamp <= serverTimeNow then
					startedTournament.TextLabel.Text = "Starting soon!"
					yourTeam.TournamentInfo.StartingIn.Text = "Starting soon!"
					tournamentInfo.Description.Text = `Hosted by: @{data.host}<br/>Starting soon!`
					thread = nil

					if localPlayer:GetAttribute("InRegionalTournamentQueue") then
						break
					end

					atom2(nil)
					v8:Close("RegionalTournament")
					break
				end

				task.wait(1)
			end
		end)
		ReplicatedStorage2.Misc.pop:Play()
		atom("SelectRegion")
		atom2("StartedTournament")
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function configureRegionalTournamentMatchReplion(object2)
		local function updateMatchEnded()
			local winners = object2:Get("Winners")

			if not winners or #winners == 0 then
				return
			end

			local visible = object2:Find("Winners", localPlayer.UserId) ~= nil
			local v17 = object2:Get("Step") == "Tertiary"
			local region = object2:Get("Region") or "???"

			if v17 and visible then
				regionalTournamentEnd.YouWin.StepWarn.Text = `You won the {region} Regional Tournament, congratulations!`
				regionalTournamentEnd.YouWin.LeaveButton.Visible = true
			elseif not v17 and visible then
				regionalTournamentEnd.YouWin.LeaveButton.Visible = false
			end

			regionalTournamentEnd.YouWin.Visible = visible
			regionalTournamentEnd.YouLost.Visible = not visible
			regionalTournamentEnd.Enabled = true
		end

		v6.observeReplionPath(object2, "MatchEnded", updateMatchEnded)
		v6.observeReplionPath(object2, "Winners", updateMatchEnded)
	end

	local replion = v.Client:GetReplion("RegionalTournamentMatch")

	if replion then
		configureRegionalTournamentMatchReplion(replion) -- equivalent call inferred; original call site unknown
	else
		v.Client:OnReplionAdded(function(object2)
			if object2._channel ~= "RegionalTournamentMatch" then
				return
			end

			configureRegionalTournamentMatchReplion(object2) -- equivalent call inferred; original call site unknown
		end)
	end

	regionalTournamentEnd.YouWin.LeaveButton.Activated:Connect(function()
		remoteEvent2:FireServer()
	end)
	regionalTournamentEnd.YouLost.LeaveButton.Activated:Connect(function()
		remoteEvent2:FireServer()
	end)
	local v16 = v.Client:WaitReplion("Data")
	v6.observeReplionPath(v16, "Country", function(value)
		self:UpdateCountry(value or "US")
	end)
end

return RegionalTournamentController