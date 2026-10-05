local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local WindShake = require(script:WaitForChild("WindShake"))
local WindLines = require(script:WaitForChild("WindLines"))
require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local _ = Players.LocalPlayer
local tracker_timesjoined = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_timesjoined")
local weather = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather")
local maid = Trove.new()

local function isMobile()
	local touchEnabled = UserInputService.TouchEnabled

	if touchEnabled then
		local keyboardEnabled = UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled
		touchEnabled = not keyboardEnabled
	end

	return touchEnabled
end

local flag = false

local function updateWeather(flag2: boolean?)
	if weather.Value == "Tornado" then
		WindLines:Init({
			Direction = createVector(1.25, 0, 90),
			Speed = 25,
			Lifetime = 4.1,
			SpawnRate = 10
		})

		if flag2 then
			WindShake:SetDefaultSettings({
				WindSpeed = 24,
				WindDirection = createVector(0.8, 0.25, 0.8),
				WindPower = 1.15
			})
		else
			WindShake:UpdateAllObjectSettings({
				WindSpeed = 24,
				WindDirection = createVector(0.8, 0.25, 0.8),
				WindPower = 1.15
			})
		end

		flag = true
	elseif flag then
		WindLines:Init({
			Direction = createVector(1, 0, 80),
			Speed = 10,
			Lifetime = 3.7,
			SpawnRate = 2
		})

		if flag2 then
			WindShake:SetDefaultSettings({
				WindSpeed = 8,
				WindDirection = createVector(0.5, 0, 0.5),
				WindPower = 0.5
			})
		else
			WindShake:UpdateAllObjectSettings({
				WindSpeed = 8,
				WindDirection = createVector(0.5, 0, 0.5),
				WindPower = 0.5
			})
		end

		flag = false
	end
end

local function init()
	maid:Clean()
	updateWeather(true)
	maid:Add(weather.Changed:Connect(function()
		updateWeather()
	end))
	WindShake:Init()
	maid:Add(WindShake, "Cleanup")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disable()
	maid:Clean()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabled(settingValue: boolean)
	if settingValue then
		init()
	else
		disable() -- equivalent call inferred; original call site unknown
	end
end

local function main()
	assert(tracker_timesjoined:IsA("NumberValue"), "joincount isn't a number value, wind shake will not be enabled")
	local touchEnabled = UserInputService.TouchEnabled

	if touchEnabled then
		local keyboardEnabled = UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled
		touchEnabled = not keyboardEnabled
	end

	if touchEnabled and tracker_timesjoined.Value == 0 then
		print("mobile user & first time, disabling wind shake...")
		SettingsController:EditSetting("windShake", false)
	end

	SettingsController:GetSettingChangedSignal("windShake"):Connect(setEnabled)
	setEnabled(SettingsController:GetSettingValue("windShake")) -- equivalent call inferred; original call site unknown
end

main()