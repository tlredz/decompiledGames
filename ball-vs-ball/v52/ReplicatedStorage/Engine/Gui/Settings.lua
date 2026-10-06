local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local SettingsService = require(ReplicatedStorage.Engine.Service.SettingsService)
local client2 = SettingsService.client
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonActions = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(99, 99, 99)
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local debugSettingsIcon = nil
local flag = false

local function fn() end

local Settings = {}

function Settings.SetTopbarEnabled(flag2: boolean)
	if not flag2 then
		fn()
	end

	if debugSettingsIcon then
		debugSettingsIcon:setEnabled(flag2)
	end
end

function Settings.Init()
	local frame = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("设置界面"):WaitForChild("Frame")
	local closeBtn = frame:WaitForChild("closeBtn")
	local frame2 = frame:WaitForChild("Frame")
	local v2 = frame2:WaitForChild("音乐")
	local defaultButton = v2:WaitForChild("开")
	local v4 = v2:WaitForChild("关")
	local v5 = frame2:WaitForChild("贴纸声音")
	local v6 = v5:WaitForChild("开")
	local v7 = v5:WaitForChild("关")
	local size = frame.Size
	frame.Visible = false
	GamepadPages.Register(frame, {
		defaultButton = defaultButton
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshToggleButtons(flag2: boolean, p, p2)
		local backgroundColor

		if flag2 then
			backgroundColor = color
		else
			backgroundColor = color2
		end

		p.BackgroundColor3 = backgroundColor
		local backgroundColor2

		if flag2 then
			backgroundColor2 = color2
		else
			backgroundColor2 = color
		end

		p2.BackgroundColor3 = backgroundColor2
	end

	refreshToggleButtons(client.settings.musicEnabled() ~= false, defaultButton, v4) -- equivalent call inferred; original call site unknown
	client.settings.musicEnabled.Changed(function(flag2: boolean)
		refreshToggleButtons(flag2, defaultButton, v4) -- equivalent call inferred; original call site unknown
	end)
	refreshToggleButtons(client.settings.soundEffectsEnabled() ~= false, v6, v7) -- equivalent call inferred; original call site unknown
	client.settings.soundEffectsEnabled.Changed(function(flag2: boolean)
		refreshToggleButtons(flag2, v6, v7) -- equivalent call inferred; original call site unknown
	end)

	local function openPanel()
		if flag then
			return
		end

		flag = true
		frame.Visible = true
		frame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(frame, tweenInfo, {
			Size = size
		}):Play()

		if debugSettingsIcon then
			debugSettingsIcon:select()
		end

		GamepadPages.Open(frame)
	end

	fn = function()
		if not flag then
			return
		end

		flag = false
		TweenService:Create(frame, tweenInfo2, {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(tweenInfo2.Time, function()
			if not flag then
				frame.Visible = false
				GamepadPages.Close(frame)
			end
		end)

		if debugSettingsIcon then
			debugSettingsIcon:deselect()
		end
	end

	ButtonActions.Bind(closeBtn, fn)
	ButtonActions.Bind(defaultButton, function()
		client2.setMusicEnabled(true)
	end)
	ButtonActions.Bind(v4, function()
		client2.setMusicEnabled(false)
	end)
	ButtonActions.Bind(v6, function()
		client2.setSoundEffectsEnabled(true)
	end)
	ButtonActions.Bind(v7, function()
		client2.setSoundEffectsEnabled(false)
	end)
	debugSettingsIcon = TopbarPlus.new()
	debugSettingsIcon:setImage("rbxassetid://9405931578"):setImageScale(0.8)
	debugSettingsIcon:setLeft()
	debugSettingsIcon:setOrder(5)
	debugSettingsIcon:bindEvent("selected", openPanel)
	debugSettingsIcon:bindEvent("deselected", fn)
	_G.__DebugSettingsIcon = debugSettingsIcon
end

return Settings