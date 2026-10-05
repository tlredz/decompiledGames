local MouseOver = {}
Mouse = (game.Players.LocalPlayer or game.Players:GetPropertyChangedSignal("LocalPlayer")):GetMouse()
CurrentItems = {}

local function IsInFrame(uIObj)
	if not uIObj.Visible then
		return false
	end

	local X = Mouse.X
	local Y = Mouse.Y
	local scrollingFrame = uIObj:FindFirstAncestorOfClass("ScrollingFrame")

	if scrollingFrame then
		local Y2 = uIObj.AbsolutePosition.Y

		if uIObj.AbsolutePosition.Y + uIObj.AbsoluteSize.Y < scrollingFrame.AbsolutePosition.Y or scrollingFrame.AbsolutePosition.Y + scrollingFrame.AbsoluteSize.Y < Y2 then
			return false
		end
	end

	if not (uIObj.AbsolutePosition.X < X and uIObj.AbsolutePosition.Y < Y and X < uIObj.AbsolutePosition.X + uIObj.AbsoluteSize.X and Y < uIObj.AbsolutePosition.Y + uIObj.AbsoluteSize.Y) then
		return false
	end

	local findAncestor

	findAncestor = function(guiObject)
		local guiObject2 = guiObject:FindFirstAncestorWhichIsA("GuiObject")

		if guiObject2 and guiObject2.Visible == false then
			return false
		end

		if not guiObject2 then
			return 0
		end

		if guiObject2 and guiObject2.Visible == true then
			return findAncestor(guiObject2)
		end
	end

	local guiObject = uIObj:FindFirstAncestorWhichIsA("GuiObject")
	local v

	if guiObject and guiObject.Visible == false then
		v = false
	elseif guiObject then
		if guiObject and guiObject.Visible == true then
			v = findAncestor(guiObject)
		end
	else
		v = 0
	end

	return v == 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseExited(state)
	if not state.MouseIsInFrame and state.MouseWasIn then
		state.MouseWasIn = false
		state.LeaveEvent:Fire()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckMouseEntered(state)
	if state.MouseIsInFrame and not state.MouseWasIn then
		state.MouseWasIn = true
		state.EnteredEvent:Fire()
	end
end

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	for _, v in pairs(CurrentItems) do
		v.MouseIsInFrame = IsInFrame(v.UIObj)
		CheckMouseExited(v) -- equivalent call inferred; original call site unknown
	end

	for _, v in pairs(CurrentItems) do
		CheckMouseEntered(v) -- equivalent call inferred; original call site unknown
	end
end)

function MouseOver.MouseEnterLeaveEvent(instance)
	if CurrentItems[instance] then
		return CurrentItems[instance].EnteredEvent.Event, CurrentItems[instance].LeaveEvent.Event
	end

	local v = {
		UIObj = instance
	}
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	v.EnteredEvent = bindableEvent
	v.LeaveEvent = bindableEvent2
	v.MouseWasIn = false
	CurrentItems[instance] = v
	instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			bindableEvent:Destroy()
			bindableEvent2:Destroy()
			CurrentItems[instance] = nil
		end
	end)
	return bindableEvent.Event, bindableEvent2.Event
end

return MouseOver