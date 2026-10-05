local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Controllers.UI.UIStateController)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("MovingGradient", function(instance)
	local renderSteppedConnection = nil

	local function updateVisibility()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		if instance.Parent.Visible then
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
				instance.Offset = Vector2.new(instance.Offset.X + dt * 2, 0)

				if instance.Offset.X >= 1 then
					instance.Rotation = instance.Rotation == 180 and 0 or 180
					instance.Offset = Vector2.new(-1, 0)
				end
			end)
		end
	end

	local visibleChangedConnection = instance.Parent:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
	local thread = task.defer(updateVisibility)
	return function()
		if visibleChangedConnection then
			visibleChangedConnection:Disconnect()
			visibleChangedConnection = nil
		end

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		if coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
		end
	end
end, { Players.LocalPlayer })