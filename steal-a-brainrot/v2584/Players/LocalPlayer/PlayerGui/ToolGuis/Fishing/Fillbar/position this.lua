local GuiService = game:GetService("GuiService")

if GuiService:IsTenFootInterface() then
	script.Parent.Position = UDim2.new(0.5, 0, 1, -76)
else
	script.Parent.Position = UDim2.new(0.5, 0, 1, -116)
end