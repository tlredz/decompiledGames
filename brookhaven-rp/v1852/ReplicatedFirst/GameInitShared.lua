game:GetService("GuiService")
local Players = game:GetService("Players")
local GameInitShared = {}

function GameInitShared.Setup()
	local Players2 = game:GetService("Players")
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	task.spawn(function()
		local playerGui = Players2.LocalPlayer.PlayerGui
		local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
		mainGUIHandler.Enabled = false
		local settingsMain = playerGui:WaitForChild("SettingsMain")
		settingsMain.Enabled = false
		local topCornerDetails = playerGui:WaitForChild("NoResetGUIHandler"):WaitForChild("TopCornerDetails")
		topCornerDetails.Visible = false
	end)
end

function GameInitShared.ShowUI()
	local Players2 = game:GetService("Players")
	local playerGui = Players2.LocalPlayer.PlayerGui
	local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	local settingsMain = playerGui:WaitForChild("SettingsMain")
	local topCornerDetails = playerGui:WaitForChild("NoResetGUIHandler"):WaitForChild("TopCornerDetails")
	mainGUIHandler.Enabled = true
	settingsMain.Enabled = true
	topCornerDetails.Visible = true
	mainGUIHandler.StarterInstructions.Visible = true
end

function GameInitShared.SdkWait()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local GameSdkShared = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("GameSdkShared"))
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local DatabaseRemoteConfigController = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Databases"):WaitForChild("DatabaseRemoteConfigController"))
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local Framework = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Framework"))
	GameSdkShared:WaitForLoad()
	Framework.promiseFrameworkDoneBooting():expect()

	while not DatabaseRemoteConfigController.IsLoaded() do
		task.wait()
	end
end

function GameInitShared.CheckWeather()
	local Players2 = game:GetService("Players")
	local playerGui = Players2.LocalPlayer.PlayerGui
	local UserInputService = game:GetService("UserInputService")

	if UserInputService.GamepadEnabled then
		local platformVisibility = playerGui:WaitForChild("SettingsMain"):WaitForChild("Settings"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("PlatformVisibility")
		platformVisibility.Visible = true
	end

	local player8Handler = playerGui:WaitForChild("Player8Handler")
	local Game8Settings = require(player8Handler:WaitForChild("Game8Settings"))
	local dayWeek = Game8Settings.DayWeek
	local weatherClients = Game8Settings.WeatherClients
	dayWeek:FireServer("GetDayOfWeekOnEnter")
	weatherClients:FireServer("CheckWeather")
end

function GameInitShared.PostPlay()
	local success, result = pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("AvatarEditor"):WaitForChild("AvatarEditorController")).InitializeCharacter()
	end)

	if not success then
		warn("Failed to initialize character: " .. result)
	end

	local success2, result2 = pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("IntroController")).NotifyPlayButtonPressed()
	end)

	if not success2 then
		warn("Failed to initialize check for pending rewards: " .. result2)
	end

	task.wait(0.5)
	local player8Handler = Players.LocalPlayer.PlayerGui:WaitForChild("Player8Handler")
	local Game8Settings = require(player8Handler:WaitForChild("Game8Settings"))
	Game8Settings.ClientInfo:FireServer("SetUpSettingSave")
end

return GameInitShared