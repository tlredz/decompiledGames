local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = nil
task.spawn(function()
	local success, result = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(localPlayer)
	end)

	if success then
		v = result
	end
end)
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

function getScreenGui()
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

function setUpCircularProgressBar(data)
	local uIGradient = data.LeftGradient.ProgressBarImage.UIGradient
	local uIGradient2 = data.RightGradient.ProgressBarImage.UIGradient
	data.Progress.Changed:Connect(function(p)
		local v5 = math.clamp(p * 360, 0, 360)
		uIGradient.Rotation = math.clamp(v5, 180, 360)
		uIGradient2.Rotation = math.clamp(v5, 0, 180)
	end)
end

function createPrompt(instance, p, parent)
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
	local textFrame = promptFrame:FindFirstChild("TextFrame")
	local v9 = textFrame ~= nil
	local uIListLayout = promptFrame:FindFirstChildOfClass("UIListLayout")
	local uIPadding = promptFrame:FindFirstChildOfClass("UIPadding")
	local actionText = v9 and textFrame.ActionText or promptFrame.ActionText
	local objectText = v9 and textFrame.ObjectText or promptFrame.ObjectText
	local backgroundTransparency = promptFrame.BackgroundTransparency
	local imageTransparency = promptFrame.ImageTransparency
	promptFrame.BackgroundTransparency = 1
	promptFrame.ImageTransparency = 1

	if v9 then
		table.insert(v5, TweenService:Create(promptFrame, tweenInfo2, {
			BackgroundTransparency = 1,
			ImageTransparency = 1
		}))
		table.insert(v6, TweenService:Create(promptFrame, tweenInfo2, {
			BackgroundTransparency = backgroundTransparency,
			ImageTransparency = imageTransparency
		}))
		table.insert(v7, TweenService:Create(promptFrame, tweenInfo2, {
			BackgroundTransparency = 1,
			ImageTransparency = 1
		}))
		table.insert(v8, TweenService:Create(promptFrame, tweenInfo2, {
			BackgroundTransparency = backgroundTransparency,
			ImageTransparency = imageTransparency
		}))

		if uIListLayout then
			table.insert(v5, TweenService:Create(uIListLayout, tweenInfo2, {
				Padding = UDim.new(-0.25, 0)
			}))
			table.insert(v6, TweenService:Create(uIListLayout, tweenInfo2, {
				Padding = UDim.new(0, 0)
			}))
			table.insert(v7, TweenService:Create(uIListLayout, tweenInfo2, {
				Padding = UDim.new(-0.25, 0)
			}))
			table.insert(v8, TweenService:Create(uIListLayout, tweenInfo2, {
				Padding = UDim.new(0, 0)
			}))
		end
	else
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
	end

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

	local v10 = {
		[inputFrame] = false,
		[actionText] = true,
		[objectText] = true
	}

	if textFrame then
		v10[textFrame] = false

		for _, child in pairs(actionText:GetChildren()) do
			setupUnexpectedChildTweens(child)
		end

		for _, child in pairs(objectText:GetChildren()) do
			setupUnexpectedChildTweens(child)
		end
	end

	for _, child in pairs(promptFrame:GetChildren()) do
		if v10[child] == nil then
			setupUnexpectedChildTweens(child)
		elseif v10[child] == true then
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
		local imageForKeyCode = UserInputService:GetImageForKeyCode(instance.GamepadKeyCode)

		if imageForKeyCode then
			setupIconTweens()
			buttonTextImage.Image = imageForKeyCode
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
		local v12 = false
		textButton.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
				instance:InputHoldBegin()
				v12 = true
			end
		end)
		textButton.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and v12 then
				v12 = false
				instance:InputHoldEnd()
			end
		end)
		clone.Active = true
	end

	if instance.HoldDuration > 0 then
		local progressBar = frame.ProgressBar
		setUpCircularProgressBar(progressBar)
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
			for _, v12 in ipairs(v5) do
				v12:Play()
			end
		end)
		promptButtonHoldEndedConnection = instance.PromptButtonHoldEnded:Connect(function()
			for _, v12 in ipairs(v6) do
				v12:Play()
			end
		end)
	else
		promptButtonHoldBeganConnection = nil
		promptButtonHoldEndedConnection = nil
	end

	local triggeredConnection = instance.Triggered:Connect(function()
		for _, v12 in ipairs(v7) do
			v12:Play()
		end
	end)
	local triggerEndedConnection = instance.TriggerEnded:Connect(function()
		for _, v12 in ipairs(v8) do
			v12:Play()
		end
	end)

	local function translatePromptText(p2: string, p3)
		if p2 == "" or not instance.AutoLocalize or not v then
			return p2
		end

		local v12 = v
		local success, result = pcall(function()
			return v12:Translate(p3, p2)
		end)

		if success and result ~= nil and result ~= "" then
			return result
		end

		return p2
	end

	local function measureTextBounds(text: string, p2)
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = p2.FontFace
		getTextBoundsParams.Size = p2.TextSize
		getTextBoundsParams.Width = 1000
		local success, result = pcall(function()
			return TextService:GetTextBoundsAsync(getTextBoundsParams)
		end)
		getTextBoundsParams:Destroy()

		if success and result then
			return Vector2.new(math.ceil(result.X), (math.ceil(result.Y)))
		end

		return Vector2.zero
	end

	local count = 0

	local function applyPromptSize(p2: number, p3: number, p4: number, p5: number, flag: boolean)
		if flag then
			if v9 then
				actionText.Position = UDim2.new(0, 0, 0, p4)
				objectText.Position = UDim2.new(0, 0, 0, -10)
			else
				actionText.Position = UDim2.new(0.5, p5 - p2 / 2, 0, p4)
				objectText.Position = UDim2.new(0.5, p5 - p2 / 2, 0, -10)
			end
		end

		clone.Size = UDim2.fromOffset(p2, p3)
		clone.SizeOffset = Vector2.new(
			instance.UIOffset.X / clone.Size.Width.Offset,
			instance.UIOffset.Y / clone.Size.Height.Offset
		)
	end

	local function updateUIFromPrompt()
		count += 1
		local v12 = count
		local actionText2 = instance.ActionText
		local v13 = actionText

		if actionText2 ~= "" and instance.AutoLocalize and v then
			local v14 = v
			local success, result = pcall(function()
				return v14:Translate(v13, actionText2)
			end)

			if success and result ~= nil and result ~= "" then
				actionText2 = result
			end
		end

		local objectText2 = instance.ObjectText
		local v14 = objectText

		if objectText2 ~= "" and instance.AutoLocalize and v then
			local v15 = v
			local success, result = pcall(function()
				return v15:Translate(v14, objectText2)
			end)

			if success and result ~= nil and result ~= "" then
				objectText2 = result
			end
		end

		local v15 = measureTextBounds(actionText2, actionText)
		local v16 = measureTextBounds(objectText2, objectText)
		local v17 = math.max(v15.X, v16.X)
		local v18 = 72
		local v19

		if instance.ActionText == nil or instance.ActionText == "" then
			if instance.ObjectText == nil then
				v19 = false
			else
				v19 = instance.ObjectText ~= ""
			end
		else
			v19 = true
		end

		if v19 then
			v18 = v17 + 72 + 24
		end

		if v9 and uIPadding then
			local v20 = (instance.ObjectText == nil or instance.ObjectText == "") and 0 or 9

			if v19 then
				uIPadding.PaddingRight = UDim.new(0, 24 - v20)
			else
				uIPadding.PaddingRight = UDim.new(0, 0)
			end
		end

		local v20 = (instance.ObjectText == nil or instance.ObjectText == "") and 0 or 9
		local theme2 = instance:GetAttribute("Theme")
		local v21 = theme2 == "Coins" or theme2 == "AutoDelete"
		local v22 = v9 or not v21

		if v21 then
			local pricingFrame = actionText:WaitForChild("PricingFrame")
			local priceText = pricingFrame:WaitForChild("PriceText")
			local coinImage = pricingFrame:WaitForChild("CoinImage")
			local uIListLayout2 = pricingFrame:WaitForChild("UIListLayout")
			local v23 = tonumber(string.match(instance.ActionText, "(%d+)"))

			if v23 then
				local currencyIcon = instance:GetAttribute("CurrencyIcon")

				if currencyIcon then
					coinImage.Image = currencyIcon
				end

				local horizontalPadding = instance:GetAttribute("HorizontalPadding")

				if horizontalPadding then
					uIListLayout2.Padding = UDim.new(horizontalPadding, 0)
				end

				pricingFrame.Visible = true
				priceText.Visible = true
				local text = string.gsub(instance.ActionText, tostring(v23), "")
				actionText.Text = text
				actionText.AutoLocalize = instance.AutoLocalize
				actionText.RootLocalizationTable = instance.RootLocalizationTable
				objectText.Text = instance.ObjectText
				objectText.AutoLocalize = instance.AutoLocalize
				objectText.RootLocalizationTable = instance.RootLocalizationTable
				priceText.Text = tostring(v23)
				priceText.AutoLocalize = instance.AutoLocalize
				priceText.RootLocalizationTable = instance.RootLocalizationTable
				local v25 = actionText

				if text ~= "" and instance.AutoLocalize and v then
					local v26 = v
					local success, result = pcall(function()
						return v26:Translate(v25, text)
					end)

					if success and result ~= nil and result ~= "" then
						text = result
					end
				end

				local X = measureTextBounds(text, actionText).X
				local X2 = measureTextBounds(tostring(v23), priceText).X
				v18 = math.max(v16.X, X + 36 + X2 + uIListLayout2.Padding.Offset) + 72 + 42

				if v9 and uIPadding then
					uIPadding.PaddingRight = UDim.new(0, 24 - v20 + 36 + X2 + uIListLayout2.Padding.Offset)
				end
			else
				pricingFrame.Visible = false
				priceText.Visible = false
				actionText.Text = instance.ActionText
				actionText.AutoLocalize = instance.AutoLocalize
				actionText.RootLocalizationTable = instance.RootLocalizationTable
				objectText.Text = instance.ObjectText
				objectText.AutoLocalize = instance.AutoLocalize
				objectText.RootLocalizationTable = instance.RootLocalizationTable
			end

			applyPromptSize(v18, 72, v20, 72, v22)
		else
			actionText.Text = instance.ActionText
			objectText.Text = instance.ObjectText
			actionText.AutoLocalize = instance.AutoLocalize
			actionText.RootLocalizationTable = instance.RootLocalizationTable
			objectText.AutoLocalize = instance.AutoLocalize
			objectText.RootLocalizationTable = instance.RootLocalizationTable
			applyPromptSize(v18, 72, v20, 72, true)
		end

		task.defer(function()
			RunService.RenderStepped:Wait()
			RunService.RenderStepped:Wait()

			if v12 ~= count or clone.Parent == nil or not v19 then
				return
			end

			local X

			if v9 then
				X = promptFrame.AbsoluteSize.X

				if X <= 0 then
					return
				end
			else
				local v23 = math.max(actionText.TextBounds.X, objectText.TextBounds.X)

				if v23 <= 0 then
					return
				else
					X = v23 + 72 + 42
				end
			end

			if math.abs(X - clone.Size.Width.Offset) < 1 then
				return
			end

			applyPromptSize(X, 72, v20, 72, v22)
		end)
	end

	local changedConnection = instance.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()
	clone.Adornee = instance.Parent
	clone.Parent = parent

	for _, v12 in ipairs(v8) do
		v12:Play()
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

		for _, v12 in ipairs(v7) do
			v12:Play()
		end

		wait(0.2)
		clone.Parent = nil
	end

	return cleanup
end

return {
	Start = function(_)
		ProximityPromptService.PromptShown:Connect(function(instance, p)
			if instance.Style == Enum.ProximityPromptStyle.Default or instance:GetAttribute("NoCustomTheme") then
				return
			end

			local screenGui = getScreenGui()
			local prompt = createPrompt(instance, p, screenGui)
			instance.PromptHidden:Wait()
			prompt()
		end)
	end
}