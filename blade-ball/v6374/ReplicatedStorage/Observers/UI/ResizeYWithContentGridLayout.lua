local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_ResizeYWithContentGridLayout", function(instance)
	local maid = Utils.Maid.new()
	local uIGridLayout = instance:FindFirstChildOfClass("UIGridLayout")
	local flag = false
	local flag2 = false

	if not uIGridLayout then
		return function()
			maid:Destroy()
		end
	end

	local UpdateSize

	UpdateSize = function()
		if flag then
			flag2 = true
			return
		end

		flag = true
		instance.Size = UDim2.new(
			instance.Size.X.Scale,
			math.ceil(instance.Size.X.Offset),
			0,
			(math.ceil(uIGridLayout.AbsoluteContentSize.Y))
		)
		task.delay(0.5, function()
			flag = false

			if flag2 then
				flag2 = false
				UpdateSize()
			end
		end)
	end

	maid:GiveTask(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize))
	UpdateSize()
	return function()
		maid:Destroy()
	end
end)