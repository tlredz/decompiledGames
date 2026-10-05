local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return function(parent)
	t.strict(t.instanceIsA("GuiObject"))(parent)
	local uIScale = parent:FindFirstChildWhichIsA("UIScale")

	if uIScale then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Parent = parent
	return uIScale2
end