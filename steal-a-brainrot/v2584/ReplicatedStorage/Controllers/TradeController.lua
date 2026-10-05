game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.Observers)
local UsersAPI = require(ReplicatedStorage.Shared.UsersAPI)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local HoverInfoController = require(ReplicatedStorage.Controllers.HoverInfoController)
local CornerNotificationController = require(ReplicatedStorage.Controllers.CornerNotificationController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Bases = require(ReplicatedStorage.Datas.Bases)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local TradingFlags = require(ReplicatedStorage.Shared.Flags.TradingFlags)
local Friends = require(ReplicatedStorage.Shared.Friends)
local BaseSkins = require(ReplicatedStorage.Shared.BaseSkins)
local Gears = require(ReplicatedStorage.Shared.Gears)
local Index = require(ReplicatedStorage.Datas.Index)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local prompt = playerGui:WaitForChild("TradePrompts").Prompt
local tradePlayerList = playerGui:WaitForChild("TradePlayerList").TradePlayerList
local tradeLiveTrade = playerGui:WaitForChild("TradeLiveTrade").TradeLiveTrade
local remoteEvent = Net:RemoteEvent("TradeService/CreateInvite")
local remoteEvent2 = Net:RemoteEvent("TradeService/DeclineInvite")
local remoteEvent3 = Net:RemoteEvent("TradeService/InviteResult")
local remoteFunction = Net:RemoteFunction("TradeService/AcceptInvite")
local remoteFunction2 = Net:RemoteFunction("TradeService/SearchUser")
local remoteFunction3 = Net:RemoteFunction("TradeService/Invite")
local remoteEvent4 = Net:RemoteEvent("TradeService/CancelTrade")
local remoteEvent5 = Net:RemoteEvent("TradeService/SendChatMessage")
local remoteFunction4 = Net:RemoteFunction("TradeService/AddBrainrot")
local remoteFunction5 = Net:RemoteFunction("TradeService/RemoveBrainrot")
local remoteFunction6 = Net:RemoteFunction("TradeService/AddItem")
local remoteFunction7 = Net:RemoteFunction("TradeService/RemoveItem")
local remoteFunction8 = Net:RemoteFunction("TradeService/GetTradeHistory")
local remoteEvent6 = Net:RemoteEvent("TradeService/HistoryUpdated")
Net:RemoteEvent("TradeService/TradeCompleted")
local remoteEvent7 = Net:RemoteEvent("TradeService/Accept")
local remoteEvent8 = Net:RemoteEvent("TradeService/Ready")
local remoteFunction9 = Net:RemoteFunction("SettingsService/ToggleSetting")

local function brainrotKey(data)
	return (`{data.UUID or ""}:{data.Index or ""}:{data.Mutation or ""}:{table.concat(data.Traits or {}, ",")}:{tostring(data.OneOfOne)}`)
end

local function renderBrainrotCard(p, data, maid, p2)
	BrainrotCard.Render(p, data, maid, p2)

	if FFlags:GetInstant("TradeController/EnableHoverInfo", true) then
		maid:Add(HoverInfoController:Add(p, function()
			return data.Index, data.Mutation, data.Traits
		end))
	end
end

local function renderBaseSkinCard(p, p2, object)
	p.Spacer.Title.Text = p2.SkinName
	p.Spacer.Cash.Text = "Base Skin"
	local viewportFrame = p.Spacer.ViewportFrame
	local image = BaseSkins.GetImage(p2.SkinName)

	if image then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "SkinImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Image = image
		imageLabel.Parent = viewportFrame
		object:Add(imageLabel)
	else
		local v = Index[p2.SkinName]

		if v and v.MainColor then
			viewportFrame.BackgroundColor3 = v.MainColor
		end
	end
end

local function renderGearCard(p, p2, object)
	p.Spacer.Title.Text = Gears.GetDisplayName(p2.GearName)
	p.Spacer.Cash.Text = "Gear"
	local viewportFrame = p.Spacer.ViewportFrame
	local image = Gears.GetImage(p2.GearName)

	if image then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "GearImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Image = image
		imageLabel.Parent = viewportFrame
		object:Add(imageLabel)
	end
end

local v = { "Brainrot", "BaseSkin", "Gear" }
local v2 = {
	Brainrot = {
		Id = "Brainrot",
		OfferKey = "brainrots",
		TabButton = "Brainrots",
		FetchInventory = function(object)
			local result = {}
			local animalPodiums = object:Get("AnimalPodiums")

			if typeof(animalPodiums) ~= "table" then
				return result
			end

			for k, animalPodium in animalPodiums do
				if typeof(animalPodium) ~= "table" or animalPodium.Machine or not Animals[animalPodium.Index] then
					continue
				end

				table.insert(result, {
					SelKey = tostring(k),
					RefKey = tostring(k),
					ContentKey = brainrotKey(animalPodium),
					Record = animalPodium,
					Ref = {
						podiumIndex = k,
						brainrot = animalPodium
					}
				})
			end

			return result
		end,
		RenderCard = renderBrainrotCard,
		ReadOffer = function(p)
			local brainrotsByIndexOnPlot = {}
			local brainrots = p.brainrots

			if typeof(brainrots) ~= "table" then
				return brainrotsByIndexOnPlot
			end

			for _, brainrot in brainrots do
				if typeof(brainrot) == "table" and brainrot.IndexOnPlot ~= nil then
					brainrotsByIndexOnPlot[tostring(brainrot.IndexOnPlot)] = brainrot
				end
			end

			return brainrotsByIndexOnPlot
		end,
		OfferContentKey = function(p)
			return (brainrotKey(p))
		end,
		Add = function(self)
			local v3, v4 = remoteFunction4:InvokeServer(
				"c85a2323-36b2-4121-968a-c064a6168aff",
				self.podiumIndex,
				self.brainrot
			)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end,
		Remove = function(p)
			local v3, v4 = remoteFunction5:InvokeServer(
				"4677f337-8006-49ac-b68d-9cd485140425",
				p.podiumIndex,
				p.brainrot
			)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end
	},
	BaseSkin = {
		Id = "BaseSkin",
		OfferKey = "baseSkins",
		TabButton = "BaseSkins",
		FetchInventory = function(object)
			local result = {}
			local baseSkinInventory = object:Get("BaseSkinInventory")

			if typeof(baseSkinInventory) ~= "table" then
				return result
			end

			for k, v3 in baseSkinInventory do
				if not (typeof(k) == "string" and typeof(v3) == "table" and typeof(v3.SkinName) == "string") then
					continue
				end

				if not BaseSkins.IsTradable(v3.SkinName) then
					continue
				end

				table.insert(result, {
					SelKey = k,
					RefKey = k,
					ContentKey = `{k}:{v3.SkinName}`,
					Record = {
						UUID = k,
						SkinName = v3.SkinName
					},
					Ref = {
						UUID = k,
						SkinName = v3.SkinName
					}
				})
			end

			return result
		end,
		RenderCard = renderBaseSkinCard,
		ReadOffer = function(p)
			local baseSkinsByUUID = {}
			local baseSkins = p.baseSkins

			if typeof(baseSkins) ~= "table" then
				return baseSkinsByUUID
			end

			for _, baseSkin in baseSkins do
				if not (typeof(baseSkin) == "table" and typeof(baseSkin.UUID) == "string") then
					continue
				end

				baseSkinsByUUID[baseSkin.UUID] = baseSkin
			end

			return baseSkinsByUUID
		end,
		OfferContentKey = function(p)
			return (`{p.UUID or ""}:{p.SkinName or ""}`)
		end,
		Add = function(self)
			local v3, v4 = remoteFunction6:InvokeServer("6786cce9-00d8-41e9-8beb-d96e0412b78b", "BaseSkin", self)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end,
		Remove = function(p)
			local v3, v4 = remoteFunction7:InvokeServer("a76f153f-d0cd-4fe4-ba26-a2755f3ec266", "BaseSkin", p)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end
	},
	Gear = {
		Id = "Gear",
		OfferKey = "gears",
		TabButton = "Gears",
		FetchInventory = function(p)
			local result = {}

			for _, v3 in Gears.ListOwned(p) do
				local UUID

				if typeof(v3.UUID) == "string" then
					UUID = v3.UUID
				else
					UUID = `name:{v3.GearName}`
				end

				table.insert(result, {
					SelKey = UUID,
					RefKey = UUID,
					ContentKey = `{UUID}:{v3.GearName}`,
					Record = {
						GearName = v3.GearName,
						UUID = v3.UUID
					},
					Ref = {
						GearName = v3.GearName,
						UUID = v3.UUID
					}
				})
			end

			return result
		end,
		RenderCard = renderGearCard,
		ReadOffer = function(p)
			local gears = {}
			local gears2 = p.gears

			if typeof(gears2) ~= "table" then
				return gears
			end

			for _, gear in gears2 do
				if not (typeof(gear) == "table" and typeof(gear.GearName) == "string") then
					continue
				end

				local v3

				if typeof(gear.UUID) == "string" then
					v3 = gear.UUID
				else
					v3 = `name:{gear.GearName}`
				end

				gears[v3] = gear
			end

			return gears
		end,
		OfferContentKey = function(p)
			return (`{p.UUID or p.GearName or ""}:{p.GearName or ""}`)
		end,
		Add = function(self)
			local v3, v4 = remoteFunction6:InvokeServer("6786cce9-00d8-41e9-8beb-d96e0412b78b", "Gear", self)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end,
		Remove = function(p)
			local v3, v4 = remoteFunction7:InvokeServer("a76f153f-d0cd-4fe4-ba26-a2755f3ec266", "Gear", p)

			if not v3 and typeof(v4) == "string" then
				NotificationController:Error(v4)
			end
		end
	}
}
local v3 = {}

for _, v4 in v do
	v3[v2[v4].TabButton] = v4
end

local v4 = {}
local v5 = {}

local function len(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count
end

local TradeController = {}

function TradeController:SendInvite(p: number, callback)
	local v6, v7, v8 = remoteFunction3:InvokeServer("8fbe1594-7cef-4c29-94d1-a0e93adfa5a4", p)

	if not v6 then
		return false, v7
	end

	if typeof(v8) ~= "string" then
		task.defer(callback, true, nil)
		return true
	end

	v4[v8] = callback
	local v9 = v5[v8]

	if v9 then
		v5[v8] = nil
		v4[v8] = nil
		task.defer(callback, v9.delivered, v9.message)
	end

	return true
end

function TradeController:_createPlayerList()
	local v6 = InterfaceController:Register("TradePlayerList", tradePlayerList, "TopQuint")
	v6:AttachCloseButton(tradePlayerList.Header.Close)
	v6:Close()
	local sections = tradePlayerList.Sections
	local players = sections.Players
	local list = players.List
	local searchBox = players.SearchFrame.SearchBox
	local scrollingFrame = sections.Settings.ScrollingFrame
	local scrollingFrame2 = sections.History.ScrollingFrame
	local clone = list.Frame:Clone()
	local clone2 = list.Separator:Clone()
	local v7 = {
		All = "Players",
		Friends = "History",
		Global = "Settings"
	}

	for _, guiObject in list:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local function updateUserCard(data, layoutOrder: number, clone3)
		clone3.Fill.Status2.Text = data.inGame and "Online" or data.isFriend and "Away" or "Offline"
		local status2 = clone3.Fill.Status2
		local color

		if data.inGame then
			color = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color = Color3.fromRGB(239, 225, 69)
		else
			color = Color3.fromRGB(211, 38, 38)
		end

		status2.TextColor3 = color
		local status = clone3.Fill.PlayerImage.Status
		local color2

		if data.inGame then
			color2 = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color2 = Color3.fromRGB(239, 225, 69)
		else
			color2 = Color3.fromRGB(211, 38, 38)
		end

		status.BackgroundColor3 = color2
		local send = clone3.Fill.Send
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

		clone3.LayoutOrder = layoutOrder
	end

	local function createUserCard(data, count: number)
		local clone3 = clone:Clone()
		clone3.Name = `{data.username}_{data.userId}`
		clone3.Fill.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={data.userId}&w=100&h=100`
		clone3.Fill.Username.Text = `@{data.username}`
		updateUserCard(data, count, clone3)
		clone3.Visible = true
		clone3.Parent = list
		local v8 = false
		clone3.Fill.Send.Activated:Connect(function()
			if not data.canInvite or v8 then
				return
			end

			SoundController:PlaySound("Sounds.Sfx.Activated")

			if data.inGame then
				v8 = true
				clone3.Fill.Send.Txt.Text = "SENDING..."
				local flag = false

				local function showResult(flag2: boolean, value: string?)
					if flag then
						return
					end

					flag = true

					if not flag2 and typeof(value) == "string" then
						NotificationController:Error(value)
					end

					clone3.Fill.Send.Txt.Text = flag2 and "SENT!" or "FAILED"
					task.delay(5, function()
						if clone3.Parent then
							clone3.Fill.Send.Txt.Text = "SEND"
						end

						v8 = false
					end)
				end

				if not (xpcall(function()
					local v9, v10 = self:SendInvite(data.userId, showResult)

					if not v9 then
						showResult(false, v10)
					end
				end, warn) or flag) then
					flag = true
					NotificationController:Error("Failed to send invite")
					clone3.Fill.Send.Txt.Text = "FAILED"
					task.delay(5, function()
						if clone3.Parent then
							clone3.Fill.Send.Txt.Text = "SEND"
						end

						v8 = false
					end)
				end
			elseif data.isFriend then
				local success, result = pcall(function()
					return SocialService:CanSendGameInviteAsync(localPlayer)
				end)

				if not (success and result) then
					return
				end

				local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
				experienceInviteOptions.InviteUser = data.userId
				experienceInviteOptions.PromptMessage = `Invite @{data.username} to trade`
				experienceInviteOptions.LaunchData = HttpService:JSONEncode({
					type = "TradeInvite",
					sender = localPlayer.UserId
				})
				SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
			end
		end)
		return clone3
	end

	local v8 = Trove.new()
	local v9 = false
	local count = 0

	local function renderServerPlayers()
		v9 = false
		count += 1
		local v10 = count
		v8:Clean()
		local inGameFriends = Friends:GetInGameFriends(localPlayer)
		local count2 = 0
		local v11 = {}

		for _, v12 in Players:GetPlayers() do
			if v12 == localPlayer then
				continue
			end

			count2 += 1
			v11[v12.UserId] = true
			local userCard = createUserCard({
				username = v12.Name,
				userId = v12.UserId,
				inGame = true,
				canInvite = true,
				isFriend = table.find(inGameFriends, v12) ~= nil
			}, count2)
			userCard.LayoutOrder = count2
			v8:Add(userCard)
		end

		task.spawn(function()
			local onlineFriends, v12 = Friends:GetOnlineFriends()

			if v10 ~= count or v9 or not onlineFriends or typeof(v12) ~= "table" then
				return
			end

			local v13 = {}

			for _, v14 in v12 do
				if v14.VisitorId == localPlayer.UserId or v11[v14.VisitorId] then
					continue
				end

				table.insert(v13, v14)
			end

			local layoutOrder = count2

			if count2 > 0 and #v13 > 0 then
				local clone3 = clone2:Clone()
				clone3.LayoutOrder = count2 + 1
				clone3.Visible = true
				clone3.Parent = list
				v8:Add(clone3)
				layoutOrder = clone3.LayoutOrder
			end

			for k, v14 in v13 do
				local v18 = createUserCard({
					username = v14.UserName,
					userId = v14.VisitorId,
					inGame = v14.PlaceId ~= nil and table.find(ServerData.AllPlaces, v14.PlaceId) ~= nil,
					canInvite = true,
					isFriend = true
				}, k)
				v18.LayoutOrder = layoutOrder + k
				v8:Add(v18)
			end
		end)
	end

	searchBox.ReturnPressedFromOnScreenKeyboard:Connect(function()
		searchBox:ReleaseFocus(true)
	end)
	searchBox.FocusLost:Connect(function(flag: boolean)
		local WAIT_INTERVAL = 5

		if not flag then
			return
		end

		local text = searchBox.Text

		if text == "" then
			renderServerPlayers()
			return
		end

		v9 = true
		count += 1
		searchBox.TextEditable = false
		searchBox.Active = false
		searchBox.Text = "..."
		v8:Clean()
		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(text)
		end)

		if success and typeof(result) == "number" then
			local success2, result2, inGame, canInvite = pcall(function()
				return remoteFunction2:InvokeServer("5bbf0ed7-abce-44dc-aec6-d72992f7e476", result)
			end)

			if success2 and result2 then
				local success3, result3 = pcall(function()
					return UsersAPI:GetUser(result)
				end)
				local maid = v8
				local v13 = {
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

				v13.username = username
				v13.inGame = inGame
				v13.canInvite = canInvite
				maid:Add((createUserCard(v13, 1)))
				searchBox.Text = ""
				task.wait(WAIT_INTERVAL)
				searchBox.TextEditable = true
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
				renderServerPlayers()
			end
		else
			searchBox.Text = typeof(result) == "string" and string.find(result, "Unknown user") and "User not found!" or "Failed to search for user, try again later"
			task.wait(WAIT_INTERVAL)
			searchBox.Text = ""
			searchBox.TextEditable = true
			searchBox.Active = true
			renderServerPlayers()
		end
	end)
	Players.PlayerAdded:Connect(function()
		if not v9 then
			renderServerPlayers()
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if not v9 then
			renderServerPlayers()
		end
	end)
	local v10 = Synchronizer:Wait(localPlayer)
	local maid = Trove.new()
	local clone3 = scrollingFrame.Template:Clone()

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local function renderSettings()
		maid:Clean()

		if not v10 then
			return
		end

		local text = v10:Get("Settings.Receive Trades from") or "Everyone"
		local clone4 = maid:Clone(clone3)
		clone4.Name = "Receive Trades from"
		clone4.Function.Text = "Receive Trades From"
		local color

		if text == "Everyone" then
			color = Color3.fromRGB(12, 119, 60)
		elseif text == "Friends" then
			color = Color3.fromRGB(255, 149, 0)
		else
			color = Color3.fromRGB(245, 56, 56)
		end

		local color2

		if text == "Everyone" then
			color2 = Color3.fromRGB(2, 56, 0)
		elseif text == "Friends" then
			color2 = Color3.fromRGB(190, 111, 0)
		else
			color2 = Color3.fromRGB(177, 0, 0)
		end

		local button = clone4.Buttons.Button
		button.Text.Text = text
		button.BackgroundColor3 = color
		button.UIStroke.Color = color2
		button.Text.UIStroke.Color = color2
		local v12 = AnimatedButton.new(button)
		maid:Add(v12)
		v12:Animate()
		maid:Add(v12.OnActivated:Connect(function()
			local v13, v14 = remoteFunction9:InvokeServer(
				"Receive Trades from",
				text == "Everyone" and "Friends" or text == "Friends" and "No one" or "Everyone"
			)

			if not v13 then
				NotificationController:Error(typeof(v14) ~= "string" and "Failed to update setting" or v14)
				SoundController:PlaySound("Sounds.Sfx.Error")
			end
		end))
		clone4.LayoutOrder = 1
		clone4.Visible = true
		clone4.Parent = scrollingFrame
		local v13 = v10:Get("Settings.Only Receive Trades With") == true
		local clone5 = maid:Clone(clone3)
		clone5.Name = "Only Receive Trades With"
		clone5.Function.Text = "Only Receive Trades With"
		local color3

		if v13 then
			color3 = Color3.fromRGB(12, 119, 60)
		else
			color3 = Color3.fromRGB(112, 112, 112)
		end

		local color4

		if v13 then
			color4 = Color3.fromRGB(2, 56, 0)
		else
			color4 = Color3.fromRGB(64, 64, 64)
		end

		local button2 = clone5.Buttons.Button
		button2.Text.Text = v13 and "ON" or "SELECT"
		button2.BackgroundColor3 = color3
		button2.UIStroke.Color = color4
		button2.Text.UIStroke.Color = color4
		local v14 = AnimatedButton.new(button2)
		maid:Add(v14)
		v14:Animate()
		maid:Add(v14.OnActivated:Connect(function()
			local v15, v16 = remoteFunction9:InvokeServer("Only Receive Trades With")

			if v15 then
				if not v13 then
					InterfaceController:Toggle("SelectBrainrots", true)
				end
			else
				NotificationController:Error(typeof(v16) ~= "string" and "Failed to update setting" or v16)
				SoundController:PlaySound("Sounds.Sfx.Error")
			end
		end))
		clone5.LayoutOrder = 2
		clone5.Visible = true
		clone5.Parent = scrollingFrame
	end

	renderSettings()

	if v10 then
		v10:OnChanged("Settings.Receive Trades from", renderSettings)
		v10:OnChanged("Settings.Only Receive Trades With", renderSettings)
	end

	local clone4 = scrollingFrame2.ClosedTemplate:Clone()
	local clone5 = scrollingFrame2.OpenedTemplate:Clone()

	for _, guiObject in scrollingFrame2:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function formatTradeTime(value)
		if typeof(value) == "number" then
			return (os.date("%b %d, %I:%M %p", (math.floor(value))))
		end

		return ""
	end

	local function fillItemScroll(itemsScroll, p, instance)
		local template = itemsScroll:FindFirstChild("Template")

		if not template then
			return
		end

		local uIGridLayout = itemsScroll:FindFirstChildOfClass("UIGridLayout")

		if uIGridLayout then
			local cellSize

			if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
				cellSize = UDim2.new(0.5, -2, 0.8, -2)
			else
				cellSize = UDim2.new(0.33, -2, 0.75, -2)
			end

			uIGridLayout.CellSize = cellSize
		end

		local clone6 = template:Clone()

		for _, guiObject in itemsScroll:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		for _, v11 in v do
			local v12 = v2[v11]
			local v13

			if typeof(p) == "table" then
				v13 = p[v12.OfferKey]
			end

			if typeof(v13) ~= "table" then
				continue
			end

			for _, v14 in v13 do
				local clone7 = instance:Clone(clone6)
				clone7.Visible = true
				v12.RenderCard(clone7, v14, instance, "TradeHistory")
				clone7.Parent = itemsScroll
			end
		end

		clone6:Destroy()
	end

	local function buildClosedRow(data, instance)
		local clone6 = instance:Clone(clone4)
		clone6.Visible = true
		local btn = clone6.Btn
		local v11 = nil
		local v12 = nil

		for _, label in btn:GetChildren() do
			if not label:IsA("TextLabel") then
				continue
			end

			if label.TextXAlignment == Enum.TextXAlignment.Right then
				v12 = label
			else
				v11 = label
			end
		end

		if v11 then
			v11.Text = `Trade with @{data.otherUsername or "?"}`
		end

		if v12 then
			v12.Text = formatTradeTime(data.time)
		end

		btn.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={data.otherUserId}&w=100&h=100`
		return clone6, btn
	end

	local function buildOpenedRow(data, instance)
		local clone6 = instance:Clone(clone5)
		clone6.Visible = true
		local btn = clone6.Btn
		btn.You.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
		fillItemScroll(btn.You.ItemsScroll, data.you, instance)
		btn.Other.Label.Text = `@{data.otherUsername or "?"}`
		btn.Other.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={data.otherUserId}&w=100&h=100`
		fillItemScroll(btn.Other.ItemsScroll, data.other, instance)
		return clone6, btn
	end

	local v11 = Trove.new()
	local v12 = {}
	local flag = false
	local flag2 = false

	local function renderHistoryRows()
		v11:Clean()
		local fn = nil

		for k, v13 in v12 do
			local flag3 = false
			local draw
			local maid2 = v11:Extend()
			local v14 = v13
			local layoutOrder = k
			local draw2 = draw

			draw = function()
				maid2:Clean()
				local v16, v17

				if flag3 then
					v16, v17 = buildOpenedRow(v14, maid2)
				else
					v16, v17 = buildClosedRow(v14, maid2)
				end

				v16.LayoutOrder = layoutOrder
				v16.Parent = scrollingFrame2
				maid2:Add(v17.Activated:Connect(function()
					SoundController:PlaySound("Sounds.Sfx.Activated")

					if flag3 then
						flag3 = false
						fn = nil
					else
						if fn then
							fn()
						end

						flag3 = true

						fn = function()
							flag3 = false
							draw2()
						end
					end

					draw2()
				end))
			end

			draw()
		end
	end

	local function ensureHistory()
		if flag then
			if flag2 then
				flag2 = false
				renderHistoryRows()
			end
		else
			local success, result, v13 = pcall(function()
				return remoteFunction8:InvokeServer("4702cbdd-7762-4861-9e77-109e0d3f5369")
			end)

			if not success or not result or typeof(v13) ~= "table" then
				return
			end

			v12 = v13
			flag = true
			flag2 = false
			renderHistoryRows()
		end
	end

	remoteEvent6.OnClientEvent:Connect(function(p)
		if not flag or typeof(p) ~= "table" then
			return
		end

		table.insert(v12, 1, p)

		if sections.History.Visible then
			renderHistoryRows()
		else
			flag2 = true
		end
	end)

	local function setSection(p: string)
		for _, guiObject in sections:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = guiObject.Name == p
			end
		end

		for _, button in tradePlayerList.Btns:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local backgroundColor

			if v7[button.Name] == p then
				backgroundColor = Color3.fromRGB(81, 158, 86)
			else
				backgroundColor = Color3.fromRGB(115, 152, 172)
			end

			button.BackgroundColor3 = backgroundColor
		end

		if p == "History" then
			task.spawn(ensureHistory)
		end
	end

	for _, button in tradePlayerList.Btns:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v13 = v7[button.Name]

		if not v13 then
			continue
		end

		local v14 = AnimatedButton.new(button)
		v14:Animate()
		local v15 = v13
		v14.OnActivated:Connect(function()
			SoundController:PlaySound("Sounds.Sfx.Activated")
			setSection(v15)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSearchVisibility()
		local instant = FFlags:GetInstant("TradeService/CrossServerDisabled", false)
		players.SearchFrame.Visible = not instant
	end

	updateSearchVisibility() -- equivalent call inferred; original call site unknown
	FFlags:OnUpdate(updateSearchVisibility)
	renderServerPlayers()
	setSection("Players")
end

function TradeController._createInvites(_)
	local v6 = {}
	remoteEvent.OnClientEvent:Connect(function(id: string, invite)
		local serverTimeNow = workspace:GetServerTimeNow()
		local v7 = invite.expires - serverTimeNow

		if v7 <= 0 then
			return
		end

		local user = UsersAPI:GetUser(invite.from)

		if not user then
			return
		end

		local thread = nil
		local clone = prompt:Clone()
		clone.Username.Text = `@{user.Username} wants to trade with you`
		clone.Visible = true
		local v8 = CornerNotificationController:Add(clone)
		local v9 = {
			id = id,
			invite = invite,
			frame = clone
		}
		table.insert(v6, v9)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroy()
			local index = table.find(v6, v9)

			if not index then
				return
			end

			table.remove(v6, index)
			v8()
		end

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
				xpcall(function()
					destroy() -- equivalent call inferred; original call site unknown
					local v10, v11 = remoteFunction:InvokeServer("8c94acca-6417-45e5-89f0-efb8b910cde7", id)

					if not v10 and typeof(v11) == "string" then
						NotificationController:Error(v11)
					elseif thread and coroutine.status(thread) == "suspended" then
						pcall(task.cancel, thread)
					end
				end, warn)
				flag = false
			end
		end)
		clone.No.Activated:Connect(function()
			if not (workspace:GetServerTimeNow() > invite.expires) then
				SoundController:PlaySound("Sounds.Sfx.Activated")
				remoteEvent2:FireServer("bbc2ca74-0896-4c80-9345-cdc8dd31d58d", id)

				if thread and coroutine.status(thread) == "suspended" then
					pcall(task.cancel, thread)
				end
			end

			destroy() -- equivalent call inferred; original call site unknown
		end)
		v9.frame = clone
		thread = task.delay(v7, destroy)
	end)
end

function TradeController._createLiveTrade(_)
	local v6 = ReplicatorClient.get((`Trade_{localPlayer.UserId}`))
	InterfaceController:Register("TradeLiveTrade", tradeLiveTrade, "TopQuint"):Close()
	local v7 = AnimatedButton.new(tradeLiveTrade.Header.Close)
	v7:Animate(nil, nil, 5)
	local v8 = Synchronizer:Wait(localPlayer)

	if not v8 then
		return
	end

	local maid = Trove.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupTrade()
		InterfaceController:SetState("TradeLiveTrade", false)
		maid:Clean()
	end

	local tradeId = nil
	v6:ListenRaw(function(p)
		if p == nil then
			tradeId = nil
			cleanupTrade() -- equivalent call inferred; original call site unknown
		else
			local v9 = v6:TryIndex({ "active", "data" })

			if v9 then
				if tradeId == v9.tradeId then
					InterfaceController:SetState("TradePlayerList", false)
					InterfaceController:SetState("TradeLiveTrade", true)
				else
					maid:Clean()
					InterfaceController:SetState("TradePlayerList", false)
					InterfaceController:SetState("TradeLiveTrade", true)
					tradeId = v9.tradeId
					local v10 = nil
					local v11 = nil
					local v12 = nil

					for k, v13 in v6:TryIndex({ "active", "data", "users" }) or {} do
						if v13 == localPlayer.UserId then
							v10 = k
						else
							v12 = v13
							v11 = k
						end
					end

					if not (v10 and v11 and v12) then
						return
					end

					local v13 = v6:TryIndex({
						"active",
						"data",
						"players",
						v11,
						"username"
					}) or "???"
					tradeLiveTrade.Other.Username.Text = `@{v13}'s Offer`
					tradeLiveTrade.Other.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v12}&w=100&h=100`
					tradeLiveTrade.Your.Username.Text = "Your Offer"
					tradeLiveTrade.Your.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=100&h=100`
					local chat = tradeLiveTrade.Chat
					local normalChat = chat.NormalChat
					local restrictedChat = chat.RestrictedChat
					local textBox = normalChat.ChatBox.TextBox
					local scrollingFrame = normalChat.ScrollingFrame
					local scrollingFrame2 = restrictedChat.ScrollingFrame
					local presets = restrictedChat.Presets
					chat.Header.Txt1.Text = "Trade Chat"
					local v14 = false
					local v15 = 0
					local extended = maid:Extend()
					local getTextBoundsParams = Instance.new("GetTextBoundsParams")
					getTextBoundsParams.RichText = false
					maid:Add(getTextBoundsParams)

					local function getChatMessages()
						local v16 = v6:TryIndex({ "active", "data", "chat" })

						if typeof(v16) ~= "table" then
							return {}
						end

						local v17 = {}

						for k in v16 do
							table.insert(v17, k)
						end

						table.sort(v17, function(a, b)
							return (tonumber(a) or 0) < (tonumber(b) or 0)
						end)
						local result = {}

						for _, v18 in v17 do
							local v19 = v16[v18]

							if not (typeof(v19) == "table" and typeof(v19.u) == "number" and typeof(v19.t) == "string") then
								continue
							end

							table.insert(result, v19)
						end

						return result
					end

					local function fitChatRow(frame, text: string)
						local label = frame.Label
						local X = label.AbsoluteSize.X

						if X < 1 then
							return
						end

						local parent = frame.Parent

						if not parent then
							return
						end

						local v16 = math.clamp(
							math.round(parent.AbsoluteSize.Y * TradingFlags.SignTextSizeRatio:Get()),
							TradingFlags.SignMinTextSize:Get(),
							TradingFlags.SignMaxTextSize:Get()
						)
						getTextBoundsParams.Font = label.FontFace
						getTextBoundsParams.Size = v16
						getTextBoundsParams.Width = X
						getTextBoundsParams.Text = text
						local success, textBoundsAsync = pcall(
							TextService.GetTextBoundsAsync,
							TextService,
							getTextBoundsParams
						)
						local Y

						if success then
							Y = textBoundsAsync.Y
						else
							Y = v16
						end

						if success and X < textBoundsAsync.X and textBoundsAsync.X > 0 then
							v16 = math.max(1, (math.floor(v16 * (X / textBoundsAsync.X))))
							getTextBoundsParams.Size = v16
							local success2, textBoundsAsync2 = pcall(
								TextService.GetTextBoundsAsync,
								TextService,
								getTextBoundsParams
							)

							if success2 then
								Y = textBoundsAsync2.Y
							end
						end

						label.TextScaled = false
						label.TextWrapped = true
						label.TextSize = v16
						local v17 = math.max(math.round(Y + v16), (math.round(v16 * 2)))
						frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, v17)
					end

					local function renderChat()
						extended:Clean()
						local parent

						if v14 then
							parent = scrollingFrame2
						else
							parent = scrollingFrame
						end

						local templateYou = parent.TemplateYou
						local templateOther = parent.TemplateOther
						templateYou.Visible = false
						templateOther.Visible = false
						local chatMessages = getChatMessages()
						local v17 = TradingFlags.SignMaxMessages:Get()
						local v18 = {}

						for i = math.max(1, #chatMessages - v17 + 1), #chatMessages do
							local chatMessage = chatMessages[i]
							local v21

							if chatMessage.u == localPlayer.UserId then
								v21 = templateYou
							else
								v21 = templateOther
							end

							local clone = extended:Clone(v21)
							clone.Name = `Message_{i}`
							clone.LayoutOrder = i
							clone.Label.Text = chatMessage.t
							clone.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={chatMessage.u}&w=100&h=100`
							clone.Visible = true
							clone.Parent = parent
							table.insert(v18, {
								frame = clone,
								text = chatMessage.t
							})
						end

						task.defer(function()
							for _, v19 in v18 do
								if v19.frame.Parent then
									fitChatRow(v19.frame, v19.text)
								end
							end

							parent.CanvasPosition = Vector2.new(0, parent.AbsoluteCanvasSize.Y)
						end)
					end

					local function updateChatMode()
						local v16 = (not TradingFlags.SignFreeTypeDisabled:Get() and v6:TryIndex({
							"active",
							"data",
							"players",
							v10,
							"canChat"
						}) and v6:TryIndex({
							"active",
							"data",
							"players",
							v11,
							"canChat"
						})) == true
						local visible = TradingFlags.SignEnabled:Get()
						local v18 = TradingFlags.SignPresetsEnabled:Get()

						if visible and not (v16 or v18) then
							visible = false
						end

						v14 = not v16
						chat.Visible = visible
						normalChat.Visible = visible and v16
						restrictedChat.Visible = visible and not v16
						local v19 = os.clock() < v15
						textBox.ClearTextOnFocus = false
						textBox.TextEditable = v16 and not v19
						textBox.Active = v16
						textBox.Interactable = v16
						renderChat()
					end

					local function applyChatCooldown(flag: boolean)
						local v16

						if flag then
							v16 = TradingFlags.SignPresetCooldown:Get()
						else
							v16 = TradingFlags.SignCooldown:Get()
						end

						v15 = os.clock() + v16
						updateChatMode()
						task.delay(v16, updateChatMode)
					end

					maid:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
						local text = string.gsub(textBox.Text, "[\r\n]", "")
						local v17 = TradingFlags.SignMaxLength:Get()

						if utf8.len(text) == nil then
							text = ""
						elseif v17 < #text then
							text = string.sub(text, 1, v17)
						end

						if textBox.Text ~= text then
							textBox.Text = text
						end
					end))
					maid:Add(textBox.Focused:Connect(function()
						local v16 = math.ceil(v15 - os.clock())

						if v16 > 0 then
							textBox:ReleaseFocus()
							NotificationController:Error((`Please wait {v16}s before sending another message`))
						end
					end))
					maid:Add(textBox.FocusLost:Connect(function(flag: boolean)
						if not (flag and TradingFlags.SignEnabled:Get()) then
							return
						end

						local text = textBox.Text

						if #text == 0 then
							return
						end

						SoundController:PlaySound("Sounds.Sfx.Activated")
						remoteEvent5:FireServer("a3b27b3c-4b9b-4a41-af45-7eea6cb59d86", text)
						textBox.Text = ""
						applyChatCooldown(false)
					end))
					local v16 = {}

					for _, button in presets:GetChildren() do
						if button:IsA("GuiButton") then
							table.insert(v16, {
								button = button,
								label = button:FindFirstChildWhichIsA("TextLabel")
							})
						end
					end

					table.sort(v16, function(a, b)
						return a.button.Name < b.button.Name
					end)

					local function updatePresetLabels()
						local v17 = TradingFlags.SignPresets:Get()

						for k, v18 in v16 do
							local text = v17[k] or ""

							if v18.label then
								v18.label.Text = text
							else
								v18.button.Text = text
							end

							v18.button.Visible = text ~= ""
						end
					end

					updatePresetLabels()
					maid:Add((TradingFlags.SignPresets.Changed:Connect(updatePresetLabels)))

					for k, v17 in v16 do
						local v18 = k
						maid:Add(v17.button.Activated:Connect(function()
							if not (TradingFlags.SignEnabled:Get() and TradingFlags.SignPresetsEnabled:Get()) then
								return
							end

							local v19 = math.ceil(v15 - os.clock())

							if v19 > 0 then
								NotificationController:Error((`Please wait {v19}s before sending another message`))
								return
							end

							local v20 = TradingFlags.SignPresets:Get()[v18]

							if not v20 or v20 == "" then
								return
							end

							SoundController:PlaySound("Sounds.Sfx.Activated")
							remoteEvent5:FireServer("a3b27b3c-4b9b-4a41-af45-7eea6cb59d86", v20)
							applyChatCooldown(true)
						end))
					end

					local flag = false

					local function queueRenderChat()
						if flag then
							return
						end

						flag = true
						task.defer(function()
							flag = false
							renderChat()
						end)
					end

					updateChatMode()
					maid:Add((TradingFlags.SignEnabled.Changed:Connect(updateChatMode)))
					maid:Add((TradingFlags.SignPresetsEnabled.Changed:Connect(updateChatMode)))
					maid:Add((TradingFlags.SignFreeTypeDisabled.Changed:Connect(updateChatMode)))
					maid:Add((TradingFlags.SignMaxMessages.Changed:Connect(renderChat)))
					maid:Add(v6:Listen({
						"active",
						"data",
						"players",
						tostring(v10),
						"canChat"
					}, updateChatMode))
					maid:Add(v6:Listen({
						"active",
						"data",
						"players",
						tostring(v11),
						"canChat"
					}, updateChatMode))
					maid:Add(v6:Listen({ "active", "data", "chat" }, renderChat))
					maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueRenderChat))
					maid:Add(scrollingFrame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueRenderChat))

					local function updateBaseSlots()
						local v17 = v6:TryIndex({ "active", "data", "players" })

						if typeof(v17) ~= "table" then
							return
						end

						local v18 = v17[v10]
						local v19 = v17[v11]

						if typeof(v18) ~= "table" or typeof(v19) ~= "table" then
							return
						end

						local count

						if typeof(v18.offer) == "table" and typeof(v18.offer.brainrots) == "table" then
							count = 0

							for _ in v18.offer.brainrots do
								count += 1
							end
						else
							count = 0
						end

						local count2

						if typeof(v19.offer) == "table" and typeof(v19.offer.brainrots) == "table" then
							count2 = 0

							for _ in v19.offer.brainrots do
								count2 += 1
							end
						else
							count2 = 0
						end

						local v20 = Bases[v8:Get("Rebirth")]

						if v20 then
							local maxAnimals = v20.MaxAnimals
							local animalPodiums = v8:Get("AnimalPodiums")
							local count3 = 0

							if animalPodiums then
								for i = 1, maxAnimals do
									if animalPodiums[i] ~= "Empty" and animalPodiums[i] ~= nil then
										count3 += 1
									end
								end
							end

							local v21 = count3 - count + count2
							tradeLiveTrade.Your.BaseSlots.Text = `{v21}/{maxAnimals}`
							local baseSlots = tradeLiveTrade.Your.BaseSlots
							local textColor

							if maxAnimals < v21 then
								textColor = Color3.fromRGB(255, 70, 70)
							else
								textColor = Color3.fromRGB(255, 255, 255)
							end

							baseSlots.TextColor3 = textColor
						end

						local maxSlots = v19.maxSlots
						local emptySlots = v19.emptySlots

						if typeof(maxSlots) == "number" and typeof(emptySlots) == "number" then
							local v21 = maxSlots - emptySlots - count2 + count
							tradeLiveTrade.Other.BaseSlots.Text = `{v21}/{maxSlots}`
							local baseSlots = tradeLiveTrade.Other.BaseSlots
							local textColor

							if maxSlots < v21 then
								textColor = Color3.fromRGB(255, 70, 70)
							else
								textColor = Color3.fromRGB(255, 255, 255)
							end

							baseSlots.TextColor3 = textColor
						end
					end

					maid:Add(v6:Observe({ "active", "data", "players" }, updateBaseSlots))
					maid:Add(v8:OnChanged("AnimalPodiums", updateBaseSlots))

					local function updateState()
						local v17 = v6:TryIndex({ "active", "data", "lastChange" })
						local v18 = v6:TryIndex({ "active", "data", "players" })
						local v19 = v6:TryIndex({ "active", "data", "users" })

						if typeof(v17) ~= "number" or typeof(v18) ~= "table" or typeof(v19) ~= "table" then
							return
						end

						local flag2 = false

						for _, v21 in v18 do
							if typeof(v21.offer) ~= "table" then
								continue
							end

							for _, v23 in v do
								local v24 = v21.offer[v2[v23].OfferKey]

								if not (typeof(v24) == "table" and next(v24)) then
									continue
								end

								flag2 = true
								break
							end

							if flag2 then
								break
							end
						end

						local flag3 = true

						for _, v22 in v18 do
							if v22.ready then
								continue
							end

							flag3 = false
							break
						end

						local v22 = true

						for _, v24 in v18 do
							if v24.accepted then
								continue
							end

							v22 = false
							break
						end

						local v24 = v18[table.find(v19, localPlayer.UserId)]
						local v25 = v17 + 5 - workspace:GetServerTimeNow()
						local v26 = v25 <= 0

						if v26 then
							if flag3 then
								if v24 and v24.accepted then
									v26 = false
								end
							elseif not flag2 or v24 and v24.ready then
								v26 = false
							end
						end

						local target = Spr.target
						local readyButton = tradeLiveTrade.Other.ReadyButton
						local backgroundColor

						if v26 then
							backgroundColor = Color3.fromRGB(81, 158, 86)
						else
							backgroundColor = Color3.fromRGB(112, 112, 112)
						end

						target(readyButton, 1, 5, {
							BackgroundColor3 = backgroundColor
						})
						tradeLiveTrade.Other.Timer.Text = (v22 or v6:TryIndex({ "active", "data", "isProcessing" })) and "Processing..." or v25 <= 0 and "" or `⏰{math.floor(v25 * 10) / 10}s Left`
					end

					local maid2 = maid:Extend()
					maid:Add(v6:Observe({ "active", "data", "lastChange" }, function(p2: number)
						maid2:Clean()

						if p2 == nil then
							return
						end

						maid2:Add(Timer.Simple(0.1, function()
							updateState()
						end, true))
					end))
					local v17 = {}
					local v18 = {}
					local v19 = {}

					for _, v20 in v do
						v17[v20] = maid:Extend()
						v18[v20] = {}
						v19[v20] = {}
					end

					local extended2 = maid:Extend()
					local v20 = v[1]
					local v21 = true

					-- equivalent calls inferred from this helper; original call sites unknown
					local function isTypeActive(p2: string)
						return p2 == "Brainrot" or not FFlags:GetInstant(
							"TradeService/GenericItemTradesDisabled",
							ServerData.IsProdGame()
						)
					end

					local function isSelectionVisible(p2: string, p3: string)
						return v21 and (p2 == v20 or v19[p2][p3] == true)
					end

					local function applySelectionColor(p2: string, data)
						local v22 = v19[p2][data.refKey] == true
						local isOneOfOne = data.isOneOfOne == true
						local spacer = data.frame.Spacer
						local oneOfOneBackground

						if isOneOfOne then
							oneOfOneBackground = BrainrotCard.OneOfOneBackground
						elseif v22 then
							oneOfOneBackground = Color3.fromRGB(15, 50, 15)
						else
							oneOfOneBackground = Color3.fromRGB(35, 45, 50)
						end

						spacer.BackgroundColor3 = oneOfOneBackground
						local uIStroke = data.frame.Spacer.UIStroke
						local color

						if v22 then
							color = Color3.fromRGB(0, 255, 0)
						elseif isOneOfOne then
							color = BrainrotCard.OneOfOneStroke
						else
							color = Color3.fromRGB(0, 0, 0)
						end

						uIStroke.Color = color
						local frame = data.frame
						local refKey = data.refKey
						frame.Visible = v21 and (p2 == v20 or v19[p2][refKey] == true)
						local frame2 = data.frame
						local layoutOrder

						if p2 == v20 then
							layoutOrder = data.order + 1000000
						else
							layoutOrder = data.order
						end

						frame2.LayoutOrder = layoutOrder
					end

					local function updateSelectionColors()
						for k, v22 in v18 do
							for _, v23 in v22 do
								applySelectionColor(k, v23)
							end
						end
					end

					local function setSelectionFramesVisible(flag2: boolean)
						v21 = flag2

						for k, v22 in v18 do
							for _, v23 in v22 do
								local frame = v23.frame
								local refKey = v23.refKey
								frame.Visible = v21 and (k == v20 or v19[k][refKey] == true)
							end
						end
					end

					local function renderInventory(p2: string)
						local v22 = v2[p2]
						local v23 = v18[p2]
						local v24 = v17[p2]
						local scrollingFrame3 = tradeLiveTrade.Your.ScrollingFrame

						if isTypeActive(p2) then
							local inventory = v22.FetchInventory(v8)
							local v25 = {}

							for k, v26 in inventory do
								v25[v26.SelKey] = true
								local v27 = v23[v26.SelKey]

								if v27 and v27.contentKey == v26.ContentKey then
									v27.order = k
									applySelectionColor(p2, v27)
								else
									if v27 then
										v27.trove:Clean()
										v23[v26.SelKey] = nil
									end

									local maid3 = v24:Extend()
									local clone = maid3:Clone(scrollingFrame3.Template)
									clone.Name = `Selection_{p2}_{v26.SelKey}`
									local refKey = v26.RefKey
									clone.Visible = v21 and (p2 == v20 or v19[p2][refKey] == true)
									v22.RenderCard(clone, v26.Record, maid3, "LiveTrade")
									clone.Parent = scrollingFrame3
									local flag2 = false
									local refKey2 = v26.RefKey
									local ref = v26.Ref
									maid3:Add(clone.Spacer.Activated:Connect(function()
										if flag2 then
											return
										end

										flag2 = true
										SoundController:PlaySound("Sounds.Sfx.Activated")

										if v19[p2][refKey2] then
											xpcall(v22.Remove, warn, ref)
										else
											xpcall(v22.Add, warn, ref)
										end

										flag2 = false
									end))
									local v30 = {
										frame = clone,
										trove = maid3,
										refKey = refKey2,
										contentKey = v26.ContentKey,
										order = k
									}
									v23[v26.SelKey] = v30

									if p2 == "Brainrot" then
										local v31 = v30
										local frame = clone
										maid3:Add(BrainrotCard.ObserveOneOfOne(v26.Record, function(isOneOfOne: boolean)
											v31.isOneOfOne = isOneOfOne
											BrainrotCard.ApplyOneOfOne(frame, isOneOfOne)
											applySelectionColor(p2, v31)
										end))
									else
										applySelectionColor(p2, v30)
									end
								end
							end

							for k, v26 in pairs(v23) do
								if v25[k] then
									continue
								end

								v26.trove:Clean()
								v23[k] = nil
							end
						else
							v24:Clean()
							table.clear(v23)
						end
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function renderAllInventories()
						for _, v22 in v do
							renderInventory(v22)
						end
					end

					local function renderOffers(object, p2, scrollingFrame3, p3)
						for _, v22 in v do
							if not p2[v22] then
								p2[v22] = {}
							end

							local v23 = p2[v22]

							if isTypeActive(v22) then
								local v24 = v2[v22]
								local offer = v24.ReadOffer(p3)
								local v25 = {}

								for k, v26 in offer do
									v25[k] = true
									local offerContentKey = v24.OfferContentKey(v26)
									local v27 = v23[k]

									if not (not v27 or v27.contentKey ~= offerContentKey) then
										continue
									end

									if v27 then
										v27.trove:Clean()
										v23[k] = nil
									end

									local extended3 = object:Extend()
									local clone = extended3:Clone(scrollingFrame3.Template)
									clone.LayoutOrder = v26.Order or 0
									clone.Visible = true
									v24.RenderCard(clone, v26, extended3, "LiveTrade")
									clone.Parent = scrollingFrame3
									v23[k] = {
										trove = extended3,
										contentKey = offerContentKey
									}
								end

								for k, v26 in pairs(v23) do
									if v25[k] then
										continue
									end

									v26.trove:Clean()
									v23[k] = nil
								end
							else
								for k, v24 in pairs(v23) do
									v24.trove:Clean()
									v23[k] = nil
								end
							end
						end
					end

					local function clearOfferStates(items)
						for _, item in items do
							for k, v22 in pairs(item) do
								v22.trove:Clean()
								item[k] = nil
							end
						end
					end

					local function setTab(p2: string)
						if not v2[p2] or p2 ~= "Brainrot" and FFlags:GetInstant(
							"TradeService/GenericItemTradesDisabled",
							ServerData.IsProdGame()
						) then
							return
						end

						v20 = p2

						for _, button in tradeLiveTrade["Side Buttons"]:GetChildren() do
							if not button:IsA("GuiButton") then
								continue
							end

							local backgroundColor

							if v3[button.Name] == p2 then
								backgroundColor = Color3.fromRGB(81, 158, 86)
							else
								backgroundColor = Color3.fromRGB(64, 86, 97)
							end

							button.BackgroundColor3 = backgroundColor
						end

						updateSelectionColors()
					end

					for _, button in tradeLiveTrade["Side Buttons"]:GetChildren() do
						if not button:IsA("GuiButton") then
							continue
						end

						local v22 = v3[button.Name]

						if v22 then
							button.Visible = isTypeActive(v22)
							local v23 = AnimatedButton.new(button)
							v23:Animate()
							maid:Add(v23)
							local v24 = v22
							maid:Add(v23.OnActivated:Connect(function()
								setTab(v24)
							end))
						else
							button.Visible = false
						end
					end

					local v22 = {}
					local v23 = false
					maid:Add(v6:Observe({ "active", "data", "players" }, function(items)
						for _, v24 in v do
							v19[v24] = {}
						end

						if typeof(items) == "table" then
							local item = items[v10]
							local v24 = (typeof(item) ~= "table" or typeof(item.offer) ~= "table") and {} or item.offer

							for _, v25 in v do
								local v26 = {}

								for k in v2[v25].ReadOffer(v24) do
									v26[k] = true
								end

								v19[v25] = v26
							end

							local flag2 = true

							for _, item2 in items do
								if item2.ready then
									continue
								end

								flag2 = false
								break
							end

							local v26 = true

							for _, item2 in items do
								if item2.accepted then
									continue
								end

								v26 = false
								break
							end

							tradeLiveTrade["Side Buttons"].Visible = not v26
							local ready = tradeLiveTrade.Your.Ready
							local ready2

							if item.accepted then
								ready2 = true
							elseif flag2 then
								ready2 = false
							else
								ready2 = item.ready
							end

							ready.Visible = ready2
							tradeLiveTrade.Your.Ready.Label.Text = item.accepted and "Confirmed!" or "Ready!"

							if flag2 then
								setSelectionFramesVisible(false)
								renderOffers(extended2, v22, tradeLiveTrade.Your.ScrollingFrame, v24)
							else
								if v23 then
									clearOfferStates(v22)
								end

								setSelectionFramesVisible(true)
								updateSelectionColors()
							end

							v23 = flag2
						else
							v23 = false
							clearOfferStates(v22)
							setSelectionFramesVisible(true)
							updateSelectionColors()
							tradeLiveTrade["Side Buttons"].Visible = true
						end
					end))
					renderAllInventories() -- equivalent call inferred; original call site unknown
					setTab(v[1])
					maid:Add(FFlags:OnChange("TradeService/GenericItemTradesDisabled", function()
						for _, button in tradeLiveTrade["Side Buttons"]:GetChildren() do
							if not button:IsA("GuiButton") then
								continue
							end

							local v24 = v3[button.Name]

							if v24 then
								button.Visible = isTypeActive(v24)
							end
						end

						if v20 ~= "Brainrot" and FFlags:GetInstant(
							"TradeService/GenericItemTradesDisabled",
							ServerData.IsProdGame()
						) then
							setTab("Brainrot")
						end

						renderAllInventories() -- equivalent call inferred; original call site unknown
					end))
					maid:Add(v8:OnChanged("AnimalAddedOrRemoved", function()
						renderInventory("Brainrot")
					end))
					maid:Add(v8:OnChanged("AnimalPodiums", function()
						renderInventory("Brainrot")
					end, true))
					maid:Add(v8:OnChanged("BaseSkinInventory", function()
						renderInventory("BaseSkin")
					end, true))
					maid:Add(v8:OnDictionaryInserted("BaseSkinInventory", function()
						renderInventory("BaseSkin")
					end))
					maid:Add(v8:OnDictionaryRemoved("BaseSkinInventory", function()
						renderInventory("BaseSkin")
					end))
					maid:Add(v8:OnChanged("GearInventory", function()
						renderInventory("Gear")
					end, true))
					maid:Add(v8:OnDictionaryInserted("GearInventory", function()
						renderInventory("Gear")
					end))
					maid:Add(v8:OnDictionaryRemoved("GearInventory", function()
						renderInventory("Gear")
					end))
					maid:Add(v8:OnDictionaryInserted("Items", function()
						renderInventory("Gear")
					end))
					maid:Add(v8:OnDictionaryRemoved("Items", function()
						renderInventory("Gear")
					end))
					local flag2 = false

					local function cancelTrade()
						if flag2 then
							return
						end

						flag2 = true
						SoundController:PlaySound("Sounds.Sfx.Activated")
						remoteEvent4:FireServer("171b5ced-5729-49c0-8d80-9c1897ff1ea3")
						flag2 = false
					end

					maid:Add(tradeLiveTrade.Other.Cancel.Activated:Connect(cancelTrade))
					maid:Add(v7.OnActivated:Connect(cancelTrade))
					tradeLiveTrade.Other.ReadyButton.Txt.Text = "READY"
					maid:Add(tradeLiveTrade.Other.ReadyButton.Activated:Connect(function()
						SoundController:PlaySound("Sounds.Sfx.Activated")
						local v24 = v6:TryIndex({ "active", "data", "lastChange" })

						if typeof(v24) ~= "number" or workspace:GetServerTimeNow() < v24 + 5 then
							return
						end

						local v25 = v6:TryIndex({ "active", "data", "players" })

						if typeof(v25) ~= "table" then
							return
						end

						local flag3 = true

						for _, v27 in v25 do
							if v27.ready then
								continue
							end

							flag3 = false
							break
						end

						if flag3 then
							remoteEvent7:FireServer("86eea964-f19e-4ac6-b401-a71ecc89e596")
						else
							remoteEvent8:FireServer("23f15b0b-b633-4f6b-888f-5924b7425522")
						end
					end))
					local v24 = {}
					local v25 = {}
					maid:Add(v6:Observe({ "active", "data", "players" }, function(items)
						if typeof(items) ~= "table" then
							return
						end

						local flag3 = true

						for _, item in items do
							if item.ready then
								continue
							end

							flag3 = false
							break
						end

						tradeLiveTrade.Other.ReadyButton.Txt.Text = flag3 and "ACCEPT" or "READY"

						for k, item in items do
							local v27 = tonumber(k)

							if not (v27 and v27 ~= v10) then
								continue
							end

							local scrollingFrame3 = tradeLiveTrade.Other.ScrollingFrame

							if not v24[k] then
								v24[k] = maid:Extend()
								v25[k] = {}
							end

							local ready = tradeLiveTrade.Other.Ready
							local ready2

							if item.accepted then
								ready2 = true
							elseif flag3 then
								ready2 = false
							else
								ready2 = item.ready
							end

							ready.Visible = ready2
							tradeLiveTrade.Other.Ready.Label.Text = item.accepted and "Confirmed!" or "Ready!"
							renderOffers(v24[k], v25[k], scrollingFrame3, item.offer or {})
						end
					end))
				end
			else
				tradeId = nil
				cleanupTrade() -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

function TradeController:Start()
	remoteEvent3.OnClientEvent:Connect(function(value: string, delivered: boolean, value2: string?)
		if typeof(value) ~= "string" or typeof(delivered) ~= "boolean" or value2 ~= nil and typeof(value2) ~= "string" then
			return
		end

		local v6 = v4[value]

		if v6 then
			v4[value] = nil
			v6(delivered, value2)
		else
			local v7 = {
				delivered = delivered,
				message = value2
			}
			v5[value] = v7
			task.delay(5, function()
				if v5[value] == v7 then
					v5[value] = nil
				end
			end)
		end
	end)
	task.spawn(self._createPlayerList, self)
	task.spawn(self._createInvites, self)
	task.spawn(self._createLiveTrade, self)
end

return TradeController