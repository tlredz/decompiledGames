local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local clientGameModules = ReplicatedStorage3.ClientGameModules
local v2 = require3(ReplicatedStorage3.Shared.UniverseIds)
require3(ReplicatedStorage3.Packages.Cooldown)
local v3 = require3(ReplicatedStorage3.Packages.Net)
local v4 = require3(ReplicatedStorage3.Common.Utils)
local v5 = require3(ReplicatedStorage3.Packages.Replion)
require3(clientGameModules.GuiHandler)
require3(ReplicatedStorage3.Shared.TeamData)
local serverInfo = ReplicatedStorage3.ServerInfo
local v6 = require3(serverInfo)
local remoteEvent = v3:RemoteEvent("PlayerWantsToJoinStage")
local remoteEvent2 = v3:RemoteEvent("PlayerWantsToLeaveStage")
v3:RemoteEvent("ResponseToInviteForStage")
v3:RemoteEvent("SendInviteForStage")
local remoteEvent3 = v3:RemoteEvent("PlayerDevice")
local remoteFunction = v3:RemoteFunction("GetDeviceTypeForPlayer")
local remoteEvent4 = v3:RemoteEvent("UpdateHUDTimer")
local remoteEvent5 = v3:RemoteEvent("PlatformCountdown")
local remoteFunction2 = v3:RemoteFunction("GetPlayerRatio")
local remoteEvent6 = v3:RemoteEvent("PlayerWonRound")
local remoteEvent7 = v3:RemoteEvent("PlayerLostRound")
local remoteEvent8 = v3:RemoteEvent("PlayerWonMatch")
local remoteEvent9 = v3:RemoteEvent("PlayerLostMatch")
local remoteEvent10 = v3:RemoteEvent("PlayerReturnToLobby")
local remoteEvent11 = v3:RemoteEvent("PlayerWantsRematch")
local remoteEvent12 = v3:RemoteEvent("SetDuelAutoQueue")
local v7 = {
	["1v1"] = 2,
	["2v2"] = 4,
	["3v3"] = 6,
	["4v4"] = 8
}
local v8 = {
	["1v1"] = {},
	["2v2"] = {},
	["3v3"] = {},
	["4v4"] = {}
}
local spawn = nil
local stages = nil
local localPlayer = Players.LocalPlayer
local duelUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("DuelUI")
local DuelController = {}

local function ShowRoundScreen(p, buttonText)
	p.Size = UDim2.fromScale(1, 0)
	p.BackgroundTransparency = 1
	buttonText.TextTransparency = 1
	p.Visible = true
	TweenService:Create(p, TweenInfo.new(0.5), {
		Size = UDim2.fromScale(1, 0.07),
		BackgroundTransparency = 0.2
	}):Play()
	TweenService:Create(buttonText, TweenInfo.new(0.6), {
		TextTransparency = 0
	}):Play()
	task.delay(5, function()
		TweenService:Create(p, TweenInfo.new(0.5), {
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(buttonText, TweenInfo.new(0.6), {
			TextTransparency = 1
		}):Play()
		task.delay(0.7, function()
			p.Visible = false
		end)
	end)
end

local function drawPlayerIcon(p: number, child)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.BorderSizePixel = 0
	imageLabel.BackgroundTransparency = 1
	imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={p}&w=100&h=100`
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(0.95, 0.95)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.ZIndex = 5
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	imageLabel.Parent = child
	return imageLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createRegion3FromPart(part)
	local size = part.Size
	local position = part.Position
	local v9 = position - size / 2
	local v10 = position + size / 2
	return Region3.new(v9, v10)
end

local function isCharacterInRegion(character, p)
	if not character.PrimaryPart then
		return false
	end

	local partsInRegion3 = workspace:FindPartsInRegion3(p, nil, 1e999)

	for _, v9 in pairs(partsInRegion3) do
		if v9:IsDescendantOf(character) then
			return true
		end
	end

	return false
end

function DuelController:RequestAddToStage(p, p2: number)
	remoteEvent:FireServer(p.Platform, p2)
end

function DuelController:RequestRemoveFromStage(p)
	remoteEvent2:FireServer(p.Platform)
end

function DuelController:AddPlayer(data, p: number, p2: number)
	local playerByUserId = Players:GetPlayerByUserId(p2)

	if not playerByUserId then
		warn("Player not found for UserID:", p2)
		return
	end

	data.SlotToPlayer[p] = playerByUserId
	data.PlayerToSlot[playerByUserId] = p
	local child = data.Platform:FindFirstChild(`Player_{p}`, true)
	local playerName = child:FindFirstChild("PlayerName")
	playerName.Text = playerByUserId.Name
	local icon = child:FindFirstChild("Icon", true)
	icon.Image = `rbxthumb://type=AvatarHeadShot&id={p2}&w=60&h=60`
	local BG = child:FindFirstChild("BG", true)
	local ratio = BG:FindFirstChild("Ratio")

	if not ratio then
		ratio = script.Ratio:Clone()
		ratio.Parent = BG
	end

	task.defer(function()
		local v9 = remoteFunction2:InvokeServer(playerByUserId)

		if not v9 then
			ratio.Visible = false
			return
		end

		ratio.Text = `W/L Ratio : {v9}%`
		ratio.Visible = true
	end)
	local device = child:FindFirstChild("Device", true)
	local v9 = remoteFunction:InvokeServer(playerByUserId)
	local child2 = v9 and device:FindFirstChild(v9)

	if child2 then
		child2.Visible = true
	end

	local connectivity = child:FindFirstChild("Connectivity", true)
	local networkPing = playerByUserId:GetNetworkPing()

	for i = 1, 3 do
		local child3 = connectivity:FindFirstChild((`{i}Bar`))

		if not child3 then
			continue
		end

		if networkPing <= 100 then
			child3.Visible = true
		elseif i > 1 then
			child3.Visible = false
		end
	end
end

function DuelController:ResetFrame(p, p2: number)
	local child = p.Platform:FindFirstChild(`Player_{p2}`, true)
	local playerName = child:FindFirstChild("PlayerName")
	playerName.Text = "N/A"
	local icon = child:FindFirstChild("Icon", true)
	icon.Image = ""
	local ratio = child:FindFirstChild("BG", true):FindFirstChild("Ratio")

	if ratio then
		ratio.Visible = false
	end

	for _, image in child:FindFirstChild("Device", true):GetChildren() do
		if image:IsA("ImageLabel") then
			image.Visible = false
		end
	end

	local connectivity = child:FindFirstChild("Connectivity", true)
	local child2 = connectivity:FindFirstChild((`{1}Bar`))

	if child2 then
		child2.Visible = false
	end

	local child3 = connectivity:FindFirstChild((`{2}Bar`))

	if child3 then
		child3.Visible = false
	end

	local child4 = connectivity:FindFirstChild((`{3}Bar`))

	if child4 then
		child4.Visible = false
	end
end

function DuelController:RemovePlayer(p, p2: number, p3)
	p.SlotToPlayer[p2] = nil
	p.PlayerToSlot[p3] = nil
	DuelController:ResetFrame(p, p2)
end

function DuelController:CreateStage(p: string, instance)
	local v9 = {
		Pads = {},
		PlayerToSlot = {},
		SlotToPlayer = {},
		Platform = instance
	}

	for i = 1, v7[p] do
		local child = instance:FindFirstChild((tostring(i)))
		local part = Instance.new("Part")
		local clone = script.Part:Clone()
		local folder = clone

		local function setVisual(flag: boolean)
			if flag then
				for i2, effect in folder:GetDescendants() do
					if effect:IsA("ParticleEmitter") then
						effect.Color = ColorSequence.new(Color3.fromRGB(89, 255, 89))
					elseif effect:IsA("Beam") then
						effect.Color = ColorSequence.new(Color3.fromRGB(89, 255, 89))
					end
				end
			else
				for i2, effect in folder:GetDescendants() do
					if effect:IsA("ParticleEmitter") then
						effect.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					elseif effect:IsA("Beam") then
						effect.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					end
				end
			end
		end

		if child then
			v9.Pads[i] = child
			local _, size = child:GetBoundingBox()
			clone.Parent = child
			local part2 = child:FindFirstChild("Part")
			part.Size = size
			part.Parent = child
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = true
			part.CFrame = part2.CFrame
			clone.CFrame = part.CFrame + createVector(0, 0.23, 0)
			local flag = false
			local region3FromPart = createRegion3FromPart(part) -- equivalent call inferred; original call site unknown
			local v12 = i
			v4.Thread.Every(0.1, function()
				local character = localPlayer.Character

				if character then
					if isCharacterInRegion(character, region3FromPart) then
						if flag then
							if instance:GetAttribute((`Platform{v12}`)) == nil then
								DuelController:RequestAddToStage(v9, v12)
							end
						else
							flag = true
							DuelController:RequestAddToStage(v9, v12)
						end
					elseif flag then
						flag = false
						DuelController:RequestRemoveFromStage(v9)
					end
				end
			end)
		end

		local v10 = i
		local setVisual2 = setVisual

		local function PlatformChanged()
			local attribute = instance:GetAttribute((`Platform{v10}`))

			if attribute == nil then
				setVisual2(false)
			else
				setVisual2(true)
			end

			if v9.SlotToPlayer[v10] and v9.SlotToPlayer[v10].UserId ~= attribute then
				DuelController:RemovePlayer(v9, v10, v9.SlotToPlayer[v10])
			end

			if attribute == nil then
				return
			end

			DuelController:AddPlayer(v9, v10, attribute)
		end

		local PlatformChanged2 = PlatformChanged
		instance:GetAttributeChangedSignal((`Platform{i}`)):Connect(function()
			PlatformChanged2()
		end)
		PlatformChanged()
		DuelController:ResetFrame(v9, i)
	end

	v8[p][tonumber(instance.Name)] = v9
end

function isPlayerOnMobile()
	return v:GetLastInputType() == Enum.UserInputType.Touch
end

function isPlayerOnDesktop()
	local lastInputType = v:GetLastInputType()
	return lastInputType == Enum.UserInputType.MouseButton1 or lastInputType == Enum.UserInputType.MouseButton2 or lastInputType == Enum.UserInputType.MouseWheel
end

function DuelController.Start(_)
	local duelMatchServer = v6.isDuelMatchServer()
	local rankedMatchServer = v6.isRankedMatchServer()

	if duelMatchServer then
		local value = serverInfo:WaitForChild("numPlayers").Value
		duelUI.Enabled = true
		local duelsHUD = duelUI:WaitForChild("DuelsHUD")
		duelsHUD.Visible = true
		task.defer(function()
			local isItemDuels = serverInfo:FindFirstChild("isItemDuels")
			local v9 = isItemDuels and isItemDuels.Value == true
			local desc = duelsHUD:WaitForChild("Timer"):WaitForChild("Desc")
			desc.Text = v9 and "ITEM DUEL" or "DUEL"
		end)
		local v9 = v5.Client:WaitReplion("DuelMatch")
		local maid = v4.Maid.new()

		local function ShowEndScreen(instance)
			maid:DoCleaning()
			instance:WaitForChild("Icon")
			local buttons = instance:WaitForChild("Buttons")
			local rematchButton = buttons:WaitForChild("RematchButton")
			local playAgain = buttons:WaitForChild("PlayAgain")
			local container = rematchButton:WaitForChild("Container")
			local exitButton = buttons:WaitForChild("ExitButton")
			local duelGlobalQueue = (TeleportService:GetLocalPlayerTeleportData() or {}).DuelGlobalQueue == true
			print("Is global queue match:", duelGlobalQueue)
			local inDuelParty = localPlayer:GetAttribute("InDuelParty")

			if inDuelParty ~= localPlayer.UserId and inDuelParty ~= tostring(localPlayer.UserId) then
				duelGlobalQueue = not inDuelParty and duelGlobalQueue
			end

			playAgain.Visible = duelGlobalQueue
			local isItemDuels = serverInfo:FindFirstChild("isItemDuels")
			rematchButton.Visible = not isItemDuels or isItemDuels.Value ~= true
			maid.ExitButtonAction = exitButton.Activated:Connect(function()
				if localPlayer:GetAttribute("ShowTeleportingUI") then
					return
				end

				remoteEvent10:FireServer()
			end)
			local buttonText = rematchButton:WaitForChild("ButtonText")
			maid.RematchButtonAction = rematchButton.Activated:Connect(function()
				if localPlayer:GetAttribute("Rematch") then
					return
				end

				remoteEvent11:FireServer()
			end)
			maid.PlayAgainButtonAction = playAgain.Activated:Connect(function()
				if localPlayer:GetAttribute("Rematch") then
					return
				end

				local v10 = math.clamp(math.ceil(serverInfo:WaitForChild("numPlayers").Value / 2), 1, 4)
				remoteEvent12:FireServer("Duel", (`{v10}v{v10}`))
			end)
			local rematch = v9:Get("Rematch")

			if rematch > 0 then
				buttonText.Text = `{rematch}/{value} Rematch`
			else
				buttonText.Text = "Rematch"
			end

			maid.RematchOnChange = v9:OnChange("Rematch", function(p)
				if p > 0 then
					buttonText.Text = `{p}/{value} Rematch`
				end
			end)

			for _, v10 in Players:GetPlayers() do
				local clone = script.RematchTemplate:Clone()
				clone.Image = `rbxthumb://type=AvatarHeadShot&id={v10.UserId}&w=100&h=100`
				clone.Visible = v10:GetAttribute("Rematch") == true
				clone.Parent = container
				maid:GiveTask(clone)
				local v11 = v10
				maid:GiveTask(v10:GetAttributeChangedSignal("Rematch"):Connect(function()
					local rematch2 = v11:GetAttribute("Rematch")

					if rematch2 then
						clone.Visible = rematch2
					else
						clone.Visible = false
					end
				end))
			end

			instance.Visible = true
		end

		local winScreen = duelUI:WaitForChild("WinScreen")
		remoteEvent8.OnClientEvent:Connect(function()
			ShowEndScreen(winScreen)
		end)
		local loseScreen = duelUI:WaitForChild("LoseScreen")
		remoteEvent9.OnClientEvent:Connect(function()
			ShowEndScreen(loseScreen)
		end)

		local function onGameActiveChanged(_: boolean)
			loseScreen.Visible = false
			winScreen.Visible = false
		end

		v9:OnChange("GameActive", onGameActiveChanged)
		local blueSide = duelsHUD:WaitForChild("BlueSide")
		local title = blueSide:WaitForChild("Title")

		local function onTeamOnePointsChanged(teamOnePoints: number)
			title.Text = tostring(teamOnePoints)

			for i = 1, 3 do
				local child = blueSide:FindFirstChild((`Round_{i}`))

				if not child then
					continue
				end

				if i <= teamOnePoints then
					child.ImageColor3 = Color3.fromRGB(255, 255, 255)
				else
					child.ImageColor3 = Color3.fromRGB(0, 0, 0)
				end
			end
		end

		v9:OnChange("TeamOnePoints", onTeamOnePointsChanged)
		local redSide = duelsHUD:WaitForChild("RedSide")
		local title2 = redSide:WaitForChild("Title")

		local function onTeamTwoPointsChanged(teamTwoPoints: number)
			title2.Text = tostring(teamTwoPoints)

			for i = 1, 3 do
				local child = redSide:FindFirstChild((`Round_{i}`))

				if not child then
					continue
				end

				if i <= teamTwoPoints then
					child.ImageColor3 = Color3.fromRGB(255, 255, 255)
				else
					child.ImageColor3 = Color3.fromRGB(0, 0, 0)
				end
			end
		end

		v9:OnChange("TeamTwoPoints", onTeamTwoPointsChanged)
		local bluePlayers = duelsHUD:WaitForChild("BluePlayers")
		local redPlayers = duelsHUD:WaitForChild("RedPlayers")
		local children = {}

		local function onTeamCacheChanged(teamCache)
			local v10 = teamCache[1]
			local v11 = teamCache[2]

			if not (v10 and v11) then
				return
			end

			for i = 1, #v10 do
				local v12 = v10[i]
				local child = bluePlayers:FindFirstChild((`Player_{i}`))

				if not child then
					continue
				end

				children[tonumber(v12)] = child
				child.Visible = true
				drawPlayerIcon(v12, child)
			end

			for i = 1, #v11 do
				local v12 = v11[i]
				local child = redPlayers:FindFirstChild((`Player_{i}`))

				if not child then
					continue
				end

				children[tonumber(v12)] = child
				child.Visible = true
				drawPlayerIcon(v12, child)
			end
		end

		v9:OnChange("TeamCache", onTeamCacheChanged)

		local function onDeadChanged(dead)
			for k, item in dead do
				local v10 = children[tonumber(k)]

				if not v10 then
					continue
				end

				local deadOverlay = v10:FindFirstChild("DeadOverlay", true)

				if deadOverlay then
					deadOverlay.Visible = item
				end
			end
		end

		v9:OnChange("Dead", onDeadChanged)
		task.spawn(function()
			onTeamOnePointsChanged(v9:Get("TeamOnePoints"))
			onTeamTwoPointsChanged(v9:Get("TeamTwoPoints"))
			local teamCache = v9:Get("TeamCache")

			if teamCache then
				onTeamCacheChanged(teamCache)
			end

			local dead = v9:Get("Dead")

			if dead then
				onDeadChanged(dead)
			end
		end)
	end

	if duelMatchServer or rankedMatchServer then
		duelUI.Enabled = true
		local roundWon = duelUI:WaitForChild("RoundWon")
		local buttonText = roundWon:WaitForChild("ButtonText")
		remoteEvent6.OnClientEvent:Connect(function()
			ShowRoundScreen(roundWon, buttonText)
		end)
		local roundLost = duelUI:WaitForChild("RoundLost")
		local buttonText2 = roundLost:WaitForChild("ButtonText")
		remoteEvent7.OnClientEvent:Connect(function()
			ShowRoundScreen(roundLost, buttonText2)
		end)
		local timer, title

		if rankedMatchServer then
			local rankedHUD = duelUI:WaitForChild("RankedHUD")
			timer = rankedHUD:WaitForChild("Timer")
			title = timer:WaitForChild("Title")
			timer.Visible = false
			rankedHUD.Visible = true
		else
			timer = duelUI:WaitForChild("DuelsHUD"):WaitForChild("Timer")
			title = timer:WaitForChild("Title")
		end

		remoteEvent4.OnClientEvent:Connect(function(p: number)
			title.Text = `{p}s`

			if p <= 1 then
				task.wait(1)
				timer.Visible = false
			elseif not timer.Visible then
				timer.Visible = true
			end
		end)
	end

	if not v6.isDuelLobbyServer() then
		return
	end

	spawn = workspace:WaitForChild("Spawn")
	stages = spawn:WaitForChild("Stages")
	remoteEvent5.OnClientEvent:Connect(function(instance, p: number)
		local cover = p <= 0 and instance:FindFirstChild("Cover", true)

		if cover then
			cover:Destroy()
			return
		end

		local cover2 = instance:FindFirstChild("Cover", true)

		if not cover2 then
			local surfaceGui = instance:FindFirstChild("SurfaceGui", true)

			if surfaceGui and surfaceGui.PixelsPerStud ~= 40 then
				surfaceGui.PixelsPerStud = 40
			end

			if surfaceGui then
				cover2 = script.Cover:Clone()
				cover2.Parent = surfaceGui:GetChildren()[1]
			end
		end

		local countdown = cover2:FindFirstChild("Countdown")
		countdown.Text = tostring(p)
	end)
	task.spawn(function()
		if isPlayerOnMobile() then
			remoteEvent3:FireServer("Mobile")
			return
		end

		if isPlayerOnDesktop() then
		end

		remoteEvent3:FireServer("PC")
	end)

	for _, child in stages:GetChildren() do
		local name = child.Name

		for _, child2 in child:GetChildren() do
			DuelController:CreateStage(name, child2)
		end
	end

	localPlayer = Players.LocalPlayer
	local joinData = localPlayer:GetJoinData()

	if joinData.Members and joinData.SourcePlaceId == v2.Default.PlaceId then
		local v9 = {}

		for _, member in joinData.Members do
			v9[member] = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playerAdded(player)
			if not v9[player.UserId] then
				return
			end

			local character = player.Character or player.CharacterAdded:Wait()
			local clone = script.Icon:Clone()
			clone.Parent = character:WaitForChild("Head")
		end

		Players.PlayerAdded:Connect(function(player)
			if not v9[player.UserId] then
				return
			end

			local character = player.Character or player.CharacterAdded:Wait()
			local clone = script.Icon:Clone()
			clone.Parent = character:WaitForChild("Head")
		end)

		for _, v10 in Players:GetPlayers() do
			playerAdded(v10) -- equivalent call inferred; original call site unknown
		end
	end
end

return DuelController