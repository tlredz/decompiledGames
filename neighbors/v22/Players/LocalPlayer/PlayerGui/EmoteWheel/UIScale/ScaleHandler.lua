local UserInputService = game:GetService("UserInputService")
local parent = script.Parent.Parent

-- equivalent calls inferred from this helper; original call sites unknown
local function update_scale()
	local absoluteSize = parent.AbsoluteSize

	if UserInputService.TouchEnabled then
		script.Parent.Scale = absoluteSize.X / 700 * 0.45
	else
		script.Parent.Scale = absoluteSize.X / 1200 * 0.65
	end
end

parent:GetPropertyChangedSignal("AbsoluteSize"):connect(update_scale)
update_scale() -- equivalent call inferred; original call site unknown