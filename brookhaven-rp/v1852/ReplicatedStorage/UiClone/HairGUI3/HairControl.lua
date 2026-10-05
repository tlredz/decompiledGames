local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
workspace:WaitForChild(localPlayer.Name):WaitForChild("Humanoid")
local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local maxy = module.Maxy
local UserInputService = game:GetService("UserInputService")
local frame = script.Parent:WaitForChild("Frame")
local finalColor = frame:WaitForChild("FinalColor")
local darknessBar = frame:WaitForChild("DarknessBar")
local palette = frame:WaitForChild("Palette")
local uIGradient = frame:WaitForChild("DarknessBar"):WaitForChild("UIGradient")
local hue = script:WaitForChild("Hue")
local hue2 = script:WaitForChild("Hue")
local saturation = script:WaitForChild("Saturation")
local value = script:WaitForChild("Value")
local color = Color3.new(0, 0, 0)
local v = false

if UserInputService.GamepadEnabled then
	palette.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v2 in gamepadState do
			if not (v2.KeyCode == Enum.KeyCode.ButtonA and v2.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			local v3 = (p.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X
			local v4 = (p.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y
			local v5 = math.sqrt((v3 - 0.5) ^ 2 + (v4 - 0.5) ^ 2)

			if v5 > 0.5 then
				v3 = (v3 - 0.5) / v5 * 0.5 + 0.5
				v4 = (v4 - 0.5) / v5 * 0.5 + 0.5
				v5 = 0.5
			end

			local v6 = math.atan2(v4 - 0.5, v3 - 0.5)
			local v7 = (3.141592653589793 - v6) / 6.283185307179586
			hue2.Value = v7
			saturation.Value = v5 * 2
			finalColor.BackgroundColor3 = Color3.fromHSV(v7, v5 * 2, value.Value)
			uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v7, v5 * 2, 1))
		end
	end)
end

if UserInputService.GamepadEnabled then
	darknessBar.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v2 in gamepadState do
			if not (v2.KeyCode == Enum.KeyCode.ButtonA and v2.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			value.Value = 1 - math.clamp(
				(p.Position.Y - darknessBar.AbsolutePosition.Y) / darknessBar.AbsoluteSize.Y,
				0,
				1
			)
			finalColor.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
		end
	end)
end

palette.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local v2 = (input.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X
		local v3 = (input.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y
		local v4 = math.sqrt((v2 - 0.5) ^ 2 + (v3 - 0.5) ^ 2)

		if v4 > 0.5 then
			v2 = (v2 - 0.5) / v4 * 0.5 + 0.5
			v3 = (v3 - 0.5) / v4 * 0.5 + 0.5
			v4 = 0.5
		end

		local v5 = math.atan2(v3 - 0.5, v2 - 0.5)
		local v6 = (3.141592653589793 - v5) / 6.283185307179586
		hue2.Value = v6
		saturation.Value = v4 * 2
		finalColor.BackgroundColor3 = Color3.fromHSV(v6, v4 * 2, value.Value)
		uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v6, v4 * 2, 1))
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
darknessBar.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		value.Value = 1 - math.clamp(
			(input.Position.Y - darknessBar.AbsolutePosition.Y) / darknessBar.AbsoluteSize.Y,
			0,
			1
		)
		finalColor.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
finalColor.MouseButton1Click:Connect(function()
	if v == false then
		v = true
		maxy:FireServer("ChangeHairColor3", finalColor.BackgroundColor3)
		wait(0.5)
		v = false
	end
end)