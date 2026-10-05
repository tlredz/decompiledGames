local parent = script.Parent
local frame = parent.Parent.Frame
frame:GetPropertyChangedSignal("Visible"):Connect(function()
	parent.Visible = frame.Visible
end)