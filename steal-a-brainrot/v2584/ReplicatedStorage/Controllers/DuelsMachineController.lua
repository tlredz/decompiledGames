game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local UsersAPI = require(ReplicatedStorage.Shared.UsersAPI)
require(ReplicatedStorage.Packages.Promise)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CornerNotificationController = require(ReplicatedStorage.Controllers.CornerNotificationController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local DuelsFlags = require(ReplicatedStorage.Shared.Flags.DuelsFlags)
local Animals = require(ReplicatedStorage.Shared.Animals)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local Friends = require(ReplicatedStorage.Shared.Friends)
require(ReplicatedStorage.Shared.Updates)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local duelsMachinePlayerList = playerGui:WaitForChild("DuelsMachinePlayerList").DuelsMachinePlayerList
local duelsMachinePrompt = playerGui:WaitForChild("DuelsMachinePrompt").DuelsMachinePrompt
local duelsMachineSession = playerGui:WaitForChild("DuelsMachineSession").DuelsMachineSession
local remoteEvent = Net:RemoteEvent("DuelsMachineService/ReconnectWarn")
local remoteEvent2 = Net:RemoteEvent("DuelsMachineService/CreateInvite")
local remoteEvent3 = Net:RemoteEvent("DuelsMachineService/Reconnect")
local remoteFunction = Net:RemoteFunction("DuelsMachineService/AcceptInvite")
local remoteFunction2 = Net:RemoteFunction("DuelsMachineService/SearchUser")
local remoteFunction3 = Net:RemoteFunction("DuelsMachineService/Invite")
local DuelsMachineController = {
	IsEnabled = function(_)
		return not (FFlags:GetInstant("DuelsMachineService/Disabled") or ServerData.IsNewPlayersServer()) and not ServerData.IsDuelsServer() and (ServerData.IsJumpLTMServer() or not ServerData.IsTsunamiServer()) and true
	end,
	SendInvite = function(self, p: number)
		return remoteFunction3:InvokeServer(p)
	end
}

function DuelsMachineController._createPlayerList(_)
	local v = InterfaceController:Register("DuelsMachinePlayerList", duelsMachinePlayerList, "TopQuint")
	v:AttachCloseButton(duelsMachinePlayerList.Header.Close)
	v:Close()
	local searchBox = duelsMachinePlayerList.SearchFrame.SearchBox
	local v2 = nil
	local v3 = nil

	local function updateUserCard(parent, data, layoutOrder: number, clone)
		local formatted = `{data.username}_{data.userId}`
		local v4 = clone or parent:FindFirstChild(formatted)

		if not v4 then
			return
		end

		v4.Fill.Status2.Text = data.inGame and "Online" or data.isFriend and "Away" or "Offline"
		local status2 = v4.Fill.Status2
		local color

		if data.inGame then
			color = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color = Color3.fromRGB(239, 225, 69)
		else
			color = Color3.fromRGB(211, 38, 38)
		end

		status2.TextColor3 = color
		local status = v4.Fill.PlayerImage.Status
		local color2

		if data.inGame then
			color2 = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color2 = Color3.fromRGB(239, 225, 69)
		else
			color2 = Color3.fromRGB(211, 38, 38)
		end

		status.BackgroundColor3 = color2
		local send = v4.Fill.Send
		local backgroundColor

		if data.inGame and data.canInvite or data.isFriend then
			backgroundColor = Color3.fromRGB(81, 158, 86)
		else
			backgroundColor = Color3.fromRGB(112, 112, 112)
		end

		send.BackgroundColor3 = backgroundColor

		if not data.inGame then
			layoutOrder += 300
		end

		v4.LayoutOrder = layoutOrder
	end

	local function createUserCard(localList, data, k: number)
		local formatted = `{data.username}_{data.userId}`
		local clone = duelsMachinePlayerList.LocalList.UIListLayout.Template:Clone()
		clone.Name = formatted
		clone.Fill.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={data.userId}&w=100&h=100`
		clone.Fill.Username.Text = `@{data.username}`
		updateUserCard(localList, data, k, clone)
		clone.Visible = true
		clone.Parent = localList
		local v4 = false
		clone.Fill.Send.Activated:Connect(function()
			if not data.canInvite or v4 then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")

			if data.inGame then
				v4 = true
				xpcall(function()
					local v5, v6 = DuelsMachineController:SendInvite(data.userId)

					if not v5 and typeof(v6) == "string" then
						NotificationController:Error(v6)
					end

					clone.Fill.Send.Txt.Text = v5 and "SENT!" or "FAILED"
					task.wait(5)
					clone.Fill.Send.Txt.Text = "SEND"
				end, warn)
				v4 = false
			elseif data.isFriend then
				local success, result = pcall(function()
					return SocialService:CanSendGameInviteAsync(localPlayer)
				end)

				if not (success and result) then
					return
				end

				local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
				experienceInviteOptions.InviteUser = data.userId
				experienceInviteOptions.PromptMessage = `Invite {data.username} to a duel`
				experienceInviteOptions.LaunchData = HttpService:JSONEncode({
					type = "DuelsInvite",
					sender = localPlayer.UserId
				})
				SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
			end
		end)
		return clone
	end

	local maid = Trove.new()

	local function updateLists()
		local thread = coroutine.running()
		v3 = thread
		maid:Clean()

		if v2 == "Global" then
			return
		end

		local inGameFriends = Friends:GetInGameFriends(localPlayer)
		local v4 = {}

		if v2 == "Server" then
			for _, v5 in Players:GetPlayers() do
				if v5 ~= localPlayer then
					table.insert(v4, {
						username = v5.Name,
						userId = v5.UserId,
						inGame = true,
						canInvite = true,
						isFriend = table.find(inGameFriends, v5) ~= nil
					})
				end
			end
		elseif v2 == "Friends" then
			local onlineFriends, v5 = Friends:GetOnlineFriends()

			if onlineFriends and typeof(v5) == "table" then
				for _, v6 in v5 do
					table.insert(v4, {
						username = v6.UserName,
						userId = v6.VisitorId,
						inGame = v6.PlaceId and table.find(ServerData.AllPlaces, v6.PlaceId) ~= nil,
						canInvite = true,
						isFriend = true
					})
				end
			end
		end

		if thread ~= v3 then
			return
		end

		for k, v5 in v4 do
			maid:Add((createUserCard(duelsMachinePlayerList.LocalList, v5, k)))
		end
	end

	local function setTab(p: string)
		if v2 == p then
			return
		end

		v2 = p
		searchBox.Text = ""
		duelsMachinePlayerList.LocalList.Visible = v2 ~= "Global"
		duelsMachinePlayerList.GlobalList.Visible = v2 == "Global"
		duelsMachinePlayerList.SearchFrame.Visible = v2 == "Global"

		for _, button in duelsMachinePlayerList.Btns:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local name = button.Name
			local backgroundColor

			if v2 == name then
				backgroundColor = Color3.fromRGB(81, 158, 86)
			else
				backgroundColor = Color3.fromRGB(115, 152, 172)
			end

			button.BackgroundColor3 = backgroundColor
		end

		updateLists()
	end

	Players.PlayerAdded:Connect(function()
		if v2 == "Server" then
			updateLists()
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if v2 == "Server" then
			updateLists()
		end
	end)
	duelsMachinePlayerList.SearchFrame.SearchBox.ReturnPressedFromOnScreenKeyboard:Connect(function()
		duelsMachinePlayerList.SearchFrame.SearchBox:ReleaseFocus(true)
	end)
	duelsMachinePlayerList.SearchFrame.SearchBox.FocusLost:Connect(function(flag: boolean)
		local WAIT_INTERVAL = 5

		if not flag then
			return
		end

		local text = searchBox.Text
		searchBox.TextEditable = false
		searchBox.Active = false
		searchBox.Text = "..."
		maid:Clean()
		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(text)
		end)

		if success and typeof(result) == "number" then
			local success2, result2, inGame, canInvite = pcall(function()
				return remoteFunction2:InvokeServer(result)
			end)

			if success2 and result2 then
				local success3, result3 = pcall(function()
					return UsersAPI:GetUser(result)
				end)
				local maid2 = maid
				local globalList = duelsMachinePlayerList.GlobalList
				local v7 = {
					userId = result,
					username = 0,
					inGame = 0,
					canInvite = 0
				}
				local username

				if success3 and typeof(result3) == "table" and result3.IsLoaded then
					username = result3.Username
				else
					username = string.upper(text)
				end

				v7.username = username
				v7.inGame = inGame
				v7.canInvite = canInvite
				maid2:Add((createUserCard(globalList, v7, 1)))
				searchBox.Text = ""
				task.wait(WAIT_INTERVAL)
				searchBox.TextEditable = true
				searchBox.ClearTextOnFocus = true
				searchBox.Active = true
			else
				local searchBox2 = searchBox

				if typeof(result2) ~= "string" then
					result2 = typeof(inGame) ~= "string" and "Failed to search for user, try again later" or inGame
				end

				searchBox2.Text = result2
				task.wait(WAIT_INTERVAL)
				searchBox.Text = ""
				searchBox.TextEditable = true
				searchBox.Active = true
				return false
			end
		else
			searchBox.Text = string.find(result, "Unknown user") and "User not found!" or "Failed to search for user, try again later"
			task.wait(WAIT_INTERVAL)
			searchBox.Text = ""
			searchBox.TextEditable = true
			searchBox.Active = true
			return false
		end
	end)

	for _, button in duelsMachinePlayerList.Btns:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local name = button.Name
		local v4 = AnimatedButton.new(button)
		v4:Animate()
		v4.OnActivated:Connect(function()
			setTab(name)
		end)
	end

	setTab("Server")
	Observers.observeTag("DuelsMachinePrompt", function(p)
		local triggeredConnection = p.Triggered:Connect(function()
			InterfaceController:Toggle("DuelsMachinePlayerList")
		end)
		return function()
			triggeredConnection:Disconnect()
		end
	end)
end

function DuelsMachineController._createInvites(_)
	local v = {}
	remoteEvent2.OnClientEvent:Connect(function(id: string, invite)
		local serverTimeNow = workspace:GetServerTimeNow()
		local v2 = invite.expires - serverTimeNow

		if v2 <= 0 then
			return
		end

		local user = UsersAPI:GetUser(invite.from)

		if not user then
			return
		end

		local thread = nil
		local clone = duelsMachinePrompt.InviteTemplate:Clone()
		clone.Username.Text = `@{user.Username} invited you to a Duel!`
		clone.Visible = true
		local v3 = CornerNotificationController:Add(clone)
		local v4 = {
			id = id,
			invite = invite,
			frame = clone
		}
		table.insert(v, v4)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroy()
			local index = table.find(v, v4)

			if not index then
				return
			end

			table.remove(v, index)
			v3()
		end

		CreateTween(clone.Fill, TweenInfo.new(v2), {
			Size = UDim2.fromScale(0, clone.Fill.Size.Y.Scale)
		})
		local flag = false
		clone.Yes.Activated:Connect(function()
			if flag then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")

			if workspace:GetServerTimeNow() > invite.expires then
				destroy() -- equivalent call inferred; original call site unknown
			else
				flag = true

				if thread and coroutine.status(thread) == "suspended" then
					pcall(task.cancel, thread)
				end

				destroy() -- equivalent call inferred; original call site unknown
				xpcall(function()
					local v5, v6 = remoteFunction:InvokeServer(id)

					if not v5 and typeof(v6) == "string" then
						NotificationController:Error(v6)
					end
				end, warn)
				flag = false
			end
		end)
		clone.No.Activated:Connect(function()
			if not (workspace:GetServerTimeNow() > invite.expires) then
				SoundController:PlaySound("Sounds.Sfx.Activated")

				if thread and coroutine.status(thread) == "suspended" then
					pcall(task.cancel, thread)
				end
			end

			destroy() -- equivalent call inferred; original call site unknown
		end)
		v4.frame = clone
		thread = task.delay(v2, destroy)
	end)
	remoteEvent3.OnClientEvent:Connect(function(p: number)
		local _, result = pcall(function()
			return UsersAPI:GetUser(p)
		end)

		if not (result and result.IsLoaded) then
			return
		end

		local v2 = Synchronizer:Wait(localPlayer)

		if not v2 then
			return
		end

		local v3 = ConfirmationController:Show(
			`You disconnected an active duel with @{result.Username}`,
			600,
			"ReconnectTemplate"
		)

		if not v3 then
			if v2:Get("DuelsReconnectWarn") then
				return
			end

			if ConfirmationController:Show(
				"Leaving the duel will count as a forfeit and you will lose your brainrot! Are you sure?",
				60,
				"WarningTemplate"
			) then
				remoteEvent:FireServer()
				return
			end
		end

		remoteEvent3:FireServer(v3)
	end)
end

function DuelsMachineController._createSelection(_)
	if ServerData.IsDuelsServer() then
		return
	end

	local v = ReplicatorClient.get((`DuelSelection_{localPlayer.UserId}`))
	local v2 = InterfaceController:Register("DuelsMachineSession", duelsMachineSession, "TopQuint")
	v2:AttachCloseButton(duelsMachineSession.Header.Close)
	v2:Close()
	local v3 = Synchronizer:Wait(localPlayer)
	local maid = nil
	local values = {}
	local v4 = {}

	local function getLocalPlayerIndex(p)
		if not (p and p.users) then
			return nil
		end

		for k, user in p.users do
			if user == localPlayer.UserId then
				return k
			end
		end

		return nil
	end

	local function getOtherPlayerIndex(p)
		if not (p and p.users) then
			return nil
		end

		for k, user in p.users do
			if user ~= localPlayer.UserId then
				return k
			end
		end

		return nil
	end

	local function teardownSession()
		if maid then
			maid:Clean()
			maid = nil
		end

		values = {}
		v4 = {}
		InterfaceController:SetState("DuelsMachineSession", false)
	end

	local function setupSession()
		if maid then
			return
		end

		maid = Trove.new()
		InterfaceController:SetState("DuelsMachineSession", true)
		duelsMachineSession.Mode.Text = ""
		duelsMachineSession.Your.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
		local maid2 = maid:Extend()
		maid:Add(v:Observe({ "active", "data", "lastChange" }, function(p: number)
			maid2:Clean()

			if p == nil then
				return
			end

			maid2:Add(Timer.Simple(0.1, function()
				local v5 = v:TryIndex({ "active", "data" })

				if not v5 then
					return
				end

				local serverTimeNow = workspace:GetServerTimeNow()
				local v6 = p + 5 - serverTimeNow
				duelsMachineSession.Other.Timer.Text = v6 <= 0 and "" or `⏰{math.floor(v6 * 10) / 10}s Left`
				local players = v5.players or {}
				local v7 = true

				for _, player in players do
					if player.brainrot then
						continue
					end

					v7 = false
					break
				end

				local v9

				if v5 and v5.users then
					for k, user in v5.users do
						if user ~= localPlayer.UserId then
							continue
						end

						v9 = k
						break
					end
				end

				local v10

				if v9 then
					v10 = players[v9]
				end

				local target = Spr.target
				local ready = duelsMachineSession.Other.Ready
				local backgroundColor

				if v6 <= 0 and v7 and next(players) and not (v10 and v10.accepted) then
					backgroundColor = Color3.fromRGB(81, 158, 86)
				else
					backgroundColor = Color3.fromRGB(112, 112, 112)
				end

				target(ready, 1, 5, {
					BackgroundColor3 = backgroundColor
				})
			end, true))
		end))

		local function updateFrame(p: string, item, p2)
			local item2 = p2.Item
			p2.Frame.Ready.Text = item.accepted and "ACCEPTED" or "READY"
			p2.Frame.Ready.Visible = item.ready
			local target = Spr.target
			local uIStroke = item2.UIStroke
			local color

			if item.ready then
				color = Color3.fromRGB(0, 255, 0)
			else
				color = Color3.fromRGB(0, 0, 0)
			end

			target(uIStroke, 1, 5, {
				Color = color
			})
			local formatted = `{item.indexOnPlot}_{item.brainrot and item.brainrot.UUID}`

			if values[p] == formatted then
				return
			end

			values[p] = formatted

			if not v4[p] then
				v4[p] = maid:Extend()
			end

			v4[p]:Clean()
			local brainrot = item.brainrot

			if brainrot then
				v4[p]:Add(BrainrotCard.ObserveOneOfOne(brainrot, function(flag: boolean)
					BrainrotCard.ApplyOneOfOne(p2, flag, false)
				end))
				item2.Title.Text = Animals:GetDisplayName(brainrot.Index)
				item2.Cash.Text = `${NumberUtils:ToString(Animals:GetGeneration(brainrot.Index, brainrot.Mutation, brainrot.Traits))}/s`
				local v9 = Animals:AttachOnViewportWithOptimizations(
					brainrot.Index,
					item2.ViewportFrame,
					nil,
					brainrot.Mutation
				)

				if v9 then
					v4[p]:Add(v9)
				end

				for _, name in brainrot.Traits or {} do
					local trait = Traits[name]

					if not trait then
						continue
					end

					local clone = v4[p]:Clone(item2.Traits.Template)
					clone.Name = name
					clone.Visible = true
					clone.Image = trait.Icon
					clone.Parent = item2.Traits
				end
			else
				BrainrotCard.ApplyOneOfOne(p2, false, false)
				item2.Title.Text = "Waiting for player to select..."
				item2.Cash.Text = ""
			end
		end

		maid:Add(v:Observe({ "active", "data", "players" }, function(items)
			if not items then
				return
			end

			local v5 = v:TryIndex({ "active", "data" })
			local v6

			if v5 and v5.users then
				for k, user in v5.users do
					if user ~= localPlayer.UserId then
						continue
					end

					v6 = k
					break
				end
			end

			local v7

			if v5 and v5.users then
				for k, user in v5.users do
					if user == localPlayer.UserId then
						continue
					end

					v7 = k
					break
				end
			end

			local flag = true

			for _, item in items do
				if item.ready and item.brainrot then
					continue
				end

				flag = false
				break
			end

			duelsMachineSession.Other.Ready.Txt.Text = flag and "ACCEPT" or "READY"

			if v6 and items[v6] then
				local item = items[v6]
				duelsMachineSession.Your.Frame.Ready.Text = item.accepted and "ACCEPTED" or "READY"
				duelsMachineSession.Your.Frame.Ready.Visible = item.ready
				duelsMachineSession.Main.Visible = flag
				duelsMachineSession.ScrollingFrame.Visible = not flag

				if flag then
					updateFrame(tostring(v6), item, duelsMachineSession.Main)
				end
			end

			if v7 and items[v7] then
				local item = items[v7]
				local v9

				if v5 then
					v9 = v5.users[v7]
				end

				local playerByUserId

				if v9 then
					playerByUserId = Players:GetPlayerByUserId(v9)
				end

				local username = duelsMachineSession.Other.Frame.Username
				local v11

				if playerByUserId then
					v11 = playerByUserId.Name
				else
					v11 = item.username or "???"
				end

				username.Text = `@{v11}'s Offer`

				if v9 then
					duelsMachineSession.Other.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v9}&w=100&h=100`
				end

				updateFrame(tostring(v7), item, duelsMachineSession.Other)
			end
		end))
		local maid3 = maid:Extend()
		maid:Add(v3:OnChanged("AnimalPodiums", function(items)
			maid3:Clean()

			for k, item in items do
				if typeof(item) ~= "table" or item.Machine then
					continue
				end

				local clone = maid3:Clone(duelsMachineSession.ScrollingFrame.Template)
				clone.Visible = true
				BrainrotCard.Render(clone, item, maid3, "Duels")
				maid3:Add(BrainrotCard.ObserveOneOfOne(item, function(flag: boolean)
					BrainrotCard.ApplyOneOfOne(clone, flag, false)
				end))
				clone.Parent = duelsMachineSession.ScrollingFrame
				local v6 = k
				local v7 = item
				maid3:Add(clone.Spacer.Activated:Connect(function()
					SoundController:PlaySound("Sounds.Sfx.Activated")
					Net:RemoteEvent("DuelsMachineService/Selection/Select"):FireServer(v6, v7)
				end))
				local formatted = `{k}_{item.UUID}`
				local flag = true
				local v8 = v:TryIndex({ "active", "data" })
				local v9

				if v8 and v8.users then
					for k2, user in v8.users do
						if user ~= localPlayer.UserId then
							continue
						end

						v9 = k2
						break
					end
				else
					local k2 = nil
					v9 = k2
				end

				if not v9 then
					continue
				end

				local v10 = formatted
				local v11 = clone
				maid3:Add(v:Observe({
					"active",
					"data",
					"players",
					v9
				}, function(p)
					if not p then
						return
					end

					local v12 = v10 == `{p.indexOnPlot}_{p.brainrot and p.brainrot.UUID}`
					local color

					if v12 then
						color = Color3.fromRGB(15, 50, 15)
					else
						color = Color3.fromRGB(35, 45, 50)
					end

					local color2

					if v12 then
						color2 = Color3.fromRGB(0, 255, 0)
					else
						color2 = Color3.fromRGB(0, 0, 0)
					end

					if flag then
						flag = false
						v11.Spacer.BackgroundColor3 = color
						v11.Spacer.UIStroke.Color = color2
					else
						Spr.target(v11.Spacer, 1, 5, {
							BackgroundColor3 = color
						})
						Spr.target(v11.Spacer.UIStroke, 1, 5, {
							Color = color2
						})
					end
				end))
			end
		end, true))
	end

	v:Observe({ "active" }, function(p)
		if not DuelsFlags.PreTeleportSelection:Get() then
			teardownSession()
			return
		end

		local v5

		if p == nil then
			v5 = false
		else
			v5 = p.data ~= nil
		end

		if v5 then
			setupSession()
		else
			teardownSession()
		end
	end)
	duelsMachineSession.Other.Ready.Activated:Connect(function()
		if not DuelsFlags.PreTeleportSelection:Get() then
			return
		end

		local v5 = v:TryIndex({ "active" })

		if not (v5 and v5.data) then
			return
		end

		SoundController:PlaySound("Sounds.Sfx.Activated")
		local players = v5.data.players

		if not players then
			return
		end

		local flag = true

		for _, player in players do
			if player.ready and player.brainrot then
				continue
			end

			flag = false
			break
		end

		if flag then
			Net:RemoteEvent("DuelsMachineService/Selection/Accept"):FireServer()
		else
			Net:RemoteEvent("DuelsMachineService/Selection/Ready"):FireServer()
		end
	end)
	duelsMachineSession.Other.Cancel.Activated:Connect(function()
		if not DuelsFlags.PreTeleportSelection:Get() then
			return
		end

		local v5 = v:TryIndex({ "active" })

		if v5 and v5.data then
			SoundController:PlaySound("Sounds.Sfx.Activated")
			Net:RemoteEvent("DuelsMachineService/Selection/Cancel"):FireServer()
		end
	end)
	v2.OnClose:Connect(function()
		if not DuelsFlags.PreTeleportSelection:Get() then
			return
		end

		local v5 = v:TryIndex({ "active" })

		if v5 and v5.data then
			Net:RemoteEvent("DuelsMachineService/Selection/Cancel"):FireServer()
		end
	end)
end

function DuelsMachineController:Start()
	task.spawn(self._createPlayerList, self)
	task.spawn(self._createInvites, self)
	task.spawn(self._createSelection, self)
end

return DuelsMachineController