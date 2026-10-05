local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace:WaitForChild(localPlayer.Name)
local humanoid = child:WaitForChild("Humanoid")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
require(ReplicatedStorage.Modules.Client.UI.GamepassNeededController)
local currentCamera = game.Workspace.CurrentCamera
local ContextActionService = game:GetService("ContextActionService")
game:GetService("UserInputService")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local WalkToggleController = require(ReplicatedStorage.Modules.Client.Input.WalkToggleController)
local MusicPlayerController = require(ReplicatedStorage.Modules.Client.Music.MusicPlayerController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local game8Settings = script:WaitForChild("Game8Settings")
local module = require(game8Settings)
local maxy = module.Maxy
local playerTrigEvent = module.PlayerTrigEvent
local gettingHouse = module.GettingHouse
local playersHouse = module.PlayersHouse
local playerTool = module.PlayerTool
local noMotorVehicles = module.NoMotorVehicles
local horseRemote = module.HorseRemote
local props = module.Props
local messages = module.Messages
local playersCar = module.PlayersCar
local flying = module.Flying
local giveAnimationTools = module.GiveAnimationTools
local babyFollow = module.BabyFollow
local agencyRemote = module.AgencyRemote
local pickingHouseMusicText = module.PickingHouseMusicText
local mainGUIHandler = script.Parent:WaitForChild("MainGUIHandler")
local noResetGUIHandler = playerGui:WaitForChild("NoResetGUIHandler")
local mainHouseMenu = mainGUIHandler:WaitForChild("MainHouseMenu")
local quakeSound = script:WaitForChild("QuakeSound")
local agencyPool = script:WaitForChild("AgencyPool")
local agencyArch = script:WaitForChild("AgencyArch")
local agencyDiscover = script:WaitForChild("AgencyDiscover")
local crystalPower = script:WaitForChild("CrystalPower")
local mainButtons = mainGUIHandler:WaitForChild("MainButtons")
local mainAudio = mainGUIHandler:WaitForChild("MainAudio")
local menu = mainGUIHandler:WaitForChild("Menu")
local cam = menu:WaitForChild("Cam")
local animationStop = menu:WaitForChild("AnimationStop")
local houseKey = noResetGUIHandler:WaitForChild("HouseKey")
local turboNumber = noResetGUIHandler:WaitForChild("TurboNumber")
local animationPlaying = script:WaitForChild("AnimationPlaying")
local chatAnimationPlaying = script:WaitForChild("ChatAnimationPlaying")
local houseSpinner = mainGUIHandler:WaitForChild("HouseSpinner")
local spinner = houseSpinner:WaitForChild("Spinner")
local loadingBool = script:WaitForChild("LoadingBool")
local MusicABTestController = require(ReplicatedStorage.Modules.Client.Music.MusicABTestController)
local MainButtonPopout = require(ReplicatedStorage.Modules.Client.Components.UI.MainButtonPopout)
local tempPlotOfLand = script:WaitForChild("TempPlotOfLand")
local tempHouseNumber = script:WaitForChild("TempHouseNumber")
local flag = false
local v = false
local v2 = false
local flag2 = false
local flag3 = false
local v3 = false
local maid = Janitor.new()
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local track = nil
local v4 = {
	House = mainHouseMenu,
	Apartment = mainHouseMenu,
	Mansion = mainHouseMenu,
	Motel = mainHouseMenu,
	Landmark = mainHouseMenu
}

local function SprintRequest(_, p, _)
	if p == Enum.UserInputState.Begin then
		v = true
	elseif p == Enum.UserInputState.End then
		v = false
	end

	if child.Humanoid.WalkSpeed ~= 0 and not child:FindFirstChild(localPlayer.Name .. "Horse") and not child:FindFirstChild("NoMotorVehicleModel") and child:FindFirstChild("LowerTorso") ~= nil and child.LowerTorso:FindFirstChild("SprintDust") ~= nil then
		WalkToggleController.StopWalking()
		child.Humanoid.WalkSpeed = 24

		if child.Humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
			child.LowerTorso.SprintDust.Enabled = true
		end

		repeat
			task.wait(0.2)
		until v == false

		if child.Humanoid.WalkSpeed ~= 0 and not (child:FindFirstChild(localPlayer.Name .. "Horse") or child:FindFirstChild("NoMotorVehicleModel")) then
			child.Humanoid.WalkSpeed = 16
		end

		if child.LowerTorso:FindFirstChild("SprintDust") ~= nil then
			child.LowerTorso.SprintDust.Enabled = false
		end
	end
end

ContextActionService:BindAction("SprintRequest", SprintRequest, false, Enum.KeyCode.LeftShift)

function CloseSecurityCams()
	if localPlayer and localPlayer.Character then
		local humanoid2 = localPlayer.Character:FindFirstChild("Humanoid")

		if humanoid2 ~= nil then
			currentCamera.CameraSubject = humanoid2
			currentCamera.CameraType = "Custom"
		end
	end
end

messages.OnClientEvent:Connect(function(text)
	if mainGUIHandler.Messages.Visible == false then
		mainGUIHandler.Messages.Notification.TextMessage.Text = text
		mainGUIHandler.Messages.Visible = true
		wait(7)
		mainGUIHandler.Messages.Visible = false
	end
end)

function ClientMessage(p: string)
	NotificationController.Notify(p)
end

local v5 = {
	NoMotorColor = {
		controlGui = "NoMotorVehicleControl",
		remoteEvent = noMotorVehicles,
		playRequest = {
			select = "PickingScooterMusicText",
			play = "PickingScooterMusicPlay",
			stop = "PickingScooterMusicStop",
			volume = "ChangeVolume"
		}
	},
	Vehicle = {
		controlGui = "VehicleControl",
		remoteEvent = playersCar,
		playRequest = {
			select = "PickingVehicleMusicText",
			play = "VehicleMusicPlay",
			stop = "VehicleMusicStop",
			volume = "ChangeVolume"
		}
	},
	Horse = {
		controlGui = "HorseControl",
		remoteEvent = horseRemote,
		playRequest = {
			select = "PickingHorseMusicText",
			play = "HorseMusicPlay",
			stop = "HorseMusicStop",
			volume = "ChangeVolume"
		}
	},
	Car = {
		controlGui = "CarControl",
		remoteEvent = playersCar,
		playRequest = {
			select = "PickingCarMusicText",
			play = "CarMusicPlay",
			stop = "CarMusicStop",
			volume = "ChangeVolume"
		}
	},
	CarSiren = {
		controlGui = "CarControlSiren",
		remoteEvent = playersCar,
		playRequest = {
			select = "PickingCarMusicText",
			play = "CarMusicPlay",
			stop = "CarMusicStop",
			volume = "ChangeVolume"
		}
	},
	HousePanelLazyLoaded = {
		controlGui = "HouseControlPanel",
		remoteEvent = playersHouse,
		playRequest = {
			select = pickingHouseMusicText,
			play = "PickingHouseMusicPlay",
			stop = "PickingHouseMusicStop",
			volume = "ChangeVolume"
		}
	},
	Tool = {
		controlGui = nil,
		remoteEvent = playerTool,
		playRequest = {
			select = "ToolMusicText",
			play = "ToolMusicPlay",
			stop = "ToolMusicStop",
			volume = "ChangeVolume"
		},
		enableTools = { "Boombox" }
	},
	Prop = {
		controlGui = "PropMenuFilter",
		screenGui = "NoResetGUIHandler",
		remoteEvent = props,
		playRequest = {
			select = "PropMusicText",
			play = "PropMusicPlay",
			stop = "PropMusicStop",
			volume = "ChangeVolume"
		}
	},
	AirVehicle = {
		controlGui = "MainAirVehicleMenu",
		remoteEvent = playersCar,
		playRequest = {
			select = "Picking",
			play = "MusicPlay",
			stop = "MusicStop",
			volume = "ChangeVolume"
		}
	},
	WickedGramophone = {
		controlGui = nil,
		allowSameTypeStop = true,
		remoteEvent = playersCar,
		playRequest = {
			select = "WickedGramophoneMusicSelect",
			play = "WickedGramophoneMusicPlay",
			stop = "WickedGramophoneMusicStop",
			volume = "WickedGramophoneChangeVolume"
		}
	},
	GenericBoombox = {
		controlGui = nil,
		allowSameTypeStop = true,
		remoteEvent = playersCar,
		playRequest = {
			select = "Picking",
			play = "MusicPlay",
			stop = "MusicStop",
			volume = "ChangeVolume"
		}
	}
}
local v6 = {
	"GenericBoombox",
	"Tool",
	"Prop",
	"WickedGramophone",
	"NoMotorColor",
	"Vehicle",
	"Horse",
	"Car",
	"CarSiren",
	"AirVehicle",
	"HousePanelLazyLoaded"
}

local function getActiveControlType()
	local musicContext = MusicPlayerController.GetMusicContext()

	if musicContext then
		return musicContext, v5[musicContext.name], musicContext.instance
	end

	for _, v7 in v6 do
		local v8 = v5[v7]
		local v9 = v8.screenGui == nil and "MainGUIHandler" or v8.screenGui

		if not (v8.controlGui ~= "VehicleControl" or VehicleController.IsPlayerDriving()) then
			continue
		end

		if v8.controlGui == "MainAirVehicleMenu" and VehicleController.IsPlayerDrivingAirVehicle() then
			return v7, v8
		end

		local _, v10 = MusicController.GetActivationSource()

		if v8.controlGui == "PropMenuFilter" and (PanelController.IsOpen("NoResetGUIHandler", "PropMenuFilter") or v10 == "PropMusicButton") then
			return v7, v8
		end

		if v8.enableTools == nil or v8.controlGui ~= nil then
			if PanelController.IsManualLazyPanel(v9, v8.controlGui) then
				if PanelController.IsRegistered(v9, v8.controlGui) and PanelController.IsOpen(v9, v8.controlGui) then
					return v7, v8
				end
			elseif v8.controlGui and PanelController.IsOpen(v9, v8.controlGui) then
				return v7, v8
			end
		elseif localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool") then
			local tool = localPlayer.Character:FindFirstChildOfClass("Tool")

			for _, enableTool in v8.enableTools do
				if enableTool == tool.Name then
					return v7, v8
				end
			end
		end
	end

	return nil, nil
end

local MusicsConfig = require(ReplicatedStorage.Modules.Shared.DB.Musics.MusicsConfig)
local config = MusicsConfig.GetConfig()
local scrollingFrame = mainAudio.Catalog.Container.ScrollingFrame
local freeSongsWicked = scrollingFrame:FindFirstChild("FreeSongsWicked")
local freeSongsEdSheeran = scrollingFrame:FindFirstChild("FreeSongsEdSheeran")
local songs = scrollingFrame:FindFirstChild("Songs")
local musicTemplateButton = scrollingFrame:FindFirstChild("MusicTemplateButton")
local color = Color3.fromHex("#008E1C")
local color2 = Color3.fromHex("#000000")
local v7 = nil
local v8 = {}
local expect = MusicABTestController.ShouldRunABTest():expect()
local v9, v10 = ABTest.GetExperimentVariable("music-purchase-flow", "show-ed-sheeran-music"):timeout(3):await()

if not v9 then
	warn(v10)
end

local v11 = not expect or v10

if musicTemplateButton ~= nil then
	musicTemplateButton.Parent = nil

	for k, v12 in config do
		if not (v12.FreeCategory ~= "EdSheeran2025" or v11) then
			continue
		end

		local clone = musicTemplateButton:Clone()
		clone.Name = string.format("%03d_%s", k, v12.SongName)
		clone.Title.Text = v12.SongName
		clone.ID.Value = v12.AssetID
		clone.LayoutOrder = v12.LayoutOrder
		clone.Title.TextColor3 = v12.New and color or color2
		clone.BackgroundTransparency = v12.New and 0.1 or 0.36

		if v12.Icon then
			clone.Icon.Image = v12.Icon
			clone.Icon.Visible = true
		else
			clone.Icon.Visible = false
		end

		if v12.IconSize ~= nil then
			local iconSize = v12.IconSize
			clone.Icon.Size = UDim2.new(iconSize.X, 0, iconSize.Y, 0)
		end

		local titleSize = v12.TitleSize

		if titleSize == nil and v12.titleSize ~= nil then
			titleSize = v12.titleSize
		end

		if titleSize ~= nil then
			clone.Title.Size = UDim2.new(titleSize.X, 0, titleSize.Y, 0)
		end

		clone.Parent = songs
		assert(v8[v12.AssetID] == nil, "Music button already exists for asset ID " .. tostring(v12.AssetID))
		v8[v12.AssetID] = clone
	end
end

local count = 0

for _, button in freeSongsWicked:GetChildren() do
	if button:IsA("ImageButton") then
		count += 1
	end
end

local count2 = 0

for _, button in freeSongsEdSheeran:GetChildren() do
	if button:IsA("ImageButton") then
		count2 += 1
	end
end

if count <= 0 then
	freeSongsWicked.Visible = false
	local dividerWicked = scrollingFrame:FindFirstChild("DividerWicked")

	if dividerWicked then
		dividerWicked.Visible = false
	end
end

if count2 <= 0 then
	freeSongsEdSheeran.Visible = false
	local dividerEdSheeran = scrollingFrame:FindFirstChild("DividerEdSheeran")

	if dividerEdSheeran then
		dividerEdSheeran.Visible = false
	end
end

if not musicTemplateButton then
	for _, v12 in { songs, freeSongsWicked, freeSongsEdSheeran } do
		for _, button in v12:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			button.GreenCheckMark.Visible = false
			v8[tonumber(button.ID.Value)] = button
		end
	end

	v7 = nil
end

for _, button in v8 do
	if not button:IsA("ImageButton") then
		continue
	end

	local v12 = button
	button.Activated:Connect(function()
		local function selectMusic()
			if v7 then
				v7.GreenCheckMark.Visible = false
			end

			v7 = v12

			if v12.GreenCheckMark then
				v12.GreenCheckMark.Visible = true
			end

			local ID = v12:FindFirstChild("ID")
			local title = v12:FindFirstChild("Title")

			if ID and title then
				local value = ID.Value
				local text = title.Text
				mainAudio.Catalog.Header.Title.Background.SongName.Text = text
				mainAudio.Catalog.Header.Title.Background.SongName.ID.Value = value
				local activeControlType, v13, v14 = getActiveControlType()

				if v13 then
					mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://114212393771017"
					local stop = v13.playRequest.stop

					for k, v15 in v6 do
						local v16 = v15 == activeControlType
						local allowSameTypeStop = v13.allowSameTypeStop

						if not (allowSameTypeStop or not v16) then
							continue
						end

						local v17 = v5[v15]

						if v17.playRequest.stop ~= stop or allowSameTypeStop then
							v17.remoteEvent:FireServer(v17.playRequest.stop, "", v14, true)
						end
					end

					v13.remoteEvent:FireServer(v13.playRequest.select, value, v14, true)
					mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://114212393771017"
				end
			end
		end

		local activationSource, v13 = MusicController.GetActivationSource()

		if UnlockableController.IsFeatureUnlocked(activationSource.id, Gamepasses.MUSIC_UNLOCKED) or MusicsConfig.IsMusicFree((tonumber(v12.ID.Value))) then
			if flag2 then
				return
			end

			flag2 = true
			selectMusic()
			task.wait(1)
			flag2 = false
		else
			GamepassController.Show(
				Gamepasses.MUSIC_UNLOCKED,
				nil,
				v13,
				nil,
				activationSource,
				nil,
				v13,
				v12.Name,
				function()
					PanelController.Open("MainGUIHandler", "MainAudio")
					selectMusic()
				end
			)
			PanelController.Close("MainGUIHandler", "MainAudio")
		end
	end)
end

mainAudio.Catalog.Header.ButtonsList.Next.MouseButton1Click:Connect(function()
	local _, v12, v13 = getActiveControlType()

	if v12 then
		local text = mainAudio.Catalog.Header.Title.Background.SongName.Text
		local value = mainAudio.Catalog.Header.Title.Background.SongName.ID.Value

		for k, v14 in config do
			if not (v14.SongName == text and v14.AssetID == value) then
				continue
			end

			local v16 = config[k % #config + 1]

			if not v16 then
				break
			end

			local activationSource, _ = MusicController.GetActivationSource()

			if not (UnlockableController.IsFeatureUnlocked(activationSource.id, Gamepasses.MUSIC_UNLOCKED) or MusicsConfig.IsMusicFree((tonumber(v16.AssetID)))) then
				return
			end

			v12.remoteEvent:FireServer(v12.playRequest.select, v16.AssetID, v13)
			mainAudio.Catalog.Header.Title.Background.SongName.Text = v16.SongName
			mainAudio.Catalog.Header.Title.Background.SongName.ID.Value = v16.AssetID
			mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://114212393771017"

			if v7 then
				v7.GreenCheckMark.Visible = false
			end

			local v17 = v8[v16.AssetID]

			if not v17 then
				break
			end

			v17.GreenCheckMark.Visible = true
			v7 = v17
			return
		end
	end
end)
mainAudio.Catalog.Header.ButtonsList.Previous.MouseButton1Click:Connect(function()
	local _, v12, v13 = getActiveControlType()

	if v12 then
		local text = mainAudio.Catalog.Header.Title.Background.SongName.Text
		local value = mainAudio.Catalog.Header.Title.Background.SongName.ID.Value

		for k, v14 in config do
			if not (v14.SongName == text and v14.AssetID == value) then
				continue
			end

			local v16 = config[(k - 2) % #config + 1]

			if not v16 then
				break
			end

			local activationSource, _ = MusicController.GetActivationSource()

			if not (UnlockableController.IsFeatureUnlocked(activationSource.id, Gamepasses.MUSIC_UNLOCKED) or MusicsConfig.IsMusicFree((tonumber(v16.AssetID)))) then
				return
			end

			v12.remoteEvent:FireServer(v12.playRequest.select, v16.AssetID, v13)
			mainAudio.Catalog.Header.Title.Background.SongName.Text = v16.SongName
			mainAudio.Catalog.Header.Title.Background.SongName.ID.Value = v16.AssetID
			mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://114212393771017"

			if v7 then
				v7.GreenCheckMark.Visible = false
			end

			local v17 = v8[v16.AssetID]

			if not v17 then
				break
			end

			v17.GreenCheckMark.Visible = true
			v7 = v17
			return
		end
	end
end)
mainAudio.Catalog.Header.ButtonsList.PausePlay.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true
	local _, v12, v13 = getActiveControlType()

	if v12 then
		local pausePlay = mainAudio.Catalog.Header.ButtonsList.PausePlay
		local v14 = pausePlay.Image == "rbxassetid://114212393771017"
		pausePlay.Image = v14 and "rbxassetid://118117426385847" or "rbxassetid://114212393771017"
		local stop = v14 and v12.playRequest.stop or v12.playRequest.play
		v12.remoteEvent:FireServer(stop, "", v13)
	end

	task.wait(0.5)
	flag3 = false
end)
houseKey.House.Value.MouseButton1Click:Connect(function()
	local houseControlPanel = mainGUIHandler:FindFirstChild("HouseControlPanel")

	if houseControlPanel then
		local cam2 = houseControlPanel:FindFirstChild("Cam")

		if cam2 and cam2.Visible == true then
			return
		end
	end

	if flag or (PanelController.IsOpen("MainGUIHandler", "CarControl") or PanelController.IsOpen(
		"MainGUIHandler",
		"CarControlSiren"
	) or PanelController.IsOpen("MainGUIHandler", "HorseControl")) then
		return
	end

	flag = true
	local value = houseKey.House.Value.Key.HouseKeyNumber.Value
	local houseType = HouseUtil.GetHouseType(value)

	if houseType then
		local houseControlPanel2 = HouseUtil.GetHouseControlPanel(houseType)

		if PanelController.IsOpen("MainGUIHandler", houseControlPanel2) then
			PanelController.Close("MainGUIHandler", houseControlPanel2)
			mainAudio.Visible = false
		elseif not (VehicleController.IsPlayerDriving() or VehicleController.IsPlayerDrivingAirVehicle()) then
			if VehicleController.GetCurrentNonMotorVehicle() then
				NotificationController.NotifyCenter("Dismount your vehicle to access house controls")
			else
				PanelController.Open("MainGUIHandler", houseControlPanel2)
			end
		end
	else
		ClientMessage("House Controls Are Unavailable.")
	end

	task.wait(0.2)
	flag = false
end)
gettingHouse.OnClientEvent:Connect(function(p, p2: number, p3: string, flag4: boolean?)
	if p == "HouseSold" then
		houseKey.House.Value.Visible = false
	end

	if p ~= "BuyHouseSetUpUI" then
		return
	end

	tempPlotOfLand.Value = p3
	tempHouseNumber.Value = p2
	houseKey.House.Value.Key.Text = "#" .. tempHouseNumber.Value
	houseKey.House.Value.Key.HouseKeyNumber.Value = tempHouseNumber.Value
	houseKey.House.Value.SettingsLabel.Text = "Picking Style"
	houseKey.House.Value.Visible = true
	local v12, v13 = ABTest.GetExperimentVariable("house-cameras-rework", "cameraEnabled"):timeout(5):await()
	local v14 = v12 and v13 and LotUtil.GetById(p2)

	if v14 then
		local type = v14:GetAttribute("Type")
		local ID = v14:GetAttribute("ID")
		houseKey.House.Value.Key.Text = type .. " #" .. ID
	end

	local value = tempPlotOfLand.Value

	if value then
		local houseMenu = HouseUtil.GetHouseMenu(value)
		local v15 = mainGUIHandler[houseMenu]
		local HouseMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMenu)
		HouseMenu:WaitForInstance(v15):expect():OpenAsHouseType(p3, p2)
		local scrollingFrame2 = v15.Catalog.Container.ScrollGroup.ScrollingFrame
		scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame2.UIGridLayout.AbsoluteContentSize.Y)
		PanelController.ToggleGroup("TopArea", false)

		if flag4 then
			PanelController.ToggleGroup("RightSide", false)
			PanelController.OpenPanelByContext("MainGUIHandler", houseMenu)
			MainButtonPopout.Close()
		end
	end

	PanelController.Close("MainGUIHandler", "WhiteCircle")
end)

function LoadingGui()
	while loadingBool.Value ~= false do
		wait(0.05)
		spinner.Rotation += 30
	end
end

local v12 = {
	standardHouse = { "HousePickedByPlayer", "HouseModel", "001_AnimationPermission" },
	changeableHouse = {
		"HousePickedByPlayer",
		"HouseModel",
		"001_ChangeRoom",
		"001_HoldRooms",
		"Room",
		"001_AnimationPermission"
	},
	motel = { "Motel", "001_AnimationPermission" }
}

local function handleHousePermission(p, items, p2)
	local child2 = game.Workspace["001_Lots"]:FindFirstChild(p .. "House")

	if not child2 then
		return
	end

	for _, childName in items do
		child2 = child2:FindFirstChild(childName)

		if not child2 then
			return
		end
	end

	for _, child3 in child2:GetChildren() do
		local TF = child3:FindFirstChild("TF")

		if TF then
			TF.Value = p2
		end
	end
end

gettingHouse.OnClientEvent:Connect(function(p, p2)
	local v13 = ({
		PermissionOwner = function()
			handleHousePermission(localPlayer.Name, v12.standardHouse, true)
		end,
		PermissionOwnerChangeableHouse = function()
			handleHousePermission(localPlayer.Name, v12.changeableHouse, true)
		end,
		PermissionNotOwnerChangeableHouse = function()
			handleHousePermission(p2, v12.changeableHouse, true)
		end,
		RemovePermissionNotOwnerChangeableHouse = function()
			handleHousePermission(p2, v12.changeableHouse, false)
		end,
		PermissionOwnerMotel = function()
			handleHousePermission(localPlayer.Name, v12.motel, true)
		end
	})[p]

	if v13 then
		v13()
	end
end)
gettingHouse.OnClientEvent:Connect(function(p, p2: string?)
	if p == "LoadingGui" then
		if not loadingBool.Value then
			loadingBool.Value = true
			spawn(LoadingGui)
			houseSpinner.Visible = true
		end
	elseif p == "LoadingGuiStop" then
		loadingBool.Value = false
		houseSpinner.Visible = false
	else
		local menu2

		if p2 then
			menu2 = v4[p2]
		else
			menu2 = mainHouseMenu
		end

		local v16 = ({
			HouseLoadedGiveLazyLoadedGui = {
				menu = menu2,
				controlPanel = "HouseControlPanel"
			}
		})[p]

		if not v16 then
			return
		end

		local houseOwn = localPlayer.PlayersBag:FindFirstChild("HouseOwn")

		if not (houseOwn and houseOwn.Value) then
			return
		end

		v16.menu.Catalog.Header.CategoryTabs.LeaveHome.Visible = true
		houseSpinner.Visible = false
		loadingBool.Value = false
		mainAudio.Visible = false
		local v17 = not (VehicleController.IsPlayerDriving() or VehicleController.IsPlayerDrivingAirVehicle()) and not VehicleController.GetCurrentNonMotorVehicle() and PanelController.WaitForPanel(
			"MainGUIHandler",
			v16.controlPanel
		)

		if v17 then
			v17:Open()
		end
	end
end)
playerTrigEvent.OnClientEvent:Connect(function(p, p2)
	if p == "GivePermissionLoopToClient" then
		handleHousePermission(p2.Name, v12.standardHouse, true)
	elseif p == "RemovePermissionLoopToClient" then
		handleHousePermission(p2.Name, v12.standardHouse, false)
	end
end)
local v13 = {
	["133519034814297"] = {
		name = "Wave",
		repeats = false,
		showStop = false
	},
	["120490880559140"] = {
		name = "Point",
		repeats = false,
		showStop = false
	},
	["100946763039371"] = {
		name = "Yes",
		repeats = false,
		showStop = false
	},
	["108708048283802"] = {
		name = "No",
		repeats = false,
		showStop = false
	},
	["88643697154290"] = {
		name = "idk",
		repeats = false,
		showStop = false
	},
	["72741818559206"] = {
		name = "Lol / Laugh",
		repeats = false,
		showStop = false
	},
	["71296307181937"] = {
		name = "T-Pose",
		repeats = false,
		showStop = true
	},
	["101315817843410"] = {
		name = "Wolfpaq",
		repeats = true,
		showStop = true
	},
	["128370255637213"] = {
		name = "Aidanleewolf",
		repeats = true,
		showStop = true
	},
	["105128771246795"] = {
		name = "Cranky",
		repeats = true,
		showStop = true
	}
}

for k in v13 do
	EmotesController.RegisterExternalEmote(k)
end

local function ChatGuiAnimation(p, repeats)
	if not EmotesController.CanPlayEmote() then
		return
	end

	if child ~= nil and humanoid ~= nil and animationPlaying.Value == false then
		if track ~= nil and track.IsPlaying then
			track:Stop()
		end

		if repeats == true then
			chatAnimationPlaying.Value = true
		else
			chatAnimationPlaying.Value = false
		end

		local animationId = "rbxassetid://" .. tostring(p)
		local animation = Instance.new("Animation")
		animation.Name = "LocalAnimation"
		animation.AnimationId = animationId
		track = localPlayer.Character.Humanoid:LoadAnimation(animation)
		track:Play()
		EmotesController.ExternalEmotePlayed(track)
	end
end

maid:Add(maxy.OnClientEvent:Connect(function(p)
	if not localPlayer or localPlayer.Character:FindFirstChild("NoMotorVehicleModel") or localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") then
		return
	end

	local v14 = v13[p]

	if not v14 then
		return
	end

	ChatGuiAnimation(p, v14.repeats)
	animationStop.Visible = v14.showStop
end))
giveAnimationTools.OnClientEvent:Connect(function(p)
	if p == "StopAnimations" then
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in playingAnimationTracks do
			if playingAnimationTrack.Name == "LocalAnimation" then
				playingAnimationTrack:Stop()
			end

			if child ~= nil and child.Humanoid ~= nil then
				child.Humanoid.WalkSpeed = 16
			end
		end
	end
end)
animationStop.MouseButton1Click:connect(function()
	EmotesController.StopEmote()
end)

function CheckAddOnsOn(folder, p)
	if p == true then
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageLabel") and descendant.Name == "SpringONOFF" then
				descendant.Visible = true
			end
		end
	else
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageLabel") and descendant.Name == "SpringONOFF" then
				descendant.Visible = false
			end
		end
	end
end

function CheckWheelieOn(folder, p)
	if p == nil or p ~= true then
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Wheelie" then
				descendant.Visible = false
			end
		end

		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Spring" then
				descendant.Visible = true
			end
		end
	else
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Spring" then
				descendant.Visible = false
			end
		end

		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Wheelie" then
				descendant.Visible = true
			end
		end
	end
end

function CheckWheelieSirenOn(folder, p)
	if p == nil or p ~= true then
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Wheelie" then
				descendant.Visible = false
			end
		end

		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Spring" then
				descendant.Visible = true
			end
		end
	else
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Spring" then
				descendant.Visible = false
			end
		end

		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageButton") and descendant.Name == "Wheelie" then
				descendant.Visible = true
			end
		end
	end
end

function CheckAddOnsOnSiren(folder, p)
	if p == true then
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageLabel") and descendant.Name == "SpringONOFF" then
				descendant.Visible = true
			end
		end
	else
		for _, descendant in folder:GetDescendants(), nil, nil do
			if descendant:isA("ImageLabel") and descendant.Name == "SpringONOFF" then
				descendant.Visible = false
			end
		end
	end
end

function CheckTurboStage(p, p2, p3)
	if p2 == nil or p3 == nil or p2 ~= true then
		p.PassSpeedGUI.Drift.Turbo.Visible = false
	else
		p.PassSpeedGUI.Drift.Turbo.Visible = true

		if p3.Value == "27.9" then
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "1"
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			turboNumber.Value = 1
		elseif p3.Value == "44.5" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "2"
			turboNumber.Value = 2
		elseif p3.Value == "61.1" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "3"
			turboNumber.Value = 3
		elseif p3.Value == "11.3" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "Off"
			turboNumber.Value = 0
		end
	end
end

function CheckTurboStageOnSiren(p, p2, p3)
	if p2 == nil or p3 == nil or p2 ~= true then
		p.PassSpeedGUI.Drift.Turbo.Visible = false
	else
		p.PassSpeedGUI.Drift.Turbo.Visible = true

		if p3.Value == "27.9" then
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "1"
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			turboNumber.Value = 1
		elseif p3.Value == "44.5" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "2"
			turboNumber.Value = 2
		elseif p3.Value == "61.1" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo Stage"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "3"
			turboNumber.Value = 3
		elseif p3.Value == "11.3" then
			p.PassSpeedGUI.Drift.Turbo.TurboText.Text = "Turbo"
			p.PassSpeedGUI.Drift.Turbo.StageNumber.Text = "Off"
			turboNumber.Value = 0
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function doesCurrentHouseHaveGarage()
	local playerHouseStructure = localPlayer.PlayersBag:FindFirstChild("PlayerHouseStructure")

	if playerHouseStructure then
		return playerHouseStructure.Value == "House" or playerHouseStructure.Value == "Mansion"
	end

	return false
end

playersCar.OnClientEvent:Connect(function(p, p2, p3, p4, p5)
	if p == "OpenCarGUI" then
		localPlayer.PlayersBag:FindFirstChild("PlayerHouseStructure")
		local houseControlPanel = mainGUIHandler:FindFirstChild("HouseControlPanel")

		if houseControlPanel then
			local cam2 = houseControlPanel:FindFirstChild("Cam")

			if cam2 and cam2.Visible == true then
				cam2.Visible = false
				CloseSecurityCams()
				return
			end
		end

		PanelController.ToggleGroup("TopArea", false)
		PanelController.Open("MainGUIHandler", "CarControl")
		local carControl = mainGUIHandler:WaitForChild("CarControl")
		carControl.LocalCarControl.Disabled = false
		mainAudio.Visible = false

		if houseKey.Visible == true then
			-- equivalent call inferred; original call site unknown
			if doesCurrentHouseHaveGarage() then
				houseKey.House.Value.GarageDoor.Visible = true
			end
		end

		CheckAddOnsOn(carControl, p2)
		CheckTurboStage(carControl, p3, p4)
		CheckWheelieOn(carControl, p5)
	elseif p == "CloseCarGUI" then
		PanelController.Close("MainGUIHandler", "CarControl")
		mainAudio.Visible = false
		houseKey.House.Value.GarageDoor.Visible = false
		local carControl_2 = mainGUIHandler:WaitForChild("CarControl")
		carControl_2.LocalCarControl.Disabled = true
	elseif p == "OpenCarGUISiren" then
		local houseControlPanel = mainGUIHandler:FindFirstChild("HouseControlPanel")

		if houseControlPanel then
			local cam2 = houseControlPanel:FindFirstChild("Cam")

			if cam2 and cam2.Visible == true then
				cam2.Visible = false
				CloseSecurityCams()
				return
			end
		end

		PanelController.ToggleGroup("TopArea", false)
		PanelController.Open("MainGUIHandler", "CarControlSiren")
		local carControlSiren = mainGUIHandler:WaitForChild("CarControlSiren")
		carControlSiren.LocalCarControlSiren.Disabled = false
		mainAudio.Visible = false

		if houseKey.Visible == true then
			-- equivalent call inferred; original call site unknown
			if doesCurrentHouseHaveGarage() then
				houseKey.House.Value.GarageDoor.Visible = true
			end
		end

		CheckAddOnsOnSiren(carControlSiren, p2)
		CheckTurboStageOnSiren(carControlSiren, p3, p4)
		CheckWheelieSirenOn(carControlSiren, p5)
	elseif p == "CloseCarGUISiren" then
		PanelController.Close("MainGUIHandler", "CarControlSiren")
		local carControlSiren_2 = mainGUIHandler:WaitForChild("CarControlSiren")
		carControlSiren_2.LocalCarControlSiren.Disabled = true
		mainAudio.Visible = false
		houseKey.House.Value.GarageDoor.Visible = false
	elseif p == "DestroyCarGUIONNoCar" then
		PanelController.Close("MainGUIHandler", "CarControlSiren")
		PanelController.Close("MainGUIHandler", "CarControl")
		mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://118117426385847"
		houseKey.House.Value.GarageDoor.Visible = false
	end
end)
playersCar.OnClientEvent:Connect(function(p)
	if p == "Lift1" then
		playersCar:FireServer("Lift1Enable")
	elseif p == "Lift2" then
		playersCar:FireServer("Lift2Enable")
	end
end)
agencyRemote.OnClientEvent:Connect(function(p)
	if p == "TeleportAgencyPool" then
		agencyPool:Play()
	elseif p == "TeleportAgencyArch" then
		agencyArch:Play()
	elseif p == "AgencyDiscoverSound" then
		agencyDiscover:Play()
	elseif p == "CrystalPowerSound" then
		crystalPower:Play()
	end
end)
flying.OnClientEvent:Connect(function(p)
	if p == "DroneGUI" then
		menu.DroneJump.Visible = true
		script.WindDiving.PlaybackSpeed = 1.5
		script.WindDiving.Volume = 0.05
	elseif p == "TurnJumpButtonOff" then
		menu.DroneJump.Visible = false
		script.WindDiving:Stop()
	end
end)
menu.DroneJump.MouseButton1Click:Connect(function()
	menu.DroneJump.Visible = false
	flying:FireServer("PlayerJumpedFromDrone")
	script.WindDiving:Stop()
end)

for _, child2 in menu.BankCards:GetChildren(), nil, nil do
	if not child2:isA("ImageButton") then
		continue
	end

	local v14 = child2
	child2.MouseButton1Click:connect(function()
		if v2 == false then
			v2 = true

			if v14.Name == "CreditCardBoy" or v14.Name == "CreditCardGirl" then
				local pickingTools = module.PickingTools
				module.Tools:InvokeServer(pickingTools, v14.Name)
				menu.BankCards.Visible = false
			end

			task.wait(1)
			v2 = false
		end
	end)
end

local function QuakeOn()
	while v3 == true do
		currentCamera.FieldOfView = math.random(67, 70)
		wait(0.01)
	end
end

maxy.OnClientEvent:Connect(function(p, p2)
	if p == "EarthQuakeOn" and v3 == false then
		quakeSound.Volume = 6
		v3 = true
		quakeSound:Play()
		spawn(function()
			QuakeOn()
		end)
		wait(p2)
		quakeSound.Volume = 0.1
		wait(0.1)
		quakeSound:Stop()
		v3 = false
	end
end)

if localPlayer ~= nil and localPlayer:FindFirstChild("PlayersBag") ~= nil and localPlayer.PlayersBag:FindFirstChild("FollowCharacterName") ~= nil then
	local followCharacterName = localPlayer.PlayersBag:FindFirstChild("FollowCharacterName")

	if followCharacterName.Value ~= "NoFollowCharacter" then
		babyFollow:FireServer("CharacterFollowSpawnPlayer", followCharacterName.Value)
	end

	if localPlayer.PlayersBag:FindFirstChild("Job") ~= nil then
		local job = localPlayer.PlayersBag:FindFirstChild("Job")
		local jobOrStudent = job:FindFirstChild("JobOrStudent")

		if job.Value == true then
			local jobTitlePic = job:FindFirstChild("JobTitlePic")
			cam.JobOpen.JobImage.Image = "rbxassetid://" .. jobTitlePic.Value

			if jobOrStudent.Value == false then
				cam.JobOpen.Words.Text = "Student"
			else
				cam.JobOpen.Words.Text = "Job"
			end

			cam.JobOpen.Visible = true
		end
	end
end

PanelController.Close("NoResetGUIHandler", "AvatarEditorMenu")
mainButtons.Visible = true
noResetGUIHandler.MailboxUI.Visible = false
noResetGUIHandler.GunAssaultMenu.Visible = false
noResetGUIHandler.GunSniperMenu.Visible = false
noResetGUIHandler.GunShotGunMenu.Visible = false
noResetGUIHandler.GunGlockMenu.Visible = false
noResetGUIHandler.GunGlockBrownMenu.Visible = false
noResetGUIHandler.GunSkinsMenu.Visible = false
wait(0.6)
VehicleController.OnPlayerStartedDriving:Connect(function(_)
	local garageDoor = houseKey.House.Value.GarageDoor
	local visible = doesCurrentHouseHaveGarage() -- equivalent call inferred; original call site unknown
	garageDoor.Visible = visible
end)
VehicleController.OnPlayerStoppedDriving:Connect(function()
	houseKey.House.Value.GarageDoor.Visible = false
end)
local Players2 = game:GetService("Players")
Players2.LocalPlayer.CharacterRemoving:Connect(function()
	ContextActionService:UnbindAction("SprintRequest")
	maid:Destroy()
	maid = nil
end)