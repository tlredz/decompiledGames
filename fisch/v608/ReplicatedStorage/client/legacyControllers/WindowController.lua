local Lighting = game:GetService("Lighting")
game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
local anyWindow = ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs"):WaitForChild("AnyWindow")
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage:WaitForChild("packages")
local Signal = require(packages:WaitForChild("Signal"))
local WindowController = {
	CurrentWindow = nil,
	WindowOpened = Signal.new(),
	WindowClosed = Signal.new()
}
local screenGuis = {}
local v = false
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function tweenOpening()
	TweenService:Create(currentCamera, tweenInfo, {
		FieldOfView = 60
	}):Play()
	TweenService:Create(Lighting:WaitForChild("uiblur"), tweenInfo, {
		Size = 10
	}):Play()
	TweenService:Create(Lighting:WaitForChild("uicc"), tweenInfo2, {
		Brightness = -0.07,
		TintColor = Color3.fromRGB(184, 184, 184),
		Saturation = -0.3
	}):Play()
end

local function tweenClosing()
	TweenService:Create(currentCamera, tweenInfo2, {
		FieldOfView = 70
	}):Play()
	TweenService:Create(Lighting:WaitForChild("uiblur"), tweenInfo2, {
		Size = 0
	}):Play()
	TweenService:Create(Lighting:WaitForChild("uicc"), tweenInfo2, {
		Brightness = 0,
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = 0
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isActive(instance)
	if instance:IsA("Frame") then
		return instance.Visible
	end

	if instance:IsA("ScreenGui") then
		return instance.Enabled
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActive(instance, p)
	if instance:IsA("Frame") then
		instance.Visible = p
	elseif instance:IsA("ScreenGui") then
		instance.Enabled = p
	end
end

local function closeOpenedFrame()
	for _, instance in ipairs(screenGuis) do
		-- equivalent call inferred; original call site unknown
		if not isActive(instance) then
			continue
		end

		local close = instance:FindFirstChild("Close")

		if not (close and close.Visible) then
			return false
		end

		if instance:IsA("Frame") then
			instance.Visible = false
		elseif instance:IsA("ScreenGui") then
			instance.Enabled = false
		end

		return true
	end

	local currentWindow = WindowController.CurrentWindow

	if currentWindow then
		WindowController.WindowClosed:Fire(currentWindow)
	end

	WindowController.CurrentWindow = nil
	anyWindow.Enabled = false
	return true
end

local function onWindowOpened(screenGui)
	for _, instance in ipairs(screenGuis) do
		if instance == screenGui then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if not isActive(screenGui) then
			continue
		end

		if instance:IsA("Frame") then
			instance.Visible = false
		elseif instance:IsA("ScreenGui") then
			instance.Enabled = false
		end
	end

	if screenGui:IsA("Frame") then
		screenGui.Visible = true
	elseif screenGui:IsA("ScreenGui") then
		screenGui.Enabled = true
	end

	if WindowController.CurrentWindow ~= screenGui then
		WindowController.CurrentWindow = screenGui
		WindowController.WindowOpened:Fire(screenGui)
		anyWindow.Enabled = true
	end
end

local function trackWindow(screenGui)
	table.insert(screenGuis, screenGui)

	-- equivalent call inferred; original call site unknown
	if isActive(screenGui) then
		onWindowOpened(screenGui)
	end

	(screenGui:IsA("ScreenGui") and screenGui:GetPropertyChangedSignal("Enabled") or screenGui:GetPropertyChangedSignal("Visible")):Connect(function()
		-- equivalent call inferred; original call site unknown
		if isActive(screenGui) then
			onWindowOpened(screenGui)
			return
		end

		WindowController.CurrentWindow = nil
		WindowController.WindowClosed:Fire(screenGui)
		anyWindow.Enabled = false
	end)
	local close = screenGui:FindFirstChild("Close")

	if close and not screenGui:GetAttribute("IgnoreBindClose") then
		close.Activated:Connect(function()
			setActive(screenGui, false) -- equivalent call inferred; original call site unknown
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function filterElement(instance)
	if instance:IsA("Frame") or instance:IsA("ScreenGui") then
		trackWindow(instance)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setVirtualCursor(flag: boolean, instance)
	if flag then
		GamepadService:EnableGamepadCursor(instance)
	else
		GamepadService:DisableGamepadCursor()
	end
end

function WindowController:CloseActiveWindow()
	v = true
	closeOpenedFrame()
	v = false
end

function WindowController.Start(_)
	for _, v2 in pairs(CollectionService:GetTagged("Window")) do
		filterElement(v2) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("Window"):Connect(filterElement)
	anyWindow.CloseWindow.Pressed:Connect(function()
		if not v then
			WindowController:CloseActiveWindow()
		end
	end)
	WindowController.WindowOpened:Connect(function(instance)
		if not instance:GetAttribute("NoScreenDarken") then
			task.defer(tweenOpening)
		end

		if not instance:GetAttribute("NoGamepadCursor") then
			task.spawn(function()
				task.wait(0.2)
				setVirtualCursor(true, instance) -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	WindowController.WindowClosed:Connect(function(instance)
		tweenClosing()

		if not instance:GetAttribute("NoGamepadCursor") then
			GamepadService:DisableGamepadCursor()
		end

		if instance:GetAttribute("UnequipTools") then
			local character = localPlayer.Character

			if instance:GetAttribute("UnequipToolName") then
				local tool = character and character:FindFirstChildOfClass("Tool")

				if not tool or tool.Name ~= instance:GetAttribute("UnequipToolName") then
					return
				end
			end

			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:UnequipTools()
			end
		end
	end)
end

return WindowController