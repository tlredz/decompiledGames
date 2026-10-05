local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxView.png",
	[Enum.KeyCode.ButtonStart] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLB.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRB.png",
	[Enum.KeyCode.ButtonL2] = "rbxasset://textures/ui/Controls/xboxLT.png",
	[Enum.KeyCode.ButtonR2] = "rbxasset://textures/ui/Controls/xboxRT.png",
	[Enum.KeyCode.ButtonL3] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR3] = "rbxasset://textures/ui/Controls/xboxRS.png",
	[Enum.KeyCode.Thumbstick1] = "rbxasset://textures/ui/Controls/xboxLSDirectional.png",
	[Enum.KeyCode.Thumbstick2] = "rbxasset://textures/ui/Controls/xboxRSDirectional.png"
}
local v2 = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png"
}
local v3 = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png"
}
local v4 = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12"
}

local function getScreenGui()
	local v5 = playerGui:FindFirstChild("ProximityPrompts")

	if v5 ~= nil then
		return v5
	end

	v5 = Instance.new("ScreenGui")
	v5.Name = "ProximityPrompts"
	v5.ResetOnSpawn = false
	v5.Parent = playerGui
	return v5
end

local function createProgressBarGradient(frame, p)
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.fromScale(0.5, 1)
	frame2.Position = UDim2.fromScale(p and 0 or 0.5, 0)
	frame2.BackgroundTransparency = 1
	frame2.ClipsDescendants = true
	frame2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(2, 1)
	imageLabel.Position = UDim2.fromScale(p and 0 or -1, 0)
	imageLabel.Image = "rbxasset://textures/ui/Controls/RadialFill.png"
	imageLabel.Parent = frame2
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4999, 0),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Rotation = p and 180 or 0
	uIGradient.Parent = imageLabel
	return uIGradient
end

local function createCircularProgressBar()
	local frame = Instance.new("Frame")
	frame.Name = "CircularProgressBar"
	frame.Size = UDim2.fromOffset(58, 58)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.BackgroundTransparency = 1
	local progressBarGradient = createProgressBarGradient(frame, true)
	local progressBarGradient2 = createProgressBarGradient(frame, false)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "Progress"
	numberValue.Parent = frame
	numberValue.Changed:Connect(function(p)
		local v5 = math.clamp(p * 360, 0, 360)
		progressBarGradient.Rotation = math.clamp(v5, 180, 360)
		progressBarGradient2.Rotation = math.clamp(v5, 0, 180)
	end)
	return frame
end

local function createPrompt(instance, p, parent)
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local tweenInfo = TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "Prompt"
	billboardGui.AlwaysOnTop = true
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.5, 1)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = Color3.new(0.07, 0.07, 0.07)
	frame.Parent = billboardGui
	local v9 = instance:GetAttribute("State") == "Sell"

	if v9 then
		frame.BackgroundColor3 = Color3.fromRGB(67, 0, 0)
	end

	local backgroundColor = instance:GetAttribute("BackgroundColor")

	if typeof(backgroundColor) == "Color3" then
		frame.BackgroundColor3 = backgroundColor
	end

	local uICorner_2 = Instance.new("UICorner")
	uICorner_2.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "InputFrame"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundTransparency = 1
	frame2.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.Position = UDim2.fromScale(0.5, 0.5)
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.BackgroundTransparency = 1
	frame3.Parent = frame2
	local uIScale = Instance.new("UIScale")
	uIScale.Parent = frame3
	local scale = p == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	table.insert(v5, TweenService:Create(uIScale, tweenInfo3, {
		Scale = scale
	}))
	table.insert(v6, TweenService:Create(uIScale, tweenInfo3, {
		Scale = 1
	}))
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ActionText"
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 19
	textLabel.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	local actionColor = instance:GetAttribute("ActionColor")

	if typeof(actionColor) == "Color3" then
		textLabel.TextColor3 = actionColor
	end

	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	table.insert(v5, TweenService:Create(textLabel, tweenInfo3, {
		TextTransparency = 1
	}))
	table.insert(v6, TweenService:Create(textLabel, tweenInfo3, {
		TextTransparency = 0
	}))
	table.insert(v7, TweenService:Create(textLabel, tweenInfo3, {
		TextTransparency = 1
	}))
	table.insert(v8, TweenService:Create(textLabel, tweenInfo3, {
		TextTransparency = 0
	}))
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "ObjectText"
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextSize = 14
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextTransparency = 1
	textLabel2.TextColor3 = Color3.new(0.7, 0.7, 0.7)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = frame
	table.insert(v5, TweenService:Create(textLabel2, tweenInfo3, {
		TextTransparency = 1
	}))
	table.insert(v6, TweenService:Create(textLabel2, tweenInfo3, {
		TextTransparency = 0
	}))
	table.insert(v7, TweenService:Create(textLabel2, tweenInfo3, {
		TextTransparency = 1
	}))
	table.insert(v8, TweenService:Create(textLabel2, tweenInfo3, {
		TextTransparency = 0
	}))
	table.insert(v5, TweenService:Create(frame, tweenInfo3, {
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1
	}))
	table.insert(v6, TweenService:Create(frame, tweenInfo3, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.2
	}))
	table.insert(v7, TweenService:Create(frame, tweenInfo3, {
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1
	}))
	table.insert(v8, TweenService:Create(frame, tweenInfo3, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.2
	}))
	local frame4 = Instance.new("Frame")
	frame4.Name = "RoundFrame"
	frame4.Size = UDim2.fromOffset(48, 48)
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.Position = UDim2.fromScale(0.5, 0.5)
	frame4.BackgroundTransparency = 1
	frame4.Parent = frame3
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame4
	table.insert(v7, TweenService:Create(frame4, tweenInfo4, {
		BackgroundTransparency = 1
	}))
	table.insert(v8, TweenService:Create(frame4, tweenInfo4, {
		BackgroundTransparency = 0.5
	}))

	if p == Enum.ProximityPromptInputType.Gamepad then
		if v[instance.GamepadKeyCode] ~= nil then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "ButtonImage"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(24, 24)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.ImageTransparency = 1
			imageLabel.Image = UserInputService:GetImageForKeyCode(instance.GamepadKeyCode)
			imageLabel.Parent = frame3
			table.insert(v7, TweenService:Create(imageLabel, tweenInfo4, {
				ImageTransparency = 1
			}))
			table.insert(v8, TweenService:Create(imageLabel, tweenInfo4, {
				ImageTransparency = 0
			}))
		end
	elseif p == Enum.ProximityPromptInputType.Touch then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ButtonImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = 1
		imageLabel.Size = UDim2.fromOffset(25, 31)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		imageLabel.Parent = frame3
		table.insert(v7, TweenService:Create(imageLabel, tweenInfo4, {
			ImageTransparency = 1
		}))
		table.insert(v8, TweenService:Create(imageLabel, tweenInfo4, {
			ImageTransparency = 0
		}))
	else
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ButtonImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = 1
		imageLabel.Size = UDim2.fromOffset(28, 30)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Image = "rbxasset://textures/ui/Controls/key_single.png"
		imageLabel.Parent = frame3
		table.insert(v7, TweenService:Create(imageLabel, tweenInfo4, {
			ImageTransparency = 1
		}))
		table.insert(v8, TweenService:Create(imageLabel, tweenInfo4, {
			ImageTransparency = 0
		}))
		local stringForKeyCode = UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)
		local image = v2[instance.KeyboardKeyCode]

		if image == nil then
			image = v3[stringForKeyCode]
		end

		if image == nil then
			stringForKeyCode = v4[instance.KeyboardKeyCode] or stringForKeyCode
		end

		if image then
			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Name = "ButtonImage"
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel2.Size = UDim2.fromOffset(36, 36)
			imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.ImageTransparency = 1
			imageLabel2.Image = image
			imageLabel2.Parent = frame3
			table.insert(v7, TweenService:Create(imageLabel2, tweenInfo4, {
				ImageTransparency = 1
			}))
			table.insert(v8, TweenService:Create(imageLabel2, tweenInfo4, {
				ImageTransparency = 0
			}))
		elseif stringForKeyCode == nil or stringForKeyCode == "" then
			error("ProximityPrompt '" .. instance.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(instance.KeyboardKeyCode))
		else
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "ButtonText"
			textLabel3.Position = UDim2.fromOffset(0, -1)
			textLabel3.Size = UDim2.fromScale(1, 1)
			textLabel3.Font = Enum.Font.GothamMedium
			textLabel3.TextSize = 14

			if string.len(stringForKeyCode) > 2 then
				textLabel3.TextSize = 12
			end

			textLabel3.BackgroundTransparency = 1
			textLabel3.TextTransparency = 1
			textLabel3.TextColor3 = Color3.new(1, 1, 1)
			textLabel3.TextXAlignment = Enum.TextXAlignment.Center
			textLabel3.Text = stringForKeyCode
			textLabel3.Parent = frame3
			table.insert(v7, TweenService:Create(textLabel3, tweenInfo4, {
				TextTransparency = 1
			}))
			table.insert(v8, TweenService:Create(textLabel3, tweenInfo4, {
				TextTransparency = 0
			}))
		end
	end

	if p == Enum.ProximityPromptInputType.Touch or instance.ClickablePrompt then
		local textButton = Instance.new("TextButton")
		textButton.BackgroundTransparency = 1
		textButton.TextTransparency = 1
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Parent = billboardGui
		local v11 = false
		textButton.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
				instance:InputHoldBegin()
				v11 = true
			end
		end)
		textButton.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and v11 then
				v11 = false
				instance:InputHoldEnd()
			end
		end)
		billboardGui.Active = true
	end

	if instance.HoldDuration > 0 then
		local circularProgressBar = createCircularProgressBar()
		circularProgressBar.Parent = frame3
		table.insert(v5, TweenService:Create(circularProgressBar.Progress, tweenInfo, {
			Value = 1
		}))
		table.insert(v6, TweenService:Create(circularProgressBar.Progress, tweenInfo2, {
			Value = 0
		}))
	end

	local promptButtonHoldBeganConnection, promptButtonHoldEndedConnection

	if instance.HoldDuration > 0 then
		promptButtonHoldBeganConnection = instance.PromptButtonHoldBegan:Connect(function()
			for _, v11 in ipairs(v5) do
				v11:Play()
			end
		end)
		promptButtonHoldEndedConnection = instance.PromptButtonHoldEnded:Connect(function()
			for _, v11 in ipairs(v6) do
				v11:Play()
			end
		end)
	else
		promptButtonHoldBeganConnection = nil
		promptButtonHoldEndedConnection = nil
	end

	local triggeredConnection = instance.Triggered:Connect(function()
		for _, v11 in ipairs(v7) do
			v11:Play()
		end
	end)
	local triggerEndedConnection = instance.TriggerEnded:Connect(function()
		for _, v11 in ipairs(v8) do
			v11:Play()
		end
	end)

	local function updateUIFromPrompt()
		local textSize = TextService:GetTextSize(
			instance.ActionText,
			19,
			Enum.Font.GothamMedium,
			Vector2.new(1000, 1000)
		)
		local textSize2 = TextService:GetTextSize(
			instance.ObjectText,
			14,
			Enum.Font.GothamMedium,
			Vector2.new(1000, 1000)
		)
		local v11 = math.max(textSize.X, textSize2.X)
		local v12, v13, v14

		if v9 then
			v12 = 62
			v13 = 62
			v14 = 62
		else
			v12 = 72
			v13 = 72
			v14 = 72
		end

		if instance.ActionText ~= nil and instance.ActionText ~= "" or instance.ObjectText ~= nil and instance.ObjectText ~= "" then
			v12 = v11 + v13 + 24
		end

		local v15 = (instance.ObjectText == nil or instance.ObjectText == "") and 0 or 9
		textLabel.Position = UDim2.new(0.5, v13 - v12 / 2, 0, v15)
		textLabel2.Position = UDim2.new(0.5, v13 - v12 / 2, 0, -10)
		textLabel.Text = instance.ActionText
		textLabel2.Text = instance.ObjectText
		textLabel.AutoLocalize = instance.AutoLocalize
		textLabel.RootLocalizationTable = instance.RootLocalizationTable
		textLabel2.AutoLocalize = instance.AutoLocalize
		textLabel2.RootLocalizationTable = instance.RootLocalizationTable
		billboardGui.Size = UDim2.fromOffset(v12, v14)
		billboardGui.SizeOffset = Vector2.new(
			instance.UIOffset.X / billboardGui.Size.Width.Offset,
			instance.UIOffset.Y / billboardGui.Size.Height.Offset
		)
	end

	local changedConnection = instance.Changed:Connect(updateUIFromPrompt)
	task.spawn(updateUIFromPrompt)
	billboardGui.Adornee = instance.Parent
	billboardGui.Parent = parent

	for _, v11 in ipairs(v8) do
		v11:Play()
	end

	local flag = false

	local function cleanup()
		if flag then
			return
		end

		flag = true

		if promptButtonHoldBeganConnection then
			promptButtonHoldBeganConnection:Disconnect()
		end

		if promptButtonHoldEndedConnection then
			promptButtonHoldEndedConnection:Disconnect()
		end

		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()
		changedConnection:Disconnect()

		for _, v11 in ipairs(v7) do
			v11:Play()
		end

		task.wait(0.2)
		billboardGui.Parent = nil
	end

	return cleanup
end

local function onLoad()
	local v5 = false
	local v6 = {}
	ProximityPromptService.PromptShown:Connect(function(instance, p)
		if instance.Style == Enum.ProximityPromptStyle.Default or instance:GetAttribute("CustomStyleDisabled") or (instance:GetAttribute("State") == "Sell" or instance:GetAttribute("State") == "Grab") and v5 then
			return
		end

		local v7 = playerGui:FindFirstChild("ProximityPrompts")

		if v7 == nil then
			v7 = Instance.new("ScreenGui")
			v7.Name = "ProximityPrompts"
			v7.ResetOnSpawn = false
			v7.Parent = playerGui
		end

		local prompt = createPrompt(instance, p, v7)
		local enabledChangedConnection = nil
		local promptHiddenConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanupFunction()
			v6[instance] = nil

			if enabledChangedConnection then
				enabledChangedConnection:Disconnect()
			end

			if promptHiddenConnection then
				promptHiddenConnection:Disconnect()
			end

			prompt()
		end

		enabledChangedConnection = instance:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not instance.Enabled then
				cleanupFunction() -- equivalent call inferred; original call site unknown
			end
		end)
		promptHiddenConnection = instance.PromptHidden:Connect(function()
			cleanupFunction() -- equivalent call inferred; original call site unknown
		end)

		if instance.Enabled then
			v6[instance] = cleanupFunction
		else
			cleanupFunction() -- equivalent call inferred; original call site unknown
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(p)
		if v6[p] then
			v6[p]()
			v6[p] = nil
		end
	end)
	ProximityPromptService.PromptButtonHoldBegan:Connect(function()
		v5 = true
	end)
	ProximityPromptService.PromptButtonHoldEnded:Connect(function()
		v5 = false
	end)
end

task.spawn(onLoad)
return {}