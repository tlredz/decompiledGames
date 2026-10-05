-- equivalent calls inferred from this helper; original call sites unknown
local function typeOrClassName(instance)
	if typeof(instance) == "Instance" then
		return instance.ClassName
	end

	return (typeof(instance))
end

return {
	new = function(instance)
		assert(instance, "Argument 1 missing or nil")
		local isA = instance:IsA("GuiObject")
		local v2 = typeOrClassName(instance) -- equivalent call inferred; original call site unknown
		assert(isA, "Expected a GuiObject, got a", v2)

		if instance:IsA("TextBox") then
			local frame = Instance.new("Frame")
			frame.Name = "HoverDetectionFrame"
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 1
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.Position = UDim2.new(0, 0, 0, 0)
			frame:SetAttribute("HoveringModuleInstances", true)
			frame.Parent = instance
			instance = frame
		end

		local bindableEvent = Instance.new("BindableEvent")
		local bindableEvent2 = Instance.new("BindableEvent")
		local v3 = {
			HoverStarted = bindableEvent.Event,
			HoverEnded = bindableEvent2.Event
		}
		instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				bindableEvent:Fire()
			elseif input.UserInputType == Enum.UserInputType.Touch then
				bindableEvent:Fire()
			end
		end)
		instance.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				bindableEvent2:Fire()
			elseif input.UserInputType == Enum.UserInputType.Touch then
				bindableEvent2:Fire()
			end
		end)
		return v3
	end
}