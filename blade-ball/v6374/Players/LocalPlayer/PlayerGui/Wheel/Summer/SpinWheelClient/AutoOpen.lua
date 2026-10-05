local parent = script.Parent
local parent2 = parent.Parent
local parent3 = parent2.Parent

local function checkEnabled()
	local enabled = parent.Enabled and parent3.Enabled or false
	parent2.Enabled = enabled
end

parent:GetPropertyChangedSignal("Enabled"):Connect(checkEnabled)
parent3:GetPropertyChangedSignal("Enabled"):Connect(checkEnabled)