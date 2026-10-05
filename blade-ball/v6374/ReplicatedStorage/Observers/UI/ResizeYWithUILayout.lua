local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTag("UI_ResizeYWithUILayout", function(instance)
	local maid = Utils.Maid.new()
	local uI_Extra = instance:GetAttribute("UI_Extra") or 0
	local uI_Source = instance:GetAttribute("UI_Source")
	local v = (uI_Source and (instance.Name == uI_Source or instance:IsA(uI_Source)) or instance:IsA("UIListLayout") or instance:IsA("UIGridLayout")) and instance or nil

	if v then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateSize()
			local parent = instance.Parent

			if not parent then
				return
			end

			parent.Size = UDim2.new(
				parent.Size.X.Scale,
				parent.Size.X.Offset,
				parent.Size.Y.Scale,
				v.AbsoluteContentSize.Y + uI_Extra
			)
		end

		maid:GiveTask(v:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize))
		UpdateSize() -- equivalent call inferred; original call site unknown
	end

	return function()
		maid:Destroy()
	end
end)