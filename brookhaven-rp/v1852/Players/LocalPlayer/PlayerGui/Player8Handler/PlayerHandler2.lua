local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local humanoid = workspace:WaitForChild(localPlayer.Name):WaitForChild("Humanoid")
local currentCamera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local game8Settings = script.Parent:WaitForChild("Game8Settings")
local module = require(game8Settings)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local FreeCamController = require(ReplicatedStorage.Modules.Client.PlayerController.FreeCamController)
local Permissions = require(ReplicatedStorage.Modules.Shared.Permissions)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local dayWeek = module.DayWeek
local clock = module.Clock
local maxy = module.Maxy
local schoolDryBoards = module.SchoolDryBoards
local flying = module.Flying
local jobs = module.Jobs
local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
local settingsMain = playerGui:WaitForChild("SettingsMain")
local noResetGUIHandler = playerGui:WaitForChild("NoResetGUIHandler")
local jobMenuWorkspace = noResetGUIHandler:WaitForChild("JobMenuWorkspace")
local menu = mainGUIHandler:WaitForChild("Menu")
local subwayStationMenu = menu:WaitForChild("SubwayStationMenu")
local blackScreen = menu:WaitForChild("BlackScreen")
local cam = menu:WaitForChild("Cam")
local submarineCam = menu:WaitForChild("SubmarineCam")
local jobMessage = menu:WaitForChild("JobMessage")
local phoneCall = menu:WaitForChild("PhoneCall")
local jobMessageSmall = menu:WaitForChild("JobMessageSmall")
local cemeteryName = menu:WaitForChild("CemeteryName")
local codeName = menu:WaitForChild("CodeName")
script:WaitForChild("CameraNumber")
script:WaitForChild("CameraNumberTotal")
script:WaitForChild("CamObject")
local subCameraNumber = script:WaitForChild("SubCameraNumber")
local subCameraNumberTotal = script:WaitForChild("SubCameraNumberTotal")
local subCamObject = script:WaitForChild("SubCamObject")
local subway = script.Parent:WaitForChild("Subway")
local planeSound = script.Parent:WaitForChild("PlaneSound")
local windDiving = script.Parent:WaitForChild("WindDiving")
local planeShaker = script.Parent:WaitForChild("PlaneShaker")
local shaker = planeShaker:WaitForChild("Shaker")
local cellRinging = script.Parent:WaitForChild("Cell Ringing")
local agencyPool = script.Parent:WaitForChild("AgencyPool")
local lake = subwayStationMenu.Frame:WaitForChild("Lake")
local blackhawk = subwayStationMenu.Frame:WaitForChild("Blackhawk")
local crownPointe = subwayStationMenu.Frame:WaitForChild("CrownPointe")
local downtown = subwayStationMenu.Frame:WaitForChild("Downtown")
local close = subwayStationMenu.White:WaitForChild("Close")
local subwaySeatNumber = script.Parent:WaitForChild("SubwaySeatNumber")
local subwayStation = script.Parent:WaitForChild("SubwayStation")
local topCornerDetails = noResetGUIHandler:WaitForChild("TopCornerDetails")
local time = topCornerDetails.Clock:WaitForChild("Time")
local day = topCornerDetails.Clock:WaitForChild("Day")
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = false
local v8 = false
local v9 = false
local v10 = false
local v11 = false
local v12 = false
local v13 = false
local animationPlaying = script.Parent:WaitForChild("AnimationPlaying")
local horseRemote = module.HorseRemote
local v14 = false
local track = humanoid:LoadAnimation((script:WaitForChild("RiderAnimationOne")))
clock.OnClientEvent:Connect(function(text)
	time.Text = text
end)
dayWeek.OnClientEvent:Connect(function(p, text)
	if p == "GiveDayOfWeek" then
		day.Text = text
	end
end)

function ClientMessage(p: string)
	NotificationController.Notify(p)
end

function TweenJobTitle(p)
	if jobMessage.Visible == false then
		jobMessage.Image = "rbxassetid://" .. p
		jobMessage.Visible = true
		jobMessage.Position = UDim2.new(-0.4, 0, 0.15, 0)
		jobMessage:TweenPosition(UDim2.new(0.45, 0, 0.15, 0), "InOut", "Sine", 0.3, true)
		wait(1.7)
		jobMessage:TweenPosition(UDim2.new(1.4, 0, 0.15, 0), "InOut", "Sine", 0.5, true)
		wait(1)
		jobMessage.Visible = false
	end
end

function TweenMessageSmall(text)
	if jobMessageSmall.Visible == false then
		jobMessageSmall.JobTextHere.Text = text
		jobMessageSmall.Visible = true
		jobMessageSmall.Position = UDim2.new(-0.4, 0, 0.15, 0)
		jobMessageSmall:TweenPosition(UDim2.new(0.33, 0, 0.15, 0), "InOut", "Sine", 0.3, true)
		wait(1.7)
		jobMessageSmall:TweenPosition(UDim2.new(1.4, 0, 0.15, 0), "InOut", "Sine", 0.5, true)
		wait(1)
		jobMessageSmall.Visible = false
	end
end

jobs.OnClientEvent:Connect(function(p, p2, p3, p4)
	if p == "JobMainUIOpen" then
		cam.JobOpen.JobImage.Image = "rbxassetid://" .. p2

		if p4 == false then
			cam.JobOpen.Words.Text = "Student"
		else
			cam.JobOpen.Words.Text = "Job"
		end

		cam.JobOpen.Visible = true
		spawn(function()
			TweenJobTitle(p3)
		end)
	elseif p == "JobMainUIClose" then
		cam.JobOpen.Visible = false
	end
end)
cam.JobOpen.MouseButton1Click:connect(function()
	if v == false then
		v = true

		if jobMenuWorkspace.Visible == false then
			jobMenuWorkspace.Visible = true
		else
			jobMenuWorkspace.Visible = false
		end

		wait(0.3)
		v = false
	end
end)
jobMenuWorkspace.Close.MouseButton1Click:connect(function()
	if v4 == false then
		v4 = true
		jobMenuWorkspace.Visible = false
		wait(0.3)
		v4 = false
	end
end)
jobMenuWorkspace.MainButtons.MainOpen.QuitJob.MouseButton1Click:connect(function()
	if v2 == false then
		v2 = true
		jobMenuWorkspace.Visible = false
		cam.JobOpen.Visible = false
		jobMenuWorkspace.MainButtons.MainOpen.Break.Break.Text = "Take Break"
		Remotes.fireServer("QuitJob")
		wait(0.3)
		v2 = false
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function indicateOffJobBreak()
	jobMenuWorkspace.Visible = false
	jobMenuWorkspace.MainButtons.MainOpen.Break.Break.Text = "Take Break"
	spawn(function()
		TweenJobTitle("Off Break")
	end)
end

jobMenuWorkspace.MainButtons.MainOpen.Break.MouseButton1Click:connect(function()
	if v3 == false then
		v3 = true

		if jobMenuWorkspace.MainButtons.MainOpen.Break.Break.Text == "Take Break" then
			jobMenuWorkspace.Visible = false
			jobMenuWorkspace.MainButtons.MainOpen.Break.Break.Text = "End Break"
			Remotes.fireServer("ToggleBreak")
			spawn(function()
				TweenJobTitle("On Break")
			end)
		else
			Remotes.fireServer("ToggleBreak")
			indicateOffJobBreak() -- equivalent call inferred; original call site unknown
		end

		wait(0.3)
		v3 = false
	end
end)
jobs.OnClientEvent:connect(function(p, value)
	if p == "WrongLockerJob" then
		local v15 = "Must be " .. (typeof(value) ~= "string" and "Student" or value)
		spawn(function()
			TweenMessageSmall(v15)
		end)
	elseif p == "LockerOwned" then
		spawn(function()
			TweenMessageSmall("Locker Owned")
		end)
	elseif p == "AlreadyHaveLocker" then
		spawn(function()
			TweenMessageSmall("You own a Locker")
		end)
	end
end)
local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "Job")

if playerBagInstance then
	playerBagInstance:WaitForChild("JobName").Changed:Connect(function()
		indicateOffJobBreak() -- equivalent call inferred; original call site unknown
	end)
end

local v15 = false
local v16 = false
local animations = script:WaitForChild("Animations")
local tracksByName = {}
local v17 = "None"
local v18 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function StopAll()
	for _, v19 in pairs(tracksByName) do
		v19:Stop()
	end
end

function HorseRun(player, object)
	while v16 == true do
		wait(0.05)

		if not (player ~= nil and player.Character ~= nil) then
			continue
		end

		local v19 = math.max(15, player.Character.Head.Velocity.magnitude)
		object:AdjustSpeed(v18 and 1 or v19 / 10)
	end
end

local function ChangeState(p)
	if v17 ~= p then
		v16 = false
		StopAll() -- equivalent call inferred; original call site unknown
		v17 = p

		if tracksByName[v17] and v17 ~= "Walk" and v17 ~= "Trot" and v17 ~= "Canter" and v17 ~= "Gallop" then
			if v17 == "Jump" then
				if not tracksByName[v17].IsPlaying then
					tracksByName[v17]:Play(nil, nil, v18 and 1 or 3)
				end
			elseif v17 ~= "Fall" then
				tracksByName[v17]:Play(nil, nil, v18 and 1 or 3)
			elseif not tracksByName[v17].IsPlaying then
				tracksByName[v17]:Play(0.25, nil, v18 and 1 or 3)
			end
		else
			local v19 = tracksByName[v17]
			v16 = true
			spawn(function()
				HorseRun(localPlayer, v19)
			end)

			if v17 == "Canter" then
				v19:Play(nil, nil, 1.5)
			else
				v19:Play(nil, nil, v18 and 1 or 0)
			end
		end
	end
end

function renderHorse(p, instance)
	local exitHorse = mainGUIHandler:WaitForChild("NoMotorControlHolder"):WaitForChild("HorseControl"):WaitForChild("ExitHorse")
	local horseSpeed = localPlayer.PlayersBag:FindFirstChild("HorsePass"):FindFirstChild("HorseSpeed")
	local humanoid2 = instance:WaitForChild("Humanoid")

	while v15 == true do
		if humanoid2.FloorMaterial == Enum.Material.Air then
			if p.Velocity.Y < 0.05 or v15 ~= true then
				ChangeState("Fall")
			else
				exitHorse.Visible = false
				ChangeState("Jump")
			end
		elseif Vector3.new(p.Velocity.X, 0, p.Velocity.Z).Magnitude > 1 and v15 == true then
			ChangeState(horseSpeed.Value <= 10 and "Walk" or horseSpeed.Value > 10 and horseSpeed.Value <= 20 and "Trot" or horseSpeed.Value > 20 and horseSpeed.Value <= 35 and "Canter" or "Gallop")
			exitHorse.Visible = false
		else
			ChangeState("Idle")
			exitHorse.Visible = true
		end

		wait()
		previousVelocity = p.Velocity
	end
end

local flag = false

local function requestHorseDismount()
	if v14 or not v15 then
		return
	end

	v14 = true
	v15 = false
	PanelController.Close("MainGUIHandler", "HorseControl")
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	horseRemote:FireServer("HorseDismount")
	wait(2)
	StopAll() -- equivalent call inferred; original call site unknown
	v14 = false
end

function registerListener()
	if flag then
		return
	end

	flag = true
	mainGUIHandler:WaitForChild("NoMotorControlHolder"):WaitForChild("HorseControl"):WaitForChild("ExitHorse").MainOpen.Dismount.MouseButton1Click:connect(requestHorseDismount)
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonX and not v14 then
			if not v15 then
				return
			end

			v14 = true
			v15 = false
			PanelController.Close("MainGUIHandler", "HorseControl")
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			horseRemote:FireServer("HorseDismount")
			wait(2)
			StopAll() -- equivalent call inferred; original call site unknown
			v14 = false
		end
	end)
end

horseRemote.OnClientEvent:Connect(function(p)
	if p == "CheckPlayeForHorse" then
		if humanoid.WalkSpeed ~= 0 and animationPlaying.Value == false and not (EmotesController.IsPlayingEmote() or localPlayer.Character.LowerTorso:FindFirstChild("Client_To_ClientWeld")) then
			horseRemote:FireServer("PlayerReadyForHorse")
		end
	elseif p == "TurnOnHorseMountButton" then
		if game.Workspace.Vehicles:FindFirstChild(localPlayer.Name .. "Horse") ~= nil then
			local child = game.Workspace.Vehicles:FindFirstChild(localPlayer.Name .. "Horse")
			child.MountButton.GUI.Enabled = true
			child.MountButton.ClickDetector.MaxActivationDistance = 10
		end
	elseif p == "HorseStart" then
		if localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") then
			local humanoid2 = localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse"):FindFirstChild("Humanoid")
			local animation = Instance.new("Animation")
			animation.Name = "LocalAnimation"
			animation.AnimationId = "rbxassetid://97603241185761"
			local track2 = humanoid2:LoadAnimation(animation)
			track2:Play()
			track2:Stop()
		end

		if localPlayer.Character.Humanoid ~= nil then
			task.spawn(function()
				EmotesController.StopEmote()
			end)
			PanelController.Close("MainGUIHandler", "HouseControlPanel")
			local horseControl = mainGUIHandler:WaitForChild("NoMotorControlHolder"):WaitForChild("HorseControl")
			PanelController.Open("MainGUIHandler", "HorseControl")
			registerListener()
			horseControl.LocalHorseControl.Disabled = false
			local horsePass = localPlayer.PlayersBag:FindFirstChild("HorsePass")

			if horsePass ~= nil then
				local horseSpeed = horsePass:FindFirstChild("HorseSpeed")

				if horseSpeed ~= nil then
					humanoid.WalkSpeed = horseSpeed.Value
					localPlayer.Character:SetAttribute("HorseSpeed", horseSpeed.Value)
				end
			end

			humanoid.JumpPower = 70
			track:Play()

			if localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") then
				local child = localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse")
				child.MountButton.GUI.Enabled = false
				child.MountButton.ClickDetector.MaxActivationDistance = 0
				local humanoid2 = child:FindFirstChild("Humanoid")
				animations = child:WaitForChild("Animations")
				v18 = child:GetAttribute("LockAnimationSpeed") == true

				for _, animation in pairs(animations:GetChildren()) do
					tracksByName[animation.Name] = humanoid2:LoadAnimation(animation)
				end

				v15 = true
				tick()
				horseRemote:FireServer(localPlayer)
				renderHorse(child.PrimaryPart, child)
			end
		end
	elseif p == "HorseDismountPlayer" then
		v15 = false

		if track then
			track:Stop()
		end

		localPlayer.Character.Humanoid.Jump = true
		humanoid.CameraOffset = createVector(0, 0, 0)
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		PanelController.Close("MainGUIHandler", "HorseControl")
		local horseControl_2 = mainGUIHandler:WaitForChild("NoMotorControlHolder"):WaitForChild("HorseControl")
		horseControl_2.LocalHorseControl.Disabled = true
		task.wait(2)

		if game.Workspace.Vehicles:FindFirstChild(localPlayer.Name .. "Horse") ~= nil then
			local child = game.Workspace.Vehicles:FindFirstChild(localPlayer.Name .. "Horse")
			child.MountButton.GUI.Enabled = true
			child.MountButton.ClickDetector.MaxActivationDistance = 10
		end
	end
end)
schoolDryBoards.OnClientEvent:Connect(function(p, p2)
	if p == "AskBoardNameGUI" then
		cemeteryName.Visible = true
		cemeteryName.A.B.C.D.FocusLost:connect(function()
			if v8 == false then
				v8 = true
				schoolDryBoards:FireServer("ReturningBoardName", p2, cemeteryName.A.B.C.D.Text)
				cemeteryName.Visible = false
				cemeteryName.A.B.C.D.Text = ""
				wait(0.5)
				v8 = false
			end
		end)
	elseif p == "AskFilmCode" then
		codeName.Visible = true
		codeName.A.B.C.D.FocusLost:connect(function()
			if v5 == false then
				v5 = true
				schoolDryBoards:FireServer("ReturningFilmCode", codeName.A.B.C.D.Text)
				codeName.Visible = false
				codeName.A.B.C.D.Text = ""
				wait(0.5)
				v5 = false
			end
		end)
	end
end)

function RunCarriedOnSubway()
	blackScreen.Visible = true

	for i = 1, 0, -0.05 do
		wait(0.02)
		blackScreen.BackgroundTransparency = i
	end

	blackScreen.BackgroundTransparency = 0
	wait(4)

	for i = 0, 1, 0.05 do
		wait(0.02)
		blackScreen.BackgroundTransparency = i
	end

	blackScreen.Visible = false
end

function FadeBlack()
	downtown.Visible = false
	lake.Visible = false
	blackhawk.Visible = false
	crownPointe.Visible = false
	close.Visible = false
	blackScreen.Visible = true

	for i = 1, 0, -0.05 do
		wait(0.02)
		blackScreen.BackgroundTransparency = i
	end

	blackScreen.BackgroundTransparency = 0
end

function FadeClear()
	for i = 0, 1, 0.05 do
		wait(0.02)
		blackScreen.BackgroundTransparency = i
	end

	blackScreen.Visible = false
	downtown.Visible = true
	lake.Visible = true
	blackhawk.Visible = true
	crownPointe.Visible = true
	close.Visible = true
end

close.MouseButton1Click:Connect(function()
	subwayStationMenu.Visible = false
end)
maxy.OnClientEvent:Connect(function(p)
	if p == "SubwayMovingLocationBlack" then
		subway:Play()
		FadeBlack()
	elseif p == "SubwayMovingLocationClear" then
		FadeClear()
	elseif p == "SubwaySitTurnOnStation" then
		subwayStationMenu.Visible = true
	elseif p == "SubwaySitTurnOffStation" then
		subwayStationMenu.Visible = false
	elseif p == "SubwayBlackoutWhileBeingCarried" then
		subway:Play()
		RunCarriedOnSubway()
	end
end)
lake.MouseButton1Click:Connect(function()
	if v9 == false then
		v9 = true
		local value = subwaySeatNumber.Value
		local value2 = subwayStation.Value

		if subwayStation.Value ~= "Lake" then
			maxy:FireServer("SubwayMove", "Lake", value, value2)
		end

		wait(0.5)
		v9 = false
	end
end)
downtown.MouseButton1Click:Connect(function()
	if v10 == false then
		v10 = true
		local value = subwaySeatNumber.Value
		local value2 = subwayStation.Value

		if subwayStation.Value ~= "Downtown" then
			maxy:FireServer("SubwayMove", "Downtown", value, value2)
		end

		wait(0.5)
		v10 = false
	end
end)
blackhawk.MouseButton1Click:Connect(function()
	if v12 == false then
		v12 = true
		local value = subwaySeatNumber.Value
		local value2 = subwayStation.Value

		if subwayStation.Value ~= "Blackhawk" then
			maxy:FireServer("SubwayMove", "Blackhawk", value, value2)
		end

		wait(0.5)
		v12 = false
	end
end)
crownPointe.MouseButton1Click:Connect(function()
	if v11 == false then
		v11 = true
		local value = subwaySeatNumber.Value
		local value2 = subwayStation.Value

		if subwayStation.Value ~= "Crown" then
			maxy:FireServer("SubwayMove", "Crown", value, value2)
		end

		wait(0.5)
		v11 = false
	end
end)
maxy.OnClientEvent:Connect(function(p)
	if p == "PlaneTurnOnTurbulance" then
		planeSound:Play()
		planeShaker.Disabled = false
	elseif p == "PlaneTurnOffTurbulance" then
		planeSound:Stop()
		planeShaker.Disabled = true
		wait(0.1)
		shaker.Disabled = true
	elseif p == "PlaneTurnOffTurbulancePlayWind" then
		windDiving.PlaybackSpeed = 2
		windDiving.Volume = 0.35
		windDiving:Play()
		planeSound:Stop()
		planeShaker.Disabled = true
		wait(0.1)
		shaker.Disabled = true
	elseif p == "SecretsYellowVision" and v13 == false then
		v13 = true
		agencyPool:Play()
		game.Lighting.FogColor = Color3.fromRGB(56, 56, 27)
		game.Lighting.FogEnd = 15
		game.Lighting.FogStart = 0
		wait(2)
		game.Lighting.FogColor = Color3.fromRGB(208, 208, 208)
		game.Lighting.FogEnd = 100000
		game.Lighting.FogStart = 1
		v13 = false
	end
end)
settingsMain.SettingsMenu.Catalog.Container.Frame.Cam.Activated:Connect(function()
	if v6 == false then
		if FreeCamController.IsFreecamEnabled() then
			return
		end

		v6 = true
		local v19 = not mainGUIHandler.Enabled
		mainGUIHandler.Enabled = v19
		noResetGUIHandler.TopCornerDetails.Visible = v19
		local houseNumber = localPlayer.PlayersBag:FindFirstChild("HouseNumber")
		noResetGUIHandler.HouseKey.House.Value.Visible = v19 and houseNumber and houseNumber.Value ~= 0
		local lego2026 = playerGui:FindFirstChild("Lego2026")

		if lego2026 then
			lego2026.Enabled = v19
		end

		NotificationController.NotifyCenterAlwaysVisible(
			v19 and "UI elements are now visible!" or "UI elements hidden!",
			nil,
			nil,
			"uiElementsVisible"
		)
		local eggHunts = playerGui:FindFirstChild("EggHunts")

		if eggHunts then
			local eggsCollected = eggHunts:FindFirstChild("EggsCollected")

			if eggsCollected and eggsCollected.Visible then
				eggHunts.Enabled = v19
			end
		end

		task.wait(0.5)
		v6 = false
	end
end)
settingsMain.SettingsMenu.Catalog.Container.Frame.FreeCam.Activated:Connect(function()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid2

	if character then
		humanoid2 = character:FindFirstChild("Humanoid")
	end

	if humanoid2 and humanoid2.Health == 0 then
		return
	end

	if v7 == false then
		v7 = true
		FreeCamController.ToggleFreeCam()
		v7 = false
	end
end)
settingsMain.Settings.Frame.Frame.Open.Activated:Connect(function()
	if not FreeCamController.HasValidFreecamModule() then
		settingsMain.SettingsMenu.Catalog.Container.Frame.FreeCam.Visible = false
	end

	PanelController.Close("MainGUIHandler", "StarterInstructions")
end)
settingsMain.SettingsMenu.Catalog.Container.Frame.FreeCam.Visible = Permissions.hasAdminAccess(localPlayer)
flying.OnClientEvent:Connect(function(p)
	if p == "OpenServerOwner" then
		settingsMain.SettingsMenu.Catalog.Container.Frame.FreeCam.Visible = true
	end
end)

function TweenPhoneSide()
	if phoneCall.Visible == false then
		spawn(function()
			ClientMessage("Incoming call for service / Player sharing location")
		end)
		cellRinging:Play()
		phoneCall.Visible = true
		phoneCall.Position = UDim2.new(-0.4, 0, 0.4, 0)
		phoneCall:TweenPosition(UDim2.new(0.13, 0, 0.4, 0), "InOut", "Sine", 0.5, true)
		wait(6)
		phoneCall:TweenPosition(UDim2.new(-0.4, 0, 0.4, 0), "InOut", "Sine", 0.5, true)
		wait(1)
		phoneCall.Visible = false
	end
end

function MoveArrowUpDown(object, instance)
	local v19 = 140

	while v19 > 0 do
		v19 -= 1
		object:TweenPosition(UDim2.new(0, 0, 0, 10), "Out", "Sine", 0.2)
		wait(0.21)
		object:TweenPosition(UDim2.new(0, 0, 0, -10), "Out", "Sine", 0.2)
		wait(0.21)

		if v19 <= 0 then
			instance:Destroy()
		end
	end
end

jobs.OnClientEvent:Connect(function(p, p2)
	if p == "TurnOnArrowClientLocally" then
		local children = game.Players:GetChildren()

		for _, v19 in children do
			if not (v19 ~= nil and v19 == p2) then
				continue
			end

			local clone = game.ReplicatedStorage.UiClone.PhoneInCharacter:Clone()

			if not (v19.Character ~= nil and v19.Character:FindFirstChild("Head") ~= nil and v19.Character.Head:FindFirstChild("Arrow") == nil) then
				continue
			end

			local head = v19.Character.Head
			clone.Name = "Arrow"
			clone.Parent = head
			spawn(function()
				TweenPhoneSide()
			end)
			wait(0.2)

			if head:FindFirstChild("Arrow") == nil then
				continue
			end

			local arrow = head:FindFirstChild("Arrow")
			local v20 = arrow:FindFirstChild("ArrowImage")
			spawn(function()
				MoveArrowUpDown(v20, arrow)
			end)
		end
	end
end)
humanoid.Died:connect(function()
	PanelController.Close("MainGUIHandler", "HorseControl")
	local child = localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse")

	if child ~= nil then
		child:Destroy()
	end
end)
maxy.OnClientEvent:Connect(function(p, p2)
	if p == "SubmarineCamOpen" then
		if p2 ~= nil then
			subCamObject.Value = p2

			if submarineCam.Visible == false then
				submarineCam.Visible = true
				currentCamera.CameraSubject = p2["Camera" .. 1]
				currentCamera.CameraType = "Scriptable"
				currentCamera.CFrame = p2["Camera" .. 1].CFrame
			end
		end
	elseif p == "SubmarineCamClose" and localPlayer and localPlayer.Character then
		submarineCam.Visible = false
		local humanoid2 = localPlayer.Character:FindFirstChild("Humanoid")

		if humanoid2 ~= nil then
			currentCamera.CameraSubject = humanoid2
			currentCamera.CameraType = "Custom"
		end
	end
end)
submarineCam.HouseCamsUI.Picks.Frame.Left.MouseButton1Click:connect(function()
	local value = subCameraNumber.Value

	if value == subCameraNumberTotal.Value then
		subCameraNumber.Value = 0
		value = 0
	end

	if subCamObject.Value:FindFirstChild("Camera" .. value + 1) then
		local v19 = value + 1
		subCameraNumber.Value += 1
		currentCamera.CameraSubject = subCamObject.Value["Camera" .. v19]
		currentCamera.CameraType = "Scriptable"
		currentCamera.CFrame = subCamObject.Value["Camera" .. v19].CFrame
	end
end)
submarineCam.HouseCamsUI.Picks.Frame.Right.MouseButton1Click:connect(function()
	local value = subCameraNumber.Value

	if value == 1 then
		value = subCameraNumberTotal.Value + 1
		subCameraNumber.Value = subCameraNumberTotal.Value + 1
	end

	if subCamObject.Value:FindFirstChild("Camera" .. value - 1) then
		local v19 = value - 1
		subCameraNumber.Value -= 1
		currentCamera.CameraSubject = subCamObject.Value["Camera" .. v19]
		currentCamera.CameraType = "Scriptable"
		currentCamera.CFrame = subCamObject.Value["Camera" .. v19].CFrame
	end
end)
noResetGUIHandler.Enabled = true
localPlayer.CameraMode = Enum.CameraMode.Classic
localPlayer.CameraMinZoomDistance = 10
localPlayer.CameraMaxZoomDistance = 10
localPlayer.CameraMinZoomDistance = 0.5
localPlayer.CameraMaxZoomDistance = 128
workspace.CurrentCamera.FieldOfView = 70