local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

repeat
	wait(0.1)
until localPlayer:FindFirstChild("PlayerStats") and localPlayer:FindFirstChild("DataLoaded") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and _G.CheckBoughtClient

local localPlayer2 = Players.LocalPlayer
local character = localPlayer2.Character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
RunService:IsStudio()
local playerGui = localPlayer2.PlayerGui
local parent = script.Parent.Parent
local RunService2 = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopbarPlus = require(ReplicatedStorage.Chest.Modules.TopbarPlus)
require(ReplicatedStorage.Chest.Modules.PeodizService)
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local IslandInfo = require(ReplicatedStorage.Chest.Modules.IslandInfo)
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local AccessoriesList = require(ReplicatedStorage.Chest.Modules.AccessoriesList)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local TierImage = require(ReplicatedStorage.Chest.Modules.TierImage)
local TierColor = require(ReplicatedStorage.Chest.Modules.TierColor)
local QuestManager = require(ReplicatedStorage.Chest.Modules.QuestManager)
local FruitList = require(ReplicatedStorage.Chest.Modules.FruitList)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local DFTier = require(ReplicatedStorage.Chest.Modules.DFTier)
local ChestChances = require(ReplicatedStorage.Chest.Modules.ChestChances)
local starterFrame = parent.StarterFrame
local statusEffect = starterFrame.StatusEffect
local fruitFrame = starterFrame.FruitFrame
local statsFrame = starterFrame.StatsFrame
local shopFrame = starterFrame.ShopFrame
local setting_Frame = starterFrame.Setting_Frame
local tradeFrame = starterFrame.TradeFrame
local mapFrame = starterFrame.MapFrame
local inventory_Frame = starterFrame.Inventory_Frame
local allyFrame = starterFrame.AllyFrame
local crewFrame = starterFrame.CrewFrame
local serverBrowserFrame = starterFrame.ServerBrowserFrame
local battlepass_Frame = starterFrame.Battlepass_Frame
local fightingStyleFrame = starterFrame.FightingStyleFrame
local dropBoostFrame = starterFrame.DropBoostFrame
local homeFrame = starterFrame.HomeFrame
local guidelineFrame = starterFrame.GuidelineFrame
local shutdownAlertFrame = starterFrame.ShutdownAlertFrame
local baseFrameOG = parent.BaseFrameOG
local baseFrame = parent.BaseFrame
local buttonFrame = baseFrame.ButtonFrame
local menuButton = baseFrame.Frame.MenuButton
local home_Button = baseFrame.Frame.Home_Button
local home_Button2 = baseFrameOG.Frame.Home_Button
local statsButton = buttonFrame.StatsButton
local shopButton = buttonFrame.ShopButton
local setting_Button = buttonFrame.Setting_Button
local trade_Button = buttonFrame.Trade_Button
local inventoryButton = buttonFrame.InventoryButton
local crewButton = buttonFrame.CrewButton
local allyButton = buttonFrame.AllyButton
local mapButton = buttonFrame.MapButton
local battlepass_Button = buttonFrame.Battlepass_Button
local fightingStyle = statsFrame.ProfilePage.ScrollingFrame.FightingStyle
local dropBoost = statsFrame.ProfilePage.ScrollingFrame["Drop Boost"]
local trackQuestButton = baseFrame.Frame.TrackQuestButton
local flag = nil

function UpdateShutdownText()
	if flag then
		return
	end

	local serverShuttingDown = workspace:GetAttribute("ServerShuttingDown")

	if not serverShuttingDown then
		return
	end

	flag = true
	shutdownAlertFrame.Visible = true
	task.spawn(function()
		while true do
			local v = serverShuttingDown - os.time()
			local v2 = math.floor(v / 60)
			local v3 = math.floor(v) % 60
			shutdownAlertFrame.TimeLabel.Text = `Time remaining: {v2}min(s) {v3}second(s)`
			task.wait(0.1)
		end
	end)
end

UpdateShutdownText()
workspace:GetAttributeChangedSignal("ServerShuttingDown"):Connect(UpdateShutdownText)
workspace:WaitForChild("Island")
local uDim = UDim2.new(0.09, 0, 0.09, 0)
local uDim2 = UDim2.new(0.135, 0, 0.135, 0)
local clone = nil
local v = nil
local v2 = nil
local v3 = {
	[WorldsId.Testing.SecondSea] = true,
	[WorldsId.KingLegacy.SecondSea] = true
}
local v4 = {
	[WorldsId.Testing.ThirdSea] = true,
	[WorldsId.KingLegacy.ThirdSea] = true
}
local mouse = localPlayer2:GetMouse()
local v5 = TopbarPlus.new()
v5:setLabel("Servers", "Selected"):setImage(114977439671420)
v5:setOrder(4)
v5:setCaption("Servers Browser")
v5:setName("ServerBrowser")
local v6 = TopbarPlus.new()
v6:setOrder(3)
v6:setImage(94513760125394, "Deselected")
v6:setImage(120507614636652, "Selected")
v6:bindEvent("selected", function(_)
	_G.UIVisible = false
	_G.VisibleGui(false)
	setting_Frame.Visible = false
	statusEffect.Visible = false
end)
v6:bindEvent("deselected", function(_)
	_G.UIVisible = true
	_G.VisibleGui(true)
	setting_Frame.Visible = true
	statusEffect.Visible = true
end)
local v7 = TopbarPlus.new()
v7:setOrder(1)
v7:align("Right")
v7:setWidth(60)
v7:setEnabled(false)
v7:lock()
v7:setName("CountdownLabel")

function UpdateCountdown()
	local liveCountdown = workspace:GetAttribute("LiveCountdown")
	v7:setEnabled(liveCountdown ~= nil)

	if not liveCountdown then
		return
	end

	v7:setLabel(liveCountdown)
end

workspace:GetAttributeChangedSignal("LiveCountdown"):Connect(UpdateCountdown)
task.spawn(function()
	UpdateCountdown()
end)
_G.ServerBrowserButton = v5
spawn(function()
	repeat
		wait()
	until playerGui:FindFirstChild("TopbarPlus")

	local topbarContainer = playerGui:WaitForChild("TopbarPlus"):WaitForChild("TopbarContainer")

	repeat
		local v8 = nil
		local updateVersion = topbarContainer:FindFirstChild("UpdateVersion", true)

		if updateVersion then
			local iconButton = updateVersion:FindFirstChild("IconButton")
			v8 = iconButton and iconButton:FindFirstChild("IconLabel") and true or v8
		end

		wait(1)
	until v8
end)

function ResetButtonPosition()
	local uDim3 = UDim2.new(0.5, 0, 0.75, 0)

	if _G.CheckSettingClient(localPlayer2, "Setting_RetroUI") then
		uDim3 = UDim2.new(0.107, 0, 0.5, 0)
	end

	statsButton.Position = uDim3
	inventoryButton.Position = uDim3
	crewButton.Position = uDim3
	allyButton.Position = uDim3
	shopButton.Position = uDim3
	setting_Button.Position = uDim3
	trade_Button.Position = uDim3
	mapButton.Position = uDim3
	battlepass_Button.Position = uDim3
end

ResetButtonPosition()

function UpdateFramePosY(p)
	if p then
		guidelineFrame.Position = UDim2.fromScale(0.5, 0.5)
	else
		guidelineFrame.Position = UDim2.fromScale(0.5, 0.45)
	end

	for _, child in pairs(starterFrame:GetChildren()) do
		if not child:GetAttribute("Udim2") then
			continue
		end

		if p then
			child:SetAttribute("Udim2", UDim2.fromScale(-0.5, 0.5))
			child.Position = UDim2.fromScale(child.Position.X.Scale, 0.5)
		else
			child:SetAttribute("Udim2", UDim2.fromScale(-0.5, 0.45))
			child.Position = UDim2.fromScale(child.Position.X.Scale, 0.45)
		end
	end
end

_G.UpdateFramePosY = UpdateFramePosY

function ResetFramePosition()
	for _, child in pairs(starterFrame:GetChildren()) do
		local udim2 = child:GetAttribute("Udim2")

		if udim2 then
			child.Position = udim2
		end
	end
end

ResetFramePosition()
statsButton.Visible = false
inventoryButton.Visible = false
crewButton.Visible = false
allyButton.Visible = false
shopButton.Visible = false
setting_Button.Visible = false
trade_Button.Visible = false
mapButton.Visible = false
battlepass_Button.Visible = false
starterFrame.DragonColorFrame.Visible = false
local v8 = true
local v9 = true

function ClearServerFrames()
	v8 = nil
	serverBrowserFrame.MainFrame.RefreshButton.Text = "Clearing"

	for i, frame in pairs(serverBrowserFrame.MainFrame.ServerFrame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame:Destroy()

		if i % 50 == 1 then
			wait()
		end
	end

	task.spawn(function()
		wait(0.5)
		serverBrowserFrame.MainFrame.RefreshButton.Text = "Refresh"
		v8 = true
	end)
end

local v10 = true

function MenuClicked(p)
	if not v10 then
		return
	end

	local closeAllButtons = p and p.CloseAllButtons
	v10 = false
	local size = menuButton:GetAttribute("Size") or menuButton.Size
	local uDim3 = UDim2.new(size.X.Scale * 1.35, 0, size.Y.Scale * 1.35, 0)

	if p and p.ByKeyCode then
		uDim3 = size
	end

	if not closeAllButtons then
		menuButton.Size = uDim3
		TweenService:Create(
			menuButton,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = UDim2.new(size.X.Scale * 2.5, 0, size.Y.Scale * 2.5, 0)
			}
		):Play()
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true,
				MenuSound = true
			})
		end)
	end

	spawn(function()
		wait(0.45)
		v10 = true
	end)
	local uDim4 = UDim2.fromScale(0.09, 0.09)
	local uDim5 = UDim2.fromScale(0.05, 0.05)

	if statsButton.Visible or closeAllButtons then
		_G.ButtonClicked({
			Frame = nil,
			Button = nil
		})
		local uDim6 = UDim2.new(0.5, 0, 0.75, 0)

		if _G.CheckSettingClient(localPlayer2, "Setting_RetroUI") then
			uDim6 = UDim2.new(0.107, 0, 0.5, 0)
		end

		for _, button in pairs(buttonFrame:GetChildren()) do
			if button:IsA("ImageButton") then
				button.Interactable = nil
			end
		end

		menuButton.Alert.Visible = false
		local v11 = Enum.EasingDirection.In
		local back = Enum.EasingStyle.Back
		TweenService:Create(inventoryButton, TweenInfo.new(0.25, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		task.delay(0.25, function()
			inventoryButton.Visible = false
		end)
		TweenService:Create(statsButton, TweenInfo.new(0.3, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		TweenService:Create(shopButton, TweenInfo.new(0.3, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		task.delay(0.3, function()
			statsButton.Visible = false
			shopButton.Visible = false
		end)
		TweenService:Create(trade_Button, TweenInfo.new(0.35, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		TweenService:Create(battlepass_Button, TweenInfo.new(0.35, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		task.delay(0.35, function()
			trade_Button.Visible = false
			battlepass_Button.Visible = false
		end)
		TweenService:Create(allyButton, TweenInfo.new(0.4, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		TweenService:Create(mapButton, TweenInfo.new(0.4, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		task.delay(0.4, function()
			allyButton.Visible = false
			mapButton.Visible = false
		end)
		TweenService:Create(crewButton, TweenInfo.new(0.45, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		TweenService:Create(setting_Button, TweenInfo.new(0.45, back, v11), {
			Position = uDim6,
			Size = uDim5
		}):Play()
		task.delay(0.45, function()
			crewButton.Visible = false
			setting_Button.Visible = false
		end)
	else
		ResetButtonPosition()
		local out = Enum.EasingDirection.Out
		local back = Enum.EasingStyle.Back

		for _, button in pairs(buttonFrame:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			button.Size = UDim2.new(0, 0, 0, 0)
			button.Interactable = true
		end

		TweenService:Create(inventoryButton, TweenInfo.new(0.25, back, out), {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(shopButton, TweenInfo.new(0.3, back, out), {
			Position = UDim2.new(0.402, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(statsButton, TweenInfo.new(0.3, back, out), {
			Position = UDim2.new(0.598, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(trade_Button, TweenInfo.new(0.35, back, out), {
			Position = UDim2.new(0.304, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(battlepass_Button, TweenInfo.new(0.35, back, out), {
			Position = UDim2.new(0.696, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(allyButton, TweenInfo.new(0.4, back, out), {
			Position = UDim2.new(0.205, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(mapButton, TweenInfo.new(0.4, back, out), {
			Position = UDim2.new(0.795, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(setting_Button, TweenInfo.new(0.45, back, out), {
			Position = UDim2.new(0.893, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		TweenService:Create(crewButton, TweenInfo.new(0.45, back, out), {
			Position = UDim2.new(0.107, 0, 0.5, 0),
			Size = uDim4
		}):Play()
		statsButton.Visible = true
		shopButton.Visible = true
		inventoryButton.Visible = true
		crewButton.Visible = true
		allyButton.Visible = true
		setting_Button.Visible = true
		trade_Button.Visible = true
		mapButton.Visible = true
		battlepass_Button.Visible = true
	end
end

local flag2 = true
local flag3 = true
local flag4 = true
local flag5 = true
local flag6 = true
local flag7 = true
local flag8 = true
local flag9 = true
local flag10 = true
local flag11 = true
local flag12 = true
local flag13 = true

function HideFrame(instance)
	if instance.Visible and instance == fruitFrame then
		_G.NPCTalk = false
	end

	task.spawn(function()
		local scale = instance:GetAttribute("Udim2") and instance:GetAttribute("Udim2").Y.Scale or 0.45
		local tween = TweenService:Create(instance, TweenInfo.new(0.1), {
			Position = UDim2.new(1.5, 0, scale, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		instance.Visible = false

		if instance:FindFirstChild("InfoFrame") then
			instance.InfoFrame.Visible = nil
		end
	end)
end

function _G.ButtonClicked(data)
	if data and data.Died then
		starterFrame.Gacha_Frame.Frame.Visible = nil
		fruitFrame.Visible = nil
	end

	local frame

	if data then
		frame = data.Frame or nil
	end

	local button = data and data.Button or nil

	if frame then
		local v11 = not frame:GetAttribute("Udim2") and 0.45 or frame:GetAttribute("Udim2").Y.Scale or 0.45
		frame.Position = UDim2.new(-0.5, 0, v11, 0)
		frame.Visible = true
		TweenService:Create(frame, TweenInfo.new(0.25), {
			Position = UDim2.new(0.5, 0, v11, 0)
		}):Play()
	end

	if button and button ~= v5 and button ~= fightingStyle and button ~= home_Button and button ~= dropBoost then
		button.Size = uDim
		TweenService:Create(
			button,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = uDim2
			}
		):Play()
	end

	for _, child in pairs(starterFrame:GetChildren()) do
		if frame ~= child and child:GetAttribute("Udim2") and child.Visible then
			HideFrame(child)
		end
	end

	if frame and frame ~= starterFrame.GlobalGiftMainFrame.GiftFrame or not frame then
		HideFrame(starterFrame.GlobalGiftMainFrame.GiftFrame)
	end

	if button ~= statsButton then
		flag2 = true
	end

	if button ~= inventoryButton then
		flag6 = true
	end

	if button ~= setting_Button then
		flag4 = true
	end

	if button ~= shopButton then
		flag3 = true
	end

	if button ~= allyButton then
		flag8 = true
	end

	if button ~= crewButton then
		flag7 = true
	end

	if button ~= trade_Button then
		flag5 = true
	end

	if button ~= mapButton then
		flag10 = true
	end

	if button ~= battlepass_Button then
		flag9 = true
	end

	if button ~= fightingStyle then
		flag11 = true
	end

	if button ~= dropBoost then
		flag12 = true
	end

	if button ~= home_Button then
		flag13 = true
	end
end

function ButtonClosed(p)
	local frame

	if p then
		frame = p.Frame or nil
	else
		frame = nil
	end

	local button = p and p.Button or nil
	task.spawn(function()
		if frame then
			frame.Visible = true
			local tween = TweenService:Create(frame, TweenInfo.new(0.1), {
				Position = UDim2.new(1.5, 0, 0.45, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			frame.Visible = false

			if frame:FindFirstChild("InfoFrame") then
				frame.InfoFrame.Visible = nil
			end
		end
	end)
	task.spawn(function()
		if button and button ~= fightingStyle and button ~= home_Button and button ~= dropBoost then
			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			button.Size = uDim
			TweenService:Create(
				button,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = uDim2
				}
			):Play()

			if button:FindFirstChild("ImageLabel") then
				button.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(
					button.ImageLabel,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						ImageColor3 = Color3.fromRGB(0, 0, 0)
					}
				):Play()
			end
		end
	end)
end

_G.ButtonClosed = ButtonClosed

function _G.ServerButtonClick()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	serverBrowserFrame.Visible = true

	if v5.isSelected then
		_G.ButtonClicked({
			Frame = serverBrowserFrame,
			Button = v5
		})
	else
		ButtonClosed({
			Frame = serverBrowserFrame,
			Button = nil
		})
	end
end

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.M then
		MenuClicked({
			ByKeyCode = true
		})
	end
end)

function _G.StatsButtonClick()
	if not v9 then
		return
	end

	v9 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)

	if flag2 then
		if flag2 then
			flag2 = nil
			_G.ButtonClicked({
				Frame = statsFrame,
				Button = statsButton
			})
		end
	else
		flag2 = true
		statsFrame.ArmConfig.Visible = false
		ButtonClosed({
			Frame = statsFrame,
			Button = statsButton
		})
		statsButton.Alert.Visible = false
	end

	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)
end

function _G.ShopButtonClick()
	if not v9 then
		return
	end

	v9 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)
	shopFrame.Visible = true

	if flag3 then
		if flag3 then
			flag3 = nil
			_G.ButtonClicked({
				Frame = shopFrame,
				Button = shopButton
			})
		end
	else
		flag3 = true
		ButtonClosed({
			Frame = shopFrame,
			Button = shopButton
		})
	end
end

function GetHome()
	if not (localPlayer2 and localPlayer2:FindFirstChild("PlayerStats")) then
		return
	end

	local spawned = localPlayer2.PlayerStats:FindFirstChild("spawned")
	local spawnPoints = workspace:FindFirstChild("SpawnPoints")
	local v11

	if not (spawnPoints and spawned) then
		return v11
	end

	local child = spawnPoints:FindFirstChild("Spawn" .. spawned.Value) and spawnPoints["Spawn" .. spawned.Value]

	if character:GetAttribute("SoloDamage") then
		child = spawnPoints:FindFirstChild(character:GetAttribute("SoloDamage") .. "CustomSpawn")
	end

	if child then
		return CFrame.new(child.Position) * CFrame.new(0, 2, 0)
	end

	return spawnPoints.Spawn1.CFrame * CFrame.new(0, 2, 0)
end

local allspawnDF = workspace.AllspawnDF
local flag14 = true

function SetupCharacterTopbar()
	local function UpdateCharacterAttribute()
		if character:GetAttribute("InDungeon") then
			flag14 = nil
			v6:setEnabled(false)
			v5:setEnabled(false)
		elseif not character:GetAttribute("InDungeon") then
			if flag14 then
				return
			end

			flag14 = true
			v6:setEnabled(true)
			v5:setEnabled(true)
		end
	end

	UpdateCharacterAttribute()
	character.AttributeChanged:Connect(function()
		wait()
		UpdateCharacterAttribute()
	end)
end

SetupCharacterTopbar()
localPlayer2.CharacterAdded:Connect(function(character2)
	humanoidRootPart = character2:WaitForChild("HumanoidRootPart")
	character = character2
	SetupCharacterTopbar()
	ClearServerFrames()
end)
local allies = localPlayer2:WaitForChild("Allies")
local points = localPlayer2.PlayerStats.Points
local PVP = localPlayer2.PlayerStats.PVP

function _G.MenuAlert(p)
	local visible = points.Value >= 1 or (not localPlayer2.PlayerStats.PVP.Value or p)
	menuButton.Alert.Visible = visible
	baseFrameOG.Frame.MenuButton.Alert.Visible = visible
end

function CheckPointsTweenAlert()
	if points.Value >= 1 then
		statsButton.Alert.Visible = true
		baseFrameOG.ButtonFrame.StatsButton.Alert.Visible = true
		_G.MenuAlert(true)
	elseif points.Value <= 0 then
		statsButton.Alert.Visible = false
		baseFrameOG.ButtonFrame.StatsButton.Alert.Visible = false
		_G.MenuAlert(false)
	end
end

function PvPSettingAlert()
	spawn(function()
		if localPlayer2.PlayerGui:FindFirstChild("MainGui") and localPlayer2:FindFirstChild("PlayerStats") then
			local setting_PVP = starterFrame.Setting_Frame.Frame.Setting_PVP
			local setting_Button2 = baseFrame.ButtonFrame.Setting_Button

			if localPlayer2.PlayerStats.PVP.Value then
				if localPlayer2.PlayerStats.PVP.Value then
					setting_PVP.Alert.Visible = false
					setting_Button2.Alert.Visible = false
					baseFrameOG.ButtonFrame.Setting_Button.Alert.Visible = false
					_G.MenuAlert(false)

					if setting_PVP.Menu.Position == UDim2.new(0, 0, 0, 0) then
						setting_PVP.Menu.Position = UDim2.new(0.5, 0, 0, 0)
						setting_PVP.Menu.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					end
				end
			else
				if setting_PVP.Menu.Position == UDim2.new(0.5, 0, 0, 0) then
					setting_PVP.Menu.Position = UDim2.new(0, 0, 0, 0)
					setting_PVP.Menu.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
				end

				setting_PVP.Alert.Visible = true
				setting_Button2.Alert.Visible = true
				baseFrameOG.ButtonFrame.Setting_Button.Alert.Visible = true
				_G.MenuAlert(true)
			end
		end
	end)
end

points.Changed:Connect(function()
	CheckPointsTweenAlert()
end)
PVP.Changed:Connect(function()
	PvPSettingAlert()
end)
CheckPointsTweenAlert()

function FindFruit()
	for _, tool in pairs(allspawnDF:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("LegacyFruit") then
			return tool
		end
	end
end

local RaidBossList = require(ReplicatedStorage.Chest.Modules.RaidBossList)
local models = {}
local v11 = {}
local v12 = {}
local v13 = {}

function Commas(p)
	return tostring((math.floor(p))):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function ConnectBoss(instance)
	if not RaidBossList[instance.Name] then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid or not humanoid.RootPart or humanoid.Health <= 0 or v11[instance] then
		return
	end

	if instance:GetAttribute("FuseHP") then
		if not v12[instance.Name] then
			local connections = {}
			local v14 = {
				Connections = connections
			}
			local fuseHP = instance:GetAttribute("FuseHP") or 1
			local doubleConstrainedValue = Instance.new("DoubleConstrainedValue")
			doubleConstrainedValue.Name = "BossHP"
			doubleConstrainedValue.MinValue = 0
			doubleConstrainedValue.MaxValue = 0
			local fuse = {}
			local name = RaidBossList[instance.Name].Name
			local clone2 = script.File.BossFrame:Clone()
			clone2.Name = instance.Name
			clone2.HPFrame.BossName.Text = name
			local absoluteSize = starterFrame.BossesHealthBar.Frames.AbsoluteSize
			local scale = clone2.Size.Y.Scale
			clone2.Size = UDim2.new(1, 0, 0, absoluteSize.Y * scale)
			clone2.HPFrame.BossNameShadow.Text = name

			if RaidBossList[instance.Name].BorderImage then
				clone2.HPFrame.BorderFrame.Visible = true
				clone2.HPFrame.BorderFrame.Image = RaidBossList[instance.Name].BorderImage
			end

			local absoluteSize2 = starterFrame.BossesHealthBar.Frames.AbsoluteSize
			clone2.Size = UDim2.new(1, 0, 0, absoluteSize2.Y * 0.024)
			clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize2.Y * 0.024)

			local function UpdateOffset(visible)
				if visible then
					local v16 = absoluteSize2.Y * 0.024 + clone2.HPFrame.Drops.DropsList.UIListLayout.AbsoluteContentSize.Y + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y + 1
					clone2.Size = UDim2.new(1, 0, 0, v16)
					clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize2.Y * 0.024)
					clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">▼</font></font>"
				else
					local v16 = absoluteSize2.Y * 0.024
					clone2.Size = UDim2.new(1, 0, 0, v16)
					clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize2.Y * 0.024)
					clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">►</font></font>"
				end
			end

			local drops = RaidBossList[instance.Name].Drops

			if drops and typeof(drops) == "function" then
				drops = drops()
			end

			if drops then
				local v16 = 0
				local characterPassives = character:FindFirstChild("CharacterPassives")

				if characterPassives and characterPassives:FindFirstChild("IncreaseDropRate") then
					local increaseDropRate = characterPassives.IncreaseDropRate

					if increaseDropRate.Value > 0 then
						v16 = increaseDropRate.Value / 100
					end
				end

				for k, drop in pairs(drops) do
					local v17 = tonumber((string.sub(drop, 1, #drop - 1)))

					if not v17 then
						continue
					end

					local v18 = v17 * (localPlayer2.PlayerStats.RealDropX2.Value + v16)
					local v19 = string.format("%.6f", v18)
					local v20 = string.gsub(v19, "0+$", "")
					local v21 = tostring((string.gsub(v20, "%.$", ""))) .. "% (x" .. localPlayer2.PlayerStats.RealDropX2.Value + v16 .. ")"
					local clone3 = script.File.Item1:Clone()
					clone3.Name = k
					clone3.Text = (CustomNames[k] or k) .. " - " .. v21
					local v22 = AccessoriesList[k] or SwordList[k] or MaterialList[k]

					if v22 and v22.Image then
						clone3.ImageLabel.Image = v22.Image
					end

					clone3.Parent = clone2.HPFrame.Drops.DropsList
				end

				clone2.HPFrame.Drops.DropsButton.MouseButton1Click:Connect(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					clone2.HPFrame.Drops.DropsList.Visible = not clone2.HPFrame.Drops.DropsList.Visible
					UpdateOffset(clone2.HPFrame.Drops.DropsList.Visible)
				end)
				UpdateOffset(clone2.HPFrame.Drops.DropsList.Visible)
			else
				clone2.HPFrame.Drops.Visible = nil
			end

			clone2.Parent = starterFrame.BossesHealthBar.Frames
			v14.Fuse = fuse
			v14.Frame = clone2
			local bar = clone2.HPFrame.Bar
			local underFrame = clone2.HPFrame.UnderFrame
			local healthText = clone2.HPFrame.HealthText
			bar.Size = UDim2.new(1, 0, 0.98, 0)
			underFrame.Size = UDim2.new(1, 0, 0.98, 0)

			local function UpdateHP()
				local total = 0
				local maxValue = 0
				local flag15 = true

				for _, v17 in pairs(fuse) do
					total += math.max(v17.Health, 0)

					if maxValue == 0 then
						maxValue = v17.MaxHealth * fuseHP
					end

					if v17.Health > 0 then
						flag15 = nil
					end
				end

				if flag15 then
					DisconnectBoss(instance)
				end

				TweenService:Create(doubleConstrainedValue, TweenInfo.new(0.25), {
					MinValue = total,
					MaxValue = maxValue
				}):Play()
			end

			v12[instance.Name] = v14
			connections[#connections + 1] = doubleConstrainedValue:GetPropertyChangedSignal("MinValue"):Connect(function()
				if not v12[instance.Name] then
					for _, connection in pairs(connections) do
						connection:Disconnect()
					end
				end

				wait()
				local minValue = doubleConstrainedValue.MinValue
				local maxValue = doubleConstrainedValue.MaxValue
				healthText.Text = tostring(Commas(minValue)) .. "/" .. Commas(maxValue)
				bar.Size = UDim2.new(math.clamp(minValue / maxValue, 0, 1), 0, 0.98, 0)
				wait(0.2)
				underFrame.Size = UDim2.new(math.clamp(minValue / maxValue, 0, 1), 0, 0.98, 0)
			end)

			for _, child in pairs(workspace.Monster.Boss:GetChildren()) do
				if child.Name ~= instance.Name or fuse[child] then
					continue
				end

				local v16 = child
				task.spawn(function()
					local humanoid2 = v16:WaitForChild("Humanoid", 6)

					if humanoid2 then
						fuse[v16] = humanoid2
						humanoid2.HealthChanged:Connect(function()
							wait()
							UpdateHP()
						end)
						UpdateHP()
					end
				end)
			end

			connections[#connections + 1] = workspace.Monster.Boss.ChildAdded:Connect(function(child)
				if not v12[instance.Name] then
					for _, connection in pairs(connections) do
						connection:Disconnect()
					end
				end

				if child.Name ~= instance.Name or fuse[child] then
					return
				end

				local humanoid2 = child:WaitForChild("Humanoid", 6)

				if humanoid2 then
					fuse[child] = humanoid2
					humanoid2.HealthChanged:Connect(function()
						wait()
						UpdateHP()
					end)
					UpdateHP()
				end
			end)
			connections[#connections + 1] = workspace.Monster.Boss.ChildRemoved:Connect(function(child)
				if child.Parent ~= nil then
					return
				end

				if not v12[instance.Name] then
					for _, connection in pairs(connections) do
						connection:Disconnect()
					end
				end

				if not (child.Name == instance.Name and fuse[child]) then
					return
				end

				fuse[child] = nil
				UpdateHP()
			end)
			UpdateHP()
		end
	else
		local connections = {}
		local v14 = {
			Connections = connections
		}
		local name = RaidBossList[instance.Name].Name
		local clone2 = script.File.BossFrame:Clone()
		clone2.Name = instance.Name
		clone2.HPFrame.BossName.Text = name
		clone2.HPFrame.BossNameShadow.Text = name

		if RaidBossList[instance.Name].BorderImage then
			clone2.HPFrame.BorderFrame.Visible = true
			clone2.HPFrame.BorderFrame.Image = RaidBossList[instance.Name].BorderImage
		end

		local absoluteSize = starterFrame.BossesHealthBar.Frames.AbsoluteSize
		clone2.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024 + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y)
		clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)

		local function UpdateOffset(visible)
			if visible then
				local v15 = absoluteSize.Y * 0.024 + clone2.HPFrame.Drops.DropsList.UIListLayout.AbsoluteContentSize.Y + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y + 1
				clone2.Size = UDim2.new(1, 0, 0, v15)
				clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)
				clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">▼</font></font>"
			else
				local v15 = absoluteSize.Y * 0.024
				clone2.Size = UDim2.new(1, 0, 0, v15 + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y)
				clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)
				clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">►</font></font>"
			end
		end

		local drops = RaidBossList[instance.Name].Drops

		if drops and typeof(drops) == "function" then
			drops = drops()
		end

		if drops then
			local v15 = 0
			local characterPassives = character:FindFirstChild("CharacterPassives")

			if characterPassives and characterPassives:FindFirstChild("IncreaseDropRate") then
				local increaseDropRate = characterPassives.IncreaseDropRate

				if increaseDropRate.Value > 0 then
					v15 = increaseDropRate.Value / 100
				end
			end

			for k, drop in pairs(drops) do
				local v16 = tonumber((string.sub(drop, 1, #drop - 1)))

				if not v16 then
					continue
				end

				local v17 = v16 * (localPlayer2.PlayerStats.RealDropX2.Value + v15)
				local v18 = string.format("%.6f", v17)
				local v19 = string.gsub(v18, "0+$", "")
				local v20 = tostring((string.gsub(v19, "%.$", ""))) .. "% (x" .. localPlayer2.PlayerStats.RealDropX2.Value + v15 .. ")"
				local clone3 = script.File.Item1:Clone()
				clone3.Name = k
				clone3.Text = (CustomNames[k] or k) .. " - " .. v20
				local v21 = AccessoriesList[k] or SwordList[k] or MaterialList[k]

				if v21 and v21.Image then
					clone3.ImageLabel.Image = v21.Image
					local v22 = nil
					local connections2 = {}
					local name2 = k
					local v24 = v21
					local v25 = clone3
					connections2[#connections2 + 1] = clone3.ImageLabel.MouseEnter:Connect(function()
						v22 = true
						local mouseLocation = UserInputService:GetMouseLocation()
						local X = mouseLocation.X
						local Y = mouseLocation.Y
						local v27 = starterFrame.BossesHealthBar.AbsoluteSize.X * 0.075
						local clone4 = script.File.PreviewItem:Clone()
						clone4.Name = name2
						clone4.Position = UDim2.new(0, X, 0, Y)
						clone4.Size = UDim2.new(0, v27, 0, v27)
						clone4.Image = v24.Image
						clone4.Parent = starterFrame.BossesHealthBar

						while v22 and v25:IsDescendantOf(starterFrame.BossesHealthBar) do
							local mouseLocation2 = UserInputService:GetMouseLocation()
							local X2 = mouseLocation2.X
							local Y2 = mouseLocation2.Y
							clone4.Position = UDim2.new(0, X2, 0, Y2 - clone4.AbsoluteSize.Y / 2)
							task.wait()
						end

						clone4:Destroy()
						v22 = nil

						if not v25:IsDescendantOf(starterFrame.BossesHealthBar) then
							for k2, connection in pairs(connections2) do
								if connection.Connected then
									connection:Disconnect()
								end
							end

							table.clear(connections2)
						end
					end)
					connections2[#connections2 + 1] = clone3.ImageLabel.MouseLeave:Connect(function()
						v22 = nil
					end)
				end

				clone3.Parent = clone2.HPFrame.Drops.DropsList
			end

			clone2.HPFrame.Drops.DropsButton.MouseButton1Click:Connect(function()
				_G.ClickFrameEffect({
					Sound = true
				})
				clone2.HPFrame.Drops.DropsList.Visible = not clone2.HPFrame.Drops.DropsList.Visible
				UpdateOffset(clone2.HPFrame.Drops.DropsList.Visible)
			end)
			UpdateOffset(clone2.HPFrame.Drops.DropsList.Visible)
		else
			clone2.HPFrame.Drops.Visible = nil
		end

		clone2.Parent = starterFrame.BossesHealthBar.Frames
		local bar = clone2.HPFrame.Bar
		local underFrame = clone2.HPFrame.UnderFrame
		local healthText = clone2.HPFrame.HealthText
		local intValue = Instance.new("IntValue")
		intValue.Name = "BossHP"
		intValue.Value = humanoid.Health
		intValue.Parent = clone2

		local function UpdateHP()
			if not clone2:IsDescendantOf(starterFrame.BossesHealthBar) then
				return
			end

			local value = intValue.Value
			healthText.Text = tostring(Commas(value)) .. "/" .. Commas(humanoid.MaxHealth)
			bar.Size = UDim2.new(math.clamp(value / humanoid.MaxHealth, 0, 1), 0, 0.98, 0)
			wait(0.2)
			underFrame.Size = UDim2.new(math.clamp(value / humanoid.MaxHealth, 0, 1), 0, 0.98, 0)
			wait(0.2)

			if humanoid.Health <= 0 then
				DisconnectBoss(instance)
			end
		end

		connections[#connections + 1] = humanoid.HealthChanged:Connect(function()
			wait()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(intValue, TweenInfo.new(0.25), {
				Value = humanoid.Health
			}):Play()
		end)
		connections[#connections + 1] = intValue.Changed:Connect(function()
			wait()
			UpdateHP()
		end)
		connections[#connections + 1] = humanoid.Died:Connect(function()
			wait()
			DisconnectBoss(instance)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateCustomName()
			local customName = instance:GetAttribute("CustomName")

			if not customName then
				return
			end

			clone2.HPFrame.BossName.Text = tostring(customName)
			clone2.HPFrame.BossNameShadow.Text = tostring(customName)
		end

		connections[#connections + 1] = instance:GetAttributeChangedSignal("CustomName"):Connect(function(_)
			local customName = instance:GetAttribute("CustomName")

			if not customName then
				return
			end

			clone2.HPFrame.BossName.Text = tostring(customName)
			clone2.HPFrame.BossNameShadow.Text = tostring(customName)
		end)
		UpdateCustomName() -- equivalent call inferred; original call site unknown
		UpdateHP()
		v14.Frame = clone2
		v11[instance] = v14
	end
end

function DisconnectBoss(p, p2)
	if v12[p.Name] and not p2 then
		local flag15 = true
		local fuse = v12[p.Name].Fuse

		if fuse then
			local v14 = not RaidBossList[p.Name].Distance and 450 or RaidBossList[p.Name].Distance

			for _, v15 in pairs(fuse) do
				local rootPart = v15.RootPart

				if rootPart and v15.Health > 0 and (humanoidRootPart.Position - rootPart.Position).Magnitude < v14 then
					flag15 = nil
				end
			end

			if flag15 then
				v12[p.Name].Frame:Destroy()

				for _, connection in pairs(v12[p.Name].Connections) do
					connection:Disconnect()
				end

				v12[p.Name] = nil
			end
		else
			v12[p.Name].Frame:Destroy()

			for _, connection in pairs(v12[p.Name].Connections) do
				connection:Disconnect()
			end

			v12[p.Name] = nil
		end
	else
		if not v11[p] then
			return
		end

		if v11[p].Connections then
			for _, connection in pairs(v11[p].Connections) do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			v11[p].Connections = nil
		end

		if v11[p].Frame then
			v11[p].Frame:Destroy()
			v11[p].Frame = nil
		end

		v11[p] = nil
	end
end

function IsBossBeingTracked(p)
	for _, v14 in pairs(v13) do
		local bosses = v14.Bosses

		if bosses and table.find(bosses, p) then
			return true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RoundNumber(p: number)
	local v14 = string.format("%.3f", p)
	local v15 = string.gsub(v14, "0+$", "")
	return (string.gsub(v15, "%.$", ""))
end

function FindTrackedBossByID(p)
	for _, v14 in pairs(v13) do
		if v14.BossID == p then
			return v14
		end
	end
end

function TrackBoss(instance)
	local humanoid = instance:WaitForChild("Humanoid", 7)

	if not humanoid or IsBossBeingTracked(instance) then
		return
	end

	local maxHealth = humanoid.MaxHealth
	local bossID = instance:GetAttribute("BossID")
	local v14 = bossID and FindTrackedBossByID(bossID)

	if v14 then
		v14.TotalBossMaxHealth = (v14.TotalBossMaxHealth or 0) + maxHealth
		table.insert(v14.Bosses, instance)
	else
		local class = {}
		local v15 = {
			Bosses = {},
			Events = class,
			TotalBossMaxHealth = maxHealth
		}

		if bossID then
			v15.BossID = bossID
		end

		table.insert(v15.Bosses, instance)
		local distance = 300
		local name = RaidBossList[instance.Name] and RaidBossList[instance.Name].Name or instance.Name
		local connections = {}
		local clone2 = script.File.BossFrame:Clone()
		clone2.Name = instance.Name
		clone2.HPFrame.BossName.Text = name
		clone2.HPFrame.BossNameShadow.Text = name

		if RaidBossList[instance.Name] and RaidBossList[instance.Name].BorderImage then
			clone2.HPFrame.BorderFrame.Visible = true
			clone2.HPFrame.BorderFrame.Image = RaidBossList[instance.Name].BorderImage
		end

		if RaidBossList[instance.Name] and RaidBossList[instance.Name].Distance then
			distance = RaidBossList[instance.Name].Distance
		end

		clone2.Visible = nil
		local absoluteSize = starterFrame.BossesHealthBar.Frames.AbsoluteSize
		clone2.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024 + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y)
		clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function VisibleDamageList(p)
			if p then
				clone2.HPFrame.Damages.DropsButton.Text = "<font color=\"#ff0000\"><font size=\"8\">▼</font></font> Damages "
			else
				clone2.HPFrame.Damages.DropsButton.Text = "<font color=\"#ff0000\"><font size=\"8\">◄</font></font> Damages "
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function VisibleDropList(p)
			if p then
				clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">▼</font></font>"
			else
				clone2.HPFrame.Drops.DropsButton.Text = "Drops <font color=\"#ff0000\"><font size=\"8\">►</font></font>"
			end
		end

		local function UpdateOffset()
			if clone2.HPFrame.Damages.ScrollingFrame.Visible or clone2.HPFrame.Drops.DropsList.Visible then
				local v16 = absoluteSize.Y * 0.024
				local Y = clone2.HPFrame.Drops.DropsList.UIListLayout.AbsoluteContentSize.Y

				if clone2.HPFrame.Damages.ScrollingFrame.Visible and clone2.HPFrame.Drops.DropsList.Visible then
					Y = math.max(
						clone2.HPFrame.Drops.DropsList.UIListLayout.AbsoluteContentSize.Y,
						math.min(#clone2.HPFrame.Damages.ScrollingFrame:GetChildren() - 1, 3) * v16
					)
				elseif (clone2.HPFrame.Damages.ScrollingFrame.Visible or not clone2.HPFrame.Drops.DropsList.Visible) and clone2.HPFrame.Damages.ScrollingFrame.Visible and not clone2.HPFrame.Drops.DropsList.Visible then
					Y = math.min(#clone2.HPFrame.Damages.ScrollingFrame:GetChildren() - 1, 3) * v16
				end

				local v17 = v16 + Y + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y + 1
				clone2.Size = UDim2.new(1, 0, 0, v17)
				clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)
			elseif not (clone2.HPFrame.Damages.ScrollingFrame.Visible or clone2.HPFrame.Drops.DropsList.Visible) then
				local v16 = absoluteSize.Y * 0.024
				clone2.Size = UDim2.new(1, 0, 0, v16 + clone2.HPFrame.Drops.DropsButton.AbsoluteSize.Y)
				clone2.HPFrame.Size = UDim2.new(1, 0, 0, absoluteSize.Y * 0.024)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateCustomName()
			local customName = instance:GetAttribute("CustomName")

			if not customName then
				return
			end

			clone2.HPFrame.BossName.Text = tostring(customName)
			clone2.HPFrame.BossNameShadow.Text = tostring(customName)
		end

		if RaidBossList[instance.Name] and RaidBossList[instance.Name].Drops then
			local drops = RaidBossList[instance.Name].Drops

			if drops and typeof(drops) == "function" then
				drops = drops()
			end

			for k, drop in pairs(drops) do
				if not tonumber((string.sub(drop, 1, #drop - 1))) then
					continue
				end

				local clone3 = script.File.Item1:Clone()
				clone3.Name = k
				local v16 = AccessoriesList[k] or SwordList[k] or MaterialList[k]

				if v16 and v16.Image then
					clone3.ImageLabel.Image = v16.Image
					local v17 = nil
					local connections2 = {}
					local name2 = k
					local v19 = v16
					local v20 = clone3
					connections2[#connections2 + 1] = clone3.ImageLabel.MouseEnter:Connect(function()
						v17 = true
						local mouseLocation = UserInputService:GetMouseLocation()
						local X = mouseLocation.X
						local Y = mouseLocation.Y
						local v22 = starterFrame.BossesHealthBar.AbsoluteSize.X * 0.05
						local clone4 = script.File.PreviewItem:Clone()
						clone4.Name = name2
						clone4.Position = UDim2.new(0, X, 0, Y)
						clone4.Size = UDim2.new(0, v22, 0, v22)
						clone4.Image = v19.Image
						clone4.Parent = starterFrame.BossesHealthBar

						while v17 and v20:IsDescendantOf(starterFrame.BossesHealthBar) do
							local mouseLocation2 = UserInputService:GetMouseLocation()
							local X2 = mouseLocation2.X
							local Y2 = mouseLocation2.Y
							clone4.Position = UDim2.new(
								0,
								X2 - clone4.AbsoluteSize.Y / 3,
								0,
								Y2 - clone4.AbsoluteSize.Y / 2
							)
							task.wait()
						end

						clone4:Destroy()
						v17 = nil

						if not v20:IsDescendantOf(starterFrame.BossesHealthBar) then
							for k2, connection in pairs(connections2) do
								if connection.Connected then
									connection:Disconnect()
								end
							end

							table.clear(connections2)
						end
					end)
					connections2[#connections2 + 1] = clone3.ImageLabel.MouseLeave:Connect(function()
						v17 = nil
					end)
				end

				clone3.Parent = clone2.HPFrame.Drops.DropsList
			end

			function class.UpdateDropChances()
				local value = 0
				local characterPassives = character:FindFirstChild("CharacterPassives")

				if characterPassives and characterPassives:FindFirstChild("IncreaseDropRate") then
					local increaseDropRate = characterPassives.IncreaseDropRate

					if increaseDropRate.Value > 0 then
						value = increaseDropRate.Value
					end
				end

				local jSONDecode = HttpService:JSONDecode(localPlayer2.PlayerStats.LuckBoosts.Value)

				for childName, drop in pairs(drops) do
					local v16 = tonumber((string.sub(drop, 1, #drop - 1)))

					if not v16 then
						continue
					end

					local child = clone2.HPFrame.Drops.DropsList:FindFirstChild(childName)

					if not child then
						continue
					end

					local v17 = jSONDecode[childName] or 0
					local total = 0

					if localPlayer2.PlayerStats.RealDropX2.Value > 1 then
						total += 100
					end

					local v19 = 0 + v16 * value
					local v20 = total + value
					v19 += v17
					local v21 = v20 + v17
					local roundNumber = RoundNumber(v16 + v16 * v21 / 100) -- equivalent call inferred; original call site unknown
					local v24

					if v21 > 0 then
						v24 = tostring(roundNumber) .. "% (+" .. RoundNumber(v21) .. "%)"
					else
						v24 = tostring(roundNumber) .. "%"
					end

					child.Text = (CustomNames[childName] or childName) .. " - " .. v24

					if MaterialList[childName] and MaterialList[childName].FixedName then
						child.Text = MaterialList[childName].FixedName .. " - " .. v24
					end
				end
			end

			class.UpdateDropChances()
			table.insert(connections, clone2.HPFrame.Drops.DropsButton.MouseButton1Click:Connect(function()
				_G.ClickFrameEffect({
					Sound = true
				})
				clone2.HPFrame.Drops.DropsList.Visible = not clone2.HPFrame.Drops.DropsList.Visible

				if clone2.HPFrame.Drops.DropsList.Visible then
					VisibleDropList(true) -- equivalent call inferred; original call site unknown
				else
					VisibleDropList(false) -- equivalent call inferred; original call site unknown
				end
			end))
			UpdateOffset(clone2.HPFrame.Drops.DropsList.Visible)
		else
			clone2.HPFrame.Drops.Visible = nil
		end

		table.insert(connections, clone2.HPFrame.Damages.DropsButton.MouseButton1Click:Connect(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			clone2.HPFrame.Damages.ScrollingFrame.Visible = not clone2.HPFrame.Damages.ScrollingFrame.Visible

			if clone2.HPFrame.Damages.ScrollingFrame.Visible then
				VisibleDamageList(true) -- equivalent call inferred; original call site unknown
			else
				VisibleDamageList(false) -- equivalent call inferred; original call site unknown
			end
		end))
		clone2.Parent = starterFrame.BossesHealthBar.Frames
		table.insert(connections, instance:GetAttributeChangedSignal("CustomName"):Connect(function()
			local customName = instance:GetAttribute("CustomName")

			if not customName then
				return
			end

			clone2.HPFrame.BossName.Text = tostring(customName)
			clone2.HPFrame.BossNameShadow.Text = tostring(customName)
		end))
		table.insert(connections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			v15.TotalBossMaxHealth = humanoid.MaxHealth
		end))
		UpdateCustomName() -- equivalent call inferred; original call site unknown

		function class.UpdateOffset()
			local v16 = absoluteSize.Y * 0.024
			local count = 0

			for _, label in pairs(clone2.HPFrame.Damages.ScrollingFrame:GetChildren()) do
				if not label:IsA("TextLabel") then
					continue
				end

				label.Size = UDim2.new(0.95, 0, 0, v16)
				count += 1
			end

			clone2.HPFrame.Damages.ScrollingFrame.Size = UDim2.new(0.985, 0, 0, math.min(count, 3) * v16)
			UpdateOffset()
		end

		function class.Destroy()
			for i = #v13, 1, -1 do
				if v13[i] ~= v15 then
					continue
				end

				table.remove(v13, i)
				break
			end

			clone2:Destroy()
			table.clear(v15.Bosses)
			v15.Bosses = nil

			for k, _ in pairs(class) do
				class[k] = nil
			end

			class = nil

			for k, _ in pairs(v15) do
				v15[k] = nil
			end

			v15 = nil

			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			connections = nil
		end

		function class.IsInBossDistance()
			local bosses = v15.Bosses

			for _, boss in pairs(bosses) do
				local humanoidRootPart2 = boss:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					continue
				end

				local v16 = humanoidRootPart.Position - humanoidRootPart2.Position

				if math.sqrt(v16.X ^ 2 + v16.Z ^ 2) < distance then
					return true
				end
			end
		end

		function class.Step()
			if not v15 then
				return
			end

			local bosses = v15.Bosses

			if not bosses or bosses and #bosses <= 0 then
				class:Destroy()
				return
			end

			local v16 = {}

			for i = #bosses, 1, -1 do
				local boss = bosses[i]

				if boss and (not boss or boss:IsDescendantOf(game)) then
					local humanoid2 = boss:FindFirstChild("Humanoid")

					for _, intValue in pairs(humanoid2:GetChildren()) do
						if not (intValue:IsA("IntValue") and game.Players:FindFirstChild(intValue.Name)) then
							continue
						end

						v16[intValue.Name] = (v16[intValue.Name] or 0) + intValue.Value
					end
				else
					table.remove(bosses, i)
				end
			end

			local totalBossMaxHealth = v15.TotalBossMaxHealth or 0

			for childName, v17 in pairs(v16) do
				local clone3 = clone2.HPFrame.Damages.ScrollingFrame:FindFirstChild(childName)

				if not clone3 then
					clone3 = script.File.DamageLabel:Clone()
					clone3.Name = childName
					clone3.Parent = clone2.HPFrame.Damages.ScrollingFrame
				end

				local v18 = string.format("%.2f", (tostring(math.clamp(v17 / totalBossMaxHealth, 0, 1) * 100)))
				clone3.Text = tostring("%s - %s%%"):format(childName, (tostring(v18)))

				if childName == localPlayer2.Name then
					clone3.LayoutOrder = -1e999
				else
					clone3.LayoutOrder = -v17
				end
			end

			class.UpdateOffset()

			if class.IsInBossDistance() then
				if not clone2.Visible then
					clone2.Visible = true

					if class.UpdateDropChances then
						class.UpdateDropChances()
					end
				end
			elseif clone2.Visible then
				clone2.Visible = nil
			end

			if not clone2.Visible then
				return
			end

			local totalBossMaxHealth2 = v15.TotalBossMaxHealth or 0
			local total = 0

			for _, boss in pairs(bosses) do
				local humanoid2 = boss:FindFirstChild("Humanoid")

				if humanoid2 then
					total += humanoid2.Health
				end
			end

			local v17 = math.clamp(total / totalBossMaxHealth2, 0, 1)

			if v15.CurrentHealth ~= total then
				v15.CurrentHealth = total
				TweenService:Create(clone2.HPFrame.Bar, TweenInfo.new(0.25), {
					Size = UDim2.fromScale(v17, 0.98)
				}):Play()

				if total <= 0 then
					clone2.HPFrame.HealthText.Text = "DEFEATED"
				else
					clone2.HPFrame.HealthText.Text = tostring(Commas(total)) .. "/" .. Commas(totalBossMaxHealth2)
				end

				task.delay(0.2, function()
					if clone2 and clone2:FindFirstChild("HPFrame") and clone2.HPFrame:FindFirstChild("UnderFrame") then
						TweenService:Create(clone2.HPFrame.UnderFrame, TweenInfo.new(0.25), {
							Size = UDim2.fromScale(v17, 0.98)
						}):Play()
					end
				end)
			end
		end

		table.insert(v13, v15)
	end
end

function AddBoss(model)
	if not (model:IsA("Model") and RaidBossList[model.Name]) then
		return
	end

	table.insert(models, model)
	TrackBoss(model)
end

function RemoveBoss(model)
	if not (model:IsA("Model") and RaidBossList[model.Name]) then
		return
	end

	for k, v14 in pairs(models) do
		if v14 ~= model then
			continue
		end

		DisconnectBoss(model, true)
		table.remove(models, k)
		break
	end
end

workspace:WaitForChild("Monster")
workspace.Monster.Boss.ChildAdded:Connect(AddBoss)
workspace.Monster.Mon.ChildAdded:Connect(AddBoss)
workspace.Monster.Boss.ChildRemoved:Connect(RemoveBoss)
workspace.Monster.Mon.ChildRemoved:Connect(RemoveBoss)

if workspace:FindFirstChild("MOB") then
	workspace.MOB.ChildAdded:Connect(AddBoss)
end

for _, child in pairs(workspace.Monster.Mon:GetChildren()) do
	AddBoss(child)
end

for _, child in pairs(workspace.Monster.Boss:GetChildren()) do
	AddBoss(child)
end

local ghostMonster = workspace:FindFirstChild("GhostMonster")
local seaMonster = workspace:FindFirstChild("SeaMonster")

if ghostMonster then
	ghostMonster.ChildAdded:Connect(AddBoss)
	ghostMonster.ChildRemoved:Connect(RemoveBoss)

	for _, child in pairs(ghostMonster:GetChildren()) do
		AddBoss(child)
	end
end

if seaMonster then
	seaMonster.ChildAdded:Connect(AddBoss)
	seaMonster.ChildRemoved:Connect(RemoveBoss)

	for _, child in pairs(seaMonster:GetChildren()) do
		AddBoss(child)
	end
end

local userOwnsGamePassAsync = MarketplaceService:UserOwnsGamePassAsync(localPlayer2.UserId, 7936106)
spawn(function()
	local fruitDistance = statusEffect.FruitDistance

	while wait(0.1) do
		for i = #v13, 1, -1 do
			local v14 = v13[i]

			if v14 then
				local events = v14.Events

				if events then
					local events2 = events
					local success, result = pcall(function()
						events2:Step()
					end)

					if not success then
						pcall(events.Destroy)
						warn(result)
					end
				end
			else
				table.remove(v13, i)
			end
		end

		local v14 = FindFruit()

		if v14 and v14:FindFirstChild("Handle") then
			local jSONDecode = HttpService:JSONDecode(localPlayer2.PlayerStats.Misc.Value)

			if userOwnsGamePassAsync or jSONDecode.FruitNotifier then
				if not fruitDistance.Visible then
					fruitDistance.Visible = true
				end

				if fruitDistance.Frame.ImageLabel.Image ~= v14.TextureId then
					fruitDistance.Frame.ImageLabel.Image = v14.TextureId
				end

				local v15 = math.floor((humanoidRootPart.Position - v14.Handle.Position).Magnitude / 7)

				if localPlayer2.PlayerStats.Language.Value == "TH" then
					fruitDistance.Frame.TimeLabel.Text = v15 .. "ม."
				else
					fruitDistance.Frame.TimeLabel.Text = v15 .. "M"
				end
			end
		elseif fruitDistance.Visible then
			fruitDistance.Visible = false
		end

		local trackQuestGui = localPlayer2.PlayerGui:FindFirstChild("TrackQuestGui")

		if trackQuestGui and trackQuestGui.Adornee and trackQuestGui.Adornee:IsA("BasePart") then
			trackQuestGui.TextLabel.Text = math.floor((humanoidRootPart.Position - trackQuestGui.Adornee.Position).Magnitude / 7) .. "m"
		end
	end
end)
local imageLabel = mapFrame.ImageLabel
local versionText = starterFrame:WaitForChild("VersionText")
local v14, v15

if v3[game.PlaceId] then
	imageLabel = mapFrame.ImageLabel2
	v14 = "Sea2"
	v15 = 0.15
else
	v14 = "Sea1"
	v15 = 0.12
end

if v4[game.PlaceId] then
	imageLabel = mapFrame.ImageLabel3
	v14 = "Sea3"
	v15 = 0.15
end

versionText.Text = `v10.2-{v14}`
task.spawn(function()
	local mapFrame2 = starterFrame:WaitForChild("MapFrame")
	local playerIconFrame = mapFrame2:WaitForChild("PlayerIconFrame")
	local playerDot = playerIconFrame:WaitForChild("PlayerDot")
	local whirlpoolTracking = mapFrame2.MapBuff.WhirlpoolTracking
	mapFrame2:GetPropertyChangedSignal("Visible"):Connect(function()
		if _G.CheckAwakeClient(localPlayer2, "WhirlpoolTracking") then
			whirlpoolTracking.Visible = true
		else
			whirlpoolTracking.Visible = false
		end
	end)
	whirlpoolTracking.MouseEnter:Connect(function()
		whirlpoolTracking.TextLabel.Visible = true
	end)
	whirlpoolTracking.MouseLeave:Connect(function()
		whirlpoolTracking.TextLabel.Visible = false
	end)
	local localPlayer3 = Players.LocalPlayer

	for _, button in pairs(imageLabel:GetChildren()) do
		if not (button:IsA("TextButton") and button:GetAttribute("IslandButton")) then
			continue
		end

		local parent2 = button
		button.MouseButton1Click:Connect(function()
			local name = parent2.Name

			if clone then
				clone:Destroy()
				clone = nil
			end

			if v then
				v:Destroy()
				v = nil
			end

			if v2 then
				v2:Destroy()
				v2 = nil
			end

			parent2.Size = UDim2.new(v15 * 1.25, 0, v15 * 1.25, 0)
			TweenService:Create(
				parent2,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = UDim2.new(v15 * 2, 0, v15 * 2, 0)
				}
			):Play()
			parent2.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				parent2.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()

			if IslandInfo[name] then
				if mapFrame2.Information.NameText.Text == IslandInfo[name].Name and mapFrame2.Information.Visible then
					mapFrame2.Information.Visible = false
					return
				end

				if not parent2:FindFirstChild("Selected") then
					clone = script.Selected:Clone()
					clone.Rotation = 180
					clone.Parent = parent2
					v = TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Rotation = 360
					})
					v:Play()
				end

				mapFrame2.Information.Icon.Image = IslandInfo[name].Icon
				mapFrame2.Information.InfoText.Text = IslandInfo[name].InfoText
				mapFrame2.Information.NameText.Text = IslandInfo[name].Name
				mapFrame2.Information.Visible = true
				mapFrame2.Information.Icon.Size = UDim2.new(0, 0, 0, 0)
				v2 = TweenService:Create(mapFrame2.Information.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = UDim2.new(0.525, 0, 0.5, 0)
				})
				v2:Play()
			end
		end)
		local v17 = button
		button.MouseEnter:Connect(function()
			v17.ImageLabel.ZIndex = 2
			v17.Size = UDim2.new(v15, 0, v15, 0)
			TweenService:Create(v17, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = UDim2.new(v15 * 1.25, 0, v15 * 1.25, 0)
			}):Play()
		end)
		local v18 = button
		button.MouseLeave:Connect(function()
			v18.ImageLabel.ZIndex = 1
			TweenService:Create(v18, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				Size = UDim2.new(v15, 0, v15, 0)
			}):Play()
		end)
	end

	local v16, v17

	if v3[game.PlaceId] then
		v16 = 22225.48046875
		v17 = 17994.458984375
	else
		v16 = 11676.365234375
		v17 = 14067.544921875
	end

	if v4[game.PlaceId] then
		v16 = 24713.1796875
		v17 = 27123.091796875
	end

	playerDot.AnchorPoint = Vector2.new(0.5, 0.5)
	local userThumbnailAsync = Players:GetUserThumbnailAsync(
		localPlayer3.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	playerDot.PlayerIcon.ImageLabel.Image = userThumbnailAsync or "rbxassetid://7992557358"
	local v18 = {}

	while true do
		if mapFrame2.Visible then
			task.wait(0.5)
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			for _, v19 in pairs(Players:GetPlayers()) do
				if allies:FindFirstChild(v19.Name) then
					if not v18[v19.Name] then
						v18[v19.Name] = true
					end
				elseif v18[v19.Name] then
					v18[v19.Name] = nil
					local child = playerIconFrame:FindFirstChild(v19.Name)

					if child then
						child:Destroy()
					end
				end
			end

			if humanoid then
				for childName, _ in pairs(v18) do
					local child = Players:FindFirstChild(childName)

					if child then
						local character2 = child.Character

						if character2 then
							local humanoid2 = character2:FindFirstChild("Humanoid")

							if humanoid2 and humanoid2.Health > 0 and humanoid2 ~= humanoid and humanoid2.RootPart then
								local rootPart = humanoid2.RootPart
								local v19 = 0.5 + rootPart.Position.X / v16
								local v20 = 0.5 + rootPart.Position.Z / v17
								local v21 = math.clamp(v19, -0.1, 1.1)
								local v22 = math.clamp(v20, -0.1, 1.1)
								local clone2 = playerIconFrame:FindFirstChild(child.Name)

								if not clone2 then
									local userThumbnailAsync2 = Players:GetUserThumbnailAsync(
										child.UserId,
										Enum.ThumbnailType.HeadShot,
										Enum.ThumbnailSize.Size420x420
									)
									clone2 = script.File.AllyDot:Clone()

									if userThumbnailAsync2 then
										clone2.PlayerIcon.ImageLabel.Image = userThumbnailAsync2
									else
										clone2.PlayerIcon.ImageLabel.Image = "rbxassetid://7992557358"
									end

									clone2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
									clone2.Name = child.Name
									clone2.AllyName.Text = child.Name
									clone2.Visible = true
									clone2.Parent = playerIconFrame
								end

								clone2.Position = UDim2.new(v21, 0, v22, 0)
							end
						end
					else
						local child2 = playerIconFrame:FindFirstChild(childName)

						if child2 then
							child2:Destroy()
						end

						v18[childName] = nil
					end
				end
			end

			if humanoidRootPart2 then
				local v19 = 0.5 + humanoidRootPart2.Position.x / v16
				local v20 = 0.5 + humanoidRootPart2.Position.z / v17
				local v21 = math.clamp(v19, -0.1, 1.1)
				local v22 = math.clamp(v20, -0.1, 1.1)
				playerDot.Position = UDim2.new(v21, 0, v22, 0)
			end

			local serpentWhirlpool = workspace.Effects:FindFirstChild("SerpentWhirlpool")
			local visible = _G.CheckAwakeClient(localPlayer3, "WhirlpoolTracking")
			mapFrame2.MapBuff.Visible = visible
			mapFrame2.MapBuff.WhirlpoolTracking.Visible = visible
			local whirlpoolImage = mapFrame2.PlayerIconFrame:FindFirstChild("WhirlpoolImage")

			if serpentWhirlpool and not whirlpoolImage and visible then
				whirlpoolImage = script.File.WhirlpoolImage:Clone()
				whirlpoolImage.Parent = mapFrame2.PlayerIconFrame
			elseif not (serpentWhirlpool and visible) and whirlpoolImage then
				whirlpoolImage:Destroy()
				whirlpoolImage = nil
			end

			if whirlpoolImage then
				local position = serpentWhirlpool:GetPivot().Position
				local v20 = 0.5 + position.X / v16
				local v21 = 0.5 + position.Z / v17
				local v22 = math.clamp(v20, -0.1, 1.1)
				local v23 = math.clamp(v21, -0.1, 1.1)
				whirlpoolImage.Position = UDim2.fromScale(v22, v23)
			end
		else
			task.wait()
			mapFrame2:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
local clouds = mapFrame:WaitForChild("Clouds")
imageLabel.Visible = true
local v16 = { "rbxassetid://9569199936", "rbxassetid://9569201381", "rbxassetid://9569202114" }
local v17 = {}
local v18 = {
	["Bubble Island"] = true,
	["Chef Ship"] = true,
	Fishland = true,
	["Lobby Island"] = true,
	["Pirate Island"] = true,
	["Rainy Stone"] = true,
	["Desert Island"] = true,
	["Shark Island"] = true,
	["Sky Island"] = true,
	["Soldier Island"] = true,
	["Starter Island"] = true,
	["Snow Island"] = true,
	["War Island"] = true,
	["Zombie Island"] = true,
	["Stone Arena"] = true,
	["Forgotten Prison"] = true,
	["Dead Tundra"] = true,
	["Japan Island"] = true,
	["Loaf Island"] = true,
	["Shred Endangering"] = true,
	["Skull Island"] = true,
	["Soldier Headquater"] = true,
	["Pirate Skull Island"] = true,
	Fiore = true,
	["Lavahold Prison"] = true,
	["The Unearthly"] = true,
	["The Shallow"] = true,
	["Luma Grove"] = true,
	["Forgotten Coliseum"] = true,
	["Drakenhold Fortress"] = true,
	["Land of Detention"] = true,
	["Crownfall Isle"] = true,
	["Primeval Isle"] = true
}

for i = -0.08, 0.8, 0.12 do
	for i2 = -0.1, 0.8, 0.12 do
		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Image = v16[math.random(1, #v16)]
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.Size = UDim2.new(0.35, 0, 0.35, 0)
		imageLabel2.Rotation = math.random(-10, 10)
		imageLabel2.Position = UDim2.new(i, 0, i2, 0)
		imageLabel2.ZIndex = 2
		imageLabel2.ImageTransparency = math.random(0, 500) / 1000
		imageLabel2.Parent = clouds
		table.insert(v17, imageLabel2)
	end
end

function UpdateClound()
	wait(0.1)
	local jSONDecode = HttpService:JSONDecode(localPlayer2.PlayerStats.IslandUnlock.Value)
	local v19 = {}

	for k, v20 in pairs(v18) do
		v19[k] = v20
	end

	local flag15 = true

	for childName, _ in pairs(v18) do
		if jSONDecode[childName] then
			continue
		end

		v19[childName] = nil
		flag15 = nil

		if imageLabel:FindFirstChild(childName) then
			imageLabel[childName].Visible = false
		end
	end

	for _, button in pairs(imageLabel:GetChildren()) do
		if not (button:IsA("TextButton") and v19[button.Name]) then
			continue
		end

		button.Visible = true

		for _, v20 in pairs(v17) do
			if not ((v20.AbsolutePosition + v20.AbsoluteSize / 3 - button.AbsolutePosition).Magnitude <= imageLabel.AbsoluteSize.Magnitude / 7.5 and v20:IsDescendantOf(mapFrame.Clouds)) then
				continue
			end

			v20:Destroy()
		end
	end

	if flag15 then
		for _, _ in pairs(v17) do

		end
	end
end

localPlayer2:WaitForChild("PlayerStats").IslandUnlock:GetPropertyChangedSignal("Value"):Connect(UpdateClound)
spawn(function()
	wait(2)
	UpdateClound()
end)
spawn(function()
	while true do
		if mapFrame.Visible then
			for _, v19 in pairs(v17) do
				if not v19:IsDescendantOf(mapFrame.Clouds) then
					continue
				end

				local v20 = math.random(25, 35) / 100
				TweenService:Create(v19, TweenInfo.new(5, Enum.EasingStyle.Linear), {
					Rotation = math.random(-15, 15),
					Size = UDim2.new(v20, 0, v20, 0)
				}):Play()
			end

			wait(4)
		else
			task.wait()
			mapFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
local v19 = nil
local part = nil
local currentQuest = localPlayer2:WaitForChild("CurrentQuest")
local clone2 = nil
local v20 = nil
local value = nil
local heartbeatConnection = nil

function UpdateTrackQuest()
	local trackQuestGui = localPlayer2.PlayerGui:FindFirstChild("TrackQuestGui")

	if not trackQuestGui then
		warn("Not Found TrackQuestGui.")
	elseif v19 then
		local v21 = 0
		local v22 = 0
		local elitePirate = nil

		for _, child in pairs(workspace.AllNPC:GetChildren()) do
			local levelMin = child:GetAttribute("LevelMin")
			local levelMax = child:GetAttribute("LevelMax")

			if not (levelMin and levelMax and levelMin <= localPlayer2.PlayerStats.lvl.Value and v21 <= levelMin) then
				continue
			end

			elitePirate = child
			v22 = levelMax
			v21 = levelMin
		end

		for _, child in pairs(ReplicatedStorage.NPC:GetChildren()) do
			local levelMin = child:GetAttribute("LevelMin")
			local levelMax = child:GetAttribute("LevelMax")

			if not (levelMin and levelMax and levelMin <= localPlayer2.PlayerStats.lvl.Value and v21 <= levelMin) then
				continue
			end

			elitePirate = child
			v21 = levelMin
		end

		if v22 == 2200 then
			if localPlayer2.PlayerStats.SecondSeaProgression.Value == "Yes" then
				elitePirate = workspace.AllNPC:FindFirstChild("Elite Pirate") or ReplicatedStorage.MAP:FindFirstChild("Elite Pirate")
			end
		elseif v22 == 3950 and _G.CheckAwakeClient(localPlayer2, "ThirdSea") then
			elitePirate = workspace.AllNPC:FindFirstChild("The Squid") or ReplicatedStorage.MAP:FindFirstChild("The Squid")
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		if elitePirate and v19 then
			if clone2 and clone2.Parent then
				clone2:Destroy()
				clone2 = nil
			end

			if not clone2 then
				clone2 = ReplicatedStorage.Chest.Etc.ArrowQuest:Clone()
				clone2.Name = localPlayer2.Name .. " ArrowQuest"
				clone2:SetAttribute("NoAutoDelete", true)
				clone2.Parent = workspace.Effects
			end

			if currentQuest.Value == "" then
				if currentQuest.Value == "" then
					if part and part.Parent then
						part:Destroy()
						part = nil
					end

					if trackQuestGui:FindFirstChild("ImageLabel") then
						trackQuestGui.ImageLabel.Image = "rbxassetid://85874026506238"
					end

					trackQuestGui.Adornee = elitePirate
					trackQuestGui.Enabled = true
					local position = elitePirate.Position
					local v23 = nil
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						if clone2 and not part and (not clone2 or clone2.Parent) then
							local transparency = math.abs((math.sin(os.clock() * 4))) * 0.5
							clone2.Transparency = transparency
							local v25 = position - humanoidRootPart.Position

							if v25.Magnitude > 0 then
								local cFrame = CFrame.new(
									humanoidRootPart.Position,
									humanoidRootPart.Position + v25.Unit
								) * CFrame.new(0, 0, -4)

								if not v23 or (v23.Position - cFrame.Position).Magnitude > 0.05 or v23.LookVector:Dot(cFrame.LookVector) < 0.999 then
									clone2.CFrame = cFrame
									v23 = cFrame
								end
							end

							return
						end

						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end)
				end
			else
				if part and part.Parent then
					part:Destroy()
					part = nil
				end

				trackQuestGui.Adornee = nil
				trackQuestGui.Enabled = false

				if value then
					if value and value ~= currentQuest.Value then
						value = currentQuest.Value
					end
				else
					value = currentQuest.Value
				end

				local mob = QuestManager[currentQuest.Value].Mob
				local v23 = mob and ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer(
					"GetEntityLocation",
					{
						EntityName = mob
					}
				)

				if v23 then
					part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.Size = createVector(1, 1, 1)
					part.Transparency = 1
					part.Material = Enum.Material.SmoothPlastic
					part.CFrame = CFrame.new(v23) * CFrame.new(0, 30, 0)
					part:SetAttribute("NoAutoDelete", true)
					part.Parent = workspace.Effects

					if trackQuestGui:FindFirstChild("ImageLabel") then
						trackQuestGui.ImageLabel.Image = "rbxassetid://74242855054195"
					end

					trackQuestGui.Adornee = part
					trackQuestGui.Enabled = true
					local v24 = nil
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						if clone2 and part and (not clone2 or clone2.Parent) and (not part or part.Parent) then
							local transparency = math.abs((math.sin(os.clock() * 4))) * 0.5
							clone2.Transparency = transparency
							local v26 = v23 - humanoidRootPart.Position

							if v26.Magnitude > 0 then
								local cFrame = CFrame.new(
									humanoidRootPart.Position,
									humanoidRootPart.Position + v26.Unit
								) * CFrame.new(0, 0, -4)

								if not v24 or (v24.Position - cFrame.Position).Magnitude > 0.05 or v24.LookVector:Dot(cFrame.LookVector) < 0.999 then
									clone2.CFrame = cFrame
									v24 = cFrame
								end
							end
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
				end
			end
		end
	else
		value = nil
		v20 = nil
		trackQuestGui.Adornee = nil
		trackQuestGui.Enabled = false

		if clone2 and clone2.Parent then
			clone2:Destroy()
			clone2 = nil
		end
	end
end

localPlayer2.PlayerStats.lvl.Changed:Connect(function()
	UpdateTrackQuest()
end)
currentQuest.Changed:Connect(function()
	UpdateTrackQuest()
end)
local file = script:WaitForChild("File")
starterFrame:WaitForChild("Configuration")
local settingFrame = serverBrowserFrame.MainFrame:WaitForChild("SettingFrame")
serverBrowserFrame.MainFrame:WaitForChild("ServerFrame")
local refreshButton = serverBrowserFrame.MainFrame:WaitForChild("RefreshButton")
serverBrowserFrame.MainFrame:WaitForChild("ServerCount")
game:GetService("TeleportService")
spawn(function()
	repeat
		wait()
	until localPlayer2.PlayerGui:FindFirstChild("TopbarPlus")

	local topbarContainer = localPlayer2.PlayerGui:WaitForChild("TopbarPlus"):WaitForChild("TopbarContainer")

	repeat
		local flag15 = nil
		local serverBrowser = topbarContainer:FindFirstChild("ServerBrowser", true)

		if serverBrowser then
			local iconButton = serverBrowser:FindFirstChild("IconButton")
			local iconLabel = iconButton and iconButton:FindFirstChild("IconLabel")

			if iconLabel then
				iconLabel.TextScaled = true
				flag15 = true
			end
		end

		wait(1)
	until flag15
end)
v5.selected:Connect(function()
	_G.ServerButtonClick()
end)
v5.deselected:Connect(function()
	_G.ServerButtonClick()
end)

function SearchCheck(value2, value3, _)
	if value2 == "" then
		return true
	end

	local v21 = string.lower(value2)
	local v22 = string.lower(value3)

	for i = 1, #v22 do
		if string.sub(v21, 1, #v21) == string.sub(v22, 1, i) or string.sub(v21, 1, #v21) == string.sub(
			v22,
			i,
			i + (#v21 - 1)
		) then
			return true
		end
	end
end

function SetFrame()
	if not v9 then
		return
	end

	v9 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	settingFrame.RegionFrame.Visible = false
end

local v21 = true
refreshButton.MouseButton1Click:Connect(function()
	if not (v21 and v9) then
		return
	end

	v9 = false
	v21 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	task.spawn(function()
		wait(0.5)
		v21 = true
	end)
end)
local v22 = nil
local v23 = nil
require(ReplicatedStorage.Chest.Modules.PeodizService)
local compassFrame = script.Parent:WaitForChild("CompassFrame")
local v24 = {
	"NW",
	"N",
	"NE",
	"E",
	"SE",
	"S",
	"SW",
	"W",
	"NW",
	"N",
	"NE"
}
local currentCamera = workspace.CurrentCamera
local slideFrame = compassFrame:WaitForChild("SlideFrame")
compassFrame:WaitForChild("Background")
local mainFrame = slideFrame:WaitForChild("MainFrame")
local clones = {}
local v25 = {}
local clones2 = {}
local v26 = {
	SerpentLocation = {
		LocationName = "Serpent",
		LocationImage = "rbxassetid://88523269369843"
	},
	KrakenLocation = {
		LocationName = "Chaos Kraken",
		LocationImage = "rbxassetid://17583135281"
	},
	SeaDragonLocation = {
		LocationName = "Abyssal Tyrant",
		LocationImage = "rbxassetid://104776755060269"
	},
	DragonLocation = {
		LocationName = "Drakenfyr the Inferno King",
		LocationImage = "rbxassetid://16741887011"
	},
	CrabLocation = {
		LocationName = "Deepsea Crusher",
		LocationImage = "rbxassetid://17583091055"
	},
	LegacyIslandArea = {
		LocationName = "Sea King",
		LocationImage = "rbxassetid://7788782004"
	},
	HydraIslandArea = {
		LocationName = "Hydra",
		LocationImage = "rbxassetid://11518150703"
	},
	["Ghost Ship"] = {
		LocationName = "Ghost Ship",
		LocationImage = "rbxassetid://8620146789"
	},
	["Angel Island"] = {
		LocationName = "Angel Island",
		LocationImage = "rbxassetid://132683936061250"
	},
	["Animal Island"] = {
		LocationName = "Animal Island",
		LocationImage = "rbxassetid://84995508065012"
	},
	["Demon Island"] = {
		LocationName = "Demon Island",
		LocationImage = "rbxassetid://70986398339264"
	},
	["Fish Island"] = {
		LocationName = "Fish Island",
		LocationImage = "rbxassetid://76847002837730"
	},
	["Human Island"] = {
		LocationName = "Human Island",
		LocationImage = "rbxassetid://131562380057662"
	},
	["SeaKing Island"] = {
		LocationName = "Sea Beast Island",
		LocationImage = "rbxassetid://117582670764674"
	},
	["Gale Island"] = {
		LocationName = "Gale Island",
		LocationImage = "rbxassetid://130892917343902"
	},
	["Shark Galleon Boss"] = {
		LocationName = "Shark Galleon",
		LocationImage = "rbxassetid://97236799756912"
	},
	["Whale Galleon Boss"] = {
		LocationName = "Whale Galleon",
		LocationImage = "rbxassetid://118219452269050"
	},
	["Kraken Galleon Boss"] = {
		LocationName = "Kraken Galleon",
		LocationImage = "rbxassetid://83482344472092"
	},
	["Royal Galleon Boss"] = {
		LocationName = "Royal Galleon",
		LocationImage = "rbxassetid://110180479021761"
	},
	["Ghost Galleon Boss"] = {
		LocationName = "Ghost Galleon",
		LocationImage = "rbxassetid://128263505627024"
	},
	["Galleon Boss"] = {
		LocationName = "Galleon",
		LocationImage = "rbxassetid://113328809359129"
	}
}

function LoadDirections()
	for i = 1, #v24 do
		local text = v24[i]
		local clone3 = file.DirectionLabel:Clone()
		clone3.Name = i
		clone3.Text = text
		clone3.Parent = mainFrame
		table.insert(clones, clone3)
	end
end

function CreateCompassLines()
	for i = 1, #v24 * 2 do
		local clone3 = file.LineFrame:Clone()

		if i % 2 == 1 then
			clone3.Size = UDim2.new(0, 3, 0.1, 0)
		end

		clone3.Parent = mainFrame
		table.insert(clones2, clone3)
	end
end

function UpdateCompass()
	local v27 = mainFrame.AbsoluteSize.X / 90
	local v28 = math.deg((math.atan2(-currentCamera.CFrame.LookVector.X, -currentCamera.CFrame.LookVector.Z)))
	local v29 = not (v28 > 0) and 0 or v27 * 360
	local v30 = math.floor(v28 / 90 * mainFrame.AbsoluteSize.X / (mainFrame.AbsoluteSize.X * 0.01)) * (mainFrame.AbsoluteSize.X * 0.01)

	for k, v31 in pairs(clones) do
		v31.Position = UDim2.new(0, 45 * (k - 1) * v27 - v29 + v30, 0.5, 0)
	end

	for i = 1, #clones2 do
		clones2[i].Position = UDim2.new(0, (i - 1) * 22.5 * v27 - v29 + v30, 0, 0)
	end

	local flag15 = nil

	for instance, v31 in pairs(v25) do
		local position = nil

		if instance:IsA("BasePart") then
			position = instance.Position
		elseif instance:IsA("Model") then
			position = instance:GetBoundingBox().Position
		end

		if position then
			if not v31.Visible then
				v31.Visible = true
			end

			local pointToObjectSpace = currentCamera.CFrame:PointToObjectSpace(position)
			local v32 = math.floor(math.deg((math.atan2(pointToObjectSpace.X, -pointToObjectSpace.Z))) / 90 * mainFrame.AbsoluteSize.X / (mainFrame.AbsoluteSize.X * 0.01)) * (mainFrame.AbsoluteSize.X * 0.01)
			v31.Position = UDim2.new(0.5, v32, 0.5, 0)

			if not flag15 and math.abs(v32) < mainFrame.AbsoluteSize.X * 0.03 then
				compassFrame.StudLabel.Text = math.floor((currentCamera.CFrame.Position - position).Magnitude / 7) .. " m"
				flag15 = true
			end
		else
			v31.Visible = nil
		end
	end

	if flag15 then
		compassFrame.StudLabel.Visible = true
	else
		compassFrame.StudLabel.Visible = nil
	end
end

function AddLocationLabel(p)
	wait()

	if not v26[p.Name] or v25[p] then
		return
	end

	local v27 = v26[p.Name]
	local clone3 = file.MarkLocationLabel:Clone()
	clone3.Name = v27.LocationName
	clone3.Image = v27.LocationImage
	v25[p] = clone3
	clone3.Parent = mainFrame
end

function RemoveLocationLabel(p)
	wait()

	if not (v26[p.Name] and v25[p]) then
		return
	end

	v25[p]:Destroy()
	v25[p] = nil
end

function CheckExistLocation()
	for _, child in pairs(workspace.Island:GetChildren()) do
		if v26[child.Name] then
			AddLocationLabel(child)
		end
	end

	for _, child in pairs(workspace.Areas:GetChildren()) do
		if v26[child.Name] then
			AddLocationLabel(child)
		end
	end

	for _, child in pairs(workspace.Monster.Boss:GetChildren()) do
		if v26[child.Name] then
			AddLocationLabel(child)
		end
	end

	if ghostMonster then
		for _, child in pairs(ghostMonster:GetChildren()) do
			if v26[child.Name] then
				AddLocationLabel(child)
			end
		end
	end

	if seaMonster then
		for _, child in pairs(seaMonster:GetChildren()) do
			if v26[child.Name] then
				AddLocationLabel(child)
			end
		end
	end
end

CreateCompassLines()
LoadDirections()
CheckExistLocation()
local visible2 = 1

function SetEnabledCompass(flag15: boolean)
	if visible2 == flag15 then
		return
	end

	visible2 = flag15
	compassFrame.Visible = visible2

	if flag15 then
		task.spawn(function()
			while visible2 do
				UpdateCompass()
				RunService2.Heartbeat:Wait()
			end
		end)
	end
end

ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI.Event:Connect(function(childName, data)
	if localPlayer2.Character and localPlayer2.Character:FindFirstChild("Humanoid") and localPlayer2.Character.Humanoid.Health <= 0 and not data.Force or not childName then
		return
	end

	if childName == "BaseFrame" and _G.UIVisible then
		if data and data.VisibleType then
			baseFrame.Visible = data.VisibleType
		else
			baseFrame.Visible = not baseFrame.Visible
		end
	end

	local child = starterFrame:FindFirstChild(childName)

	if child then
		if childName == "CompassFrame" then
			SetEnabledCompass(data.VisibleType)
			return
		end

		if data and data.VisibleType ~= nil then
			child.Visible = data.VisibleType
		else
			child.Visible = not child.Visible
		end

		if data and data.Sea then
			if data.Sea == "SecondSea" and child:FindFirstChild("SecondSea") then
				child.SecondSea.Visible = true
				local seaMonsterSpawnText = ReplicatedStorage:GetAttribute("SeaMonsterSpawnText")

				if seaMonsterSpawnText then
					child.SecondSea.SKTimeLabel.Text = seaMonsterSpawnText
				end

				local ghostShipSpawnText = ReplicatedStorage:GetAttribute("GhostShipSpawnText")

				if ghostShipSpawnText then
					child.SecondSea.GSTimeLabel.Text = ghostShipSpawnText
				end
			elseif data.Sea == "ThirdSea" then
				child.ThirdSea.Visible = true
				local thirdSeaMonsterSpawnText = ReplicatedStorage:GetAttribute("ThirdSeaMonsterSpawnText")

				if thirdSeaMonsterSpawnText then
					child.ThirdSea.TextLabel.Text = thirdSeaMonsterSpawnText
				end
			end
		end
	end
end)
ReplicatedStorage.Chest.Remotes.Bindables.FlyTime.Event:Connect(function(data)
	local type2 = data.Type or "Fly"
	local time = data.Time or 30
	local flyBar = baseFrame.Frame.ExpFrame.FlyBar

	if type2 == "Fly2" then
		flyBar = baseFrame.Frame.ExpFrame.FlyBar2
	end

	local mode = data.Mode or nil
	local color = data.Color or Color3.fromRGB(0, 170, 255)

	if mode == "Start" then
		if type2 == "Teleport" then
			return
		end

		if type2 == "Conqueror" then
			character:SetAttribute("Conqueror", true)
			task.delay(_G.ConquerorCDClient, function()
				character:SetAttribute("Conqueror", nil)
			end)
		else
			flyBar.BackgroundColor3 = color
			flyBar.Size = UDim2.new(1, 0, 1, 0)
			flyBar.Visible = true
			v22 = TweenService:Create(flyBar, TweenInfo.new(time, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, 0, 1, 0)
			})

			if v22 then
				v22:Play()
			end
		end
	elseif mode == "Stop" then
		if type2 == "Teleport" then
			return
		elseif type2 == "Conqueror" then
			return
		end

		if type2 == "PVPDisabled" then
			if v23 then
				v23:Pause()
				v23 = nil
			end
		else
			flyBar.Size = UDim2.new(0.74, 0, 0.164, 0)
			flyBar.Visible = false

			if v22 then
				v22:Pause()
				v22 = nil
			end
		end
	end
end)
starterFrame.PassiveInfoFrame.Close.MouseButton1Click:Connect(function()
	starterFrame.PassiveInfoFrame.Visible = false
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
end)
starterFrame.PassiveInfoFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = starterFrame.PassiveInfoFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	starterFrame.PassiveInfoFrame.Close.Size = UDim2.new(0.091, 0, 0.249, 0)
	TweenService:Create(starterFrame.PassiveInfoFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.1365, 0, 0.3735, 0)
	}):Play()
end)
starterFrame.PassiveInfoFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(starterFrame.PassiveInfoFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.091, 0, 0.249, 0)
	}):Play()
end)
mapFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked()
end)
mapFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = mapFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	mapFrame.Close.Size = UDim2.new(0.12, 0, 0.12, 0)
	TweenService:Create(mapFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.18, 0, 0.18, 0)
	}):Play()
end)
mapFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(mapFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.12, 0, 0.12, 0)
	}):Play()
end)
battlepass_Frame.BTPFrame.ButtonFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
battlepass_Frame.EasterEggFrame.ButtonFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
allyFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
allyFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = allyFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	allyFrame.Close.Size = UDim2.new(0.108, 0, 0.154, 0)
	TweenService:Create(allyFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.162, 0, 0.23099999999999998, 0)
	}):Play()
end)
allyFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(allyFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.108, 0, 0.154, 0)
	}):Play()
end)
crewFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
crewFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = crewFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	crewFrame.Close.Size = UDim2.new(0.081, 0, 0.124, 0)
	TweenService:Create(crewFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.1215, 0, 0.186, 0)
	}):Play()
end)
crewFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(crewFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.081, 0, 0.124, 0)
	}):Play()
end)
tradeFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
tradeFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = tradeFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	tradeFrame.Close.Size = UDim2.new(0.108, 0, 0.154, 0)
	TweenService:Create(tradeFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.162, 0, 0.23099999999999998, 0)
	}):Play()
end)
tradeFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(tradeFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.108, 0, 0.154, 0)
	}):Play()
end)
serverBrowserFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)
	_G.ButtonClicked({
		Frame = nil,
		Button = nil
	})
end)
serverBrowserFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = serverBrowserFrame.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	serverBrowserFrame.Close.Size = UDim2.new(0.075, 0, 0.149, 0)
	TweenService:Create(serverBrowserFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.11249999999999999, 0, 0.22349999999999998, 0)
	}):Play()
end)
serverBrowserFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(serverBrowserFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.075, 0, 0.149, 0)
	}):Play()
end)

if _G.IsMobile then
	if not _G.ExtendMobileGUI then
		local lastTime = os.clock()

		repeat
			task.wait(0.05)
		until _G.ExtendMobileGUI or os.clock() - lastTime > 15
	end

	if not _G.ExtendMobileGUI then
		warn("extend mobile gui not complete")
		_G.ExtendMobileGUI = 1
	end

	local function ScaleFrame(p)
		p.Size = UDim2.new(p.Size.X.Scale * _G.ExtendMobileGUI, 0, p.Size.Y.Scale * _G.ExtendMobileGUI, 0)
	end

	local mainFrame2 = starterFrame:WaitForChild("TradingFrame"):WaitForChild("MainFrame")
	local frame = starterFrame:WaitForChild("Gacha_Frame"):WaitForChild("Frame")
	ScaleFrame(baseFrame.Frame)
	ScaleFrame(battlepass_Frame)
	ScaleFrame(allyFrame)
	ScaleFrame(crewFrame)
	ScaleFrame(inventory_Frame)
	ScaleFrame(setting_Frame)
	ScaleFrame(shopFrame)
	ScaleFrame(statsFrame)
	ScaleFrame(tradeFrame)
	ScaleFrame(frame)
	ScaleFrame(fightingStyleFrame)
	ScaleFrame(dropBoostFrame)
	ScaleFrame(homeFrame)
	ScaleFrame(fruitFrame)
	ScaleFrame(mainFrame2)
	ScaleFrame(mapFrame)
	ScaleFrame(serverBrowserFrame)
end

task.spawn(function()
	while true do
		if shopButton.Visible then
			local v28 = task.wait() * 60
			local imageLabel2 = shopButton:FindFirstChild("ImageLabel")

			if not imageLabel2 then
				continue
			end

			imageLabel2.UIGradient.Rotation = (imageLabel2.UIGradient.Rotation + v28 * 2) % 360

			if imageLabel2.UIGradient.Enabled then
				continue
			end
		end

		task.wait()
		shopButton:GetPropertyChangedSignal("Visible"):Wait()
	end
end)
workspace.Areas.ChildAdded:Connect(AddLocationLabel)
workspace.Island.ChildAdded:Connect(AddLocationLabel)
workspace.Island.ChildRemoved:Connect(RemoveLocationLabel)
workspace.Areas.ChildRemoved:Connect(RemoveLocationLabel)
local ghostMonster2 = workspace:FindFirstChild("GhostMonster")

if ghostMonster2 then
	ghostMonster2.ChildAdded:Connect(AddLocationLabel)
	ghostMonster2.ChildRemoved:Connect(RemoveLocationLabel)
end

if seaMonster then
	seaMonster.ChildAdded:Connect(AddLocationLabel)
	seaMonster.ChildRemoved:Connect(RemoveLocationLabel)
end

task.spawn(function()
	local v28 = SwordList
	local v29 = fightingStyleFrame
	local infoFrame = v29.InfoFrame
	local textFrame = infoFrame.TextFrame
	local icon = infoFrame.BG.Icon
	local _ = infoFrame.BG.CanvasGroup.BG
	local back = textFrame.Back
	local action = textFrame.Action
	local info = textFrame.Info
	local fightingStyleName = textFrame.FightingStyleName
	local strength = textFrame.Strength
	local agility = textFrame.Agility
	local combo = textFrame.Combo
	local scrollingFrame = v29:WaitForChild("ScrollingFrame")
	local name = nil

	local function UpdateScrolling()
		local uIGridLayout = scrollingFrame.UIGridLayout
		local scrollBarThickness = scrollingFrame.ScrollBarThickness
		local v30 = (scrollingFrame.AbsoluteSize.X - scrollBarThickness - 0) / 4
		uIGridLayout.CellSize = UDim2.new(0, v30, 0, v30)
		uIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	UpdateScrolling()
	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateScrolling()
	end)

	local function ClearGuideFrame()
		for _, frame in pairs(guidelineFrame.ScrollingFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end
	end

	local function CreateGuideFrame(list)
		if list then
			ClearGuideFrame()

			for _, v30 in ipairs(list) do
				if v30.Image and v30.Text then
					local clone3 = file.GuideFrame:Clone()
					clone3.Icon.Image = v30.Image
					clone3.TextLabel.Text = v30.Text
					clone3.Parent = guidelineFrame.ScrollingFrame
				end

				if v30.GuideName then
					guidelineFrame.TextLabel.Text = v30.GuideName
				end
			end

			guidelineFrame.Visible = true
		end
	end

	local function CheckUnlockedV2(p)
		if not (localPlayer2:FindFirstChild("PlayerStats") and localPlayer2.PlayerStats:FindFirstChild("FightingStyle")) then
			return false
		end

		if p == "DarkLeg" and _G.CheckAwakeClient(localPlayer2, "DarkLeg") or p == "DragonClaw" and _G.CheckAwakeClient(
			localPlayer2,
			"DragonClaw"
		) then
			return true
		end

		if p == "Cyborg" and _G.CheckQuestProgressClient(localPlayer2, "CyborgV2") and _G.CheckQuestProgressClient(
			localPlayer2,
			"CyborgV2"
		) >= 4 then
			return true
		end

		if p == "WaterStyle" and _G.CheckQuestProgressClient(localPlayer2, "WaterStyleV2") and _G.CheckQuestProgressClient(
			localPlayer2,
			"WaterStyleV2"
		) >= 4 then
			return true
		end

		if p == "Electro" and _G.CheckQuestProgressClient(localPlayer2, "ElectroV2") and _G.CheckQuestProgressClient(
			localPlayer2,
			"ElectroV2"
		) >= 13 then
			return true
		end

		return false
	end

	local function CheckUnlocked(p)
		if not (localPlayer2:FindFirstChild("PlayerStats") and localPlayer2.PlayerStats:FindFirstChild("FightingStyle")) then
			return false
		end

		if _G.CheckBoughtClient(localPlayer2, p) or p == "None" or p == "Trickster" and _G.CheckAwakeClient(
			localPlayer2,
			"Trickster"
		) then
			return true
		end

		if p == "Gale Fist" and _G.CheckQuestProgressClient(localPlayer2, "Gale Fist Quest") and _G.CheckQuestProgressClient(
			localPlayer2,
			"Gale Fist Quest"
		) >= 81 then
			return true
		end

		if p == "Justice Fist" and _G.CheckAwakeClient(localPlayer2, "Justice Fist") then
			return true
		end

		return false
	end

	local function UpdateButtonLock(p, parent2)
		if localPlayer2:FindFirstChild("PlayerStats") then
			localPlayer2.PlayerStats:FindFirstChild("FightingStyle")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Unlocked()
			if parent2:FindFirstChild("FSLocked") then
				parent2.FSLocked:Destroy()
			end

			parent2.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Locked()
			if not parent2:FindFirstChild("FSLocked") then
				local clone = file.FSButton.FSLocked:Clone()
				clone.Parent = parent2
			end

			parent2.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end

		if CheckUnlocked(p) then
			Unlocked() -- equivalent call inferred; original call site unknown
		else
			Locked() -- equivalent call inferred; original call site unknown
		end
	end

	local function InstanceButton()
		for childName, _ in pairs(v28) do
			if scrollingFrame:FindFirstChild(childName) or not v28[childName].FightingStyle then
				continue
			end

			local tier = v28[childName].Tier
			local clone3 = file.FSButton:Clone()
			clone3.Name = childName
			clone3.FightingStyleName.Text = CustomNames[childName] or childName
			clone3.ImageLabel.Image = v28[childName].Image
			clone3.ImageLabel.ImageColor3 = Color3.fromRGB()
			clone3.ImageLabel.BackgroundColor3 = TierColor[tier]
			clone3.TierImage.Image = TierImage[tier]
			clone3.LayoutOrder = _G.Layouts[tier]
			UpdateButtonLock(childName, clone3)
			clone3.Parent = scrollingFrame
		end
	end

	InstanceButton()
	_G.CallShipCache()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateV2Button(p)
		if not CheckUnlockedV2(p) then
			infoFrame.BG.V2.ImageLabel.Image = "rbxassetid://76037993177299"
		elseif _G.CheckAwakeClient(localPlayer2, p .. "Z") then
			infoFrame.BG.V2.ImageLabel.Image = "rbxassetid://97406740710376"
		else
			infoFrame.BG.V2.ImageLabel.Image = "rbxassetid://129969136776489"
		end
	end

	local function UpdateInfoFrame(name2)
		if not (name2 and v28[name2]) then
			return
		end

		name = name2
		fightingStyleName.Text = CustomNames[name2] or name2

		if v28[name2].Guideline2 then
			UpdateV2Button(name2) -- equivalent call inferred; original call site unknown
			infoFrame.BG.V2.Visible = true
		else
			infoFrame.BG.V2.Visible = nil
		end

		if v28[name2].Image then
			icon.Size = UDim2.fromScale(0, 0)
			icon.Image = v28[name2].Image
			icon.ImageColor3 = Color3.fromRGB()
			TweenService:Create(icon, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = UDim2.fromScale(1, 1)
			}):Play()
			TweenService:Create(
				icon,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.1),
				{
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
		end

		if v28[name2].Info then
			info.Text = v28[name2].Info

			if localPlayer2:FindFirstChild("PlayerStats") and localPlayer2.PlayerStats:FindFirstChild("Language") and localPlayer2.PlayerStats.Language.Value == "TH" then
				info.Text = v28[name2].InfoTH
			end
		end

		if v28[name2].Strength then
			local v30 = v28[name2].Strength / 10
			strength.Border.Bar.Line.Size = UDim2.new(0, 0, 1, 0)
			TweenService:Create(strength.Border.Bar.Line, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = UDim2.new(1 * v30, 0, 1, 0)
			}):Play()
		end

		if v28[name2].Agility then
			local v30 = v28[name2].Agility / 10
			agility.Border.Bar.Line.Size = UDim2.new(0, 0, 1, 0)
			TweenService:Create(agility.Border.Bar.Line, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = UDim2.new(1 * v30, 0, 1, 0)
			}):Play()
		end

		if v28[name2].Combo then
			local v30 = v28[name2].Combo / 10
			combo.Border.Bar.Line.Size = UDim2.new(0, 0, 1, 0)
			TweenService:Create(combo.Border.Bar.Line, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = UDim2.new(1 * v30, 0, 1, 0)
			}):Play()
		end

		if CheckUnlocked(name2) then
			action.ImageLabel.Image = "rbxassetid://102392127107534"
		else
			action.ImageLabel.Image = "rbxassetid://72220288401706"
		end

		infoFrame.Visible = true
	end

	local children = scrollingFrame:GetChildren()

	for i = 1, #children do
		local button = children[i]

		if not button:IsA("TextButton") then
			continue
		end

		local parent2 = button
		button.MouseButton1Click:Connect(function()
			if infoFrame.Visible then
				return
			end

			_G.ClickFrameEffect({
				Sound = true,
				Parent = v29.Parent
			})
			UpdateInfoFrame(parent2.Name)
			name = parent2.Name
		end)
		local parent3 = button
		button.MouseEnter:Connect(function()
			_G.ShineGui({
				Parent = parent3,
				ZIndex = 5
			})
			local canvasGroup = parent3:FindFirstChild("CanvasGroup")

			if canvasGroup then
				canvasGroup:Destroy()
			end

			local clone3 = file.CanvasGroup:Clone()
			clone3.Background.ImageTransparency = 1
			clone3.LoopSpike.Enabled = true
			clone3.Parent = parent3
			TweenService:Create(clone3.Background, TweenInfo.new(0.5), {
				ImageTransparency = 0.5
			}):Play()
		end)
		local parent4 = button
		button.MouseLeave:Connect(function()
			local canvasGroup = parent4:FindFirstChild("CanvasGroup")

			if canvasGroup then
				if canvasGroup:FindFirstChild("Background") then
					TweenService:Create(canvasGroup.Background, TweenInfo.new(0.5), {
						ImageTransparency = 1
					}):Play()
				end

				_G.PU:Dust(canvasGroup, 0.5)
			end
		end)
	end

	local flag15 = nil
	local closeButton = v29.CloseButton
	local flag16 = nil
	infoFrame.BG.V2.MouseButton1Click:Connect(function()
		if flag15 then
			return
		end

		flag15 = true
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})

		if CheckUnlockedV2(name) then
			task.spawn(function()
				ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipFightingStyleV2", {
					FightingStyleName = name
				})
				UpdateV2Button(name) -- equivalent call inferred; original call site unknown
			end)
		else
			CreateGuideFrame(SwordList[name].Guideline2)
		end

		task.delay(1, function()
			flag15 = nil
		end)
	end)
	infoFrame.BG.V2.MouseEnter:Connect(function()
		if flag16 then
			return
		end

		_G.ShineGui({
			Parent = infoFrame.BG.V2,
			ZIndex = 7,
			Circle = true
		})
	end)
	back.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})
		infoFrame.Visible = nil
	end)
	back.MouseEnter:Connect(function()
		if flag16 then
			return
		end

		_G.ShineGui({
			Parent = back,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
	closeButton.MouseButton1Click:Connect(function()
		if flag16 then
			return
		end

		flag16 = true
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true,
			Parent = v29.Parent
		})
		_G.NPCTalk = false
		infoFrame.Visible = nil
		_G.ButtonClicked({
			Frame = nil,
			Button = nil
		})
		task.delay(0.5, function()
			flag16 = nil
		end)
	end)
	closeButton.MouseEnter:Connect(function()
		closeButton.Size = UDim2.new(0.104, 0, 0.15, 0)
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.11959999999999998, 0, 0.1725, 0)
		}):Play()
		_G.ShineGui({
			Parent = closeButton,
			ZIndex = 5,
			Size = UDim2.fromScale(0.8, 0.8),
			Circle = true
		})
	end)
	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.104, 0, 0.15, 0)
		}):Play()
	end)
	action.MouseButton1Click:Connect(function()
		if flag16 then
			return
		end

		flag16 = true

		if CheckUnlocked(name) then
			ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipFightingStyle", {
				FightingStyleName = name
			})
		elseif SwordList[name].Guideline then
			CreateGuideFrame(SwordList[name].Guideline)
		end

		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})
		task.delay(0.5, function()
			flag16 = nil
		end)
	end)
	action.MouseEnter:Connect(function()
		if flag16 then
			return
		end

		_G.ShineGui({
			Parent = action,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
	fightingStyleFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		for _, button in pairs(scrollingFrame:GetChildren()) do
			if button:IsA("TextButton") then
				UpdateButtonLock(button.Name, button)
			end
		end
	end)

	while true do
		if infoFrame.Visible then
			local v30 = task.wait() * 60
			infoFrame.BG.CanvasGroup.BG.UIGradient.Rotation = (infoFrame.BG.CanvasGroup.BG.UIGradient.Rotation + v30) % 360
		else
			task.wait()
			infoFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
task.spawn(function()
	local v28 = nil

	for k, v30 in pairs(WorldsId.Testing) do
		if game.PlaceId ~= v30 then
			continue
		end

		v28 = k
		break
	end

	for k, v31 in pairs(WorldsId.KingLegacy) do
		if game.PlaceId ~= v31 then
			continue
		end

		v28 = k
		break
	end

	local modules = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
	local GateWorldList = require(modules.GateWorldList)
	local IslandInfo2 = require(modules.IslandInfo)
	local firstSea = homeFrame:WaitForChild("FirstSea")

	if game.PlaceId == WorldsId.KingLegacy.SecondSea or game.PlaceId == WorldsId.Testing.SecondSea then
		firstSea = homeFrame:WaitForChild("SecondSea")
	elseif game.PlaceId == WorldsId.KingLegacy.ThirdSea or game.PlaceId == WorldsId.Testing.ThirdSea then
		firstSea = homeFrame:WaitForChild("ThirdSea")
	end

	firstSea.Visible = true
	local uIGridLayout = firstSea:WaitForChild("UIGridLayout")

	local function UpdateGrid()
		uIGridLayout.CellPadding = UDim2.new(0, 3, 0, 3)
		uIGridLayout.CellSize = UDim2.new(
			0,
			(firstSea.AbsoluteSize.X - firstSea.ScrollBarThickness - 0) / 1,
			0,
			(firstSea.AbsoluteSize.Y - 6) / 3
		)
		firstSea.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)

		for _, button in pairs(firstSea:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local islandName = button:FindFirstChild("IslandName")

			if islandName then
				islandName.Text = IslandInfo2[button.Name] and IslandInfo2[button.Name].Name or button.Name
			end

			local islandInfo = button:FindFirstChild("IslandInfo")

			if islandInfo then
				islandInfo.Text = not IslandInfo2[button.Name] and "" or IslandInfo2[button.Name].InfoText or ""

				if GateWorldList[firstSea.Name] and GateWorldList[firstSea.Name][button.Name] and GateWorldList[firstSea.Name][button.Name].InfoText then
					islandInfo.Text = GateWorldList[firstSea.Name][button.Name].InfoText
				end

				local text = islandInfo.Text
				local v31 = string.match(text, "%d+")

				if v31 then
					button.LayoutOrder = tonumber(v31)
				else
					button.LayoutOrder = 100000
				end
			end

			local imageLabel2 = button:FindFirstChild("ImageLabel")

			if imageLabel2 then
				imageLabel2.Image = not (GateWorldList[firstSea.Name] and GateWorldList[firstSea.Name][button.Name]) and "" or GateWorldList[firstSea.Name][button.Name].Image or ""
			end

			if button.Name ~= "Home" then
				continue
			end

			button.LayoutOrder = 0
			islandName.Text = "Home"
			islandInfo.Text = "Respawn Spot"
			imageLabel2.Image = "rbxassetid://131785501766527"
		end
	end

	local flag15 = nil

	for _, button in pairs(firstSea:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v31 = button
		button.MouseButton1Click:Connect(function()
			if flag15 or _G.CheckInCombat() then
				return
			end

			flag15 = true
			_G.ButtonClicked({
				Frame = nil,
				Button = nil
			})
			local position = humanoidRootPart.Position
			ReplicatedStorage.Chest.Remotes.Events.EtcEvent:FireServer({
				Type = "Recall FX"
			})
			local flag16 = true

			for i = 9, 0, -1 do
				local character2 = localPlayer2.Character

				if character2 and character2:FindFirstChild("Humanoid") and character2.Humanoid.Sit or (position - humanoidRootPart.Position).Magnitude > 1 then
					flag16 = nil
					break
				end

				if _G.CheckInCombat() then
					break
				else
					task.wait(1)
				end
			end

			local cframe = CFrame.new(GetHome().Position + createVector(0, 2, 0))

			if v28 and GateWorldList[v28] and GateWorldList[v28][v31.Name] and GateWorldList[v28][v31.Name].Position then
				cframe = CFrame.new(GateWorldList[v28][v31.Name].Position + createVector(0, 2, 0))
			end

			if flag16 then
				humanoidRootPart.CFrame = cframe
			end

			if flag16 then
				task.spawn(function()
					home_Button.Alert.Visible = true
					home_Button2.Alert.Visible = true

					for i = 30, 1, -1 do
						home_Button.Alert.Text = i
						home_Button2.Alert.Text = i
						wait(1)
					end

					home_Button.Alert.Visible = false
					home_Button2.Alert.Visible = false
					flag15 = nil
				end)
			else
				task.spawn(function()
					home_Button.Alert.Visible = true
					home_Button2.Alert.Visible = true

					for i = 5, 1, -1 do
						home_Button.Alert.Text = i
						home_Button2.Alert.Text = i
						wait(1)
					end

					home_Button.Alert.Visible = false
					home_Button2.Alert.Visible = false
					flag15 = nil
				end)
			end
		end)
	end

	UpdateGrid()
	firstSea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateGrid()
	end)
	local closeButton = homeFrame.CloseButton
	closeButton.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true
		})
		_G.ButtonClicked({
			Frame = nil,
			Button = nil
		})
	end)
	closeButton.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = closeButton,
			ZIndex = 5,
			Size = UDim2.fromScale(0.8, 0.8),
			Circle = true
		})
		closeButton.Size = UDim2.new(0.081, 0, 0.124, 0)
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.09315, 0, 0.14259999999999998, 0)
		}):Play()
	end)
	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.081, 0, 0.124, 0)
		}):Play()
	end)
	local BG = homeFrame.CanvasGroup.BG
	local v31 = 0

	while true do
		if homeFrame.Visible then
			v31 = (v31 + wait() / 25) % 1
			BG.Position = UDim2.new(-v31, 0, 0.5, 0)
		else
			task.wait()
			homeFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
fightingStyle.MouseButton1Click:Connect(function()
	if not v9 then
		return
	end

	v9 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)
	fightingStyleFrame.Visible = true

	if flag11 then
		if flag11 then
			flag11 = nil
			_G.ButtonClicked({
				Frame = fightingStyleFrame,
				Button = fightingStyle
			})
		end
	else
		flag11 = true
		ButtonClosed({
			Frame = fightingStyleFrame,
			Button = fightingStyle
		})
	end
end)
dropBoost.MouseButton1Click:Connect(function()
	if not v9 then
		return
	end

	v9 = false
	spawn(function()
		wait(0.1)
		v9 = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	task.spawn(function()
		if v5.isSelected then
			v5:deselect()
		end
	end)
	dropBoostFrame.Visible = true

	if flag12 then
		if flag12 then
			flag12 = nil
			_G.ButtonClicked({
				Frame = dropBoostFrame,
				Button = dropBoost
			})
		end
	else
		flag12 = true
		ButtonClosed({
			Frame = dropBoostFrame,
			Button = dropBoost
		})
	end
end)
local v28 = {}

function ConnectButton(data, p, data2)
	if not v28[p] then
		v28[p] = {}
	end

	for _, connection in pairs(v28[p]) do
		if connection then
			connection:Disconnect()
		end
	end

	if data2.Click then
		v28[p].Click = data.MouseButton1Click:Connect(data2.Click)
	end

	if data2.Enter then
		v28[p].Enter = data.MouseEnter:Connect(data2.Enter)
	end

	if data2.Leave then
		v28[p].Leave = data.MouseLeave:Connect(data2.Leave)
	end
end

function ButtonEnter(instance)
	instance.ZIndex = 1
	local textLabel = instance:FindFirstChild("TextLabel")

	if textLabel then
		textLabel.Visible = true
	end

	local imageLabel2 = instance:FindFirstChild("ImageLabel")

	if imageLabel2 then
		imageLabel2.ImageColor3 = Color3.fromRGB(0, 0, 0)
	end

	local imageLabelShadow = instance:FindFirstChild("ImageLabelShadow")

	if imageLabelShadow then
		imageLabelShadow.Visible = false
	end
end

function ButtonLeave(instance)
	instance.ZIndex = 0
	local textLabel = instance:FindFirstChild("TextLabel")

	if textLabel then
		textLabel.Visible = false
	end

	local imageLabel2 = instance:FindFirstChild("ImageLabel")

	if imageLabel2 then
		imageLabel2.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end

	local imageLabelShadow = instance:FindFirstChild("ImageLabelShadow")

	if imageLabelShadow then
		imageLabelShadow.Visible = true
	end
end

function UpdateSettingButton()
	if _G.CheckSettingClient(localPlayer2, "Setting_RetroUI") then
		parent.BaseFrame.Visible = false
		parent.BaseFrameOG.Visible = true
		baseFrame = parent.BaseFrameOG
	else
		parent.BaseFrame.Visible = true
		parent.BaseFrameOG.Visible = false
		baseFrame = parent.BaseFrame
	end

	buttonFrame = baseFrame.ButtonFrame
	menuButton = baseFrame.Frame.MenuButton
	home_Button = baseFrame.Frame.Home_Button
	trackQuestButton = baseFrame.Frame.TrackQuestButton
	statsButton = buttonFrame.StatsButton
	shopButton = buttonFrame.ShopButton
	setting_Button = buttonFrame.Setting_Button
	trade_Button = buttonFrame.Trade_Button
	inventoryButton = buttonFrame.InventoryButton
	crewButton = buttonFrame.CrewButton
	allyButton = buttonFrame.AllyButton
	mapButton = buttonFrame.MapButton
	battlepass_Button = buttonFrame.Battlepass_Button
	ConnectButton(menuButton, "MenuButton", {
		Click = function()
			MenuClicked()
		end,
		Enter = function()
			local size = menuButton:GetAttribute("Size") or menuButton.Size
			_G.ShineGui({
				Parent = menuButton,
				ZIndex = 5
			})
			menuButton.TextLabel.Visible = true

			if size then
				menuButton.Size = size
				TweenService:Create(menuButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
					Size = UDim2.new(size.X.Scale * 1.35, 0, size.Y.Scale * 1.35, 0)
				}):Play()
			end
		end,
		Leave = function()
			local size = menuButton:GetAttribute("Size") or menuButton.Size
			menuButton.TextLabel.Visible = false

			if size then
				TweenService:Create(menuButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
					Size = size
				}):Play()
			end
		end
	})
	ConnectButton(statsButton, "StatsButton", {
		Click = function()
			_G.StatsButtonClick()
		end,
		Enter = function()
			ButtonEnter(statsButton)
		end,
		Leave = function()
			ButtonLeave(statsButton)
		end
	})
	ConnectButton(shopButton, "ShopButton", {
		Click = function()
			_G.ShopButtonClick()
		end,
		Enter = function()
			ButtonEnter(shopButton)
		end,
		Leave = function()
			ButtonLeave(shopButton)
		end
	})
	ConnectButton(setting_Button, "Setting_Button", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			setting_Frame.Visible = true

			if flag4 then
				if flag4 then
					flag4 = nil
					_G.ButtonClicked({
						Frame = setting_Frame,
						Button = setting_Button
					})
				end
			else
				flag4 = true
				ButtonClosed({
					Frame = setting_Frame,
					Button = setting_Button
				})
			end
		end,
		Enter = function()
			ButtonEnter(setting_Button)
		end,
		Leave = function()
			ButtonLeave(setting_Button)
		end
	})
	ConnectButton(trade_Button, "Trade_Button", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			tradeFrame.Visible = true

			if flag5 then
				if flag5 then
					flag5 = nil
					_G.ButtonClicked({
						Frame = tradeFrame,
						Button = trade_Button
					})
				end
			else
				flag5 = true
				ButtonClosed({
					Frame = tradeFrame,
					Button = trade_Button
				})
			end
		end,
		Enter = function()
			ButtonEnter(trade_Button)
		end,
		Leave = function()
			ButtonLeave(trade_Button)
		end
	})
	ConnectButton(inventoryButton, "InventoryButton", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			inventory_Frame.Visible = true

			if flag6 then
				if flag6 then
					flag6 = nil
					_G.ButtonClicked({
						Frame = inventory_Frame,
						Button = inventoryButton
					})
				end
			else
				flag6 = true
				ButtonClosed({
					Frame = inventory_Frame,
					Button = inventoryButton
				})
				inventoryButton.Alert.Visible = false
				baseFrameOG.ButtonFrame.InventoryButton.Alert.Visible = false
			end
		end,
		Enter = function()
			ButtonEnter(inventoryButton)
		end,
		Leave = function()
			ButtonLeave(inventoryButton)
		end
	})
	ConnectButton(crewButton, "CrewButton", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			crewFrame.Visible = true

			if flag7 then
				if flag7 then
					flag7 = nil
					_G.ButtonClicked({
						Frame = crewFrame,
						Button = crewButton
					})
				end
			else
				flag7 = true
				ButtonClosed({
					Frame = crewFrame,
					Button = crewButton
				})
			end
		end,
		Enter = function()
			ButtonEnter(crewButton)
		end,
		Leave = function()
			ButtonLeave(crewButton)
		end
	})
	ConnectButton(allyButton, "AllyButton", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			allyFrame.Visible = true

			if flag8 then
				if flag8 then
					flag8 = nil
					_G.ButtonClicked({
						Frame = allyFrame,
						Button = allyButton
					})
				end
			else
				flag8 = true
				ButtonClosed({
					Frame = allyFrame,
					Button = allyButton
				})
			end
		end,
		Enter = function()
			ButtonEnter(allyButton)
		end,
		Leave = function()
			ButtonLeave(allyButton)
		end
	})
	ConnectButton(battlepass_Button, "Battlepass_Button", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			battlepass_Frame.Visible = true

			if flag9 then
				if flag9 then
					flag9 = nil
					_G.ButtonClicked({
						Frame = battlepass_Frame,
						Button = battlepass_Button
					})
				end
			else
				flag9 = true
				ButtonClosed({
					Frame = battlepass_Frame,
					Button = battlepass_Button
				})
			end
		end,
		Enter = function()
			ButtonEnter(battlepass_Button)
		end,
		Leave = function()
			ButtonLeave(battlepass_Button)
		end
	})
	ConnectButton(mapButton, "MapButton", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			mapFrame.Visible = true
			mapFrame.Information.Visible = false

			if clone then
				clone:Destroy()
				clone = nil
			end

			if v then
				v:Destroy()
				v = nil
			end

			if v2 then
				v2:Destroy()
				v2 = nil
			end

			if flag10 then
				if flag10 then
					flag10 = nil
					_G.ButtonClicked({
						Frame = mapFrame,
						Button = mapButton
					})
				end
			else
				flag10 = true
				ButtonClosed({
					Frame = mapFrame,
					Button = mapButton
				})
			end
		end,
		Enter = function()
			ButtonEnter(mapButton)
		end,
		Leave = function()
			ButtonLeave(mapButton)
		end
	})
	ConnectButton(home_Button, "Home_Button", {
		Click = function()
			if not v9 then
				return
			end

			v9 = false
			spawn(function()
				wait(0.1)
				v9 = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			task.spawn(function()
				if v5.isSelected then
					v5:deselect()
				end
			end)
			homeFrame.Visible = true

			if flag13 then
				if flag13 then
					flag13 = nil
					_G.ButtonClicked({
						Frame = homeFrame,
						Button = home_Button
					})
				end
			else
				flag13 = true
				ButtonClosed({
					Frame = homeFrame,
					Button = home_Button
				})
			end
		end,
		Enter = function()
			local size = home_Button:GetAttribute("Size") or home_Button.Size

			if size then
				home_Button.Size = size
				TweenService:Create(home_Button, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
					Size = UDim2.new(size.X.Scale * 2, 0, size.Y.Scale * 2, 0)
				}):Play()
			end

			_G.ShineGui({
				Parent = home_Button,
				ZIndex = 5,
				Circle = true,
				Size = UDim2.fromScale(0.9, 0.9)
			})
			home_Button.TextLabel.Visible = true
		end,
		Leave = function()
			local size = home_Button:GetAttribute("Size") or home_Button.Size

			if size then
				TweenService:Create(home_Button, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
					Size = size
				}):Play()
			end

			home_Button.TextLabel.Visible = false
		end
	})
	ConnectButton(trackQuestButton, "TrackQuestButton", {
		Click = function()
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
			v19 = not v19
			trackQuestButton.Size = UDim2.new(0.14, 0, 0.45, 0)
			TweenService:Create(
				trackQuestButton,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					Size = UDim2.new(0.21000000000000002, 0, 0.675, 0)
				}
			):Play()

			if v19 then
				trackQuestButton.TextLabel.Text = "Untrack Quest"
			else
				trackQuestButton.TextLabel.Text = "Track Quest"
			end

			UpdateTrackQuest()
		end,
		Enter = function()
			trackQuestButton.Size = UDim2.new(0.07, 0, 0.225, 0)
			TweenService:Create(trackQuestButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.14, 0, 0.45, 0)
			}):Play()
			trackQuestButton.TextLabel.Visible = true
		end,
		Leave = function()
			TweenService:Create(trackQuestButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.07, 0, 0.225, 0)
			}):Play()
			trackQuestButton.TextLabel.Visible = false
		end
	})
end

_G.UpdateSettingButton = UpdateSettingButton
UpdateSettingButton()
task.spawn(function()
	local isStudio = RunService2:IsStudio()
	local playerStats = localPlayer2:WaitForChild("PlayerStats")
	local keyStocks = playerStats:WaitForChild("KeyStocks")
	local material = playerStats:WaitForChild("Material")
	local gacha_Frame = starterFrame.Gacha_Frame
	local frame = gacha_Frame.Frame
	local viewFrame = frame.ViewFrame
	local fruitRateList = frame.FruitRateList
	local fruitRateButton = frame.FruitRateButton
	local view10Key = frame.View10Key
	local information = frame:WaitForChild("Information")
	local _ = gacha_Frame.FruitNameLabel
	local _ = gacha_Frame.TierLabel
	local button = information.Frame:WaitForChild("Button")
	local textBox = information.Frame:WaitForChild("TextBox")
	local currentCamera2 = workspace.CurrentCamera
	local gachaBackground = workspace:WaitForChild("Island"):WaitForChild("Gacha Background")
	local gachaChest = gachaBackground.GachaChest
	local flag15 = nil

	while not localPlayer2.Character do
		wait()
	end

	local function ClearOldGuaranteeFruits()
		for _, image in ipairs(frame.ViewFrame.List:GetChildren()) do
			if image:IsA("ImageLabel") then
				image:Destroy()
			end
		end
	end

	local function GetFruitRarity(p)
		for k, list in pairs(DFTier) do
			if string.find(table.concat(list, ","), p) then
				return k
			end
		end
	end

	local function CheckGuarantee(p: string, p2: number)
		ClearOldGuaranteeFruits()
		local v29 = _G.GetEtcDataClient(localPlayer2, p) or {}

		for i = 1, p2 do
			local v30 = v29[i]

			if not v30 then
				continue
			end

			local clone3 = script.File.FruitIcon:Clone()
			clone3.IndexLabel.Text = i
			clone3.Image = FruitList[v30] or ""
			local text = (CustomNames[v30] or v30):gsub("(%a)(Fruit)", "%1 %2")
			clone3.FruitNameLabel.Text = text

			if i == 1 then
				local imageColor = TierColor[GetFruitRarity(v30) or "Common"]
				clone3.Background.ImageColor3 = imageColor
				clone3.Background.Visible = true
				clone3.ArrowOnly1.ImageColor3 = imageColor
				clone3.ArrowOnly1.Visible = true
			end

			clone3.Parent = frame.ViewFrame.List
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CloseViewFrame()
		viewFrame.Visible = false
		viewFrame:SetAttribute("LastSelect", nil)
	end

	local function OpenViewFrame(p)
		viewFrame.Size = UDim2.fromScale(0, 0)
		TweenService:Create(viewFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Size = UDim2.fromScale(0.63, 0.63)
		}):Play()
		viewFrame.Visible = true
		local type2 = p.Type
		local keySelect = p.KeySelect

		if type2 and keySelect then
			viewFrame:SetAttribute("LastSelect", (`View 10 {keySelect}`))
			viewFrame.List.UIGridLayout.CellSize = UDim2.fromScale(0.19, 0.355)
			CheckGuarantee(`{keySelect}(10)`, 10)
		end
	end

	local function GetBackpackCapacity()
		local count = 0

		for _, tool in pairs(localPlayer2.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("LegacyFruit") then
				count += 1
			end
		end

		local tool = localPlayer2.Character and localPlayer2.Character:FindFirstChildOfClass("Tool")

		if tool and tool:GetAttribute("LegacyFruit") then
			count += 1
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateBackpackCapacity()
		local v29 = GetBackpackCapacity() or 0
		frame.LimitLabel.Text = "Fruit Backpack Capacity: " .. v29 .. "/" .. 100
	end

	local character2 = localPlayer2.Character or localPlayer2.CharacterAdded:Wait()

	local function SpawnCharacter()
		task.spawn(function()
			if not _G.SetupBaseFrame then
				repeat
					task.wait()
				until _G.SetupBaseFrame ~= nil
			end

			_G.SetupBaseFrame()
		end)
		local humanoidRootPart2 = character2:WaitForChild("HumanoidRootPart")
		humanoidRootPart2.Anchored = true
		local spawned = localPlayer2.PlayerStats:FindFirstChild("spawned")
		local spawnPoints = workspace:FindFirstChild("SpawnPoints")

		if spawnPoints and spawned then
			local child = spawnPoints:FindFirstChild("Spawn" .. spawned.Value) and spawnPoints["Spawn" .. spawned.Value]

			if character2:GetAttribute("SoloDamage") then
				child = spawnPoints:FindFirstChild(character2:GetAttribute("SoloDamage") .. "CustomSpawn")
			end

			if not isStudio then
				if child then
					humanoidRootPart2.CFrame = CFrame.new(child.Position) * CFrame.new(0, 2, 0)
				else
					humanoidRootPart2.CFrame = spawnPoints.Spawn1.CFrame * CFrame.new(0, 2, 0)
				end
			end
		end

		task.delay(0.4, function()
			humanoidRootPart2.Anchored = false
		end)
	end

	local success, result = pcall(function()
		SpawnCharacter()
	end)

	if not success then
		warn(result)
	end

	localPlayer2.CharacterAdded:Connect(function(character3)
		character2 = character3
		character3:WaitForChild("Humanoid")
		character3:WaitForChild("HumanoidRootPart")
		success, result = pcall(function()
			SpawnCharacter()
		end)

		if not success then
			warn(result)
		end

		UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
		localPlayer2.Backpack.ChildAdded:Connect(function()
			wait()
			UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
		end)
		localPlayer2.Backpack.ChildRemoved:Connect(function()
			wait()
			UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
		end)
		character2.ChildRemoved:Connect(function()
			wait()
			UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
		end)
		character2.ChildAdded:Connect(function()
			wait()
			UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
		end)
	end)
	ContentProvider:PreloadAsync({
		gachaChest.OpenAnimation.AnimationId,
		gachaChest.RootPart.Star.SoundId,
		gachaChest.RootPart.Smack.SoundId,
		gachaChest.RootPart.OpenSound.SoundId
	})
	local track = gachaChest.AnimationController:LoadAnimation(gachaChest.OpenAnimation)
	track:Play()
	track.Ended:Wait()
	local v29 = {
		Mythical = -1,
		Legendary = 0,
		Epic = 1,
		Rare = 2,
		Uncommon = 3,
		Common = 4
	}
	local clones3 = {}
	local v30 = {}
	local v31 = nil
	fruitRateList.ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if not v31 then
			return
		end

		v31 = nil
	end)

	for k, list in pairs(DFTier) do
		local clone3 = script.File.FruitTierFrame:Clone()
		clone3.Name = k
		clone3.LayoutOrder = v29[k] or 1
		clone3.InnerFrame.Tier.Text = k
		clone3.InnerFrame.Tier.TextColor3 = TierColor[k] or TierColor.Common
		clone3.Parent = fruitRateList.ScrollingFrame
		v30[k] = v30[k] or {}

		for i, name2 in ipairs(list) do
			local v33 = CustomNames[name2] or name2
			local clone4 = script.File.FruitRateFrame:Clone()
			clone4.Name = name2
			clone4.InnerFrame.FruitRate.TextColor3 = TierColor[GetFruitRarity(name2)] or Color3.fromRGB(255, 255, 255)
			clone4.InnerFrame.FruitName.Text = v33:gsub("Fruit", "")
			clone4.InnerFrame.FruitIcon.Image = FruitList[name2] or ""
			clone4.Parent = clone3.Lists
			local v35 = name2
			clone4.MouseEnter:Connect(function()
				if v31 then
					return
				end

				local percentage = clone4:GetAttribute("Percentage")

				if not percentage then
					return
				end

				v31 = v35
				local clone5 = script.File.RateLabel:Clone()
				clone5.Text = percentage
				clone5.TextColor3 = clone4.InnerFrame.FruitRate.TextColor3

				-- equivalent calls inferred from this helper; original call sites unknown
				local function UpdatePosition()
					local mouseLocation = UserInputService:GetMouseLocation()
					clone5.Position = UDim2.new(
						0,
						mouseLocation.X + clone5.AbsoluteSize.X / 1.75,
						0,
						mouseLocation.Y - clone5.AbsoluteSize.Y
					)
				end

				clone5.Parent = starterFrame
				UpdatePosition() -- equivalent call inferred; original call site unknown

				while v31 == v35 do
					RunService2.Heartbeat:Wait()
					UpdatePosition() -- equivalent call inferred; original call site unknown
				end

				clone5:Destroy()
			end)
			clone4.MouseLeave:Connect(function()
				v31 = nil
			end)
			table.insert(v30[k], clone4)

			if i % 10 == 0 then
				task.wait(0.03333333333333333)
			end
		end

		clones3[k] = clone3
	end

	local function FormatPercentage(value2)
		if not (type(value2) == "number" and value2 ~= 0) then
			return "???"
		end

		local function Truncate(p, value3)
			local v32 = 10 ^ (value3 or 0)
			return math.floor(p * v32) / v32
		end

		local v32 = math.floor(value2 * 100000) / 100000
		return (string.format("%.5f", v32))
	end

	local function FormatChance(value2)
		if type(value2) ~= "number" then
			return value2
		end

		local v32 = tostring(value2)
		local v33 = string.match(v32, "%.(%d+)")

		if not v33 then
			return string.format("%.5f", value2)
		end

		if #v33 < 5 then
			return string.format("%." .. 5 .. "f", value2)
		end

		return v32
	end

	local function UpdateRarityRate(chestChance)
		for k, v32 in pairs(clones3) do
			local v33 = not chestChance and "???%" or chestChance[k] or "???%"
			v32.InnerFrame.Tier.Text = `{k} - {v33}%`
		end

		for k, list in pairs(v30) do
			local v32 = chestChance and chestChance[k]
			local v33 = v32 and v32 / #list
			local text = not v33 and "???%" or `{FormatPercentage(v33)}%` or "???%"

			for _, v35 in ipairs(list) do
				v35.InnerFrame.FruitRate.Text = text
				v35:SetAttribute("Percentage", (`{FormatChance(v33)}%`))
				v35:SetAttribute("FormatPercentage", text)
			end
		end
	end

	local function UpdateTierFrameSize()
		for _, v32 in pairs(clones3) do
			local v33 = fruitRateList.ScrollingFrame.AbsoluteSize - Vector2.new(
				fruitRateList.ScrollingFrame.ScrollBarThickness,
				0
			)
			local v34 = v33.Y * 0.125
			local v35 = v33.X * 0.5
			local v36 = v33.Y * 0.15
			v32.Lists.UIGridLayout.CellSize = UDim2.fromOffset(v35, v36)
			v32.InnerFrame.Size = UDim2.new(0, v33.X - 2, 0, v34)
			v32.Lists.Position = UDim2.fromOffset(0, v34 + 5 + 1)
			v32.Size = UDim2.new(1, 0, 0, v34 + 5 + math.ceil((#v32.Lists:GetChildren() - 1) / 2) * v36 + 5)
		end
	end

	UpdateTierFrameSize()
	fruitRateList:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTierFrameSize)
	local v32 = {
		["Copper Key"] = {
			Price = 25000,
			Type = "Beli"
		},
		["Iron Key"] = {
			Price = 3,
			Type = "Gem"
		},
		["Gold Key"] = {
			Price = 15,
			Type = "Gem"
		}
	}
	local v33 = {
		["Copper Key"] = 10
	}
	local name = "Copper Key"

	local function GiveTitleFunc(p, p2)
		if not (p == "Copper Key" and (p2 == "Legendary" or p2 == "Mythical")) then
			if not (p == "Iron Key" and (p2 == "Legendary" or p2 == "Mythical")) then
				if not (p == "Gold Key" and (p2 == "Legendary" or p2 == "Mythical")) then
					if not (p == "Platinum Key" and (p2 == "Legendary" or p2 == "Mythical")) then
						if p == "Diamond Key" and p2 == "Common" then
						end
					end
				end
			end
		end
	end

	local function UpdatePlayerKeys()
		local jSONDecode = HttpService:JSONDecode(material.Value)

		for _, button2 in pairs(frame.KeyTypeFrame.Frame:GetChildren()) do
			if not button2:IsA("TextButton") then
				continue
			end

			button2.Visible = true
			local v34 = jSONDecode[button2.Name]

			if v34 or button2.Name == "Copper Key" or button2.Name == "Iron Key" or button2.Name == "Gold Key" then
				if not v34 and (button2.Name == "Copper Key" or button2.Name == "Iron Key" or button2.Name == "Gold Key") then
					button2.InfoText.Text = button2.Name:gsub(" Key$", "") .. " (0)"
				end
			else
				button2.Visible = nil
			end

			if v34 then
				button2.InfoText.Text = button2.Name:gsub(" Key$", "") .. " (" .. v34 .. ")"
			end
		end
	end

	local flag16 = nil
	frame.KeyButton.MouseButton1Click:Connect(function()
		if flag16 then
			return
		end

		flag16 = true
		_G.ClickFrameEffect({
			Sound = true
		})
		frame.KeyButton.Size = UDim2.new(0.184, 0, 0.1725, 0)
		TweenService:Create(
			frame.KeyButton,
			TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = UDim2.new(0.24, 0, 0.22499999999999998, 0)
			}
		):Play()
		frame.KeyTypeFrame.Visible = not frame.KeyTypeFrame.Visible
		UpdatePlayerKeys()
		task.delay(0.2, function()
			flag16 = nil
		end)
	end)
	frame.KeyButton.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = frame.KeyButton,
			ZIndex = 7,
			CornerRadius = UDim.new(0.15, 0),
			Circle = true
		})
		frame.KeyButton.Size = UDim2.new(0.16, 0, 0.15, 0)
		TweenService:Create(frame.KeyButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.184, 0, 0.1725, 0)
		}):Play()
	end)
	frame.KeyButton.MouseLeave:Connect(function()
		TweenService:Create(frame.KeyButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.16, 0, 0.15, 0)
		}):Play()
	end)

	local function UpdatePrice()
		local text = tonumber(textBox.Text)

		if not (text and name) then
			return
		end

		local v34 = v32[name]

		if v34 then
			if v34.Type == "Beli" then
				information.TotalPrice.Text = tostring(_G.Suffix(text * v34.Price))
				local value2 = localPlayer2.PlayerStats.beli.Value

				if text * 250000 <= value2 then
					information.TotalPrice.TextColor3 = Color3.fromRGB(117, 255, 110)
				else
					information.TotalPrice.TextColor3 = Color3.fromRGB(255, 56, 56)
				end
			else
				information.TotalPrice.Text = tostring(_G.Suffix_Comma(text * v34.Price)) .. " Gems"

				if localPlayer2.PlayerStats.Gem.Value >= text * v34.Price then
					information.TotalPrice.TextColor3 = Color3.fromRGB(188, 80, 255)
				else
					information.TotalPrice.TextColor3 = Color3.fromRGB(255, 56, 56)
				end
			end
		end
	end

	local function UpdatePlayerKeyStock()
		if v33[name] then
			information.StockText.Visible = true
			local jSONDecode = HttpService:JSONDecode(keyStocks.Value)
			local stocks = jSONDecode.Stocks
			local currentTime = jSONDecode.CurrentTime

			if not (stocks and currentTime) then
				return
			end

			if currentTime ~= math.floor(os.time() / 3600) then
				game.ReplicatedStorage.Chest.Remotes.Functions.BuyKey:InvokeServer("Update")
			elseif stocks then
				local v34 = stocks[name] or 0
				local v35 = math.max(math.ceil((3600 - os.time() % 3600) / 60), 0)
				local v36 = " (" .. v35 .. " Mins)"

				if v35 <= 1 then
					v36 = " (" .. v35 .. " Min)"
				end

				information.StockText.Text = "Stocks: " .. v34 .. "/" .. v33[name] .. v36
			end
		else
			information.StockText.Visible = nil
		end
	end

	keyStocks.Changed:Connect(function()
		wait()
		UpdatePlayerKeyStock()
	end)

	local function UpdateKeySelect()
		if not name then
			return
		end

		local child = frame.KeyTypeFrame.Frame:FindFirstChild(name)

		if not child then
			return
		end

		local jSONDecode = HttpService:JSONDecode(material.Value)
		CloseViewFrame() -- equivalent call inferred; original call site unknown
		local v34 = jSONDecode[name]
		frame.KeyButton.Amt.Text = ""
		frame.KeyButton.MainIcon.Image = child.MainIcon.Image
		frame.KeyButton.MainIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			frame.KeyButton.MainIcon,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()

		if v34 then
			frame.KeyButton.Amt.Text = "x" .. v34
		end

		local chestChance = ChestChances[name]

		if chestChance then
			for childName, v35 in pairs(chestChance) do
				if not (frame.FruitRateFrame:FindFirstChild(childName) and frame.FruitRateFrame[childName]:FindFirstChild("Percentage")) then
					continue
				end

				frame.FruitRateFrame[childName].Percentage.Text = tostring(v35) .. "%"
			end
		end

		if v32[name] then
			information.Visible = true
			information.NameText.Text = name

			if v32[name].Type == "Beli" then
				information.PriceNumber.TextColor3 = Color3.fromRGB(117, 255, 110)
				information.PriceNumber.Text = _G.Suffix(v32[name].Price)
			else
				information.PriceNumber.TextColor3 = Color3.fromRGB(188, 80, 255)
				information.PriceNumber.Text = v32[name].Price .. " Gems"
			end

			UpdatePlayerKeyStock()
			UpdatePrice()
		else
			information.Visible = nil
		end

		UpdateRarityRate(chestChance)
	end

	UpdateKeySelect()

	local function Update(p)
		local v34 = name == "Copper Key" and 10 or 99
		information.Frame.Button.Position = UDim2.new(p, 0, 0.5, 0)
		information.Frame.VolumeFrame.Size = UDim2.new(p, 0, 1, 0)
		information.Frame.TextBox.Text = math.ceil(p * v34)
		UpdatePrice()
	end

	textBox.FocusLost:Connect(function()
		local text = tonumber(textBox.Text)

		if not text then
			return
		end

		local v34 = name == "Copper Key" and 10 or 99
		Update(math.clamp(text, 1, v34) / (v34 + 1))
	end)
	material.Changed:Connect(function()
		wait()
		UpdateKeySelect()
	end)

	for _, button2 in pairs(frame.KeyTypeFrame.Frame:GetChildren()) do
		if not button2:IsA("TextButton") then
			continue
		end

		local v34 = button2
		button2.MouseButton1Click:Connect(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			frame.KeyTypeFrame.Visible = false
			fruitRateList.Visible = false
			name = v34.Name
			task.spawn(function()
				local textLabel = Instance.new("TextLabel")
				textLabel.BackgroundTransparency = 1
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.TextScaled = true
				textLabel.RichText = true
				textLabel.Font = Enum.Font.FredokaOne
				textLabel.Size = UDim2.fromScale(0.25, 0.09)
				textLabel.Position = UDim2.fromScale(0.5, 0.75)
				textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				textLabel.TextStrokeTransparency = 0
				textLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
				textLabel.Text = name
				textLabel.Parent = frame
				_G.PU:Dust(textLabel, 5)
				TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Position = UDim2.fromScale(0.5, 0.7),
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}):Play()
			end)
			UpdateKeySelect()
			Update(0.01)
		end)
		local parent2 = button2
		button2.MouseEnter:Connect(function()
			_G.ShineGui({
				Parent = parent2,
				ZIndex = 7,
				CornerRadius = UDim.new(0.3, 0),
				Circle = true
			})
		end)
	end

	UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
	localPlayer2.Backpack.ChildAdded:Connect(function()
		wait()
		UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
	end)
	localPlayer2.Backpack.ChildRemoved:Connect(function()
		wait()
		UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
	end)
	character2.ChildRemoved:Connect(function()
		wait()
		UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
	end)
	character2.ChildAdded:Connect(function()
		wait()
		UpdateBackpackCapacity() -- equivalent call inferred; original call site unknown
	end)
	local v34 = true
	information.Buy.MouseButton1Click:Connect(function()
		if not (name and v34) then
			return
		end

		_G.ClickFrameEffect({
			Sound = true
		})
		v34 = nil

		if ReplicatedStorage.Chest.Remotes.Functions.BuyKey:InvokeServer(
			name,
			(tonumber(information.Frame.TextBox.Text))
		) then
			information.Buy.Text = "PURCHASED!"
			information.Buy.TextColor3 = Color3.fromRGB(53, 255, 93)
			task.spawn(function()
				wait(0.6)
				information.Buy.Text = "BUY"
				information.Buy.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		else
			information.Buy.Text = "FAIL!"
			information.Buy.TextColor3 = Color3.fromRGB(255, 0, 0)
			task.spawn(function()
				wait(0.6)
				information.Buy.Text = "BUY"
				information.Buy.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		end

		task.spawn(function()
			wait(0.75)
			v34 = true
		end)
	end)
	information.Buy.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = information.Buy,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
		information.Buy.Size = UDim2.new(0.75, 0, 0.15, 0)
		TweenService:Create(information.Buy, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.8624999999999999, 0, 0.1725, 0)
		}):Play()
	end)
	information.Buy.MouseLeave:Connect(function()
		TweenService:Create(information.Buy, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.75, 0, 0.15, 0)
		}):Play()
	end)
	button.MouseButton1Down:Connect(function()
		if flag15 then
			return
		end

		flag15 = true

		while wait() do
			Update(math.clamp(
				math.floor((localPlayer2:GetMouse().X - information.Frame.AbsolutePosition.X) / information.Frame.AbsoluteSize.X / 0.01) * 0.01,
				0.01,
				1
			))

			if not flag15 then
				break
			end
		end

		flag15 = nil
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1 or input.UserInputType == Enum.UserInputType.Touch then
			flag15 = nil
		end
	end)
	local v35 = true
	local v36 = {
		Epic = "EpicChest",
		Legendary = "LegendaryChest",
		Mythical = "MythicalChest"
	}

	local function EnabledChestParticle(folder, enabled, p)
		for _, effect in pairs(folder:GetDescendants()) do
			if not ((effect:IsA("Beam") or effect:IsA("ParticleEmitter")) and effect.Name ~= "gradientflip") then
				continue
			end

			if effect:IsA("ParticleEmitter") and effect:IsDescendantOf(gachaChest.TopPart.Attachment2) and enabled then
				continue
			end

			effect.Enabled = enabled

			if enabled or not p or not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Clear()
		end
	end

	local v37 = {
		EpicChest = function(data, callback)
			local track2 = data.AnimationController:LoadAnimation(data.OpenAnimation)
			track2:Play(0.25)
			PeoUtils.SetParticleEnabled(data.VFX, false)
			local thread = task.spawn(function()
				task.wait(0.83)
				data.RootPart.OpenSound:Play()
				task.wait(0.31999999999999995)
				PeoUtils.EmitParticles(data.Pop)
				task.wait(1.6)
				PeoUtils.EmitParticles(data.Emit)

				if callback then
					callback()
				end
			end)
			track2.Stopped:Once(function()
				track2:Play(0)
				track2.TimePosition = track2.Length - 0.03
				track2:AdjustSpeed(0)
			end)
			return { track2, thread }
		end,
		LegendaryChest = function(data, callback)
			local track2 = data.AnimationController:LoadAnimation(data.OpenAnimation)
			track2:Play(0.25)
			PeoUtils.SetParticleEnabled(data.VFX, false)
			local thread = task.spawn(function()
				task.wait(0.83)
				data.RootPart.OpenSound:Play()
				task.wait(0.31999999999999995)
				PeoUtils.EmitParticles(data.Pop)
				task.wait(1.6)
				PeoUtils.EmitParticles(data.Emit)

				if callback then
					callback()
				end
			end)
			track2.Stopped:Once(function()
				track2:Play(0)
				track2.TimePosition = track2.Length - 0.03
				track2:AdjustSpeed(0)
			end)
			return { track2, thread }
		end,
		MythicalChest = function(data, callback)
			local track2 = data.AnimationController:LoadAnimation(data.OpenAnimation)
			track2:Play(0.25)
			PeoUtils.SetParticleEnabled(data.VFX, false)
			local thread = task.spawn(function()
				task.wait(0.83)
				data.RootPart.OpenSound:Play()
				task.wait(0.31999999999999995)
				PeoUtils.EmitParticles(data.Pop)
				task.wait(1.6)
				PeoUtils.EmitParticles(data.Emit)

				if callback then
					callback()
				end
			end)
			track2.Stopped:Once(function()
				track2:Play(0)
				track2.TimePosition = track2.Length - 0.03
				track2:AdjustSpeed(0)
			end)
			return { track2, thread }
		end,
		GachaChest = function(data, callback)
			local track2 = data.AnimationController:LoadAnimation(data.OpenAnimation)
			track2:Play(0.25)
			local thread = task.delay(0.81, function()
				data.RootPart.OpenSound:Play()
				task.wait(0.8)
				EnabledChestParticle(data, true)
				task.delay(1, function()
					EnabledChestParticle(data, false)
				end)

				if callback then
					callback()
				end
			end)
			track2.Stopped:Once(function()
				track2:Play(0)
				track2.TimePosition = track2.Length - 0.03
				track2:AdjustSpeed(0)
			end)
			return { track2, thread }
		end
	}

	local function EnableParticle(enabled, p)
		for _, descendant in pairs(gachaChest:GetDescendants()) do
			if not ((descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight")) and descendant.Name ~= "gradientflip") then
				continue
			end

			if descendant:IsA("ParticleEmitter") and descendant:IsDescendantOf(gachaChest.TopPart.Attachment2) and enabled then
				continue
			end

			descendant.Enabled = enabled

			if enabled or p or not descendant:IsA("ParticleEmitter") then
				continue
			end

			descendant:Clear()
		end
	end

	local function EnableParticle2()
		for _, emitter in pairs(gachaChest.TopPart.Attachment2:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, emitter in pairs(gachaChest.BottumPart.FloorFX:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, beam in pairs(gachaChest.BottumPart.BeamTop:GetChildren()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end
	end

	local v38 = nil

	local function RainbowTier()
		local uIGradient = gacha_Frame.TierLabel.Outline.UIGradient
		tick()
		gacha_Frame.TierLabel.Outline.TextColor3 = Color3.fromRGB(255, 255, 255)

		while v38 do
			task.wait(0.03333333333333333)
			local v39 = tick() % 1 / 1
			local colorSequenceKeypoints = {}

			for i = 1, 8 do
				local color = Color3.fromHSV(v39 - (i - 1) / 7, 1, 1)

				if v39 - (i - 1) / 7 < 0 then
					color = Color3.fromHSV(v39 - (i - 1) / 7 + 1, 1, 1)
				end

				table.insert(colorSequenceKeypoints, (ColorSequenceKeypoint.new((i - 1) / 7, color)))
			end

			uIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
			task.delay(1, function()
				table.clear(colorSequenceKeypoints)
			end)
		end
	end

	local v39 = nil
	gacha_Frame.SkipLabel.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		v39 = true
	end)
	gacha_Frame.SkipLabel.MouseEnter:Connect(function()
		gacha_Frame.SkipLabel.Size = UDim2.new(0.25, 0, 0.08, 0)
		TweenService:Create(gacha_Frame.SkipLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.2875, 0, 0.092, 0)
		}):Play()
	end)
	gacha_Frame.SkipLabel.MouseLeave:Connect(function()
		TweenService:Create(gacha_Frame.SkipLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.25, 0, 0.08, 0)
		}):Play()
	end)

	local function ClearFruitModels()
		for _, child in pairs(workspace.Effects:GetChildren()) do
			if child:GetAttribute("GachaModel") then
				child:Destroy()
			end
		end
	end

	local function ClearChests(p)
		local chests = gachaBackground.Chests

		for _, model in pairs(chests:GetChildren()) do
			if not model:IsA("Model") then
				continue
			end

			model:Destroy()

			if p then
				RunService2.Heartbeat:Wait()
			end
		end
	end

	local function ShowBackground(enabled: boolean)
		local function VisibleChest(instance)
			for _, part2 in pairs(instance:GetChildren()) do
				if part2:IsA("BasePart") and part2.Name ~= "RootPart" then
					part2.Transparency = enabled and 0 or 1
				end
			end
		end

		VisibleChest(gachaChest)

		for _, child in pairs(gachaBackground.Chests:GetChildren()) do
			VisibleChest(child)
		end

		for _, effect in pairs(gachaBackground.Background:GetDescendants()) do
			if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
				effect.Enabled = enabled
			elseif effect.Name == "cave" or effect.Name == "floor" then
				effect.Transparency = enabled and 0 or 1
			end
		end
	end

	ShowBackground(false)

	local function OpenChests(p: number, list, p2: string)
		ShowBackground(true)
		local clone3 = ReplicatedStorage.Chest.Gui.TeleportFarGui:Clone()
		clone3.Parent = localPlayer2.PlayerGui
		_G.PU:Dust(clone3, 3)
		task.wait(1)
		local chests = gachaBackground.Chests
		local cFrame = gachaBackground.CameraPart.CFrame
		_G.ChestOpening = true
		currentCamera2:SetAttribute("NoRender", true)
		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.CFrame = cFrame
		ClearChests()
		local v40 = math.floor((p - 0.5) / 5)
		local v41 = math.min(p, 5) / 5 * ((v40 + 5) / 0.5)
		local v42 = (currentCamera2.CFrame * CFrame.new(-((math.min(p, 5) - 1) * 2.5), 0, 0) * CFrame.new(
			0,
			0,
			-(v41 + 2.5)
		) - createVector(0, 2.5, 0)) * CFrame.new(0, (v40 - (p / 10 - 1)) * 5, 0)

		if p < 5 then
			v42 = v42 * CFrame.new(0, 0, -2.5) - createVector(0, 2.5, 0)
		end

		local lastTime = tick()
		local v43 = {}
		local v44 = {}
		local uIGradients = {}
		local clones4 = {}
		local v45 = {}
		local v46 = {}

		for i = 1, p do
			local v47 = math.floor((i - 0.5) / 5)
			local v48 = v42 * CFrame.new((i - 1) % 5 * 5, -(v47 * 5), 0)
			local v49 = cFrame.Position - v48.Position
			local clone4 = gachaBackground[v36[GetFruitRarity(list[i])] or "GachaChest"]:Clone()
			clone4.Parent = chests
			local cframe = CFrame.new(v48.Position, v48.Position + v49.Unit * createVector(1, 0, 1))
			clone4:PivotTo(cframe + createVector(0, 25, 0))

			if MaterialList[p2] then
				clone4.KeyPart.Color = MaterialList[p2].TrueColor
				clone4.KeyPart.Material = MaterialList[p2].TrueMaterial
			end

			table.insert(v43, {
				Chest = clone4,
				StartCF = cframe + createVector(0, 25, 0),
				TargetCF = cframe
			})
			v44[clone4] = list[i]
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { chests }
		local v47 = nil
		local v48 = nil
		local connections = {}
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 246, 148)
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 1
		highlight.Adornee = nil
		highlight.Parent = nil
		local v49 = nil
		local v50 = nil

		local function FadeOut()
			if v49 then
				v49:Pause()
				v49 = nil
			end

			local tween = TweenService:Create(highlight, TweenInfo.new(0.25), {
				FillTransparency = 1,
				OutlineTransparency = 1
			})
			tween:Play()
			v49 = tween
			v47 = nil
		end

		local clone4 = ReplicatedStorage.Chest.Etc.KeyPart:Clone()
		clone4.CFrame = cFrame * CFrame.new(1.5, -1, -2.5) * CFrame.Angles(0, 0.17453292519943295, 0)

		if MaterialList[p2] then
			clone4.Color = MaterialList[p2].TrueColor
			clone4.Material = MaterialList[p2].TrueMaterial
		end

		clone4.Parent = workspace

		local function Unbox(instance)
			local v51 = v44[instance]

			if not v51 then
				return
			end

			v44[instance] = nil

			if v50 or tick() - lastTime < 0.3 then
				instance.RootPart.OpenSound.Volume = 0.08
			else
				instance.RootPart.OpenSound.Volume = 0.4
			end

			lastTime = tick()
			local clone5 = clone4:Clone()
			clone5.Transparency = 0
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.25), {
				CFrame = instance:GetPivot() * CFrame.new(0, 0.5, -4) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			task.wait(0.25)
			clone5:Destroy()
			local v52 = v37[instance.Name](instance, function()
				local clone6 = ReplicatedStorage.Chest.Etc.Fruit2D:Clone()
				clone6.CFrame = instance:GetPivot() * CFrame.new(0, -0.5, 0)
				clone6.Fruitboard.FruitImage.Image = FruitList[v51] or "rbxassetid://11648237415"
				clone6.Fruitboard.FruitImage.ImageTransparency = 1
				local text = v51:gsub("Fruit", " Fruit")

				if CustomNames[text] then
					text = CustomNames[text]
				end

				clone6.Nameboard.FruitLabel.Text = text
				clone6.Parent = workspace.Effects
				local fruitRarity = GetFruitRarity(v51)

				if fruitRarity == "Legendary" or fruitRarity == "Mythical" then
					table.insert(uIGradients, clone6.Nameboard.FruitLabel.UIGradient)
					table.insert(uIGradients, clone6.Fruitboard.Shine.UIGradient)
				else
					clone6.Nameboard.FruitLabel.UIGradient.Color = ColorSequence.new(TierColor[fruitRarity])
				end

				table.insert(clones4, clone6)
				TweenService:Create(clone6, TweenInfo.new(1), {
					CFrame = clone6.CFrame * CFrame.new(0, 2.5, 0)
				}):Play()
				TweenService:Create(clone6.Fruitboard.FruitImage, TweenInfo.new(0.35), {
					ImageTransparency = 0
				}):Play()
				task.spawn(function()
					GiveTitleFunc(p2, fruitRarity)
				end)
				task.wait(2.5)

				if v44 then
				end
			end)

			if v52 and #v52 > 0 then
				for _, v53 in ipairs(v52) do
					table.insert(v45, v53)
				end
			end
		end

		table.insert(connections, gacha_Frame.OpenAll.MouseButton1Click:Connect(function()
			if not next(v44) then
				return
			end

			v50 = true

			for k, _ in pairs(v44) do
				local v51 = k
				task.spawn(function()
					Unbox(v51)
				end)
			end
		end))

		if p > 1 then
			TweenService:Create(gacha_Frame.OpenAll, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Position = UDim2.new(0.5, 0, 0.85, 0)
			}):Play()
			gacha_Frame.OpenAll.Visible = true
		end

		table.insert(connections, UserInputService.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Gamepad1 or userInputType == Enum.UserInputType.Touch then
				if next(v44) then
					local mouseLocation = UserInputService:GetMouseLocation()
					local viewportPointToRay = currentCamera2:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
					local raycastResult = workspace:Raycast(
						viewportPointToRay.Origin,
						viewportPointToRay.Direction * 999
					)

					if not raycastResult then
						return
					end

					local parent2 = raycastResult.Instance.Parent

					if not string.find(parent2.Name, "Chest") then
						return
					end

					Unbox(parent2)
				elseif tick() - lastTime > 1 then
					v48 = true
				end
			end
		end))
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			local _ = input.UserInputState
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseMovement or userInputType == Enum.UserInputType.Gamepad1 or userInputType == Enum.UserInputType.Touch then
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera2:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local raycastResult = workspace:Raycast(
					viewportPointToRay.Origin,
					viewportPointToRay.Direction * 999,
					raycastParams
				)

				if raycastResult then
					local parent2 = raycastResult.Instance.Parent

					if not string.find(parent2.Name, "Chest") then
						return
					end

					if not v44[parent2] then
						FadeOut()
						return
					end

					if v47 == parent2 then
						return
					end

					v47 = parent2
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1

					if v49 then
						v49:Pause()
						v49 = nil
					end

					highlight.Adornee = parent2
					highlight.Parent = parent2
					local tween = TweenService:Create(highlight, TweenInfo.new(0.25), {
						FillTransparency = 0.75,
						OutlineTransparency = 0
					})
					tween:Play()
					v49 = tween
				else
					FadeOut()
				end
			end
		end))
		local lastTime2 = tick()
		task.spawn(function()
			local v51 = {}
			PeodizService.new({
				Time = p * 0.25
			}, function(p3)
				local v52 = p3 * p
				local v53 = math.floor(v52) + 1
				local value2 = TweenService:GetValue(v52 % 1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

				for i, v55 in ipairs(v43) do
					if i < v53 then
						v55.Chest:PivotTo(v55.TargetCF)
					elseif i == v53 then
						v55.Chest:PivotTo(v55.StartCF:Lerp(v55.TargetCF, value2))

						if not v51[v55.Chest] then
							v51[v55.Chest] = true
							v55.Chest.RootPart.Smack:Play()
						end
					else
						v55.Chest:PivotTo(v55.StartCF)
					end
				end
			end)

			for _, v52 in pairs(v43) do
				v52.Chest:PivotTo(v52.TargetCF)
			end

			table.clear(v51)
			v51 = nil
		end)
		local v51 = nil
		local v52 = nil

		while true do
			local v53 = RunService2.Heartbeat:Wait()

			if not next(v44) and tick() - lastTime > 3 then
				if not gacha_Frame.ContinueLabel.Visible then
					gacha_Frame.ContinueLabel.Visible = true
					TweenService:Create(
						gacha_Frame.ContinueLabel,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Position = UDim2.new(0.5, 0, 0.85, 0)
						}
					):Play()
				end

				if v48 or v52 then
					local clone5 = ReplicatedStorage.Chest.Gui.TeleportFarGui:Clone()
					clone5.Parent = localPlayer2.PlayerGui
					_G.PU:Dust(clone5, 3)
					TweenService:Create(
						gacha_Frame.ContinueLabel,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Position = UDim2.new(0.5, 0, 1.5, 0)
						}
					):Play()
					TweenService:Create(gacha_Frame.OpenAll, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
						Position = UDim2.new(0.5, 0, 1.5, 0)
					}):Play()
					task.wait(0.75)
					currentCamera2.CameraType = Enum.CameraType.Custom
					currentCamera2:SetAttribute("NoRender", nil)
					_G.ChestOpening = nil
					task.wait(0.75)
					ShowBackground(false)
					gacha_Frame.ContinueLabel.Visible = false
					gacha_Frame.OpenAll.Visible = false
					highlight:Destroy()

					for _, v54 in ipairs(v45) do
						if typeof(v54) == "Instance" and v54.ClassName == "AnimationTrack" then
							v54:Stop()
							v54:Destroy()
						elseif typeof(v54) == "thread" then
							task.cancel(v54)
						end
					end

					table.clear(v45)
					ClearChests(true)

					if v49 then
						v49:Pause()
						v49 = nil
					end

					for _, connection in pairs(connections) do
						if connection.Connected then
							connection:Disconnect()
						end
					end

					for _, v54 in pairs(v46) do
						v54:Stop(0)
						v54:Destroy()
					end

					for _, v54 in pairs(clones4) do
						v54:Destroy()
					end

					table.clear(uIGradients)
					table.clear(connections)
					table.clear(clones4)
					table.clear(v44)
					table.clear(v46)
					clones4 = nil
					v44 = nil
					uIGradients = nil
					break
				end
			end

			if not (v51 or next(v44)) then
				TweenService:Create(gacha_Frame.OpenAll, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Position = UDim2.new(0.5, 0, 1.5, 0)
				}):Play()
				v51 = true
			end

			if tick() - lastTime > 20 and next(v44) then
				task.delay(5, function()
					v52 = true
				end)

				for k, _ in pairs(v44) do
					local v54 = k
					task.spawn(function()
						Unbox(v54)
					end)
				end
			end

			if gacha_Frame.ContinueLabel.Visible then
				gacha_Frame.ContinueLabel.Outline.ShadowGradient.Transparency = NumberSequence.new(math.sin(tick() - lastTime2) / 2)
			end

			local viewportSize = currentCamera2.ViewportSize
			local v54 = mouse.X - viewportSize.X / 2
			local v55 = mouse.Y - viewportSize.Y / 2
			local v56 = cFrame * CFrame.Angles(
				-math.rad(v55 / viewportSize.Y) * 11.25,
				-math.rad(v54 / viewportSize.X) * 45,
				0
			)
			currentCamera2.CFrame = currentCamera2.CFrame:Lerp(v56, v53 * 6)
			clone4.CFrame = clone4.CFrame:Lerp(
				v56 * CFrame.new(1.5, -1, -2.5) * CFrame.Angles(0, 0.17453292519943295, 0),
				v53 * 4
			)

			if next(v44) and not (tick() - lastTime < 0.5) then
				clone4.Transparency = 0
			else
				clone4.Transparency = 1
			end

			local v57 = tick() * 2
			local v58 = math.sin(v57) * 0.5 + 0.5
			local v59 = math.sin(v57 + 2) * 0.5 + 0.5
			local v60 = math.sin(v57 + 4) * 0.5 + 0.5

			for _, v61 in pairs(uIGradients) do
				v61.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(v58, v59, v60)),
					ColorSequenceKeypoint.new(1, Color3.new(v60, v58, v59))
				})
			end
		end
	end

	local function Open1Chest(p, p2)
		OpenChests(1, p, p2)
	end

	local function Open10Chest(p, p2)
		OpenChests(10, p, p2)
	end

	frame["10Key"].MouseButton1Click:Connect(function()
		if not name then
			return
		end

		if GetBackpackCapacity() + 10 > 100 then
			frame.LimitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				frame.LimitLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 2, true, 0),
				{
					TextColor3 = Color3.fromRGB(255, 0, 0)
				}
			):Play()
			task.wait(0.2)
		else
			local jSONDecode = HttpService:JSONDecode(material.Value)

			if jSONDecode[name] and jSONDecode[name] >= 10 then
				if not v35 then
					return
				end

				v35 = nil
				_G.ClickFrameEffect({
					Sound = true
				})
				local v40 = name
				local v41, v42 = ReplicatedStorage.Chest.Remotes.Functions.UseKey:InvokeServer(name, "Open10")
				CloseViewFrame() -- equivalent call inferred; original call site unknown

				if v41 and v42 and not localPlayer2:GetAttribute("ArePaidRandomItemsRestricted") then
					frame.KeyTypeFrame.Visible = false
					_G.VisibleGui(nil)
					frame.Visible = false
					OpenChests(10, v42, v40)
					frame.Visible = true
					_G.VisibleGui(true)
				end

				wait(0.5)
				v35 = true
			end
		end
	end)
	frame["10Key"].MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = frame["10Key"],
			ZIndex = 7,
			CornerRadius = UDim.new(0.15, 0),
			Circle = true
		})
		frame["10Key"].Size = UDim2.new(0.3, 0, 0.15, 0)
		TweenService:Create(frame["10Key"], TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.345, 0, 0.1725, 0)
		}):Play()
	end)
	frame["10Key"].MouseLeave:Connect(function()
		TweenService:Create(frame["10Key"], TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.3, 0, 0.15, 0)
		}):Play()
	end)
	frame["1Key"].MouseButton1Click:Connect(function()
		if not name then
			return
		end

		if GetBackpackCapacity() + 1 > 100 then
			for _ = 1, 3 do
				frame.LimitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(
					frame.LimitLabel,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 2, true, 0),
					{
						TextColor3 = Color3.fromRGB(255, 0, 0)
					}
				):Play()
				task.wait(0.2)
			end
		else
			local jSONDecode = HttpService:JSONDecode(material.Value)

			if jSONDecode[name] and jSONDecode[name] >= 1 then
				if not v35 then
					return
				end

				_G.ClickFrameEffect({
					Sound = true
				})
				v35 = nil
				local v40 = name
				local v41, v42 = ReplicatedStorage.Chest.Remotes.Functions.UseKey:InvokeServer(name, "Open1")
				CloseViewFrame() -- equivalent call inferred; original call site unknown

				if v41 and v42 and not localPlayer2:GetAttribute("ArePaidRandomItemsRestricted") then
					frame.KeyTypeFrame.Visible = false
					_G.VisibleGui(nil)
					frame.Visible = false
					OpenChests(1, v42, v40)
					frame.Visible = true
					_G.VisibleGui(true)
				end

				wait(0.5)
				v35 = true
			end
		end
	end)
	frame["1Key"].MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = frame["1Key"],
			ZIndex = 7,
			CornerRadius = UDim.new(0.15, 0),
			Circle = true
		})
		frame["1Key"].Size = UDim2.new(0.3, 0, 0.15, 0)
		TweenService:Create(frame["1Key"], TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.345, 0, 0.1725, 0)
		}):Play()
	end)
	frame["1Key"].MouseLeave:Connect(function()
		TweenService:Create(frame["1Key"], TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.3, 0, 0.15, 0)
		}):Play()
	end)
	frame.Close.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true
		})

		if fruitRateList.Visible then
			fruitRateList.Visible = false
			return
		end

		_G.NPCTalk = false
		TweenService:Create(frame, TweenInfo.new(0.25), {
			Position = UDim2.new(0.5, 0, 2, 0)
		}):Play()
		task.delay(0.25, function()
			frame.Visible = false
			CloseViewFrame() -- equivalent call inferred; original call site unknown
		end)
	end)
	frame.Close.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = frame.Close,
			ZIndex = 5,
			Circle = true,
			Size = UDim2.fromScale(0.8, 0.8)
		})
		frame.Close.Size = UDim2.new(0.106, 0, 0.15, 0)
		TweenService:Create(frame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.12189999999999998, 0, 0.1725, 0)
		}):Play()
	end)
	frame.Close.MouseLeave:Connect(function()
		TweenService:Create(frame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.106, 0, 0.15, 0)
		}):Play()
	end)
	viewFrame.Close.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true
		})
		CloseViewFrame() -- equivalent call inferred; original call site unknown
	end)
	viewFrame.Close.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = viewFrame.Close,
			ZIndex = 5,
			Circle = true,
			Size = UDim2.fromScale(0.8, 0.8)
		})
		viewFrame.Close.Size = UDim2.new(0.167, 0, 0.237, 0)
		TweenService:Create(viewFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.19205, 0, 0.27254999999999996, 0)
		}):Play()
	end)
	viewFrame.Close.MouseLeave:Connect(function()
		TweenService:Create(viewFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.167, 0, 0.237, 0)
		}):Play()
	end)
	fruitRateButton.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		fruitRateList.Visible = true
	end)
	fruitRateButton.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = fruitRateButton,
			ZIndex = 7,
			CornerRadius = UDim.new(0.15, 0),
			Circle = true
		})
	end)
	view10Key.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		local lastSelect = viewFrame:GetAttribute("LastSelect")

		if not lastSelect or lastSelect ~= `View 10 {name}` then
			OpenViewFrame({
				Type = "10 Key",
				KeySelect = name
			})
			return
		end

		CloseViewFrame() -- equivalent call inferred; original call site unknown
	end)
	view10Key.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = view10Key,
			ZIndex = 7,
			CornerRadius = UDim.new(0.15, 0),
			Circle = true
		})
	end)
	task.spawn(function()
		while true do
			if name and v33[name] then
				UpdatePlayerKeyStock()
			end

			wait(30)
		end
	end)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatPercent(p)
	if p == 0 then
		return "0"
	end

	return (string.format("%.6f", p):gsub("0+$", ""):gsub("%.$", ""))
end

task.spawn(function()
	local connections = {}
	local playerStats = localPlayer2:WaitForChild("PlayerStats")
	local material = playerStats:WaitForChild("Material")
	local luckBoosts = playerStats:WaitForChild("LuckBoosts")
	local v29 = dropBoostFrame
	local infoFrame = v29.InfoFrame
	local textFrame = infoFrame.TextFrame
	local icon = infoFrame.BG.Icon
	local _ = infoFrame.BG.CanvasGroup.BG
	local back = textFrame.Back
	local action = textFrame.Action
	local swordName = textFrame.SwordName
	local recipes = textFrame.Recipes
	local fishInventory = v29.ChooseFishFrame.BG.FishInventory
	local dropBoost2 = textFrame.DropBoost
	local scrollingFrame = v29:WaitForChild("ScrollingFrame")
	local weapon = nil
	local recipes2 = {}
	local v32 = {
		Common = 0.0025,
		Uncommon = 0.005,
		Rare = 0.01,
		Epic = 0.1,
		Legendary = 2.5,
		Mythical = 10
	}

	local function UpdateScrollingFishInventory()
		local uIGridLayout = fishInventory.UIGridLayout
		local scrollBarThickness = fishInventory.ScrollBarThickness
		local v33 = (fishInventory.AbsoluteSize.X - scrollBarThickness - 2 - 10) / 3
		uIGridLayout.CellSize = UDim2.new(0, v33, 0, v33)
		uIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
		fishInventory.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	local function UpdateScrollingRecipes()
		local uIGridLayout = recipes.UIGridLayout
		local scrollBarThickness = recipes.ScrollBarThickness
		local v33 = (recipes.AbsoluteSize.X - scrollBarThickness - 15) / 4
		uIGridLayout.CellSize = UDim2.new(0, v33, 0, v33)
		uIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
		recipes.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	local function UpdateScrolling()
		local uIGridLayout = scrollingFrame.UIGridLayout
		local scrollBarThickness = scrollingFrame.ScrollBarThickness
		local v33 = (scrollingFrame.AbsoluteSize.X - scrollBarThickness - 0) / 4
		uIGridLayout.CellSize = UDim2.new(0, v33, 0, v33)
		uIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	UpdateScrolling()
	UpdateScrollingRecipes()
	UpdateScrollingFishInventory()

	local function ClearRecipes()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)

		for _, button in pairs(recipes:GetChildren()) do
			if button:IsA("TextButton") and button.Name ~= "PlusButton" then
				button:Destroy()
			end
		end
	end

	local v33 = 0.01
	local text2 = nil
	TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateVolume(p)
		if not text2 then
			return
		end

		local child = fishInventory:FindFirstChild(text2)

		if not child then
			return
		end

		local amount = child:GetAttribute("Amount") or 1
		local v35 = p or 1 / amount
		local button = v29.ChooseFishFrame.TextFrame.Frame.Button
		local volumeFrame = v29.ChooseFishFrame.TextFrame.Frame.VolumeFrame
		local textBox = v29.ChooseFishFrame.TextFrame.Frame.TextBox
		button:TweenPosition(UDim2.new(v35, 0, 0.5, 0), "Out", "Quad", 0.15, true)
		volumeFrame:TweenSize(UDim2.new(v35, 0, 1, 0), "Out", "Quad", 0.15, true)
		textBox.Text = math.ceil(v35 * amount)
		v33 = 1 / amount
	end

	local function UpdateFishSelecting()
		if text2 then
			local v35 = MaterialList[text2]

			if not v35 then
				return
			end

			if v2 then
				v2:Destroy()
				v2 = nil
			end

			v29.ChooseFishFrame.TextFrame.Icon.Size = UDim2.new(0, 0, 0, 0)
			v29.ChooseFishFrame.TextFrame.Icon.Rotation = 180
			v2 = TweenService:Create(
				v29.ChooseFishFrame.TextFrame.Icon,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
				{
					Size = UDim2.new(0.7, 0, 0.525, 0),
					Rotation = 360
				}
			)
			v2:Play()
			v29.ChooseFishFrame.TextFrame.Icon.Image = v35.Image
			v29.ChooseFishFrame.TextFrame.FishName.Text = text2
			v29.ChooseFishFrame.TextFrame.Frame.Visible = true
			UpdateVolume()
		else
			v29.ChooseFishFrame.TextFrame.Icon.Image = ""
			v29.ChooseFishFrame.TextFrame.FishName.Text = ""
			v29.ChooseFishFrame.TextFrame.Frame.Visible = false
		end
	end

	local UpdateRecipes

	UpdateRecipes = function()
		ClearRecipes()
		local total = 0

		for k, text in pairs(recipes2) do
			local v36 = MaterialList[k]

			if not (v36 and v36.Fish and v36.Tier) then
				continue
			end

			local v37 = TierColor[v36.Tier]
			local clone3 = file.FishButton:Clone()
			clone3.Name = k
			clone3.BackgroundColor3 = v37
			clone3.UIStroke.Color = v37
			clone3.LayoutOrder = _G.Layouts[v36.Tier]
			clone3.Amount.Text = text
			clone3.IconMaterial.Image = v36.Image
			local v38 = k
			table.insert(connections, clone3.MouseButton1Click:Connect(function()
				_G.ClickFrameEffect({
					Sound = true,
					Parent = v29.Parent
				})
				recipes2[v38] = nil
				UpdateRecipes()
			end))
			table.insert(connections, clone3.MouseEnter:Connect(function()
				_G.ShineGui({
					Parent = clone3,
					ZIndex = 7,
					CornerRadius = UDim.new(0.1, 0),
					Circle = true
				})
			end))
			clone3.Parent = recipes

			if v32[v36.Tier] then
				total += v32[v36.Tier] * text
			end
		end

		infoFrame.Visible = true
		v29.ChooseFishFrame.Visible = false

		if not weapon then
			return
		end

		local v35 = SwordList[weapon] or AccessoriesList[weapon] or MaterialList[weapon]

		if not (v35 and v35["Drop Boost"]) then
			return
		end

		local v36 = HttpService:JSONDecode(luckBoosts.Value)[weapon] or 0
		local v37 = math.clamp(v36 / v35["Drop Boost"].Max, 0, 1)
		local v38 = math.clamp((v36 + total) / v35["Drop Boost"].Max, 0, 1)
		local v39 = math.clamp(v36 + total, 0, v35["Drop Boost"].Max)
		TweenService:Create(dropBoost2.Border.Bar.Line, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = UDim2.new(v37, 0, 1, 0)
		}):Play()
		TweenService:Create(dropBoost2.Border.Bar.ProgressLine, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = UDim2.new(v38, 0, 1, 0)
		}):Play()

		if total > 0 then
			infoFrame.TextFrame.DropBoost.Amount.Text = tostring("+%s%% > %s%%"):format(
				FormatPercent(v36),
				FormatPercent(v39)
			)
		else
			infoFrame.TextFrame.DropBoost.Amount.Text = tostring("+%s%%"):format(FormatPercent(v36))
		end
	end

	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateScrolling()
		UpdateScrollingRecipes()
		UpdateScrollingFishInventory()
	end)

	local function CheckUnlocked(p)
		if _G.CheckSwordClient(localPlayer2, p) then
			return true
		end

		return false
	end

	local function UpdateInfoFrame(name)
		if not (name and (SwordList[name] or AccessoriesList[name] or MaterialList[name])) then
			return
		end

		weapon = name
		swordName.Text = CustomNames[name] or name
		local image = ""

		if AccessoriesList[name] and AccessoriesList[name].Image then
			image = AccessoriesList[name].Image
		elseif MaterialList[name] and MaterialList[name].Image then
			image = MaterialList[name].Image
		elseif SwordList[name] and SwordList[name].Image then
			image = SwordList[name].Image
		end

		if image then
			icon.Size = UDim2.fromScale(0, 0)
			icon.Image = image
			icon.ImageColor3 = Color3.fromRGB()
			TweenService:Create(icon, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = UDim2.fromScale(1, 1)
			}):Play()
			TweenService:Create(
				icon,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.1),
				{
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}
			):Play()
		end

		infoFrame.Visible = true
		table.clear(recipes2)
		UpdateRecipes()
	end

	local function UpdateObtained()
		for _, button in pairs(scrollingFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if localPlayer2.Inventory:FindFirstChild(button.Name) or localPlayer2.Accessories:FindFirstChild(button.Name) then
				button.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				button.ImageLabel.ScaleType = Enum.ScaleType.Fit
				button.FSLocked.Size = UDim2.fromScale(0.4, 0.4)
				button.FSLocked.Image = "rbxassetid://102150559994031"
				button.FSLocked.Visible = true
			else
				button.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
				button.FSLocked.Visible = false
			end
		end
	end

	local function InstanceButton()
		for _, v36 in ipairs({ SwordList, AccessoriesList, MaterialList }) do
			for childName, v37 in pairs(v36) do
				if scrollingFrame:FindFirstChild(childName) or not v37["Drop Boost"] then
					continue
				end

				local tier = v37.Tier
				local clone3 = file.FSButton:Clone()
				clone3.Name = childName
				clone3.FightingStyleName.Text = CustomNames[childName] or childName
				clone3.ImageLabel.Image = v37.Image
				clone3.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
				clone3.ImageLabel.BackgroundColor3 = TierColor[tier]
				clone3.TierImage.Image = TierImage[tier]
				clone3.LayoutOrder = _G.Layouts[tier]
				local v38 = childName
				clone3.MouseButton1Click:Connect(function()
					if infoFrame.Visible or v29.ChooseFishFrame.Visible then
						return
					end

					if localPlayer2.Inventory:FindFirstChild(v38) or localPlayer2.Accessories:FindFirstChild(v38) then
						print("return")
						return
					end

					_G.ClickFrameEffect({
						Sound = true,
						Parent = v29.Parent
					})
					UpdateInfoFrame(clone3.Name)
				end)
				local parent2 = clone3
				clone3.MouseEnter:Connect(function()
					if infoFrame.Visible or parent2.FSLocked.Visible or v29.ChooseFishFrame.Visible then
						return
					end

					_G.ShineGui({
						Parent = parent2,
						ZIndex = 5
					})
					local canvasGroup = parent2:FindFirstChild("CanvasGroup")

					if canvasGroup then
						canvasGroup:Destroy()
					end

					local clone4 = file.CanvasGroup:Clone()
					clone4.Background.ImageTransparency = 1
					clone4.LoopSpike.Enabled = true
					clone4.Parent = parent2
					TweenService:Create(clone4.Background, TweenInfo.new(0.5), {
						ImageTransparency = 0.5
					}):Play()
				end)
				local parent3 = clone3
				clone3.MouseLeave:Connect(function()
					local canvasGroup = parent3:FindFirstChild("CanvasGroup")

					if canvasGroup and canvasGroup:FindFirstChild("Background") then
						TweenService:Create(canvasGroup.Background, TweenInfo.new(0.5), {
							ImageTransparency = 1
						}):Play()
					end

					_G.PU:Dust(canvasGroup, 0.5)
				end)
				clone3.Parent = scrollingFrame
			end
		end

		UpdateObtained()
	end

	InstanceButton()
	recipes:WaitForChild("PlusButton").MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})
		text2 = nil
		infoFrame.Visible = false
		v29.ChooseFishFrame.Visible = true
		UpdateFishSelecting()
	end)
	recipes:WaitForChild("PlusButton").MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = recipes.PlusButton,
			ZIndex = 7,
			CornerRadius = UDim.new(0.1, 0),
			Circle = true
		})
	end)
	v29.ChooseFishFrame.TextFrame.Back.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})
		infoFrame.Visible = true
		v29.ChooseFishFrame.Visible = false
	end)
	v29.ChooseFishFrame.TextFrame.Back.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = v29.ChooseFishFrame.TextFrame.Back,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
	local v35 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DisconnectFishButton(name)
		local v36 = v35[name]

		if v36 then
			for _, connection in ipairs(v36) do
				connection:Disconnect()
			end

			v35[name] = nil
		end
	end

	local function UpdateInventoryFishs()
		local jSONDecode = HttpService:JSONDecode(material.Value)

		for _, button in pairs(fishInventory:GetChildren()) do
			if not button:IsA("TextButton") or jSONDecode[button.Name] then
				continue
			end

			DisconnectFishButton(button.Name) -- equivalent call inferred; original call site unknown
			button:Destroy()

			if text2 ~= button.Name then
				continue
			end

			text2 = nil
			UpdateFishSelecting()
		end

		for childName, text in pairs(jSONDecode) do
			local v37 = MaterialList[childName]

			if not (v37 and v37.Fish and v37.Tier) then
				continue
			end

			local clone3 = fishInventory:FindFirstChild(childName)

			if not clone3 then
				local v38 = TierColor[v37.Tier]
				clone3 = file.FishButton:Clone()
				clone3.Name = childName
				clone3.BackgroundColor3 = v38
				clone3.UIStroke.Color = v38
				clone3.LayoutOrder = _G.Layouts[v37.Tier]
				clone3.IconMaterial.Image = v37.Image
				local connections2 = {}
				local v39 = childName
				table.insert(connections2, clone3.MouseButton1Click:Connect(function()
					_G.ClickFrameEffect({
						Sound = true,
						Parent = v29.Parent
					})

					if text2 == v39 then
						text2 = nil
					else
						text2 = v39
					end

					UpdateFishSelecting()
				end))
				local parent2 = clone3
				table.insert(connections2, clone3.MouseEnter:Connect(function()
					_G.ShineGui({
						Parent = parent2,
						ZIndex = 7,
						CornerRadius = UDim.new(0.1, 0),
						Circle = true
					})
				end))
				v35[childName] = connections2
				clone3.Parent = fishInventory
			end

			clone3:SetAttribute("Amount", text)
			clone3.Amount.Text = text
		end

		UpdateVolume()
	end

	UpdateInventoryFishs()
	material.Changed:Connect(function()
		task.wait(0.1)
		UpdateInventoryFishs()
	end)
	playerStats:WaitForChild("EtcData").Changed:Connect(function()
		task.wait(0.1)
		UpdateObtained()
	end)
	localPlayer2.Inventory.ChildAdded:Connect(function()
		task.wait(0.1)
		UpdateObtained()
	end)
	localPlayer2.Inventory.ChildRemoved:Connect(function()
		task.wait(0.1)
		UpdateObtained()
	end)
	localPlayer2.Accessories.ChildAdded:Connect(function()
		task.wait(0.1)
		UpdateObtained()
	end)
	localPlayer2.Accessories.ChildRemoved:Connect(function()
		task.wait(0.1)
		UpdateObtained()
	end)
	local flag15 = nil
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1 or input.UserInputType == Enum.UserInputType.Touch then
			flag15 = nil
		end
	end)
	v29.ChooseFishFrame.TextFrame.Frame.TextBox.FocusLost:Connect(function()
		local text = tonumber(v29.ChooseFishFrame.TextFrame.Frame.TextBox.Text)

		if not (text and text2) then
			return
		end

		local child = fishInventory:FindFirstChild(text2)

		if not child then
			return
		end

		local amount = child:GetAttribute("Amount") or 1
		UpdateVolume(math.clamp(text, 1, amount) / (amount + 1))
	end)
	v29.ChooseFishFrame.TextFrame.Action.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})

		if not text2 then
			return
		end

		local child = fishInventory:FindFirstChild(text2)

		if not child then
			return
		end

		local amount = child:GetAttribute("Amount") or 1
		local text = tonumber(v29.ChooseFishFrame.TextFrame.Frame.TextBox.Text)
		local v36 = tonumber(amount)

		if not (text and v36) or v36 < text then
			return
		end

		recipes2[text2] = text > 0 and text or nil
		UpdateRecipes()
	end)
	v29.ChooseFishFrame.TextFrame.Action.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = v29.ChooseFishFrame.TextFrame.Action,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
	v29.ChooseFishFrame.TextFrame.Frame.Button.MouseButton1Down:Connect(function()
		if flag15 then
			return
		end

		flag15 = true
		local mouse2 = localPlayer2:GetMouse()
		local frame = v29.ChooseFishFrame.TextFrame.Frame
		local v36 = nil

		while task.wait() do
			local v37 = (mouse2.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X
			local child = text2 and fishInventory:FindFirstChild(text2)
			local v38 = not child and 0.0001 or 1 / (child:GetAttribute("Amount") or 1)
			local v39 = math.clamp(math.floor(v37 / v33) * v33, v38, 1)

			if v39 ~= v36 then
				UpdateVolume(v39)
				v36 = v39
			end

			if not (flag15 and text2) then
				break
			end
		end

		flag15 = false
	end)
	action.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})

		if not (weapon and next(recipes2)) then
			return
		end

		if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("UpgradeLuckBoosts", {
			Weapon = weapon,
			Recipes = recipes2
		}) then
			table.clear(recipes2)
			UpdateRecipes()
		end
	end)
	local closeButton = v29.CloseButton
	local flag16 = nil
	back.MouseButton1Click:Connect(function()
		_G.ClickFrameEffect({
			Sound = true,
			Parent = v29.Parent
		})
		infoFrame.Visible = nil
	end)
	back.MouseEnter:Connect(function()
		if flag16 then
			return
		end

		_G.ShineGui({
			Parent = back,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
	closeButton.MouseButton1Click:Connect(function()
		if flag16 then
			return
		end

		flag16 = true
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true,
			Parent = v29.Parent
		})
		_G.NPCTalk = false
		infoFrame.Visible = nil
		_G.ButtonClicked({
			Frame = nil,
			Button = nil
		})
		task.delay(0.5, function()
			flag16 = nil
		end)
	end)
	closeButton.MouseEnter:Connect(function()
		closeButton.Size = UDim2.new(0.104, 0, 0.15, 0)
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.11959999999999998, 0, 0.1725, 0)
		}):Play()
		_G.ShineGui({
			Parent = closeButton,
			ZIndex = 5,
			Size = UDim2.fromScale(0.8, 0.8),
			Circle = true
		})
	end)
	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.104, 0, 0.15, 0)
		}):Play()
	end)
	action.MouseEnter:Connect(function()
		if flag16 then
			return
		end

		_G.ShineGui({
			Parent = action,
			ZIndex = 7,
			CornerRadius = UDim.new(0.3, 0),
			Circle = true
		})
	end)
end)