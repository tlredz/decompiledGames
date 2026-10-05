local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local powerfeedback = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("powerfeedback")
local PowerFeedbackController = {
	CreateFeedbackAsync = function(self, text: string, parent)
		if not parent then
			return
		end

		local clone = powerfeedback:Clone()
		clone.title.TextTransparency = 1
		clone.title.UIStroke.Transparency = 1
		clone.StudsOffsetWorldSpace = createVector(0, 2.6, 0)
		clone.title.Text = text
		clone.Parent = parent
		TweenService:Create(clone.title, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(clone.title.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			StudsOffsetWorldSpace = createVector(0, 3.7, 0)
		}):Play()
		task.wait(0.4)
		TweenService:Create(clone.title, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(clone.title.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			StudsOffsetWorldSpace = createVector(0, 4, 0)
		}):Play()
		task.delay(1.1, function()
			clone:Destroy()
		end)
	end
}

function PowerFeedbackController.CreateFeedback(_, p: string, p2)
	task.spawn(PowerFeedbackController.CreateFeedbackAsync, PowerFeedbackController, p, p2)
end

function PowerFeedbackController.Start(_)
	Net:RemoteEvent("PowerFeedback/Send", 1e999).OnClientEvent:Connect(function(...)
		PowerFeedbackController:CreateFeedbackAsync(...)
	end)
end

return PowerFeedbackController