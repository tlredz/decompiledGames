local v = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift }
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local ContextActionService = game:GetService("ContextActionService")
local CameraModule = require(game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"))
local UserInputService = game:GetService("UserInputService")

repeat
	task.wait(0.1)
until CameraModule.activeCameraController and CameraModule.activeCameraController.GetIsMouseLocked

if UserInputService.TouchEnabled and UserInputService.MouseEnabled ~= false then
	local RunService = game:GetService("RunService")
	RunService:IsStudio()
end

local isMouseLocked = nil
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v2 = Maid.new()
local flag = false
AttributeCounter.connect(game.Players.LocalPlayer, "SHIFTLOCK_DISABLED", function(p)
	v2.cameraModeTask = task.spawn(function()
		if p == 0 then
			flag = false
			ContextActionService:UnbindAction("ShiftlockDisable")

			while not CameraModule.activeCameraController do
				task.wait(0.1)
			end

			assert(CameraModule.activeCameraController):SetIsMouseLocked(isMouseLocked)
			game.ReplicatedStorage.Events.MobileUIModeUpdated:Fire()
		elseif p > 0 then
			if flag then
				return
			end

			flag = true

			while not CameraModule.activeCameraController do
				task.wait(0.1)
			end

			if CameraModule.activeCameraController then
				isMouseLocked = CameraModule.activeCameraController:GetIsMouseLocked()
				CameraModule.activeCameraController:SetIsMouseLocked(false)
			end

			ContextActionService:BindActionAtPriority("ShiftlockDisable", function(_, _, _)
				return Enum.ContextActionResult.Sink
			end, false, 9000, unpack(v))
			game.ReplicatedStorage.Events.MobileUIModeUpdated:Fire(false)
		end
	end)
end, true)