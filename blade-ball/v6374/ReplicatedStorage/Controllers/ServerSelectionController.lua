local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
game:GetService("ReplicatedFirst")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v2 = require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage3.Shared.UniverseIds)
local v4 = require3(ReplicatedStorage3.Shared.UseNewLobby)
local v5 = require3(ReplicatedStorage3.Shared.UseNewServerBrowser)
require3(ReplicatedStorage3.Shared.RankData)
local v6 = require3(ReplicatedStorage3.Shared.MapData)
local v7 = require3(ReplicatedStorage3.Packages.Net)
local v8 = require3(ReplicatedStorage3.Packages.Signal)
local v9 = require3(ReplicatedStorage3.Packages.Replion)
local v10 = require3(ReplicatedStorage3.ClientGameModules.FFlagClient)
local v11 = require3(ReplicatedStorage3.Shared.GameModes)
local v12 = require3(script.UserThumbnailCache)
local v13 = require3(ReplicatedStorage3.Common.Utils)
local v14 = require3(ReplicatedStorage3.ServerInfo)
local v15 = require3(ReplicatedStorage3.Shared.GetServerType)
local v16 = require3(ReplicatedStorage3.Controllers.Ranked.RankedSignalController)
local v17 = require3(ReplicatedStorage3.ClientGameModules.CoreCall)
require3(ReplicatedStorage3.Shared.Trading.TradeInfo)
local v18 = require3(ReplicatedStorage3.Shared.Policy)
local openMainMenuSignal = v16:GetOpenMainMenuSignal()
local updateRankedMenuSignal = v16:GetUpdateRankedMenuSignal()
local v19 = ReplicatedStorage3.Shared.LTM.GetRecentLTM:Invoke()
local gameMode = v19.getGameMode()
local placeId = game.PlaceId
local _ = script.Flags
local remoteEvent = v7:RemoteEvent("PlaceTeleport")
local remoteEvent2 = v7:RemoteEvent("ServersUpdated")
local remoteEvent3 = v7:RemoteEvent("JoinMobileServer")
local remoteFunction = v7:RemoteFunction("JoinTrainingServer")
local remoteFunction2 = v7:RemoteFunction("GetServerFromCache")
local remoteFunction3 = v7:RemoteFunction("SetRoomName")
local joinQueue = ReplicatedStorage3.Remotes.JoinQueue
local v20 = v8.new()
local v21 = v8.new()
local v22 = v8.new()
local formatted = ("%s's Room"):format(localPlayer.DisplayName)
local v23 = v8.new()
local v24 = {}
local v25 = nil
local v26 = nil
local v27 = ""
local v28 = {}
local map = "Classic"
local mode2 = "Multiplayer"
local maxPlayers2 = 2
local gameMode2 = "FFA"
local v33 = 1
local v34 = nil
local clones = {}
local inServer = nil
local v35 = nil
local v36 = nil
local v37 = "OptionsDefault"
local v38 = {
	Training = false,
	Ranked = false,
	RankedNoAbility = false,
	LTM = false,
	Duels = false,
	Tournaments = false,
	TradePlaza = false,
	FiftyPlayers = false
}
local text2 = "Options"
local v40 = false
local flag = false

for k, mode in v11.Modes do
	if not mode.DisabledInTraining then
		table.insert(v24, k)
	end
end

ReplicatedStorage3:WaitForChild("Remotes")
local serverSelection = playerGui:WaitForChild("ServerSelection")
local v41 = {
	Options = function()
		v2:Close("ServerSelection", true)
	end,
	Training = function()
		changeSelectedPage("Options")
	end,
	Duel = function()
		changeSelectedPage("Invite")
	end,
	Maps = function()
		changeSelectedPage("Training")
	end,
	CreateRoom = function()
		changeSelectedPage("Training")
	end,
	RankedOptions = function()
		changeSelectedPage("RankedOptions")
	end,
	RankedQueueOptions = function()
		changeSelectedPage("RankedQueueOptions")
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function clickWithCooldown(fn)
	local v42 = 0
	return function()
		local now = os.clock()

		if now - v42 < 1.5 then
			return
		end

		v42 = now
		fn()
	end
end

local ServerSelectionController = {
	Init = function(_)
		v25 = require3(ReplicatedStorage3.Controllers.NotificationController)
		serverSelection:GetPropertyChangedSignal("Enabled"):Connect(function()
			local enabled = serverSelection.Enabled
			v17(Enum.CoreGuiType.PlayerList, not enabled)

			if enabled then
				changeTrainingMode("Multiplayer")
				changeSelectedPage("Options")
			end
		end)
	end,
	Start = function(_)
		v26 = v9.Client:WaitReplion("Data")
		local _ = serverSelection.ServerBrowser.Mask
		local topbar = serverSelection.ServerBrowser.Topbar
		local hover = serverSelection.Mask.Hover
		local createRoomPanel = serverSelection.CreateRoomPanel
		local textBox = createRoomPanel.PlayerCount.EntryBox.TextBox
		local errorNotification = serverSelection.ServerBrowser.Servers.ErrorNotification

		local function onSearchRequested()
			local text = topbar.SearchBar.Title.Text

			if string.len(text) == 0 or text == "" then
				v27 = nil

				for _, v42 in pairs(v28) do
					v42.Visible = true
				end
			else
				v27 = text:lower()

				for k, v42 in pairs(v28) do
					v42.Visible = individualSearchQuery(k)
				end
			end
		end

		createRoomPanel.CloseButton.MouseButton1Click:Connect(closeLastFrame)
		createRoomPanel.CreateButton.MouseButton1Click:Connect(function()
			createRoomPanel.CreateButton.Active = false
			task.delay(2, function()
				createRoomPanel.CreateButton.Active = true
			end)
			ReplicatedStorage3.Remotes.PlayTrainingMode:FireServer({
				Map = map,
				Mode = mode2,
				MaxPlayers = maxPlayers2,
				GameMode = gameMode2
			})
			v2:Close("ServerSelection", true)
		end)
		local v42 = 0
		local textBox2 = createRoomPanel.RoomName.EntryBox.TextBox
		textBox2.FocusLost:Connect(function()
			local v43, text = remoteFunction3:InvokeServer(textBox2.Text)

			if v43 then
				formatted = text
			else
				formatted = ("%s's Room"):format(localPlayer.DisplayName)
				local now = tick()
				v42 = now
				createRoomPanel.RoomName.EntryBox.ErrorCode.Text = text
				createRoomPanel.RoomName.EntryBox.ErrorCode.Visible = true
				task.delay(2, function()
					if v42 == now then
						createRoomPanel.RoomName.EntryBox.ErrorCode.Visible = false
					end
				end)
			end

			textBox2.Text = formatted
		end)
		textBox.FocusLost:Connect(function()
			local text = textBox.Text

			if text == tostring(maxPlayers2) then
				return
			end

			local v43 = tonumber(text) or 0
			local v44 = mode2 == "Singleplayer" and 1 or Players.MaxPlayers
			local v45 = math.clamp(v43, mode2 == "Singleplayer" and 1 or 2, v44)
			maxPlayers2 = v45
			textBox.Text = tostring(v45)
		end)
		createRoomPanel.GameModeSelect.ChangeModeButton.MouseButton1Click:Connect(function()
			v33 += 1

			if v33 > #v24 then
				v33 = 1
			end

			local v43 = v24[v33]
			local mode = v11.Modes[v43]

			if mode then
				gameMode2 = v43
				createRoomPanel.GameModeSelect.EntryBox.TextBox.Text = mode.DisplayName
			end
		end)
		createRoomPanel.MapSelect.ChangeMapButton.MouseButton1Click:Connect(function()
			changeSelectedPage("Maps")
		end)
		topbar.SearchButton.MouseButton1Click:Connect(onSearchRequested)
		topbar.SearchBar.Title.FocusLost:Connect(onSearchRequested)
		v23:Connect(function(flag2: boolean)
			local now = tick()
			v34 = now

			for _, v43 in ipairs(clones) do
				v43:Destroy()
			end

			table.clear(clones)

			if not flag2 then
				hover.Visible = false
				return
			end

			local count = #inServer
			local uDim = UDim2.fromScale(1 / math.min(count, 4) - (count * 0.1 - 1), 0.4)
			hover.Content.UIGridLayout.CellSize = uDim
			hover.Size = UDim2.fromScale(math.min(#inServer, 4) / 4 * 0.1 + 0.1, 0.2)
			local containsThreshold = v12:ContainsThreshold(inServer, 0.5)

			for i = 1, math.min(count, 8) do
				if now ~= v34 then
					break
				end

				local v43 = inServer[i]
				local clone = serverSelection.Assets.PlayerIcon:Clone()
				clone.Visible = true
				clone.Parent = hover.Content
				table.insert(clones, clone)

				if containsThreshold then
					task.spawn(renderPlayerIcon, v43, clone)
				else
					task.delay(i / 4, renderPlayerIcon, v43, clone)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateFramePosition()
				local mouseLocation = v:GetMouseLocation()
				hover.Position = UDim2.fromOffset(
					mouseLocation.X - hover.AbsoluteSize.X - 26,
					mouseLocation.Y - hover.AbsoluteSize.Y / 2 - 5
				)
			end

			local heartbeatConnection = RunService.Heartbeat:Connect(updateFramePosition)
			v23:Once(function()
				heartbeatConnection:Disconnect()
			end)
			updateFramePosition() -- equivalent call inferred; original call site unknown
			hover.Visible = true
		end)
		remoteEvent2.OnClientEvent:Connect(function(p)
			v35 = p
			v36 = nil
			inServer = nil
			v23:Fire(false)
			local formatLocalTime = DateTime.now():FormatLocalTime("LTS", "en-us")
			local v43 = #v35 > 0
			errorNotification.LayoutOrder = -500000
			errorNotification.Frame.LastUpdated.Text = `LAST UPDATED: {formatLocalTime}`
			serverSelection.ServerBrowser.RegionCount.Text = `ACTIVE SERVERS: {#v35} ({formatLocalTime})`
			errorNotification.Visible = not v43 or RunService:IsStudio()

			if v43 then
				renderClientCache()
				onSearchRequested()
			end
		end)
		local isActive = v19.IsActive()

		if v19.LobbyLTM then
			isActive = false
		end

		if isActive then
			v37 = `Options{gameMode}`

			if not v3.Voice.Accessible(localPlayer) and serverSelection:FindFirstChild(v37 .. "_NoVoice") then
				v37 ..= "_NoVoice"
			end
		else
			v37 = "OptionsDefault"
		end

		local newServerSelectionAB = localPlayer:GetAttribute("NewServerSelectionAB")

		if newServerSelectionAB then
			v37 = "OptionsNew"
		end

		local child = serverSelection:WaitForChild(v37)
		child.Name = "Options"
		child.Visible = true
		local v43 = nil
		local rankedQueueOptions = serverSelection.RankedQueueOptions
		local join = rankedQueueOptions:FindFirstChild("Main"):FindFirstChild("Join")
		local activated = join.Activated

		local function fn()
			join.Active = false
			task.delay(1, function()
				join.Active = true
			end)

			if v43 == "Normal" then
				ReplicatedStorage3.Remotes.PlayRanked:FireServer()
			elseif v43 == "NoAbility" then
				ReplicatedStorage3.Remotes.PlayNoAbilityRanked:FireServer()
			end

			v2:Close("ServerSelection", true)
		end

		activated:Connect(clickWithCooldown(fn))
		local queue = rankedQueueOptions:FindFirstChild("Main"):FindFirstChild("Queue")
		local activated2 = queue.Activated

		local function fn2()
			queue.Active = false
			task.delay(1, function()
				queue.Active = true
			end)

			if joinQueue and v43 then
				v2:Close("ServerSelection", true)
				updateRankedMenuSignal:Fire(v43)
				openMainMenuSignal:Fire(true)
			end
		end

		activated2:Connect(clickWithCooldown(fn2))
		local close = rankedQueueOptions:FindFirstChild("Main"):FindFirstChild("Close")

		local function fn3()
			close.Active = false
			task.delay(1, function()
				close.Active = true
			end)
			changeSelectedPage("Options")
		end

		close.Activated:Connect(clickWithCooldown(fn3))
		local classicButton = serverSelection.SmallSelection:FindFirstChild("Options"):FindFirstChild("ClassicButton")
		local activated4 = classicButton.Activated

		local function fn4()
			if v38.Ranked then
				return
			end

			classicButton.Active = false
			task.delay(3, function()
				classicButton.Active = true
			end)

			if v3.Ranked.Accessible(localPlayer) then
				v43 = "Normal"
				rankedQueueOptions.Main.Title.Text = "<stroke color=\"rgb(21, 79, 171)\" joins=\"round\" thickness=\"3\">Ranked <font color=\"rgb(255, 110, 110)\">Classic</font></stroke>"
				changeSelectedPage("RankedQueueOptions")
			end
		end

		activated4:Connect(clickWithCooldown(fn4))
		local close2 = serverSelection.SmallSelection.Options.Close

		local function fn5()
			close2.Active = false
			task.delay(1, function()
				close2.Active = true
			end)
			changeSelectedPage("Options")
		end

		close2.Activated:Connect(clickWithCooldown(fn5))
		local rankedNoAbilityButton = serverSelection.SmallSelection:FindFirstChild("Options"):FindFirstChild("RankedNoAbilityButton")
		local activated6 = rankedNoAbilityButton.Activated

		local function fn6()
			if not v38.RankedNoAbility then
				return
			end

			rankedNoAbilityButton.Active = false
			task.delay(3, function()
				rankedNoAbilityButton.Active = true
			end)

			if v3.RankedNoAbility.Accessible(localPlayer) then
				rankedQueueOptions.Main.Title.Text = "<stroke color=\"rgb(21, 79, 171)\" joins=\"round\" thickness=\"3\">Ranked <font color=\"rgb(255, 110, 110)\">No Ability</font></stroke>"
				v43 = "NoAbility"
				changeSelectedPage("RankedQueueOptions")
			end
		end

		activated6:Connect(clickWithCooldown(fn6))

		if newServerSelectionAB then
			serverSelection.CloseButton.Visible = false
			serverSelection.Header.Visible = false
			local casual = serverSelection.Options.Play:FindFirstChild("Casual")

			if casual then
				local function fn7()
					casual.Active = false
					task.delay(0.5, function()
						casual.Active = true
					end)
					changeSelectedPage("Casual")
				end

				casual.Activated:Connect(clickWithCooldown(fn7))
			end

			local competitive = serverSelection.Options.Play:FindFirstChild("Competitive")

			if competitive then
				local function fn7()
					competitive.Active = false
					task.delay(0.5, function()
						competitive.Active = true
					end)
					changeSelectedPage("Competitive")
				end

				competitive.Activated:Connect(clickWithCooldown(fn7))
			end
		else
			serverSelection.CloseButton.Visible = true
			serverSelection.Header.Visible = true
		end

		local mobileServers = serverSelection.Options:FindFirstChild("MobileServers")

		if newServerSelectionAB then
			mobileServers = serverSelection.Options.TopButtons:FindFirstChild("MobileServers")
		end

		local returnButton = mobileServers and mobileServers:FindFirstChild("ReturnButton")
		local visible2 = v.TouchEnabled and not (v.KeyboardEnabled or v.MouseEnabled)

		if mobileServers then
			mobileServers.Visible = visible2
			returnButton.Visible = v14.isMobileServer()
			mobileServers.Active = not v14.isMobileServer()

			local function fn7()
				returnButton.Active = false
				task.delay(3, function()
					returnButton.Active = true
				end)
				remoteEvent:FireServer("Default")
			end

			returnButton.Activated:Connect(clickWithCooldown(fn7))

			local function fn8()
				mobileServers.Active = false
				task.delay(3, function()
					mobileServers.Active = true
				end)
				remoteEvent3:FireServer()
			end

			mobileServers.Activated:Connect(clickWithCooldown(fn8))
		end

		local child2 = serverSelection.Options:FindFirstChild(gameMode)

		if newServerSelectionAB then
			child2 = serverSelection.Options.Casual.CasualLTM:FindFirstChild(gameMode)
		end

		if child2 then
			local function fn7()
				if v38.LTM then
					return
				end

				child2.Active = false
				task.delay(3, function()
					child2.Active = true
				end)

				if v3.LTM.Accessible(localPlayer) then
					v2:Close("ServerSelection", true)

					if v19.Id == "SquadRoyale" then
						v2:Open("SquadRoyaleInvite")
					else
						remoteEvent:FireServer("LTM")
					end
				end
			end

			child2.MouseButton1Click:Connect(clickWithCooldown(fn7))
		end

		local pro = serverSelection.Options:FindFirstChild("Pro")

		if newServerSelectionAB then
			pro = serverSelection.Options.Competitive.List:FindFirstChild("Pro")
		end

		if pro then
			local function fn7()
				pro.Active = false
				task.delay(3, function()
					pro.Active = true
				end)

				if v3.Pro.Accessible(localPlayer) then
					remoteEvent:FireServer("Pro")
					v2:Close("ServerSelection", true)
				end
			end

			pro.Activated:Connect(clickWithCooldown(fn7))
		end

		local duel = serverSelection.Options:FindFirstChild("Duel")

		if newServerSelectionAB then
			duel = serverSelection.Options.Competitive.List:FindFirstChild("Duel")
		end

		local function fn7()
			if v38.Duels then
				return
			end

			duel.Active = false
			task.delay(3, function()
				duel.Active = true
			end)

			if v3.Duel.Accessible(localPlayer) then
				v2:Open("DuelParty", true)
			end
		end

		duel.Activated:Connect(clickWithCooldown(fn7))
		local fiftyPlayers = serverSelection.Options:FindFirstChild("FiftyPlayers")

		if newServerSelectionAB then
			fiftyPlayers = serverSelection.Options.Competitive.List:FindFirstChild("FiftyPlayers")
		end

		if fiftyPlayers then
			local function fn8()
				if v38.FiftyPlayers then
					return
				end

				fiftyPlayers.Active = false
				task.delay(3, function()
					fiftyPlayers.Active = true
				end)

				if v3.FiftyPlayers.Accessible(localPlayer) then
					remoteEvent:FireServer("FiftyPlayers")
					v2:Close("ServerSelection", true)
				end
			end

			fiftyPlayers.Activated:Connect(clickWithCooldown(fn8))
		end

		local ranked = serverSelection.Options:FindFirstChild("Ranked")

		if newServerSelectionAB then
			ranked = serverSelection.Options.Competitive.List:FindFirstChild("Ranked")
		end

		if ranked then
			local activated8 = ranked.Activated

			local function fn8()
				ranked.Active = false
				task.delay(0.5, function()
					ranked.Active = true
				end)

				if v3.Ranked.Accessible(localPlayer) then
					if not v38.RankedNoAbility then
						changeSelectedPage("RankedOptions")
						return
					end

					v43 = "Normal"
					rankedQueueOptions.Main.Title.Text = "<stroke color=\"rgb(21, 79, 171)\" joins=\"round\" thickness=\"3\">Ranked <font color=\"rgb(255, 110, 110)\">Classic</font></stroke>"
					changeSelectedPage("RankedQueueOptions")
				end
			end

			activated8:Connect(clickWithCooldown(fn8))
		end

		local voice = serverSelection.Options:FindFirstChild("Voice")

		if newServerSelectionAB then
			if isActive then
				voice = serverSelection.Options.Casual.CasualLTM:FindFirstChild("Voice")
			else
				voice = serverSelection.Options.Casual.Default:FindFirstChild("Voice")
			end
		end

		if voice then
			local function fn8()
				voice.Active = false
				task.delay(3, function()
					voice.Active = true
				end)

				if v3.Voice.Accessible(localPlayer) then
					remoteEvent:FireServer("Voice")
					v2:Close("ServerSelection", true)
				end
			end

			voice.Activated:Connect(clickWithCooldown(fn8))
		end

		local regions = serverSelection.Options:FindFirstChild("Regions")

		if newServerSelectionAB then
			regions = serverSelection.Options.TopButtons:FindFirstChild("ServerList")
		end

		if regions then
			regions.Visible = not (v14.isPrivateServer() or v14.isReservedServer()) and (v15() == "Normal" or (v14.isProServer() or v14.isVoiceServer() or v14.isTradingPlazaServer() or v14.isProTradingPlazaServer() or v14.isFiftyPlayersServer() or v14.isDuelLobbyServer() or v14.isRankedLobbyServer()))
			regions.Activated:Connect(function()
				v2:Open(v5() and "ServerBrowser" or "ServerBrowserOld", false, true)
			end)
		end

		for childName, v45 in v3 do
			local v46

			if childName == "LTM" then
				v46 = gameMode
			else
				v46 = (childName == "TradingPlaza" or childName == "ProTradingPlaza") and "TradePlaza" or childName
			end

			local v47 = serverSelection.Options:FindFirstChild(v46) or serverSelection.Options:FindFirstChild(childName)

			if newServerSelectionAB then
				local v48

				if isActive then
					v48 = serverSelection.Options.Casual.CasualLTM:FindFirstChild(v46) or serverSelection.Options.Casual.CasualLTM:FindFirstChild(childName)
				else
					v48 = serverSelection.Options.Casual.Default:FindFirstChild(v46) or serverSelection.Options.Casual.Default:FindFirstChild(childName)
				end

				v47 = v48 or serverSelection.Options.Competitive.List:FindFirstChild(v46) or serverSelection.Options.Competitive.List:FindFirstChild(childName) or serverSelection.Options.Play:FindFirstChild(v46) or serverSelection.Options.Play:FindFirstChild(childName)
			end

			if not v47 then
				continue
			end

			local flag2 = false

			if v45.PlaceId == placeId then
				flag2 = true
			elseif typeof(v45.AssociatedPlaces) == "table" then
				for _, associatedPlace in ipairs(v45.AssociatedPlaces) do
					local v49 = v3[associatedPlace]

					if not (v49 and v49.PlaceId == placeId) then
						continue
					end

					flag2 = true
					break
				end
			end

			local backButton = v47:FindFirstChild("BackButton")

			if not backButton then
				continue
			end

			if flag2 then
				for _, guiObject in ipairs(v47:GetChildren()) do
					if guiObject:IsA("GuiObject") then
						guiObject.Visible = false
					end
				end

				v47.ImageTransparency = 1
				v47.Active = false
				v47.Selectable = false

				local function fn8()
					remoteEvent:FireServer("Default")
					v2:Close("ServerSelection", true)
				end

				backButton.MouseButton1Click:Connect(clickWithCooldown(fn8))
			end

			backButton.Visible = flag2
		end

		local multiplayerTraining = serverSelection.Options:FindFirstChild("MultiplayerTraining")

		if newServerSelectionAB then
			multiplayerTraining = serverSelection.Options.Play:FindFirstChild("MultiplayerTraining")
		end

		if multiplayerTraining then
			multiplayerTraining.MouseButton1Click:Connect(function()
				if not v38.Training then
					changeSelectedPage("Training")
				end
			end)
		end

		serverSelection.ServerBrowser.Topbar.CreateButton.MouseButton1Click:Connect(function()
			changeSelectedPage("CreateRoom")
		end)
		v20:Connect(function()
			if newServerSelectionAB then
				serverSelection.Options.Tags.MultiplayerTag.Visible = mode2 == "Multiplayer"
				serverSelection.Options.Tags.SingleplayerTag.Visible = mode2 == "Singleplayer"
			else
				serverSelection.Header.MultiplayerTag.Visible = mode2 == "Multiplayer"
				serverSelection.Header.SingleplayerTag.Visible = mode2 == "Singleplayer"
			end

			local v45 = mode2 == "Singleplayer" and 1 or Players.MaxPlayers
			local v46 = mode2 == "Singleplayer" and 1 or 2
			maxPlayers2 = v46
			textBox.Text = tostring(v46)
			createRoomPanel.PlayerCount.TextBox.Text = ("/%d"):format(v45)
		end)
		v22:Connect(function()
			if newServerSelectionAB then
				serverSelection.Options.Play.Visible = text2 == "Options"
				serverSelection.Options.Casual.Visible = text2 == "Casual"
				serverSelection.Options.Competitive.Visible = text2 == "Competitive"
				serverSelection.Options.Close.Visible = text2 ~= "CreateRoom"

				if text2 == "Casual" or text2 == "Competitive" or text2 == "Training" then
					serverSelection.Options.Title.Text = text2
				else
					serverSelection.Options.Title.Text = "Server Selection"
				end
			else
				serverSelection.Options.Visible = text2 == "Options"
			end

			serverSelection.TrainingMode.Visible = text2 == "Training"
			serverSelection.Maps.Visible = text2 == "Maps"
			serverSelection.ServerBrowser.Visible = text2 == "ServerBrowser"
			serverSelection.CreateRoomPanel.Visible = text2 == "CreateRoom"
			local closeButton = serverSelection.CloseButton
			closeButton.Visible = text2 ~= "CreateRoom" and not newServerSelectionAB
			serverSelection.SmallSelection.Visible = text2 == "RankedOptions"
			serverSelection.RankedQueueOptions.Visible = text2 == "RankedQueueOptions"

			if not v40 and text2 == "ServerBrowser" then
				v40 = true
				local v46 = remoteFunction2:InvokeServer(1)

				if v46 then
					v35 = v46
					renderClientCache()
					onSearchRequested()
				end
			end
		end)
		v21:Connect(function()
			local v45 = v6[map]

			if v45 then
				createRoomPanel.MapSelect.EntryBox.TextBox.Text = v45.DisplayName
			end

			changeSelectedPage("CreateRoom")
		end)

		for _, button in ipairs(serverSelection.TrainingMode:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local name = button.Name
			local v46 = button
			button.MouseButton1Click:Connect(function()
				if v38.Training then
					return
				end

				changeTrainingMode(name)

				if v46.Name == "Singleplayer" then
					changeSelectedPage("CreateRoom")
				elseif v46.Name == "Multiplayer" then
					changeSelectedPage("ServerBrowser")
				end
			end)
		end

		local tournaments = serverSelection.Options:FindFirstChild("Tournaments")

		if tournaments then
			tournaments.Activated:Connect(function()
				if v38.Tournaments then
					return
				end

				v2:Open("Tournaments")
			end)
		end

		v10.DataUpdatedEvent:Connect(updateFFlags)
		task.spawn(updateFFlags)

		if newServerSelectionAB then
			serverSelection.Options.Close.MouseButton1Click:Connect(closeLastFrame)
		else
			serverSelection.CloseButton.MouseButton1Click:Connect(closeLastFrame)
		end

		local now = 0
		task.spawn(function()
			local spawn = workspace:WaitForChild("Spawn")
			local v45 = v4() and not v14.isRankedLobbyServer() or v14.isTradingPlazaServer() or v14.isFiftyPlayersServer()

			local function findHitbox()
				local menuRings = spawn:FindFirstChild("MenuRings")
				local ranked2 = menuRings and menuRings:FindFirstChild("Ranked")
				local ranked3 = spawn:FindFirstChild("Ranked")
				local v46

				if v45 then
					v46 = ranked2 or ranked3
				else
					v46 = ranked3 or ranked2
				end

				if not v46 then
					return nil
				end

				local hitbox = v46:FindFirstChild("Hitbox") or v46

				if hitbox:IsA("BasePart") then
					return hitbox
				end

				return nil
			end

			local hitbox = findHitbox()

			for _ = 1, 30 do
				if hitbox then
					break
				end

				task.wait(1)
				hitbox = findHitbox()
			end

			if hitbox then
				hitbox.Touched:Connect(function(otherPart)
					local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

					if playerFromCharacter ~= localPlayer then
						return
					end

					local distanceFromCharacter = playerFromCharacter:DistanceFromCharacter(hitbox.Position)

					if distanceFromCharacter == 0 or (hitbox.Size * createVector(1, 0, 1)).Magnitude * 1.1 < distanceFromCharacter then
						return
					end

					if os.clock() - now > 1 and not (v2:IsOpen("ServerSelection") or v2:IsOpen("DuelParty") or v2:IsOpen("Tournaments") or v2:IsOpen("ServerBrowser") or v2:IsOpen("ServerBrowserOld") or v14.isRankedMatchServer()) then
						v2:Open("ServerSelection")
					end
				end)
			else
				warn("[ServerSelection] no ranked pad in this place, the menu cannot be opened by walking")
			end
		end)
		v2:OnGuiClose("ServerSelection", function()
			now = os.clock()
			serverSelection.TradePlazaSelect.Visible = false
		end)
		v2:OnGuiOpen("ServerSelection", function()
			if workspace:GetAttribute("ForceRankedMode") then
				v2:Close("ServerSelection", true)
				return
			end

			updateRankedAccessibility(newServerSelectionAB)
			serverSelection.TradePlazaSelect.Visible = false
			child.Visible = true
		end)
		v18.PolicyInfoAdded:Connect(function()
			updateTradePlazaAccessibility(newServerSelectionAB)
		end)
		v26:OnChange("TradeBanned", function()
			updateTradePlazaAccessibility(newServerSelectionAB)
		end)
		v26:OnChange("TradeLockedUntil", function()
			updateTradePlazaAccessibility(newServerSelectionAB)
		end)
		v26:OnChange("TotalStats.Wins", function()
			updateTradePlazaAccessibility(newServerSelectionAB)
			updateProAccessibility(newServerSelectionAB)
			updateRankedAccessibility(newServerSelectionAB)
		end)

		for k, v45 in v6 do
			if v45.DisabledInTraining then
				continue
			end

			local clone = serverSelection.Assets.MapTemplate:Clone()
			clone.Image = v45.Image
			clone.HoverImage = v45.HoverImage
			clone.Title.Text = v45.DisplayName
			local v47 = k

			local function fn8()
				clone.Active = false
				task.delay(2, function()
					clone.Active = true
				end)
				changeSelectedMap(v47)
			end

			clone.Activated:Connect(clickWithCooldown(fn8))
			clone.Parent = serverSelection.Maps.Container
			clone.Visible = true
		end

		task.spawn(function()
			updateProAccessibility(newServerSelectionAB)
			updateTradePlazaAccessibility(newServerSelectionAB)

			for _ = 1, 10 do
				if updateVoiceAccessibility(newServerSelectionAB) then
					break
				else
					task.wait(5)
				end
			end
		end)

		if isActive then
			local child3 = serverSelection.Options:FindFirstChild(gameMode)

			if not child3 then
				return
			end

			local connection = nil
			connection = v13.Thread.Every(1, function()
				if not (v2:IsOpen("ServerSelection") or v14.isLTMServer()) then
					return
				end

				local tagged = CollectionService:GetTagged("LTMTimer")
				table.insert(tagged, child3.Timer.Title)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateTimers(text: string)
					for _, v45 in tagged do
						v45.Text = text
					end
				end

				if v38.LTM then
					updateTimers("Temporarily Disabled") -- equivalent call inferred; original call site unknown
					child3.Active = false
				else
					local v45 = math.max(0, v19.DateEndTime.UnixTimestamp - workspace:GetServerTimeNow())

					if v45 == 0 then
						updateTimers("Event Ended") -- equivalent call inferred; original call site unknown
						child3.Active = false

						if connection and connection.Connected then
							connection:Disconnect()
						end
					else
						updateTimers(v13.ValueConvertor:FormatTimeWithDaysFull(v45)) -- equivalent call inferred; original call site unknown
						child3.Active = true
					end
				end
			end)
		end

		local tradePlazaSelect = serverSelection.TradePlazaSelect

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toggleTradePlazaSelection(visible: boolean)
			tradePlazaSelect.Visible = visible
			child.Visible = not visible
		end

		tradePlazaSelect.Close.Activated:Connect(function()
			toggleTradePlazaSelection(false) -- equivalent call inferred; original call site unknown
		end)

		for _, button in tradePlazaSelect.List:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local v45 = button
			button.Activated:Connect(function()
				remoteEvent:FireServer(v45.Name == "Pro" and "ProTradingPlaza" or "TradingPlaza")
				v2:Close("ServerSelection", true)
			end)
		end

		local tradePlaza = serverSelection.Options:FindFirstChild("TradePlaza")

		if newServerSelectionAB then
			tradePlaza = serverSelection.Options.Play:FindFirstChild("TradePlaza")
		end

		if tradePlaza then
			tradePlaza.Activated:Connect(function()
				if v38.TradePlaza or v10:GetKey("TradingEnabled") ~= true then
					return
				end

				tradePlaza.Active = false
				task.delay(2, function()
					tradePlaza.Active = true
				end)

				if v3.ProTradingPlaza.Accessible(localPlayer) then
					toggleTradePlazaSelection(true) -- equivalent call inferred; original call site unknown
				elseif v3.TradingPlaza.Accessible(localPlayer) then
					remoteEvent:FireServer("TradingPlaza")
					v2:Close("ServerSelection", true)
				end
			end)
		end
	end
}

function closeLastFrame()
	local v42 = v41[text2]

	if v42 then
		v42()
	else
		changeSelectedPage("Options")
	end
end

function changeSelectedMap(p: string)
	map = p
	v21:Fire()
end

function changeSelectedPage(p: string)
	text2 = p
	v22:Fire()
end

function changeTrainingMode(p: string)
	mode2 = p
	v20:Fire()
end

function getServerData(p)
	for _, v42 in ipairs(v35) do
		if v42.key == p then
			return v42
		end
	end
end

function individualSearchQuery(p)
	local serverData = getServerData(p)

	if not serverData or (#serverData.value.InServer == 0 or #serverData.value.UserNames == 0) then
		return false
	end

	if string.find(serverData.value.Region:lower(), v27) then
		return true
	end

	if serverData.value.UserNames then
		for _, userName in ipairs(serverData.value.UserNames) do
			if string.find(userName:lower(), v27) then
				return true
			end
		end
	end

	local roomName = serverData.value.RoomName or serverData.key

	if string.find(roomName:lower(), v27) then
		return true
	end

	return false
end

function renderPlayerIcon(p: number, p2)
	local success, result = v12:Get(p)

	if not success then
		success, result = pcall(function()
			return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
	end

	if not success then
		p2.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=60&h=60"):format(p)
		return
	end

	v12:Append(p, result)
	p2.Image = result
end

function renderClientCache()
	if flag or not v35 then
		return
	end

	flag = true
	local value = ReplicatedStorage3.ServerInfo.Region.Value
	local v42 = {}

	for _, v43 in ipairs(v35) do
		local key = v43.key
		local value2 = v43.value
		local maxPlayers = value2.MaxPlayers or Players.MaxPlayers
		v42[key] = true
		local clone = v28[key]

		if clone == nil then
			task.wait(0.1)
			clone = serverSelection.Assets.ServerTemplate:Clone()
			local v44 = key
			clone.PlayerCount.MouseLeave:Connect(function()
				if v36 == v44 then
					v36 = nil
					inServer = nil
					v23:Fire(false)
				end
			end)
			local v45 = key
			local v46 = v43
			local mouseEnterConnection = clone.PlayerCount.MouseEnter:Connect(function()
				if v36 == v45 then
					v36 = nil
					inServer = nil
					v23:Fire(false)
				else
					local value3 = nil

					for i, v48 in ipairs(v35) do
						if v46.key ~= v45 then
							continue
						end

						value3 = v46.value
						break
					end

					if value3 then
						v36 = v45
						inServer = value3.InServer
						v23:Fire(true)
					end
				end
			end)
			local v47 = clone
			local v48 = key
			local connection = clone.JoinButton.MouseButton1Click:Connect(function()
				v47.JoinButton.Active = false
				task.delay(2, function()
					v47.JoinButton.Active = true
				end)
				local v49, v50 = remoteFunction:InvokeServer(v48)

				if v49 then
					v2:Close("ServerSelection", true)
				end
			end)
			local connection2 = mouseEnterConnection
			clone.Destroying:Once(function()
				connection:Disconnect()
				connection2:Disconnect()
			end)
			clone.Parent = serverSelection.ServerBrowser.Servers
			v28[key] = clone
		end

		clone.RoomName.Text = value2.RoomName or key
		clone.PlayerCount.PlayerCountValue.Text = ("%d/%d"):format(#value2.InServer, maxPlayers)

		if value2.Region == "None" then
			clone.Ping.Text = ("%s\n%d ms"):format("Unknown Region", value2.Ping)
		else
			clone.Ping.Text = ("%s\n%d ms"):format(value2.Region, value2.Ping)
		end

		if maxPlayers <= #value2.InServer then
			clone.Status.Text = "FULL"
			clone.JoinButton.Visible = false
		elseif game.JobId == key then
			clone.Status.Text = "YOUR SERVER"
			clone.JoinButton.Visible = false
		else
			clone.Status.Text = maxPlayers > 1 and "MULTIPLAYER" or "SINGLEPLAYER"
			local joinButton = clone.JoinButton
			joinButton.Visible = maxPlayers > 1 and not RunService:IsStudio()
		end

		if value == value2.Region then
			clone.LayoutOrder = value2.Ping
		else
			clone.LayoutOrder = 100000 + value2.Ping
		end
	end

	for k, v43 in pairs(v28) do
		if v42[k] then
			if v27 then
				v43.Visible = individualSearchQuery(remoteFunction)
			else
				v43.Visible = true
			end
		else
			v28[k] = nil
			v43:Destroy()
		end
	end

	flag = false
end

function updateProAccessibility(flag2: boolean?)
	local v42 = (v26:Get({ "TotalStats", "Wins" }) or 0) >= 50

	if flag2 then
		serverSelection.Options.Competitive.List.Pro.LockedOverlay.Visible = not v42
	else
		serverSelection.Options.Pro.LockedOverlay.Visible = not v42
	end
end

function updateTradePlazaAccessibility(flag2: boolean?)
	local policyInfo = v18:GetPolicyInfo()
	local tradePlaza = serverSelection.Options:FindFirstChild("TradePlaza")

	if flag2 then
		tradePlaza = serverSelection.Options.Play:FindFirstChild("TradePlaza")
	end

	if not tradePlaza then
		return
	end

	local tradeLockedUntil = v26:Get("TradeLockedUntil")
	local serverTimeNow = workspace:GetServerTimeNow()
	local title = tradePlaza.LockedOverlay.Title

	if policyInfo.IsPaidItemTradingAllowed then
		if v26:Get("TradeBanned") or tradeLockedUntil and tradeLockedUntil > 0 and serverTimeNow < tradeLockedUntil then
			title.Text = "Not available"
		else
			title.Text = "1+ Wins Required"
		end
	else
		title.Text = "Not available in your region"
	end

	title.Parent.Visible = not ((v3.TradingPlaza.Accessible(localPlayer) or v38.TradePlaza) and policyInfo.IsPaidItemTradingAllowed)
end

function updateRankedAccessibility(flag2: boolean?)
	local ranked = serverSelection.Options:FindFirstChild("Ranked")

	if flag2 then
		ranked = serverSelection.Options.Competitive.List:FindFirstChild("Ranked")
	end

	local accessible, v42 = v3.Ranked.Accessible(localPlayer)

	if accessible and not v38.Ranked then
		ranked.LockedOverlay.Visible = false
		return
	end

	ranked.LockedOverlay.Visible = true

	if v38.Ranked then
		ranked.LockedOverlay.Title.Text = "This Mode Is Disabled"
	elseif v42 == -1 then
		ranked.LockedOverlay.Title.Text = "You're Banned"
	else
		ranked.LockedOverlay.Title.Text = `{v42}+ Wins Required`
	end
end

function updateVoiceAccessibility(flag2: boolean?)
	local accessible = v3.Voice.Accessible(localPlayer)

	if not flag2 then
		serverSelection.Options.Voice.LockedOverlay.Visible = not accessible
		return accessible
	end

	local isActive = v19.IsActive()

	if v19.LobbyLTM then
		isActive = false
	end

	if isActive then
		serverSelection.Options.Casual.CasualLTM.Voice.LockedOverlay.Visible = not accessible
		return accessible
	end

	serverSelection.Options.Casual.Default.Voice.LockedOverlay.Visible = not accessible
	return accessible
end

local positions = {}

function updateTrainingModeMultiplayerAccessibility()
	local multiplayer = serverSelection.TrainingMode.Multiplayer
	local singleplayer = serverSelection.TrainingMode.Singleplayer

	if not positions[multiplayer] then
		positions[multiplayer] = multiplayer.Position
		positions[singleplayer] = singleplayer.Position
	end
end

function updateFFlags()
	local newServerSelectionAB = localPlayer:GetAttribute("NewServerSelectionAB")
	v19.IsActive()
	updateTrainingModeMultiplayerAccessibility()
	local isActive = v19.IsActive()

	if v19.LobbyLTM then
		isActive = false
	end

	for k, v43 in newServerSelectionAB and {
		Training = {
			FFlag = "TrainingModeEnabled",
			ButtonPath = "Options.Play.MultiplayerTraining"
		},
		Ranked = {
			FFlag = "RankedModeEnabled",
			ButtonPath = "Options.Competitive.List.Ranked"
		},
		RankedNoAbility = {
			FFlag = "NoAbilityRankedEnabled",
			ButtonPath = "SmallSelection.Options.RankedNoAbilityButton"
		},
		Duels = {
			FFlag = "DuelsEnabled",
			ButtonPath = "Options.Competitive.List.Duel"
		},
		LTM = {
			FFlag = "LimitedTimeModeEnabled",
			ButtonPath = "Options.Casual.CasualLTM.{LTMGameMode}"
		},
		Tournaments = {
			FFlag = "TournamentsEnabled",
			ButtonPath = "Options.Tournaments"
		},
		TradePlaza = {
			FFlag = "TradePlazaEnabled",
			ButtonPath = "Options.Play.TradePlaza"
		},
		FiftyPlayers = {
			FFlag = "FiftyPlayersEnabled",
			ButtonPath = "Options.Play.FiftyPlayers"
		}
	} or {
		Training = {
			FFlag = "TrainingModeEnabled",
			ButtonPath = "Options.MultiplayerTraining"
		},
		Ranked = {
			FFlag = "RankedModeEnabled",
			ButtonPath = "Options.Ranked"
		},
		RankedNoAbility = {
			FFlag = "NoAbilityRankedEnabled",
			ButtonPath = "SmallSelection.Options.RankedNoAbilityButton"
		},
		Duels = {
			FFlag = "DuelsEnabled",
			ButtonPath = "Options.Duel"
		},
		LTM = {
			FFlag = "LimitedTimeModeEnabled",
			ButtonPath = "Options.{LTMGameMode}"
		},
		Tournaments = {
			FFlag = "TournamentsEnabled",
			ButtonPath = "Options.Tournaments"
		},
		TradePlaza = {
			FFlag = "TradePlazaEnabled",
			ButtonPath = "Options.TradePlaza"
		},
		FiftyPlayers = {
			FFlag = "FiftyPlayersEnabled",
			ButtonPath = "Options.FiftyPlayers"
		}
	} do
		local key = v10:GetKey(v43.FFlag)
		local isEnabled

		if typeof(v43.IsEnabled) == "function" then
			isEnabled = v43.IsEnabled
		end

		if isEnabled then
			v38[k] = not (key and isEnabled())
		else
			v38[k] = not key
		end

		local buttonPath = v43.ButtonPath

		if isActive and string.find(buttonPath, "{LTMGameMode}") then
			buttonPath = string.gsub(buttonPath, "{LTMGameMode}", gameMode)
		end

		local v44 = string.split(buttonPath, ".")
		local button = serverSelection

		for _, childName in v44 do
			button = button and button:FindFirstChild(childName)
		end

		if not button and newServerSelectionAB then
			local v45 = v44[#v44]

			if v45 then
				local v46

				if isActive then
					v46 = serverSelection.Options.Casual.CasualLTM:FindFirstChild(v45)
				else
					v46 = serverSelection.Options.Casual.Default:FindFirstChild(v45)
				end

				button = v46 or serverSelection.Options.Competitive.List:FindFirstChild(v45) or serverSelection.Options.Play:FindFirstChild(v45)
			end
		end

		if button then
			local visible = v38[k]
			local mode_Disabled = button:FindFirstChild("Mode_Disabled") or button:FindFirstChild("LockedOverlay")

			if mode_Disabled then
				mode_Disabled.Visible = visible
			end

			if button:IsA("GuiButton") then
				button.Active = not visible
				button.Selectable = not visible
			end
		elseif k ~= "LTM" or v19.IsActive() then
			warn((`Failed to find button for {k}: ServerSelection.{v43.ButtonPath}`))
		end
	end
end

return ServerSelectionController