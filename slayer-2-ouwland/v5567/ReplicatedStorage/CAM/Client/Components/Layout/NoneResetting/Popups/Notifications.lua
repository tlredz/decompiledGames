local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local notification = game.ReplicatedStorage.Communication.CnC.Notifications.Notification
local centerNotification = game.ReplicatedStorage.Communication.CnC.Notifications.CenterNotification
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

local function sizeFor(p: number, p2: number, p3: number)
	if Platform_Handler.Platform.Value ~= "Mobile" then
		p3 = p2
	end

	return UDim2.fromScale(p, p3)
end

local modules = {
	Currency = require(script.Currency),
	Notify = require(script.Notify),
	NewItem = require(script.NewItem)
}
return function(object, instance)
	local value = object:Value(UDim2.new())

	local function followModeBar()
		local modeBar = instance:FindFirstChild("ModeBar")

		if modeBar == nil or not modeBar.Visible then
			value:Set(UDim2.new())
			return
		end

		local v2 = modeBar.AbsolutePosition.Y - instance.AbsolutePosition.Y + modeBar.AbsoluteSize.Y
		value:Set(UDim2.new(0, 0, 0, v2 + 4))
	end

	local function bindBar(guiObject)
		if guiObject.Name ~= "ModeBar" or not guiObject:IsA("GuiObject") then
			return
		end

		task.defer(followModeBar)
		object:Connect(guiObject:GetPropertyChangedSignal("AbsoluteSize"), followModeBar)
		object:Connect(guiObject:GetPropertyChangedSignal("Visible"), followModeBar)
	end

	object:Connect(instance.ChildAdded, bindBar)
	object:Connect(instance.ChildRemoved, function(p)
		if p.Name == "ModeBar" then
			followModeBar()
		end
	end)
	local modeBar = instance:FindFirstChild("ModeBar")

	if modeBar ~= nil then
		bindBar(modeBar)
	end

	followModeBar()
	local size = object:Value(sizeFor(1, 0.0235, 0.065))
	local size2 = object:Value(sizeFor(0.1, 0.035, 0.095))
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		size:Set(sizeFor(1, 0.0235, 0.065))
		size2:Set(sizeFor(0.1, 0.035, 0.095))
	end)
	return { object:Create("Frame")({
			Parent = instance,
			Name = "MainNotificationFrame",
			Position = object:Animation(value, object.Info(0.2)),
			Size = size,
			ZIndex = 1000,
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 5)
			}),
			object:Signal(notification.Event, function(p, _, p2, ...)
				return modules[p2](p, ...)
			end)
		}), object:Create("Frame")({
			Parent = instance,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.51, 0.51),
			Size = size2,
			ZIndex = 1000,
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 5)
			}),
			object:Signal(centerNotification.Event, function(p, _, p2, ...)
				return modules[p2](p, ...)
			end)
		}) }
end