local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local child = workspace:WaitForChild(localPlayer.Name)
local humanoid = child:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local game8Settings = script.Parent:WaitForChild("Game8Settings")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local module = require(game8Settings)
local maxy = module.Maxy
local props = module.Props
local clientInfo = module.ClientInfo
local horseRemote = module.HorseRemote
local noResetGUIHandler = playerGui:WaitForChild("NoResetGUIHandler")
local settingsMain = playerGui:WaitForChild("SettingsMain")
local sprint = noResetGUIHandler:WaitForChild("Sprint")
local settingsMenu = settingsMain:WaitForChild("SettingsMenu")
local mobileSprint = noResetGUIHandler:WaitForChild("MobileSprint")
local propMenuFilter = noResetGUIHandler:WaitForChild("PropMenuFilter")
local propsColor = propMenuFilter:WaitForChild("PropsColor")
local propsModMenu = propMenuFilter:WaitForChild("PropsModMenu")
local colorPicks = propsColor:WaitForChild("ColorPicks")
local colorPicksFrame = colorPicks:WaitForChild("ColorPicksFrame")
local finalColorA = colorPicksFrame:WaitForChild("FinalColorA")
local darknessBarD = colorPicksFrame:WaitForChild("DarknessBarD")
local blockerC = colorPicksFrame:WaitForChild("BlockerC")
local picksE = colorPicksFrame:WaitForChild("PicksE")
local paletteB = colorPicksFrame:WaitForChild("PaletteB")
local uIGradient = colorPicksFrame:WaitForChild("DarknessBarD"):WaitForChild("UIGradient")
local hue = script:WaitForChild("Hue")
local hue2 = script:WaitForChild("Hue")
local saturation = script:WaitForChild("Saturation")
local value = script:WaitForChild("Value")
local color = Color3.new(0, 0, 0)
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local track = humanoid:LoadAnimation((script.Parent:WaitForChild("DrumAnimation")))
local track2 = humanoid:LoadAnimation((script.Parent:WaitForChild("PianoAnimation")))
horseRemote.OnClientEvent:Connect(function(p, p2)
	if p == "PlayingDrums" then
		if localPlayer ~= nil and track then
			track:Play(nil, nil, p2)
		end
	elseif p == "KillDrums" then
		if localPlayer ~= nil then
			local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in pairs(playingAnimationTracks) do
				if playingAnimationTrack.Name == "DrumAnimation" then
					playingAnimationTrack:Stop()
				end
			end
		end
	elseif p == "PlayingPiano" then
		if localPlayer ~= nil and track2 then
			track2:Play(nil, nil, p2)
		end
	elseif p == "KillPiano" and localPlayer ~= nil then
		local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack.Name == "PianoAnimation" then
				playingAnimationTrack:Stop()
			end
		end
	end
end)
colorPicks.ColorPicksFrame.PicksE.Close.MouseButton1Down:connect(function()
	if v2 == false then
		v2 = true
		finalColorA.Visible = false
		darknessBarD.Visible = false
		picksE.Visible = false
		paletteB.Visible = false
		wait(0.2)
		blockerC.Visible = false
		wait(0.2)
		v2 = false
	end
end)

if UserInputService.GamepadEnabled then
	paletteB.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v7 in gamepadState do
			if not (v7.KeyCode == Enum.KeyCode.ButtonA and v7.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			local v8 = (p.Position.X - paletteB.AbsolutePosition.X) / paletteB.AbsoluteSize.X
			local v9 = (p.Position.Y - paletteB.AbsolutePosition.Y) / paletteB.AbsoluteSize.Y
			local v10 = math.sqrt((v8 - 0.5) ^ 2 + (v9 - 0.5) ^ 2)

			if v10 > 0.5 then
				v8 = (v8 - 0.5) / v10 * 0.5 + 0.5
				v9 = (v9 - 0.5) / v10 * 0.5 + 0.5
				v10 = 0.5
			end

			local v11 = math.atan2(v9 - 0.5, v8 - 0.5)
			local v12 = (3.141592653589793 - v11) / 6.283185307179586
			hue2.Value = v12
			saturation.Value = v10 * 2
			finalColorA.BackgroundColor3 = Color3.fromHSV(v12, v10 * 2, value.Value)
			uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v12, v10 * 2, 1))
		end
	end)
end

if UserInputService.GamepadEnabled then
	darknessBarD.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v7 in gamepadState do
			if not (v7.KeyCode == Enum.KeyCode.ButtonA and v7.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			value.Value = 1 - math.clamp(
				(p.Position.Y - darknessBarD.AbsolutePosition.Y) / darknessBarD.AbsoluteSize.Y,
				0,
				1
			)
			finalColorA.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
		end
	end)
end

paletteB.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local v7 = (input.Position.X - paletteB.AbsolutePosition.X) / paletteB.AbsoluteSize.X
		local v8 = (input.Position.Y - paletteB.AbsolutePosition.Y) / paletteB.AbsoluteSize.Y
		local v9 = math.sqrt((v7 - 0.5) ^ 2 + (v8 - 0.5) ^ 2)

		if v9 > 0.5 then
			v7 = (v7 - 0.5) / v9 * 0.5 + 0.5
			v8 = (v8 - 0.5) / v9 * 0.5 + 0.5
			v9 = 0.5
		end

		local v10 = math.atan2(v8 - 0.5, v7 - 0.5)
		local v11 = (3.141592653589793 - v10) / 6.283185307179586
		hue2.Value = v11
		saturation.Value = v9 * 2
		finalColorA.BackgroundColor3 = Color3.fromHSV(v11, v9 * 2, value.Value)
		uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v11, v9 * 2, 1))
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
darknessBarD.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		value.Value = 1 - math.clamp(
			(input.Position.Y - darknessBarD.AbsolutePosition.Y) / darknessBarD.AbsoluteSize.Y,
			0,
			1
		)
		finalColorA.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
finalColorA.MouseButton1Click:Connect(function()
	if v3 == false then
		v3 = true
		props:FireServer("ChangePropColor", finalColorA.BackgroundColor3)
		wait(1)
		v3 = false
	end
end)
propsModMenu.C.D.MouseButton1Click:connect(function()
	if v == false then
		v = true

		if blockerC.Visible == false then
			finalColorA.Visible = true
			darknessBarD.Visible = true
			picksE.Visible = true
			paletteB.Visible = true
			blockerC.Visible = true
		else
			finalColorA.Visible = false
			darknessBarD.Visible = false
			picksE.Visible = false
			paletteB.Visible = false
			blockerC.Visible = false
		end

		wait(0.5)
		v = false
	end
end)
props.OnClientEvent:connect(function(p)
	if p == "OpenLocalPropSettings" then
		propsModMenu.Visible = true
		finalColorA.Visible = false
		darknessBarD.Visible = false
		picksE.Visible = false
		paletteB.Visible = false
		blockerC.Visible = false
	elseif p == "CloseLocalPropSettings" then
		propsModMenu.Visible = false
		finalColorA.Visible = false
		darknessBarD.Visible = false
		picksE.Visible = false
		paletteB.Visible = false
		blockerC.Visible = false
	end
end)
settingsMenu.Catalog.Container.Frame.Carseat.Boy.MouseButton1Click:connect(function()
	if v4 == false then
		v4 = true

		if settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible == false then
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = true
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = false
			maxy:FireServer("CarSeatBoyRequestedOn")
			NotificationController.NotifyCenter("Baby (Blue) added to your vehicles!", nil, nil, "babyCarSeatOn")
		else
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = false
			maxy:FireServer("CarSeatBoyRequestedOff")
			NotificationController.NotifyCenter("Baby (Blue) removed from your vehicles!", nil, nil, "babyCarSeatOff")
		end

		wait(0.5)
		v4 = false
	end
end)
settingsMenu.Catalog.Container.Frame.Carseat.Girl.MouseButton1Click:connect(function()
	if v5 == false then
		v5 = true

		if settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible == false then
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = true
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = false
			maxy:FireServer("CarSeatGirlRequestedOn")
			NotificationController.NotifyCenter("Baby (Pink) added to your vehicles!", nil, nil, "babyCarSeatOn")
		else
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = false
			maxy:FireServer("CarSeatGirlRequestedOff")
			NotificationController.NotifyCenter("Baby (Pink) removed from your vehicles!", nil, nil, "babyCarSeatOff")
		end

		wait(0.5)
		v5 = false
	end
end)
settingsMenu.Catalog.Container.Frame.MobileSprint.MouseButton1Click:connect(function()
	if v6 == false then
		v6 = true

		if settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible == false then
			settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible = true

			if UserInputService.TouchEnabled then
				mobileSprint.PlatformVisibility.Nothing.Speed.Visible = true
				sprint.Value = true
			end

			maxy:FireServer("MobileSprintRequestedOn")
			NotificationController.NotifyCenter("Mobile Sprint enabled!", nil, nil, "mobileSprint")
		else
			sprint.Value = false
			settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible = false
			mobileSprint.PlatformVisibility.Nothing.Speed.Visible = false
			maxy:FireServer("MobileSprintRequestedOff")
			NotificationController.NotifyCenter("Mobile Sprint disabled!", nil, nil, "mobileSprint")
		end

		wait(0.5)
		v6 = false
	end
end)
clientInfo.OnClientEvent:Connect(function(p, p2, p3)
	if p == "SetUpSettingLocal" and localPlayer ~= nil then
		if p2 ~= nil and p2 == 0 then
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = false
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = false
		end

		if p2 ~= nil and p2 == 1 then
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = true
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = false
		end

		if p2 ~= nil and p2 == 2 then
			settingsMenu.Catalog.Container.Frame.Carseat.Boy.GreenCheckMark.Visible = false
			settingsMenu.Catalog.Container.Frame.Carseat.Girl.GreenCheckMark.Visible = true
		end

		if p3 == nil or p3 ~= true or not UserInputService.TouchEnabled then
			if p3 ~= nil and p3 == true then
				settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible = true
			end
		else
			noResetGUIHandler.Sprint.Value = true
			settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible = true
			mobileSprint.PlatformVisibility.Nothing.Speed.Visible = true
		end

		if p3 ~= nil and p3 == false then
			noResetGUIHandler.Sprint.Value = false
			settingsMenu.Catalog.Container.Frame.MobileSprint.GreenCheckMark.Visible = false
			mobileSprint.PlatformVisibility.Nothing.Speed.Visible = false
		end
	end
end)
mobileSprint.PlatformVisibility.Nothing.Speed.InputBegan:connect(function(_)
	if child ~= nil and child.Humanoid.WalkSpeed ~= 0 and not child:FindFirstChild(localPlayer.Name .. "Horse") and not child:FindFirstChild("NoMotorVehicleModel") and child:FindFirstChild("LowerTorso") ~= nil and child.LowerTorso:FindFirstChild("SprintDust") ~= nil then
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 24

		if child.Humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
			child.LowerTorso.SprintDust.Enabled = true
		end
	end
end)
mobileSprint.PlatformVisibility.Nothing.Speed.InputEnded:connect(function(_, _)
	if child ~= nil and child.Humanoid.WalkSpeed ~= 0 then
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16

		if child ~= nil and child:FindFirstChild("LowerTorso") ~= nil and child.LowerTorso:FindFirstChild("SprintDust") ~= nil then
			child.LowerTorso.SprintDust.Enabled = false
		end
	end
end)

if UserInputService.TouchEnabled and sprint.Value == true then
	mobileSprint.PlatformVisibility.Nothing.Speed.Visible = true
end