local mouse = game.Players.LocalPlayer:GetMouse()
require(game.ReplicatedStorage.Modules.UI)
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local uIScale = script.Parent.Parent.UIScale
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local absoluteSize = script.Parent.AbsoluteSize
	local vector = Vector2.new(mouse.X, mouse.Y)
	local vector2 = Vector2.new(10, 10)
	local vector3 = Vector2.new(0, 0)

	if UserInputService.GamepadEnabled and not GamepadService.GamepadCursorEnabled and GuiService.SelectedObject then
		vector = GuiService.SelectedObject.AbsolutePosition
	end

	if UserInputService.TouchEnabled then
		vector3 = Vector2.new(1, 0)
		vector2 = Vector2.new(-vector2.X, vector2.Y)

		if vector.X < 100 then
			vector3 += Vector2.new(-1, 0)
			vector2 = Vector2.new(-vector2.X, vector2.Y)
		end
	elseif vector.X > viewportSize.X - absoluteSize.X - 100 then
		vector3 += Vector2.new(1, 0)
		vector2 = Vector2.new(-vector2.X, vector2.Y)
	end

	if vector.Y > viewportSize.Y - absoluteSize.Y - 100 then
		vector3 += Vector2.new(0, 1)
		vector2 = Vector2.new(vector2.X, -vector2.Y * 0.5)
	end

	script.Parent.AnchorPoint = vector3
	script.Parent.Position = UDim2.new(
		0,
		(vector.X + vector2.X) / uIScale.Scale,
		0,
		(vector.Y + vector2.Y) / uIScale.Scale
	)
end)