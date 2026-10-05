local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local Run_Handler = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Run_Handler)
local v = simplesignal.new()
InputHandler.ListenTo("Shiftlock", function(p, p2)
	if p ~= "Down" or p2 then
		return
	end

	Run_Handler.SetShiftLock(Run_Handler.Shift_lock == 1 and 0 or 1)
end)
Run_Handler.ShiftLockChanged.Event:Connect(function(p)
	mouse.Icon = p == 1 and "rbxassetid://121895390404624" or ""
	v:Fire()
end)
local info = faye.Info(0.1)
return function(object, _)
	local character = localPlayer.Character
	local humanoid

	if character == nil then
		humanoid = nil
	else
		humanoid = character:WaitForChild("Humanoid") or nil
	end

	local value = object:Value(Color3.new(0.25, 0.25, 0.25))
	local image = object:Value("http://www.roblox.com/asset/?id=10752429453")
	local value3 = object:Value(Color3.new(1, 1, 1))

	local function upd()
		if Run_Handler.Shift_lock == 1 then
			if humanoid ~= nil then
				TweenService:Create(humanoid, tweenInfo, {
					CameraOffset = createVector(0, 1.35, 0)
				}):Play()
			end

			value:Set(Color3.new(1, 1, 1))
			value3:Set(Color3.new())
			image:Set("rbxassetid://132528693803904")
		else
			if humanoid ~= nil then
				TweenService:Create(humanoid, tweenInfo, {
					CameraOffset = createVector(0, 0, 0)
				}):Play()
			end

			value3:Reset()
			value:Reset()
			image:Reset()
		end
	end

	upd()
	object:Connect(v, upd)
	return object:Create("Frame")({
		Name = "ZShiftlock",
		Size = UDim2.fromScale(1, 0.45),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Name = "bg",
			Position = UDim2.fromScale(0, -0.2),
			BackgroundTransparency = 1,
			Image = "rbxassetid://118985613597286",
			Size = UDim2.fromScale(1, 1.5),
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.5
		}),
		object:Create("ImageLabel")({
			Name = "bg",
			Position = UDim2.fromScale(0, -0.2),
			BackgroundTransparency = 1,
			Image = "rbxassetid://71711285590074",
			Size = UDim2.fromScale(1, 1.5),
			ImageColor3 = object:Animation(value, info)
		}),
		object:Create("ImageLabel")({
			Image = image,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.5, 0.7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = object:Animation(value3, info),
			Instance.new("UIAspectRatioConstraint")
		}),
		Utility.AddTag(object:Create("Frame")({
			Name = "Shiftlock",
			BackgroundTransparency = gameSettings.KeybindTextTransparency,
			AnchorPoint = Vector2.new(0.5, 1),
			Size = gameSettings.KeybindTextSize,
			Position = UDim2.new(0.5, 0, 1, gameSettings.KeybindTextOffset - 2),
			ZIndex = -1
		}), "UIkey")
	})
end