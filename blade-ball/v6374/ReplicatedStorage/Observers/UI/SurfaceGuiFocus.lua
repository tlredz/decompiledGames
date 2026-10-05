local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("SurfaceGuiFocus", function(parent)
	local frame = Instance.new("Frame")
	frame.Active = false
	frame.Name = "SurfaceGuiFocus"
	frame.ZIndex = 999999
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	local mouseEnterConnection = frame.MouseEnter:Connect(function()
		parent.AlwaysOnTop = true
	end)
	local mouseLeaveConnection = frame.MouseLeave:Connect(function()
		parent.AlwaysOnTop = false
	end)
	return function()
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		frame:Destroy()
	end
end)