local InputUtils = {}

function InputUtils.position(p)
	return Vector2.new(p.Position.X, p.Position.Y)
end

function InputUtils.x(p)
	return p.Position.X
end

function InputUtils.isPrimaryPointer(p)
	return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
end

function InputUtils.isPointerMove(p)
	return p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Touch
end

return InputUtils