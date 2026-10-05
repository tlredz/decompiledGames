local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local wheel = parent.Wheel
local slider = parent.Slider
local cursor = wheel.Cursor
local UserInputService = game:GetService("UserInputService")
local v = false
local v2 = false
parent:GetAttribute("Color")
local now = 0
local color = Color3.new(1, 1, 1)
local preview = parent.Preview
local v3 = {}

local function getPositionsFromFinalColor(color2)
	local v4 = math.max(color2.R, color2.G, color2.B)
	local v5 = 1 - v4
	local v6

	if v4 > 0 then
		v6 = Color3.new(color2.R / v4, color2.G / v4, color2.B / v4)
	else
		v6 = Color3.new(1, 0, 0)
	end

	local HSV, v7, _ = v6:ToHSV()
	local v8 = HSV * 2 * 3.141592653589793
	local v9 = 3.141592653589793 - v8
	local v10 = wheel.AbsoluteSize.X / 2
	local v11 = Vector2.new(math.cos(v9), (math.sin(v9))) * (v7 * v10)
	return Vector2.new(wheel.AbsoluteSize.X / 2, wheel.AbsoluteSize.Y / 2) + v11, v5
end

if not script.Value.Value then
	return
end

local color2 = script.Value.Value.Color
local positionsFromFinalColor, v4 = getPositionsFromFinalColor(color2)
cursor.Position = UDim2.new(0, positionsFromFinalColor.X, 0, positionsFromFinalColor.Y)
slider.TextButton.Position = UDim2.new(0, 0, v4, 0)
preview.BackgroundColor3 = color2
local v5 = 1 - v4

local function fn(vector, vector2)
	local vector3 = Vector2.new(
		vector2.X + wheel.Cursor.AbsoluteSize.X * 0.5,
		vector2.Y + wheel.Cursor.AbsoluteSize.Y * 0.5
	)
	local v6 = math.atan2(vector3.Y - vector.Y, vector3.X - vector.X)
	local v7 = (3.141592653589793 - v6) / 6.283185307179586
	local v8 = (vector - vector3).Magnitude / (wheel.AbsoluteSize.X / 2)
	return (Color3.fromHSV(math.clamp(v7, 0, 1), math.clamp(v8, 0, 1), 1))
end

slider.MouseButton1Down:Connect(function()
	if not v2 then
		v2 = true
		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Volume = 0.5,
			Parent = localPlayer.PlayerGui
		}):Play()
	end
end)
wheel.MouseButton1Down:Connect(function()
	if not v then
		v = true
		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Volume = 0.5,
			Parent = localPlayer.PlayerGui
		}):Play()
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if v or v2 then
		v = false
		v2 = false
		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Volume = 0.5,
			Parent = localPlayer.PlayerGui
		}):Play()
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 or tick() - now < 0.06 then
		return
	end

	now = tick()

	if v2 or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local v6 = (input.Position.Y - slider.AbsolutePosition.Y) / slider.AbsoluteSize.Y
		local slider2 = math.clamp(v6, 0, 1)

		if slider2 == v6 then
			shared.sfx({
				SoundId = "rbxassetid://7198717057",
				Volume = 0.5,
				Parent = localPlayer.PlayerGui
			}):Play()
		end

		slider.TextButton:TweenPosition(UDim2.new(0, 0, slider2, 0), nil, nil, 0.1, true)
		v5 = 1 - slider2
		v3.Slider = slider2
		local v8 = color
		preview.BackgroundColor3 = Color3.new(v8.R * v5, v8.G * v5, v8.B * v5)
	else
		local mouseLocation = UserInputService:GetMouseLocation()
		local GuiService = game:GetService("GuiService")
		local v6 = mouseLocation - Vector2.new(0, GuiService:GetGuiInset().Y)
		local vector = Vector2.new(
			wheel.AbsolutePosition.X + wheel.AbsoluteSize.X / 2,
			wheel.AbsolutePosition.Y + wheel.AbsoluteSize.Y / 2
		)
		local magnitude = (v6 - vector).Magnitude
		local unit = (v6 - vector).unit

		if v or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local v7 = v6.X - wheel.AbsolutePosition.X
			local v8 = v6.Y - wheel.AbsolutePosition.Y
			local v9 = wheel.AbsoluteSize.X / 2
			shared.sfx({
				SoundId = "rbxassetid://7198717057",
				Volume = 0.5,
				Parent = localPlayer.PlayerGui
			}):Play()
			local uDim

			if magnitude <= wheel.AbsoluteSize.X * 0.5 then
				uDim = UDim2.new(0, v7, 0, v8)
			else
				uDim = UDim2.new(0, v9 + unit.X * v9, 0, v9 + unit.Y * v9)
			end

			cursor:TweenPosition(uDim, nil, nil, 0.1, true)
			v3.Cursor = { uDim.X.Offset, uDim.Y.Offset }
			local absolutePosition = cursor.Parent.AbsolutePosition
			local absoluteSize = cursor.Parent.AbsoluteSize
			local v10 = absolutePosition.X + uDim.X.Scale * absoluteSize.X + uDim.X.Offset
			local v11 = absolutePosition.Y + uDim.Y.Scale * absoluteSize.Y + uDim.Y.Offset
			color = fn(vector, Vector2.new(v10, v11))
			local v12 = color
			preview.BackgroundColor3 = Color3.new(v12.R * v5, v12.G * v5, v12.B * v5)
		end
	end
end)