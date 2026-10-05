local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_Scrolling_Y", function(instance)
	local maid = Utils.Maid.new()
	local uI_Extra = instance:GetAttribute("UI_Extra") or 0
	local uI_Source = instance:GetAttribute("UI_Source") or "UIListLayout"
	local v = instance:FindFirstChild(uI_Source) or instance:FindFirstChildOfClass(uI_Source) or instance:FindFirstChildOfClass("UIGridLayout")

	if v then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateSize()
			instance.CanvasSize = UDim2.new(0, 0, 0, v.AbsoluteContentSize.Y + uI_Extra)
		end

		maid:GiveTask(v:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize))
		UpdateSize() -- equivalent call inferred; original call site unknown
	end

	return function()
		maid:Destroy()
	end
end)