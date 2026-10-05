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
local v3 = 1
local preview = parent.Preview
local v4 = {}

local function fn(emote)
	local HttpService = game:GetService("HttpService")
	local v5 = HttpService:JSONDecode(localPlayer:GetAttribute("EmoteColors") or "[]")[emote]
	return v5 and Color3.new(v5[1] / 255, v5[2] / 255, v5[3] / 255)
end

local function getPositionsFromFinalColor(data)
	local v5 = math.max(data.R, data.G, data.B)
	local v6 = 1 - v5
	local v7

	if v5 > 0 then
		v7 = Color3.new(data.R / v5, data.G / v5, data.B / v5)
	else
		v7 = Color3.new(1, 0, 0)
	end

	local HSV, v8, _ = v7:ToHSV()
	local v9 = HSV * 2 * 3.141592653589793
	local v10 = 3.141592653589793 - v9
	local v11 = wheel.AbsoluteSize.X / 2
	local v12 = Vector2.new(math.cos(v10), (math.sin(v10))) * (v8 * v11)
	return Vector2.new(wheel.AbsoluteSize.X / 2, wheel.AbsoluteSize.Y / 2) + v12, v6
end

parent:GetPropertyChangedSignal("Parent"):Connect(function()
	local emote = parent.Parent:GetAttribute("Emote")

	if emote then
		local backgroundColor = fn(emote)
		local positionsFromFinalColor, v6 = getPositionsFromFinalColor(backgroundColor)
		cursor.Position = UDim2.new(0, positionsFromFinalColor.X, 0, positionsFromFinalColor.Y)
		slider.TextButton.Position = UDim2.new(0, 0, v6, 0)
		preview.BackgroundColor3 = backgroundColor
		v3 = 1 - v6
	end
end)

local function fn2(vector, vector2)
	local vector3 = Vector2.new(
		vector2.X + wheel.Cursor.AbsoluteSize.X * 0.5,
		vector2.Y + wheel.Cursor.AbsoluteSize.Y * 0.5
	)
	local v5 = math.atan2(vector3.Y - vector.Y, vector3.X - vector.X)
	local v6 = (3.141592653589793 - v5) / 6.283185307179586
	local v7 = (vector - vector3).Magnitude / (wheel.AbsoluteSize.X / 2)
	return (Color3.fromHSV(math.clamp(v6, 0, 1), math.clamp(v7, 0, 1), 1))
end

local function fn3()
	local v5 = color
	local color2 = Color3.new(v5.R * v3, v5.G * v3, v5.B * v3)
	preview.BackgroundColor3 = color2
	local emote = parent.Parent:GetAttribute("Emote")

	if emote then
		localPlayer.Character.Communicate:FireServer({
			Goal = "EmoteColor",
			Emote = emote,
			Color = color2
		})
	end

	return color2
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
		local v5 = (input.Position.Y - slider.AbsolutePosition.Y) / slider.AbsoluteSize.Y
		local slider2 = math.clamp(v5, 0, 1)

		if slider2 == v5 then
			shared.sfx({
				SoundId = "rbxassetid://7198717057",
				Volume = 0.5,
				Parent = localPlayer.PlayerGui
			}):Play()
		end

		slider.TextButton:TweenPosition(UDim2.new(0, 0, slider2, 0), nil, nil, 0.1, true)
		v3 = 1 - slider2
		v4.Slider = slider2
		fn3()
	else
		local mouseLocation = UserInputService:GetMouseLocation()
		local GuiService = game:GetService("GuiService")
		local v5 = mouseLocation - Vector2.new(0, GuiService:GetGuiInset().Y)
		local vector = Vector2.new(
			wheel.AbsolutePosition.X + wheel.AbsoluteSize.X / 2,
			wheel.AbsolutePosition.Y + wheel.AbsoluteSize.Y / 2
		)
		local magnitude = (v5 - vector).Magnitude
		local unit = (v5 - vector).unit

		if v or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local v6 = v5.X - wheel.AbsolutePosition.X
			local v7 = v5.Y - wheel.AbsolutePosition.Y
			local v8 = wheel.AbsoluteSize.X / 2
			shared.sfx({
				SoundId = "rbxassetid://7198717057",
				Volume = 0.5,
				Parent = localPlayer.PlayerGui
			}):Play()
			local uDim

			if magnitude <= wheel.AbsoluteSize.X * 0.5 then
				uDim = UDim2.new(0, v6, 0, v7)
			else
				uDim = UDim2.new(0, v8 + unit.X * v8, 0, v8 + unit.Y * v8)
			end

			cursor:TweenPosition(uDim, nil, nil, 0.1, true)
			v4.Cursor = { uDim.X.Offset, uDim.Y.Offset }
			local absolutePosition = cursor.Parent.AbsolutePosition
			local absoluteSize = cursor.Parent.AbsoluteSize
			local v9 = absolutePosition.X + uDim.X.Scale * absoluteSize.X + uDim.X.Offset
			local v10 = absolutePosition.Y + uDim.Y.Scale * absoluteSize.Y + uDim.Y.Offset
			color = fn2(vector, Vector2.new(v9, v10))
			fn3()
		end
	end
end)