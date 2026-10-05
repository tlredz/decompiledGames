local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_AdminPanelButton", function(parent)
	local maid = Utils.Maid.new()
	local frame = Instance.new("Frame")
	frame.Active = false
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.7
	frame.Visible = false
	maid.Cover = frame
	local uICorner = parent:FindFirstChildOfClass("UICorner")

	if uICorner then
		local clone = uICorner:Clone()
		clone.Parent = frame
		maid.Corner = clone
	end

	maid:GiveTask(parent.MouseEnter:Connect(function()
		frame.Visible = true
	end))
	maid:GiveTask(parent.MouseLeave:Connect(function()
		frame.Visible = false
	end))
	maid:GiveTask(parent.MouseButton1Down:Connect(function()
		frame.Visible = false
	end))
	maid:GiveTask(parent.MouseButton1Up:Connect(function()
		frame.Visible = true
	end))
	frame.Parent = parent
	return function()
		maid:Destroy()
	end
end)