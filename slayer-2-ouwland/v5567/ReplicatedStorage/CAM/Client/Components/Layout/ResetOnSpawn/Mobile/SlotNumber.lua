local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local vector = Vector2.new(1, 1)

local function lean(p: number, p2, p3, p4)
	if p < 0.5 then
		return p2
	end

	if p > 0.5 then
		return p4
	end

	return p3
end

return function(object, p: number, vector2: Vector2?, point: Vector2?)
	if vector2 == nil then
		vector2 = Vector2.new(0.9, 0.9)
	end

	if point == nil then
		point = vector
	end

	local v = object:Create("TextLabel")
	local v2 = {
		Name = "Number",
		ZIndex = 6,
		AnchorPoint = point,
		Position = UDim2.fromScale(vector2.X, vector2.Y),
		Size = UDim2.fromScale(0.34, 0.34),
		BackgroundTransparency = 1,
		Text = tostring(p),
		TextScaled = true,
		Font = Enum.Font.SourceSansBold,
		TextColor3 = Color3.new(1, 1, 1)
	}
	local X = point.X
	local left = Enum.TextXAlignment.Left
	local center = Enum.TextXAlignment.Center
	local right = Enum.TextXAlignment.Right

	if X < 0.5 then
		center = left
	elseif X > 0.5 then
		center = right
	end

	v2.TextXAlignment = center
	local Y = point.Y
	local top = Enum.TextYAlignment.Top
	local center2 = Enum.TextYAlignment.Center
	local bottom = Enum.TextYAlignment.Bottom

	if Y < 0.5 then
		center2 = top
	elseif Y > 0.5 then
		center2 = bottom
	end

	v2.TextYAlignment = center2
	do local _values = table.pack(object:Create("UIStroke")({
	Thickness = 1.5,
	Color = Color3.new(),
	Transparency = 0.3
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end