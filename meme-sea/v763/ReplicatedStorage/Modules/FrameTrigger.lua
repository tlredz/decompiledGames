local FrameTrigger = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 60)
local gameGui = playerGui:WaitForChild("GameGui")
playerGui:WaitForChild("Menu")
local linear = Enum.EasingStyle.Linear
local linear2 = Enum.EasingStyle.Linear

function FrameTrigger.CloseFrame(childName, instance)
	local child = instance:FindFirstChild(childName)

	if child then
		child.Visible = false
	end
end

function FrameTrigger.CloseFrameOnGameGui(childName)
	local child = gameGui:FindFirstChild(childName)

	if child then
		local tween = TweenService:Create(child, TweenInfo.new(0.25, linear2), {
			Position = UDim2.new(0.5, 0, 1.5, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			child.Visible = false
		end)
	end
end

function FrameTrigger.CloseAllFrames(instance)
	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("Frame") or guiObject:IsA("ImageLabel") then
			coroutine.wrap(FrameTrigger.CloseFrame)(guiObject.Name)
		end
	end
end

function FrameTrigger.OpenFrame(childName, instance)
	local child = instance:FindFirstChild(childName)

	if child then
		child.Visible = true
	end
end

function FrameTrigger.OpenFrameOnGameGui(childName)
	local child = gameGui:FindFirstChild(childName)

	if child and child then
		child.Position = UDim2.new(0.5, 0, 1.5, 0)
		task.wait(0.35)
		child.Visible = true
		TweenService:Create(child, TweenInfo.new(0.25, linear), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
	end
end

return FrameTrigger