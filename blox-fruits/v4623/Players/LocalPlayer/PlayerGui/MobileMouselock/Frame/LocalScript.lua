local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local CameraModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"))
local UserInputService = game:GetService("UserInputService")

repeat
	task.wait(0.1)
until CameraModule.activeCameraController and CameraModule.activeCameraController.GetIsMouseLocked

local parent = script.Parent.Parent
local touchEnabled = UserInputService.TouchEnabled

if touchEnabled then
	if UserInputService.MouseEnabled == false then
		touchEnabled = true
	else
		local RunService = game:GetService("RunService")
		touchEnabled = RunService:IsStudio()
	end
end

parent.Enabled = touchEnabled
local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local v = 1

function game.ReplicatedStorage.Events.GetCurrentMobileMouseLockMode.OnInvoke()
	return v
end

local v2 = false
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v3 = Maid.new()

if script.Parent.Parent.Enabled then
	local function reflectMode(p, flag: boolean?)
		if p then
			v = p
		elseif MobileUIController:IsNewUIEnabled() and v == 2 then
			v = 3
		end

		v2 = v >= 2

		if AttributeCounter.get(localPlayer, "SHIFTLOCK_DISABLED") > 0 then
			v2 = false
		end

		if not flag then
			v3.setCameraModeTask = task.spawn(function()
				repeat
					task.wait(0.1)
				until CameraModule.activeCameraController and CameraModule.activeCameraController.GetIsMouseLocked

				CameraModule.activeCameraController:SetMouseLockOffset(createVector(1.25, 1.25, 0))
				CameraModule.activeCameraController:SetIsMouseLocked(v >= 2)
			end)
		end

		script.Parent.Image = v2 and v >= 2 and "rbxasset://textures/ui/mouseLock_on.png" or "rbxasset://textures/ui/mouseLock_off.png"

		if v == 3 and v2 then
			script.Parent.ImageColor3 = Color3.new(1, 1, 0)
		else
			script.Parent.ImageColor3 = Color3.new(1, 1, 1)
		end

		local cursor = script.Parent.Parent.Cursor
		cursor.Visible = v == 3 and v2
		local Global = require(game.ReplicatedStorage.Global)
		Global.Shiftlock = v == 3 and v2
	end

	script.Parent.MouseButton1Click:Connect(function(_, _)
		local Global = require(game.ReplicatedStorage.Global)

		if Global.mobileSelection or not CameraModule.activeCameraController then
			return
		end

		local v4 = MobileUIController:IsNewUIEnabled() and 2 or 1
		v += v4

		if v > 3 then
			v = 1
		end

		reflectMode()
	end)
	AttributeCounter.connect(localPlayer, "SHIFTLOCK_DISABLED", function(_)
		reflectMode()
	end, true)
	game.ReplicatedStorage.Events.MobileUIModeUpdated.Event:Connect(function(flag: boolean?)
		local Global = require(game.ReplicatedStorage.Global)

		if Global.mobileSelection then
			return
		end

		reflectMode(nil, flag)
	end)
	game.ReplicatedStorage.Events.SetMobileMouseLockMode.Event:Connect(function(p)
		local Global = require(game.ReplicatedStorage.Global)

		if Global.mobileSelection then
			return
		end

		reflectMode(p)
	end)
	script.Parent.Image = "rbxasset://textures/ui/mouseLock_off.png"

	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	localPlayer.CharacterAdded:Connect(function()
		repeat
			task.wait(0.1)
		until CameraModule.activeCameraController and CameraModule.activeCameraController.GetIsMouseLocked

		reflectMode()
	end)
end