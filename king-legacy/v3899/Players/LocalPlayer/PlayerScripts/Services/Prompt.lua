local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
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
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png"
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

-- equivalent calls inferred from this helper; original call sites unknown
local function setUpCircularProgressBar(progressBar)
	local uIGradient = progressBar.LeftGradient.ProgressBarImage.UIGradient
	local uIGradient2 = progressBar.RightGradient.ProgressBarImage.UIGradient
	progressBar.Progress.Changed:Connect(function(p)
		local v5 = math.clamp(p * 360, 0, 360)
		uIGradient.Rotation = math.clamp(v5, 180, 360)
		uIGradient2.Rotation = math.clamp(v5, 0, 180)
	end)
end

local function createPrompt(instance, p, parent)
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local tweenInfo = TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local clone = nil
	local theme = instance:GetAttribute("Theme")

	if theme then
		local child = script:FindFirstChild(theme)

		if child then
			clone = child:Clone()
		end
	end

	if clone == nil then
		clone = script.Default:Clone()
	end

	clone.Enabled = true
	local promptFrame = clone.PromptFrame
	local inputFrame = promptFrame.InputFrame
	local actionText = promptFrame.ActionText
	local objectText = promptFrame.ObjectText
	local backgroundTransparency = promptFrame.BackgroundTransparency
	local imageTransparency = promptFrame.ImageTransparency
	promptFrame.BackgroundTransparency = 1
	promptFrame.ImageTransparency = 1
	table.insert(v5, TweenService:Create(promptFrame, tweenInfo2, {
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		ImageTransparency = 1
	}))
	table.insert(v6, TweenService:Create(promptFrame, tweenInfo2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = backgroundTransparency,
		ImageTransparency = imageTransparency
	}))
	table.insert(v7, TweenService:Create(promptFrame, tweenInfo2, {
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		ImageTransparency = 1
	}))
	table.insert(v8, TweenService:Create(promptFrame, tweenInfo2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = backgroundTransparency,
		ImageTransparency = imageTransparency
	}))

	local function setupUIStrokeTweens(instance2)
		local transparency = instance2.Transparency
		instance2.Transparency = 1
		table.insert(v5, TweenService:Create(instance2, tweenInfo2, {
			Transparency = 1
		}))
		table.insert(v6, TweenService:Create(instance2, tweenInfo2, {
			Transparency = transparency
		}))
		table.insert(v7, TweenService:Create(instance2, tweenInfo2, {
			Transparency = 1
		}))
		table.insert(v8, TweenService:Create(instance2, tweenInfo2, {
			Transparency = transparency
		}))
	end

	local function setupGUIObjectTweens(instance2)
		local backgroundTransparency2 = instance2.BackgroundTransparency
		instance2.BackgroundTransparency = 1
		table.insert(v5, TweenService:Create(instance2, tweenInfo2, {
			BackgroundTransparency = 1
		}))
		table.insert(v6, TweenService:Create(instance2, tweenInfo2, {
			BackgroundTransparency = backgroundTransparency2
		}))
		table.insert(v7, TweenService:Create(instance2, tweenInfo2, {
			BackgroundTransparency = 1
		}))
		table.insert(v8, TweenService:Create(instance2, tweenInfo2, {
			BackgroundTransparency = backgroundTransparency2
		}))
	end

	local function setupTextLabelTweens(state)
		local textTransparency = state.TextTransparency
		local textStrokeTransparency = state.TextStrokeTransparency
		state.TextTransparency = 1
		state.TextStrokeTransparency = 1
		table.insert(v5, TweenService:Create(state, tweenInfo2, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}))
		table.insert(v6, TweenService:Create(state, tweenInfo2, {
			TextTransparency = textTransparency,
			TextStrokeTransparency = textStrokeTransparency
		}))
		table.insert(v7, TweenService:Create(state, tweenInfo2, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}))
		table.insert(v8, TweenService:Create(state, tweenInfo2, {
			TextTransparency = textTransparency,
			TextStrokeTransparency = textStrokeTransparency
		}))
	end

	local function setupImageLabelTweens(instance2)
		local imageTransparency2 = instance2.ImageTransparency
		instance2.ImageTransparency = 1
		table.insert(v5, TweenService:Create(instance2, tweenInfo2, {
			ImageTransparency = 1
		}))
		table.insert(v6, TweenService:Create(instance2, tweenInfo2, {
			ImageTransparency = imageTransparency2
		}))
		table.insert(v7, TweenService:Create(instance2, tweenInfo2, {
			ImageTransparency = 1
		}))
		table.insert(v8, TweenService:Create(instance2, tweenInfo2, {
			ImageTransparency = imageTransparency2
		}))
	end

	local setupUnexpectedChildTweens

	setupUnexpectedChildTweens = function(child)
		if child:IsA("UIStroke") then
			setupUIStrokeTweens(child)
		elseif not child:IsA("UIGradient") and child:IsA("GuiObject") then
			setupGUIObjectTweens(child)

			if child:IsA("TextLabel") then
				setupTextLabelTweens(child)
			elseif child:IsA("ImageLabel") then
				setupImageLabelTweens(child)
			end
		end

		for _, child2 in pairs(child:GetChildren()) do
			setupUnexpectedChildTweens(child2)
		end
	end

	local v9 = {
		[inputFrame] = false,
		[actionText] = true,
		[objectText] = true
	}

	for _, child in pairs(promptFrame:GetChildren()) do
		if v9[child] == nil then
			setupUnexpectedChildTweens(child)
		elseif v9[child] == true then
			for _, child2 in pairs(child:GetChildren()) do
				setupUnexpectedChildTweens(child2)
			end
		end
	end

	local frame = inputFrame.Frame
	local uIScale = frame.UIScale
	local scale = p == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	table.insert(v5, TweenService:Create(uIScale, tweenInfo2, {
		Scale = scale
	}))
	table.insert(v6, TweenService:Create(uIScale, tweenInfo2, {
		Scale = 1
	}))
	setupTextLabelTweens(actionText)
	setupTextLabelTweens(objectText)
	local buttonFrame = frame.ButtonFrame

	local function setupButtonFrameTweens()
		local backgroundTransparency2 = buttonFrame.BackgroundTransparency
		local imageTransparency2 = buttonFrame.ImageTransparency
		table.insert(v7, TweenService:Create(buttonFrame, tweenInfo3, {
			BackgroundTransparency = 1,
			ImageTransparency = 1
		}))
		table.insert(v8, TweenService:Create(buttonFrame, tweenInfo3, {
			BackgroundTransparency = backgroundTransparency2,
			ImageTransparency = imageTransparency2
		}))

		for _, uIStroke in pairs(buttonFrame:getChildren()) do
			if not uIStroke:IsA("UIStroke") then
				continue
			end

			local transparency = uIStroke.Transparency
			table.insert(v7, TweenService:Create(uIStroke, tweenInfo3, {
				Transparency = 1
			}))
			table.insert(v8, TweenService:Create(uIStroke, tweenInfo3, {
				Transparency = transparency
			}))
		end
	end

	setupButtonFrameTweens()
	local buttonImage = frame.ButtonImage
	local buttonText = frame.ButtonText
	local buttonTextImage = frame.ButtonTextImage

	local function setupButtonTextTweens()
		local textTransparency = buttonText.TextTransparency
		local textStrokeTransparency = buttonText.TextStrokeTransparency
		local backgroundTransparency2 = buttonText.BackgroundTransparency
		buttonText.BackgroundTransparency = 1
		buttonText.TextStrokeTransparency = 1
		buttonText.TextTransparency = 1
		table.insert(v7, TweenService:Create(buttonText, tweenInfo3, {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
			BackgroundTransparency = 1
		}))
		table.insert(v8, TweenService:Create(buttonText, tweenInfo3, {
			TextTransparency = textTransparency,
			TextStrokeTransparency = textStrokeTransparency,
			BackgroundTransparency = backgroundTransparency2
		}))

		for _, uIStroke in pairs(buttonText:getChildren()) do
			if not uIStroke:IsA("UIStroke") then
				continue
			end

			local transparency = uIStroke.Transparency
			table.insert(v7, TweenService:Create(uIStroke, tweenInfo3, {
				Transparency = 1
			}))
			table.insert(v8, TweenService:Create(uIStroke, tweenInfo3, {
				Transparency = transparency
			}))
		end
	end

	local function setupButtonImageTweens()
		local imageTransparency2 = buttonImage.ImageTransparency
		local backgroundTransparency2 = buttonImage.BackgroundTransparency
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 1
		table.insert(v7, TweenService:Create(buttonImage, tweenInfo3, {
			ImageTransparency = 1,
			BackgroundTransparency = 1
		}))
		table.insert(v8, TweenService:Create(buttonImage, tweenInfo3, {
			ImageTransparency = imageTransparency2,
			BackgroundTransparency = backgroundTransparency2
		}))
	end

	local function setupIconTweens()
		local backgroundTransparency2 = buttonTextImage.BackgroundTransparency
		local imageTransparency2 = buttonTextImage.ImageTransparency
		buttonTextImage.BackgroundTransparency = 1
		buttonTextImage.ImageTransparency = 1
		table.insert(v7, TweenService:Create(buttonTextImage, tweenInfo3, {
			ImageTransparency = 1,
			BackgroundTransparency = 1
		}))
		table.insert(v8, TweenService:Create(buttonTextImage, tweenInfo3, {
			ImageTransparency = imageTransparency2,
			BackgroundTransparency = backgroundTransparency2
		}))
	end

	if p == Enum.ProximityPromptInputType.Gamepad then
		if v[instance.GamepadKeyCode] then
			setupIconTweens()
			buttonTextImage.Image = v[instance.GamepadKeyCode]
			buttonText.Visible = false
			buttonImage.Visible = false
			buttonTextImage.Visible = true
		end
	elseif p == Enum.ProximityPromptInputType.Touch then
		setupButtonImageTweens()
		buttonImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		buttonText.Visible = false
		buttonTextImage.Visible = false
		buttonImage.Visible = true
	else
		setupButtonImageTweens()
		buttonImage.Visible = true
		local stringForKeyCode = UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)
		local image = v2[instance.KeyboardKeyCode]

		if image == nil then
			image = v3[stringForKeyCode]
		end

		if image == nil then
			stringForKeyCode = v4[instance.KeyboardKeyCode] or stringForKeyCode
		end

		if image then
			setupIconTweens()
			buttonTextImage.Image = image
			buttonText.Visible = false
			buttonTextImage.Visible = true
		elseif stringForKeyCode == nil or stringForKeyCode == "" then
			error("ProximityPrompt '" .. instance.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(instance.KeyboardKeyCode))
		else
			if string.len(stringForKeyCode) > 2 then
				buttonText.TextSize = math.round(buttonText.TextSize * 6 / 7)
			end

			setupButtonTextTweens()
			buttonText.Text = stringForKeyCode
			buttonTextImage.Visible = false
			buttonText.Visible = true
		end
	end

	if p == Enum.ProximityPromptInputType.Touch or instance.ClickablePrompt then
		local textButton = clone.TextButton
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
		clone.Active = true
	end

	if instance.HoldDuration > 0 then
		local progressBar = frame.ProgressBar
		setUpCircularProgressBar(progressBar) -- equivalent call inferred; original call site unknown
		table.insert(v5, TweenService:Create(progressBar.Progress, tweenInfo, {
			Value = 1
		}))
		table.insert(v6, TweenService:Create(progressBar.Progress, tweenInfo4, {
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
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = instance.ActionText
		getTextBoundsParams.Font = actionText.FontFace
		getTextBoundsParams.Size = actionText.TextSize
		getTextBoundsParams.Width = 1000
		local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
		local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
		getTextBoundsParams2.Text = instance.ObjectText
		getTextBoundsParams2.Font = objectText.FontFace
		getTextBoundsParams2.Size = objectText.TextSize
		getTextBoundsParams2.Width = 1000
		local textBoundsAsync2 = TextService:GetTextBoundsAsync(getTextBoundsParams2)
		local v11 = math.max(textBoundsAsync.X, textBoundsAsync2.X)
		local v12 = (instance.ActionText == nil or instance.ActionText == "") and (instance.ObjectText == nil or instance.ObjectText == "") and 72 or v11 + 72 + 24
		local v13 = (instance.ObjectText == nil or instance.ObjectText == "") and 0 or 9
		actionText.Position = UDim2.new(0.5, 72 - v12 / 2, 0, v13)
		objectText.Position = UDim2.new(0.5, 72 - v12 / 2, 0, -10)
		actionText.Text = instance.ActionText
		objectText.Text = instance.ObjectText
		actionText.AutoLocalize = instance.AutoLocalize
		actionText.RootLocalizationTable = instance.RootLocalizationTable
		objectText.AutoLocalize = instance.AutoLocalize
		objectText.RootLocalizationTable = instance.RootLocalizationTable
		clone.Size = UDim2.fromOffset(v12, 72)
		clone.SizeOffset = Vector2.new(
			instance.UIOffset.X / clone.Size.Width.Offset,
			instance.UIOffset.Y / clone.Size.Height.Offset
		)
	end

	local changedConnection = instance.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()
	clone.Adornee = instance.Parent
	clone.Parent = parent

	for _, v11 in ipairs(v8) do
		v11:Play()
	end

	local function cleanup()
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

		wait(0.2)
		clone.Parent = nil
	end

	return cleanup
end

local highlight = nil

local function onLoad()
	ProximityPromptService.PromptShown:Connect(function(instance, p)
		if instance.Style == Enum.ProximityPromptStyle.Default then
			return
		end

		local v5 = playerGui:FindFirstChild("ProximityPrompts")

		if v5 == nil then
			v5 = Instance.new("ScreenGui")
			v5.Name = "ProximityPrompts"
			v5.ResetOnSpawn = false
			v5.Parent = playerGui
		end

		local prompt = createPrompt(instance, p, v5)

		if highlight then
			highlight:Destroy()
			highlight = nil
		end

		if instance.Parent and instance.Name ~= "MovePrompt" then
			highlight = Instance.new("Highlight")
			highlight.Name = "PromptHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.Parent = instance.Parent

			if instance.Parent.Name == "Attachment" then
				highlight.Parent = instance.Parent.Parent
			end
		end

		instance.PromptHidden:Wait()

		if highlight then
			highlight:Destroy()
			highlight = nil
		end

		prompt()
	end)
end

ProximityPromptService.PromptShown:Connect(function(instance, p)
	if instance.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	local v5 = playerGui:FindFirstChild("ProximityPrompts")

	if v5 == nil then
		v5 = Instance.new("ScreenGui")
		v5.Name = "ProximityPrompts"
		v5.ResetOnSpawn = false
		v5.Parent = playerGui
	end

	local prompt = createPrompt(instance, p, v5)

	if highlight then
		highlight:Destroy()
		highlight = nil
	end

	if instance.Parent and instance.Name ~= "MovePrompt" then
		highlight = Instance.new("Highlight")
		highlight.Name = "PromptHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.Parent = instance.Parent

		if instance.Parent.Name == "Attachment" then
			highlight.Parent = instance.Parent.Parent
		end
	end

	instance.PromptHidden:Wait()

	if highlight then
		highlight:Destroy()
		highlight = nil
	end

	prompt()
end)