local ConsoleControls = {
	isNavigationEnabled = true,
	isUsingCustomNavigation = false
}
local ContextActionService = game:GetService("ContextActionService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ActivePanels = require(ReplicatedStorage.Modules.Client.UI.ActivePanels)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local HUDButtonSelectionTracker = require(ReplicatedStorage.Modules.Client.UI.HUDButtonSelectionTracker)
local MainButtonPopout = require(ReplicatedStorage.Modules.Client.Components.UI.MainButtonPopout)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = false
local flag = false
local v2 = Enum.ContextActionPriority.High.Value - 1

local function getCharacterHumanoid()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return character, humanoid
	end

	return nil, nil
end

local function setSprintState(enabled: boolean)
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			character = nil
			humanoid = nil
		end
	else
		character = nil
	end

	if not (character and humanoid) or humanoid.WalkSpeed == 0 or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
		return false
	end

	if character:FindFirstChild("NoMotorVehicleModel") then
		return false
	end

	local lowerTorso = character:FindFirstChild("LowerTorso")

	if not lowerTorso then
		return false
	end

	local sprintDust = lowerTorso:FindFirstChild("SprintDust")

	if not sprintDust then
		return false
	end

	humanoid.WalkSpeed = enabled and 24 or 16

	if sprintDust:IsA("ParticleEmitter") then
		sprintDust.Enabled = enabled
	end

	return true
end

local function clearSprintState()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			humanoid = nil
			character = nil
		end
	else
		character = nil
	end

	if humanoid and humanoid.WalkSpeed ~= 0 then
		humanoid.WalkSpeed = 16
	end

	if not character then
		return
	end

	local lowerTorso = character:FindFirstChild("LowerTorso")

	if not lowerTorso then
		return
	end

	local sprintDust = lowerTorso:FindFirstChild("SprintDust")

	if sprintDust and sprintDust:IsA("ParticleEmitter") then
		sprintDust.Enabled = false
	end
end

local function getHudSelectionTargets()
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil, nil, nil, nil
	end

	local mainGUIHandler = playerGui:FindFirstChild("MainGUIHandler")
	local noResetGUIHandler = playerGui:FindFirstChild("NoResetGUIHandler")
	local settingsMain = playerGui:FindFirstChild("SettingsMain")
	local mainButtons = mainGUIHandler and mainGUIHandler:FindFirstChild("MainButtons")
	local shopButtons = mainGUIHandler and mainGUIHandler:FindFirstChild("ShopButtons")
	local topCornerDetails = noResetGUIHandler and noResetGUIHandler:FindFirstChild("TopCornerDetails")
	local settings = settingsMain and settingsMain:FindFirstChild("Settings")

	if not (mainButtons and mainButtons:IsA("GuiObject")) then
		mainButtons = nil
	end

	if not (shopButtons and shopButtons:IsA("GuiObject")) then
		shopButtons = nil
	end

	if not (topCornerDetails and topCornerDetails:IsA("GuiObject")) then
		topCornerDetails = nil
	end

	if settings and settings:IsA("GuiObject") then
		return mainButtons, shopButtons, topCornerDetails, settings
	end

	return mainButtons, shopButtons, topCornerDetails, nil
end

local function tryRestoreHudSelection(flag2: boolean?)
	if not (Platform.IsConsole() and BackActionRouter.IsEmpty() and ActivePanels.Peek() == nil) then
		return
	end

	local selectedObject = GuiService.SelectedObject

	if flag2 ~= true and selectedObject ~= nil and selectedObject.Parent ~= nil then
		return
	end

	local lastClickedButton = HUDButtonSelectionTracker.GetLastClickedButton()

	if lastClickedButton ~= nil and lastClickedButton.Visible == true then
		Platform.Select(lastClickedButton)

		if GuiService.SelectedObject == lastClickedButton then
			return
		end
	end

	local v3 = select(1, getHudSelectionTargets())

	if v3 then
		Platform.Select(v3)
	end
end

local function getConsoleControlsAB()
	local v3, v4 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	local v5, v6 = ABTest.GetExperimentVariable("console-controls", "cursor"):timeout(7):await()
	return not v3 or v4, not v5 or v6
end

local function getDpadControlsAB()
	local v3, v4 = ABTest.GetExperimentVariables("console-controls"):timeout(7):await()

	if v3 then
		return v4.dpadNavigation, v4.dpadBinds
	end

	return false, false
end

function ConsoleControls.FrameworkStart()
	local v3 = false
	local v4 = false
	local v5 = false
	local count = 0
	local consoleControlsAB, v6 = getConsoleControlsAB()
	ConsoleControls.isNewControlsEnabled = consoleControlsAB
	local v7, v8 = ABTest.GetExperimentVariables("console-controls"):timeout(7):await()
	local dpadNavigation, dpadBinds

	if v7 then
		dpadNavigation = v8.dpadNavigation
		dpadBinds = v8.dpadBinds
	else
		dpadNavigation = false
		dpadBinds = false
	end

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonL3 then
			v = setSprintState(true)
			return
		end

		if input.KeyCode ~= Enum.KeyCode.ButtonX or flag or not (EmotesController.IsPlayingEmote() or EmotesController.HasExternalCancelHandler()) then
			return
		end

		flag = true
		EmotesController.StopEmote()
		task.delay(0.5, function()
			flag = false
		end)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonL3 and v == true) then
			return
		end

		v = false
		clearSprintState()
	end)
	ContextActionService:BindActionAtPriority("PlatformSelect", function(_, p)
		if p == Enum.UserInputState.Begin then
			if v6 then
				if GamepadService.GamepadCursorEnabled then
					GamepadService:DisableGamepadCursor()
				else
					ConsoleControls.isUsingCustomNavigation = false
					Platform.Select(nil)
					GamepadService:EnableGamepadCursor(nil)
				end

				return Enum.ContextActionResult.Sink
			elseif GamepadService.GamepadCursorEnabled then
				GamepadService:DisableGamepadCursor()
				ConsoleControls.isUsingCustomNavigation = false
				return Enum.ContextActionResult.Sink
			else
				local selectedObject = GuiService.SelectedObject
				v5 = selectedObject ~= nil and selectedObject.Parent ~= nil
				v3 = true
				v4 = false
				count += 1
				local v10 = count
				task.delay(0.35, function()
					if v10 ~= count or v3 ~= true or GamepadService.GamepadCursorEnabled then
						return
					end

					local selectedObject2 = GuiService.SelectedObject

					if selectedObject2 == nil or selectedObject2.Parent == nil then
						Platform.Select(nil)
						GamepadService:EnableGamepadCursor(nil)
					else
						GamepadService:EnableGamepadCursor(selectedObject2)
						Platform.Select(nil)
					end

					v4 = true
				end)
				return Enum.ContextActionResult.Sink
			end
		else
			if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel or not consoleControlsAB or v3 ~= true then
				return Enum.ContextActionResult.Pass
			end

			v3 = false

			if v4 == true then
				return Enum.ContextActionResult.Sink
			end

			if v5 == true then
				local selectedObject = GuiService.SelectedObject

				if selectedObject ~= nil and selectedObject.Parent ~= nil then
					Platform.Select(nil)
					return Enum.ContextActionResult.Sink
				end
			end

			local v9 = ActivePanels.Peek()

			if v9 == nil then
				local v10 = select(1, getHudSelectionTargets())

				if v10 ~= nil then
					Platform.Select(v10)
					ConsoleControls.isUsingCustomNavigation = true
				end
			else
				Platform.Select(v9)
				ConsoleControls.isUsingCustomNavigation = true
			end

			return Enum.ContextActionResult.Sink
		end
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonSelect)

	local function onPlatformChanged(mode)
		if mode == "Controller" then
			if not v6 then
				Platform.Select(ActivePanels.Peek())
			end
		else
			v = false
			clearSprintState()
			v3 = false
			v4 = false
			v5 = false
			count += 1
			Platform.Select(nil)
			GamepadService:DisableGamepadCursor()
		end
	end

	Platform.PlatformChangedSignal:Connect(onPlatformChanged)
	onPlatformChanged(Platform.Mode)

	if not consoleControlsAB then
		return
	end

	BackActionRouter.OnBackActionHandled:Connect(function()
		task.defer(function()
			if dpadNavigation then
				if GamepadService.GamepadCursorEnabled or not ConsoleControls.isUsingCustomNavigation then
					return
				end

				tryRestoreHudSelection(true)
			elseif not ActivePanels.Peek() then
				Platform.EndSelection()
			end
		end)
	end)

	if dpadNavigation then
		ContextActionService:BindActionAtPriority("DPadSelect", function(_, p, p2)
			if p ~= Enum.UserInputState.Begin or GuiService.SelectedObject ~= nil and GuiService.SelectedObject.Parent ~= nil and GuiService.SelectedObject.Visible == true then
				return
			end

			local v9 = ActivePanels.Peek()

			if v9 then
				if not v6 then
					return
				end

				ConsoleControls.isUsingCustomNavigation = true
				Platform.Select(v9)
				return Enum.ContextActionResult.Sink
			else
				local keyCode = p2.KeyCode
				local hudSelectionTargets, v10, v11, v12 = getHudSelectionTargets()

				if keyCode == Enum.KeyCode.DPadRight then
					if hudSelectionTargets then
						Platform.Select(hudSelectionTargets)
					end
				elseif keyCode == Enum.KeyCode.DPadLeft then
					if v10 then
						Platform.Select(v10)
					end
				elseif keyCode == Enum.KeyCode.DPadUp then
					if v11 then
						Platform.Select(v11)
					end
				elseif keyCode == Enum.KeyCode.DPadDown and v12 then
					Platform.Select(v12)
				end

				ConsoleControls.isUsingCustomNavigation = true
			end
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.DPadRight, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown)
	end

	ContextActionService:BindActionAtPriority("ToggleQuickChat", function(_, p)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if PanelController.IsOpen("MainGUIHandler", "QuickChatPanel") then
			PanelController.Close("MainGUIHandler", "QuickChatPanel")
			return Enum.ContextActionResult.Sink
		end

		if not PanelController.IsOpen("MainGUIHandler", "QuickChatButton") then
			return Enum.ContextActionResult.Pass
		end

		PanelController.OpenPanelByContext("MainGUIHandler", "QuickChatPanel")
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonY)
	ContextActionService:BindActionAtPriority("ConsoleBackFallback", function(_, p)
		if p ~= Enum.UserInputState.Begin or not BackActionRouter.IsEmpty() or ActivePanels.Peek() then
			return Enum.ContextActionResult.Pass
		end

		local selectedObject = GuiService.SelectedObject

		if selectedObject == nil or selectedObject.Parent == nil then
			return Enum.ContextActionResult.Pass
		end

		Platform.Select(nil)
		ConsoleControls.isUsingCustomNavigation = false
		return Enum.ContextActionResult.Sink
	end, false, v2, Enum.KeyCode.ButtonB)

	if dpadBinds then
		local flag2 = false
		local _1Gettin1gHous1e = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Gettin1gHous1e")

		if _1Gettin1gHous1e and _1Gettin1gHous1e:IsA("RemoteEvent") then
			_1Gettin1gHous1e.OnClientEvent:Connect(function(p: string)
				if p == "HouseSold" then
					flag2 = false
				elseif p == "BuyHouseSetUpUI" then
					flag2 = true
				end
			end)
		end

		ContextActionService:BindActionAtPriority("DPadBinds", function(_, p, p2)
			if not (p == Enum.UserInputState.Begin and PanelController.IsOpen("MainGUIHandler", "MainButtons")) then
				return Enum.ContextActionResult.Pass
			end

			local keyCode = p2.KeyCode
			local v9 = "MainGUIHandler"
			local v10 = nil

			if keyCode == Enum.KeyCode.DPadUp then
				v9 = "NoResetGUIHandler"
				v10 = "MainToolMenuFilter"
			elseif keyCode == Enum.KeyCode.DPadLeft then
				v10 = "MainAnimationsMenu"
			elseif keyCode == Enum.KeyCode.DPadRight then
				v10 = "MainVehicleMenu"
			elseif keyCode == Enum.KeyCode.DPadDown then
				if flag2 then
					v10 = "MainHouseMenu"
				else
					v10 = "MainNoHouseMenu"
				end
			end

			if v9 == nil or v10 == nil then
				return Enum.ContextActionResult.Pass
			end

			if PanelController.IsOpen(v9, v10) then
				PanelController.Close(v9, v10)
			else
				PanelController.OpenPanelByContext(v9, v10)
				MainButtonPopout.Close()
			end

			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.DPadRight, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown)
	end
end

return ConsoleControls