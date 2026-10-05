local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Spr = require(ReplicatedStorage.Packages.Spr)
local playerGui = Players.LocalPlayer.PlayerGui
local currentCamera = workspace.CurrentCamera
local duelsMachinePrompt = playerGui:WaitForChild("DuelsMachinePrompt").DuelsMachinePrompt
local v = {}

local function reconcileAll()
	local Y = duelsMachinePrompt.AbsoluteSize.Y

	if Y <= 0 then
		return
	end

	local total = 0.01

	for _, v2 in v do
		if not v2.frame then
			continue
		end

		local Y2 = v2.frame.AbsoluteSize.Y
		Spr.target(v2.frame, 1, 5, {
			Position = UDim2.fromScale(1, 1 - total)
		})
		total += Y2 / Y + 0.01
	end
end

local CornerNotificationController = {}

function CornerNotificationController.Add(_, instance)
	local flag = false
	local v2 = {
		frame = instance
	}
	table.insert(v, v2)
	instance.Parent = duelsMachinePrompt
	instance.Position = UDim2.fromScale(1.3, 1)
	reconcileAll()
	return function()
		if flag then
			return
		end

		flag = true
		local index = table.find(v, v2)

		if not index then
			return
		end

		table.remove(v, index)
		Spr.target(instance, 1, 5, {
			Position = UDim2.fromScale(1, 1.2)
		})
		task.delay(1, function()
			instance:Destroy()
		end)
		reconcileAll()
	end
end

function CornerNotificationController.Start(_)
	local v2 = nil

	local function updateHolderPosition()
		if v2 then
			duelsMachinePrompt.AnchorPoint = Vector2.new(0.5, 1)
			duelsMachinePrompt.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, v2.Position.Y.Offset)
		else
			duelsMachinePrompt.AnchorPoint = Vector2.new(0.5, 0.5)
			duelsMachinePrompt.Position = UDim2.fromScale(0.5, 1)
		end
	end

	Observers.observeTag("JumpButton", function(instance)
		v2 = instance
		local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(updateHolderPosition)
		updateHolderPosition()
		return function()
			positionChangedConnection:Disconnect()

			if v2 == instance then
				v2 = nil
				updateHolderPosition()
			end
		end
	end)
	local thread = nil
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if thread and coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end

		thread = task.delay(0.1, function()
			thread = nil
			reconcileAll()
		end)
	end)
end

return CornerNotificationController