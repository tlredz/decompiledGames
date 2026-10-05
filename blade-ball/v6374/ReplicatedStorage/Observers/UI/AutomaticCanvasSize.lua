local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_AutomaticCanvasSize", function(instance)
	local maid = Utils.Maid.new()
	local uI_Source = instance:GetAttribute("UI_Source")
	local flag = false
	local Validate

	Validate = function(instance2)
		if flag then
			return
		end

		flag = true
		local v

		if uI_Source and (instance2.Name == uI_Source or instance2:IsA(uI_Source)) or instance2:IsA("UIListLayout") or instance2:IsA("UIGridLayout") then
			v = instance2 or nil
		else
			v = nil
		end

		if v then
			local function UpdateSize()
				local scrollingDirection = instance.ScrollingDirection
				local v2 = scrollingDirection == Enum.ScrollingDirection.Y or scrollingDirection == Enum.ScrollingDirection.XY
				local v3 = scrollingDirection == Enum.ScrollingDirection.X or scrollingDirection == Enum.ScrollingDirection.XY
				instance.CanvasSize = UDim2.new(
					0,
					v3 and v.AbsoluteContentSize.X or instance.CanvasSize.X.Offset,
					0,
					v2 and v.AbsoluteContentSize.Y or instance.CanvasSize.Y.Offset
				)
			end

			local thread = nil
			maid.TrackingSizeChanges = v:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if thread then
					pcall(task.cancel, thread)
				end

				thread = task.delay(0.2, function()
					UpdateSize()
					thread = nil
				end)
			end)
			UpdateSize()
			maid.UILayoutChanged = instance.ChildRemoved:Connect(function(child)
				if child == v then
					v = nil
					maid.UILayoutChanged = instance.ChildAdded:Connect(Validate)
				end
			end)
		elseif not maid.UILayoutChanged then
			maid.UILayoutChanged = instance.ChildAdded:Connect(Validate)
		end

		flag = false
	end

	Validate(uI_Source and (instance:FindFirstChild(uI_Source) or instance:FindFirstChildOfClass(uI_Source)) or instance:FindFirstChildOfClass("UIListLayout") or instance:FindFirstChildOfClass("UIGridLayout"))
	return function()
		maid:Destroy()
	end
end)