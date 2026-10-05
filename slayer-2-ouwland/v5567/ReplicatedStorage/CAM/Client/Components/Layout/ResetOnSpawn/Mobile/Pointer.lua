local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
return function(p)
	if p.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(p.Position.X, p.Position.Y)
	end

	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end