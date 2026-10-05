local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local v2 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v3 = require3(ReplicatedStorage2.Shared.MapData)
local v4 = require3(ReplicatedStorage2.Packages.Signal)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Packages.Net)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Packages.Observers)
local v9 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v10 = require3(ReplicatedStorage2.ServerInfo)
local v11 = v4.new()
local remoteEvent = v6:RemoteEvent("UpdateTrainingConfiguration")
local remoteEvent2 = v6:RemoteEvent("CustomModeStartMatch")
local remoteEvent3 = v6:RemoteEvent("CustomModeEndMatch")
local remoteEvent4 = v6:RemoteEvent("CustomModeResetPlayer")
local remoteEvent5 = v6:RemoteEvent("CustomModeTogglePlayer")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local HUD = playerGui:WaitForChild("HUD")
local clanButton = HUD.LeftFrame:FindFirstChild("ClanButton", true)
local settingsButton = HUD.LeftFrame:FindFirstChild("SettingsButton", true)
local backButton = HUD.LeftFrame:FindFirstChild("BackButton", true)
local AFK = HUD.LeftFrame:FindFirstChild("AFK", true)
local helpGuidePage = HUD.LeftFrame:FindFirstChild("HelpGuidePage", true)
local customModeUI = playerGui:WaitForChild("CustomModeUI")
local trainingModeServerPanel = playerGui:WaitForChild("TrainingModeServerPanel")
local frame = trainingModeServerPanel.Frame
local bots = frame.Bots
local game2 = frame.Game
local server = frame.Server
local playerPanel = trainingModeServerPanel.PlayerPanel
local notPlaying = playerPanel.NotPlaying
local playing = playerPanel.Playing
local playerTemplate = notPlaying.PlayerTemplate
playerTemplate.Parent = nil
local mapSelector = playerGui:WaitForChild("MapSelector")

local function mapN(p: number, p2: number, p3: number, p4: number, p5: number)
	return (p - p2) / (p3 - p2) * (p5 - p4) + p4
end

local function registerCheckbox(p: string, checkFrame)
	local v12 = nil

	local function updateVisual(visible: boolean)
		v12 = visible
		checkFrame.CheckIcon.Visible = visible
	end

	checkFrame.Activated:Connect(function()
		remoteEvent:FireServer({
			[p] = not v12
		})
	end)
	return function(p2)
		v2.observeReplionPath(p2, p, updateVisual)
	end
end

local TrainingModeController = {
	MapSelectionEnded = v4.new(),
	PromptMapSelection = function(self)
		mapSelector.Enabled = true
		return self.MapSelectionEnded:Wait()
	end,
	Start = function(self)
		local v12 = require3(ReplicatedStorage2.Controllers.CustomModeRulesController)
		frame.Close.Activated:Connect(function()
			v7:Close("TrainingModeServerPanel")
		end)
		v5.GuiUtils.getActivatedSignal(settingsButton):Connect(function()
			if v7:IsOpen("TrainingModeServerPanel") then
				v7:Close("TrainingModeServerPanel", true)
			else
				v7:Open("TrainingModeServerPanel", true)
			end
		end)
		onPermissionsChanged()
		v11:Connect(onPermissionsChanged)
		local serverOwner = ReplicatedStorage2.ServerInfo:FindFirstChild("serverOwner")

		if serverOwner then
			serverOwner:GetPropertyChangedSignal("Value"):Connect(function()
				v11:Fire()
			end)
		else
			ReplicatedStorage2.ServerInfo.ChildAdded:Connect(function(intValue)
				if intValue:IsA("IntValue") and intValue.Name == "serverOwner" then
					task.wait(0.1)
					v11:Fire()
				end
			end)
		end

		v5.GuiUtils.getActivatedSignal(backButton):Connect(function()
			backButton.Active = false
			task.delay(3, function()
				backButton.Active = true
			end)

			if v7:IsOpen("ServerSelection") then
				v7:Close("ServerSelection", true)
			else
				v7:Open("ServerSelection", true)
			end
		end)

		local function updateDifficultyVisual(p: string)
			for _, child in bots.Difficulties:GetChildren() do
				child.ImageTransparency = p == child.Name and 0 or 0.5
			end
		end

		for _, child in bots.Difficulties:GetChildren() do
			local v13 = child
			child.Activated:Connect(function()
				remoteEvent:FireServer({
					Difficulty = v13.Name
				})
			end)
		end

		local numberOfBots = 1

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCounterVisual(p: number)
			numberOfBots = p
			bots.Counter.Count.Text = `{p}/{10}`
			bots.Counter.Cursor.Position = UDim2.fromScale((p - 0) / 10 * 1 + 0, 0.5)
		end

		local function updateCounter()
			local X = v:GetMouseLocation().X
			local X2 = bots.Counter.AbsolutePosition.X
			local X3 = bots.Counter.AbsoluteSize.X
			local v14 = math.abs((math.clamp(math.round(((X - X2) / X3 - 0) / 1 * 10 + 0), 0, 10)))
			numberOfBots = v14
			updateCounterVisual(v14) -- equivalent call inferred; original call site unknown
		end

		local inputChangedConnection = nil
		bots.Counter.MouseButton1Down:Connect(function()
			updateCounter()
			inputChangedConnection = v.InputChanged:Connect(function(input, _)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				updateCounter()
			end)
		end)
		v.InputEnded:Connect(function(input, _)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and inputChangedConnection then
				inputChangedConnection:Disconnect()
				inputChangedConnection = nil
				remoteEvent:FireServer({
					NumberOfBots = numberOfBots
				})
			end
		end)
		local botIncrease = frame.BotIncrease
		local botDecrease = frame.BotDecrease

		-- equivalent calls inferred from this helper; original call sites unknown
		local function changeBotAmount(p)
			local v14 = numberOfBots
			local v15 = math.clamp(v14 + p, 0, 10)

			if v15 ~= v14 then
				updateCounterVisual(v15) -- equivalent call inferred; original call site unknown
				remoteEvent:FireServer({
					NumberOfBots = numberOfBots
				})
			end
		end

		botIncrease.Activated:Connect(function()
			changeBotAmount(1) -- equivalent call inferred; original call site unknown
		end)
		botDecrease.Activated:Connect(function()
			changeBotAmount(-1) -- equivalent call inferred; original call site unknown
		end)

		local function reflectLatestInputMode()
			local device = v9.Device
			local visible = device == "Console" or device == "Touch"
			botIncrease.Visible = visible
			botDecrease.Visible = visible
		end

		v9:Observe(reflectLatestInputMode)
		local v14 = registerCheckbox("Respawn", bots.Respawn.CheckFrame)
		local v15 = registerCheckbox("BotsMove", bots.Move.CheckFrame)

		local function updateGameModeVisual(p: string)
			for _, child in game2.Modes:GetChildren() do
				child.ImageTransparency = p == child.Name and 0 or 0.5
			end
		end

		for _, child in game2.Modes:GetChildren() do
			local v16 = child
			child.Activated:Connect(function()
				if v16.Name == "Custom" then
					customModeUI.Enabled = true
					server.ChangeRules.Visible = true
				else
					v12:CleanRules()
				end

				remoteEvent:FireServer({
					GameMode = v16.Name
				})
			end)
		end

		mapSelector.CloseButton.Activated:Connect(function()
			mapSelector.Enabled = false
			self.MapSelectionEnded:Fire()
		end)

		for k, v16 in v3 do
			if v16.DisabledInTraining then
				continue
			end

			local clone = mapSelector.Assets.MapTemplate:Clone()
			clone.Image = v16.Image
			clone.HoverImage = v16.HoverImage
			clone.Title.Text = v16.DisplayName
			local v17 = k
			clone.Activated:Connect(function()
				self.MapSelectionEnded:Fire(v17)
				mapSelector.Enabled = false
			end)
			clone.Parent = mapSelector.Maps.Container
			clone.Visible = true
		end

		local function updateMapVisual(p: string)
			local v16 = v3[p] or v3.TrainingMode
			game2.MapFrame.Map.Image = v16.Thumbnail or v16.Image
			game2.MapFrame.Label.Text = v16.DisplayName
		end

		game2.ChangeMap.Activated:Connect(function()
			local promptMapSelection = self:PromptMapSelection()

			if promptMapSelection then
				remoteEvent:FireServer({
					Map = promptMapSelection
				})
			end
		end)
		local v16 = registerCheckbox("ChangeAbilitiesMiddleRound", game2.Abilitymidround.CheckFrame)
		server.ChangeRules.Activated:Connect(function()
			customModeUI.Enabled = true
		end)
		local v17 = registerCheckbox("AutoStart", server.AutoStart.CheckFrame)
		server.StartRound.Activated:Connect(function()
			remoteEvent2:FireServer()
		end)
		server.EndRound.Activated:Connect(function()
			remoteEvent3:FireServer()
		end)
		server.Players.Activated:Connect(function()
			frame.Visible = false
			playerPanel.Visible = true
		end)
		playerPanel.Close.Activated:Connect(function()
			frame.Visible = true
			playerPanel.Visible = false
		end)
		v8.observePlayer(function(player)
			local clone = playerTemplate:Clone()
			clone.AvatarFrame.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
			local name

			if player == localPlayer then
				name = `!{player.DisplayName}`
			else
				name = player.DisplayName
			end

			clone.Name = name
			clone.DisplayName.Text = player.DisplayName
			clone.Username.Text = `@{player.Name}`
			clone.Username.Size = UDim2.fromScale(0.382, 0.297)

			if player == localPlayer then
				clone.Toggle.Visible = false
			end

			local v19 = v8.observeAttribute(player, "InRoundQueue", function(p)
				if p then
					clone.Toggle.Image = "rbxassetid://16789391160"
					clone.Toggle.Label.Text = "Remove"
					clone.Toggle.Label.TextStrokeColor3 = Color3.fromRGB(65, 0, 0)
					clone.Size = UDim2.fromScale(0.95, 0.247)
					clone.Parent = playing
				else
					clone.Toggle.Image = "rbxassetid://16789408068"
					clone.Toggle.Label.Text = "Add"
					clone.Toggle.Label.TextStrokeColor3 = Color3.fromRGB(0, 65, 5)
					clone.Size = UDim2.fromScale(0.95, 0.467)
					clone.Parent = notPlaying
				end
			end)
			local activatedConnection = clone.Toggle.Activated:Connect(function()
				remoteEvent5:FireServer(player)
			end)
			local activatedConnection2 = clone.Reset.Activated:Connect(function()
				remoteEvent4:FireServer(player)
			end)
			return function()
				v19()
				activatedConnection:Disconnect()
				activatedConnection2:Disconnect()
				clone:Destroy()
			end
		end)
		v2.observeClientReplion("TrainingConfiguration", function(p)
			v2.observeReplionPath(p, "Difficulty", updateDifficultyVisual)
			v2.observeReplionPath(p, "NumberOfBots", updateCounterVisual)
			v14(p)
			v15(p)
			v2.observeReplionPath(p, "GameMode", updateGameModeVisual)
			v2.observeReplionPath(p, "Map", updateMapVisual)
			v16(p)
			v17(p)
			return function() end
		end)
	end,
	HasEditPermissions = function(self, p)
		if not v10.isTrainingServer() then
			return false
		end

		local serverOwner = ReplicatedStorage2.ServerInfo:FindFirstChild("serverOwner")

		if serverOwner then
			return serverOwner.Value == p.UserId
		end

		return game.PrivateServerId ~= "" and game.PrivateServerOwnerId == p.UserId
	end
}

function onPermissionsChanged()
	local trainingServer = v10.isTrainingServer()
	local hasEditPermissions = TrainingModeController:HasEditPermissions(localPlayer)
	localPlayer:SetAttribute("ServerAdminAccess", hasEditPermissions)

	if hasEditPermissions then
		v7:Open("TrainingModeServerPanel", true)
		settingsButton.Visible = true
	else
		settingsButton.Visible = false
	end

	AFK.Visible = not (trainingServer or v10.isDungeonsLobbyServer() or v10.isDungeonsMatchServer() or v10.isTradingPlazaServer())
	backButton.Visible = trainingServer
	backButton.Position = AFK.Position
	backButton.AnchorPoint = AFK.AnchorPoint

	local function updateSettingsButton()
		if v.TouchEnabled and not (v.KeyboardEnabled and v.GamepadEnabled and GuiService:IsTenFootInterface()) then
			if clanButton.Visible then
				settingsButton.Position = helpGuidePage.Position
				settingsButton.AnchorPoint = helpGuidePage.AnchorPoint
			else
				settingsButton.Position = UDim2.fromScale(0.775, 0)
				settingsButton.AnchorPoint = Vector2.new(1, 0)
			end
		end
	end

	updateSettingsButton()
	clanButton:GetPropertyChangedSignal("Visible"):Connect(updateSettingsButton)
end

return TrainingModeController