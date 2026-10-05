local localPlayer = game.Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui")
localPlayer:GetMouse()
return function(parent)
	local bindableEvent = Instance.new("BindableEvent", parent)
	bindableEvent.Name = "EnterEvent"
	local bindableEvent2 = Instance.new("BindableEvent", parent)
	bindableEvent2.Name = "LeaveEvent"
	parent.InputBegan:connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseMovement then
			bindableEvent:Fire()
		end
	end)
	parent.InputEnded:connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseMovement then
			bindableEvent2:Fire()
		end
	end)
	return bindableEvent.Event, bindableEvent2.Event
end