local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsClient() then
	return {}
end

local Network = require(ReplicatedStorage.SharedUtils.Network)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function listen()
	if flag then
		return
	end

	flag = true
	Network:AddAction("UnstuckResult", function(p, p2)
		pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
			Title = p2 and "Unstuck" or "Unstuck unavailable",
			Text = tostring(p),
			Duration = 3
		})
	end)
end

local function recoverUi()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local info = workspace:FindFirstChild("Info")
	local loading = info and info:FindFirstChild("Loading")
	local gameStarted = info and info:FindFirstChild("GameStarted")
	local v

	if loading == nil then
		v = false
	else
		v = loading.Value == true
	end

	local v2

	if gameStarted == nil then
		v2 = false
	else
		v2 = gameStarted.Value == true
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v3

	if humanoid == nil then
		v3 = false
	else
		v3 = humanoid.Health > 0
	end

	pcall(function()
		local loadingGui = playerGui:FindFirstChild("LoadingGui")
		local loadingScreen = loadingGui and loadingGui:FindFirstChild("LoadingScreen")

		if loadingScreen and loadingScreen:IsA("GuiObject") and not v and loadingScreen.Visible then
			loadingScreen.Position = UDim2.new(0, 0, -1, 0)
			loadingScreen.Visible = false
		end
	end)

	if not v and (v2 or v3) then
		pcall(function()
			for _, descendant in ipairs(playerGui:GetDescendants()) do
				if descendant.Name ~= "LoadingScreen" then
					continue
				end

				if descendant:IsA("ScreenGui") then
					descendant.Enabled = false
				elseif descendant:IsA("GuiObject") then
					descendant.Visible = false
				end
			end
		end)
	end

	local screenGui = playerGui:FindFirstChild("ScreenGui")

	if v2 then
		pcall(function()
			local menu = screenGui and screenGui:FindFirstChild("Menu")
			local backgroundFrame = menu and menu:FindFirstChild("BackgroundFrame")

			if backgroundFrame and backgroundFrame:IsA("GuiObject") then
				backgroundFrame.Visible = false
			end
		end)
	end

	if v3 then
		pcall(function()
			if screenGui and screenGui:IsA("ScreenGui") and not screenGui.Enabled then
				screenGui.Enabled = true
			end
		end)
	end

	pcall(function()
		local CameraModeController = require(ReplicatedStorage.SharedUtils.CameraModeController)

		if CameraModeController.IsActive and CameraModeController.IsActive() then
			CameraModeController.Exit()
		end
	end)
	pcall(function()
		local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)

		if MenuManager:IsAnyOpen() then
			MenuManager:CloseAll()
		end
	end)
	pcall(function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local clientUI = modules and modules:FindFirstChild("ClientUI")
		local stickerController = clientUI and clientUI:FindFirstChild("StickerController")

		if stickerController then
			local module = require(stickerController)

			if module.ForceCloseWheel then
				module.ForceCloseWheel()
			end
		end
	end)
	pcall(function()
		local InputService = require(ReplicatedStorage.SharedUtils.InputService)
		local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)

		if MenuManager:IsAnyOpen() then
			return
		end

		local count = 0

		while InputService:IsGameplaySuspended() and count < 8 do
			InputService:ResumeGameplay()
			count += 1
		end

		if count > 0 then
			print("[UnstuckClient] gameplay input was suspended with no menu open; resumed (" .. count .. ")")
		end
	end)
end

local UnstuckClient = {}

function UnstuckClient.requestUnstuck()
	if not SettingsFlags:IsEnabled("Unstuck") then
		return
	end

	listen() -- equivalent call inferred; original call site unknown
	recoverUi()
	Network:Post("UnstuckRequest")
end

function UnstuckClient.resetCamera()
	if not SettingsFlags:IsEnabled("CameraReset") then
		return
	end

	recoverUi()
	local success, result = pcall(function()
		local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
		local CameraController = require(ReplicatedStorage.SharedUtils.CameraController)
		print("[UnstuckClient] camera reset requested; ownership was: " .. CameraAuthority.dump())
		CameraController:Reset()
		CameraAuthority.resetAll("PlayerCameraReset")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	if not success then
		warn("[UnstuckClient] camera reset failed:", result)
	end
end

return UnstuckClient