local ColorWheel = {}
ColorWheel.__index = ColorWheel

local function getCleanColor(color: Color3)
	local R = color.R
	local G = color.G
	local B = color.B
	local v = R ~= R and 0 or R
	local v2 = G ~= G and 0 or G
	local v3 = B ~= B and 0 or B
	return Color3.new(math.clamp(v, 0, 1), math.clamp(v2, 0, 1), (math.clamp(v3, 0, 1)))
end

function ColorWheel.new()
	return (setmetatable({
		PickerPosition = Vector2.new(0, 0),
		ColorWheelAbsoluteSize = Vector2.new(0, 0)
	}, ColorWheel))
end

function ColorWheel:SetPosition(pickerPosition: Vector2)
	local v = self.ColorWheelAbsoluteSize.X / 2
	local halfColorWheelAbsoluteSize = self.ColorWheelAbsoluteSize / 2

	if v <= math.clamp((pickerPosition - halfColorWheelAbsoluteSize).Magnitude, 0, v) then
		pickerPosition = halfColorWheelAbsoluteSize + (pickerPosition - halfColorWheelAbsoluteSize).Unit * v
	end

	self.PickerPosition = pickerPosition
end

function ColorWheel.GetCurrentColor(p, value: number?)
	local halfColorWheelAbsoluteSize = p.ColorWheelAbsoluteSize / 2
	local unit = (p.PickerPosition - halfColorWheelAbsoluteSize).Unit
	local magnitude = (p.PickerPosition - halfColorWheelAbsoluteSize).Magnitude

	if magnitude == 0 then
		unit = Vector2.zero
	end

	local v2 = math.atan2(unit.Y, -unit.X) / 6.283185307179586 + 0.5
	local v3 = math.clamp(magnitude / (p.ColorWheelAbsoluteSize.X / 2), 0, 1)
	return getCleanColor(Color3.fromHSV(v2, v3, (math.clamp(value or 1, 0, 1))))
end

function ColorWheel:SetColor(color: Color3)
	local R = color.R
	local G = color.G
	local B = color.B
	local v = R ~= R and 0 or R
	local v2 = G ~= G and 0 or G
	local v3 = B ~= B and 0 or B
	local HSV, v4 = Color3.new(math.clamp(v, 0, 1), math.clamp(v2, 0, 1), (math.clamp(v3, 0, 1))):ToHSV()
	self.PickerPosition = self.ColorWheelAbsoluteSize / 2 + Vector2.new(
		math.cos(HSV * 3.141592653589793 * 2),
		-math.sin(HSV * 3.141592653589793 * 2)
	) * (v4 * (self.ColorWheelAbsoluteSize.X / 2))
end

return ColorWheel