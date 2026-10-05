local UserInputService = game:GetService("UserInputService")
local parent = script.Parent.Parent

-- equivalent calls inferred from this helper; original call sites unknown
local function update_scale()
	local absoluteSize = parent.AbsoluteSize

	if UserInputService.TouchEnabled then
		script.Parent.Scale = absoluteSize.X / 1000
	else
		script.Parent.Scale = absoluteSize.X / 1600
	end
end

parent:GetPropertyChangedSignal("AbsoluteSize"):connect(update_scale)
update_scale() -- equivalent call inferred; original call site unknown