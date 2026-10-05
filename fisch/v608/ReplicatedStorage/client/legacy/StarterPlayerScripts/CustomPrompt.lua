local createVector = vector.create
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
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
local function setUpCircularProgressBar(circularProgressBar)
	local uIGradient = circularProgressBar.Frame1.ImageLabel.UIGradient
	local uIGradient2 = circularProgressBar.Frame2.ImageLabel.UIGradient
	circularProgressBar.Progress.Changed:Connect(function(p)
		local v5 = math.clamp(p * 360, 0, 360)
		uIGradient2.Rotation = math.clamp(v5, 180, 360)
		uIGradient.Rotation = math.clamp(v5, 0, 180)
	end)
end

local function createPrompt(instance, p, parent)
	local clone = script:WaitForChild("PromptTemplate"):Clone()
	clone.SizeOffset = instance.UIOffset
	local frame = clone:WaitForChild("Frame")
	local inputFrame = frame:WaitForChild("InputFrame")
	local textFrame = frame:WaitForChild("TextFrame")
	local buttonImage = inputFrame:WaitForChild("Frame"):WaitForChild("ButtonImage")
	local buttonText = inputFrame:WaitForChild("Frame"):WaitForChild("ButtonText")
	buttonText.Text = " "

	if instance:GetAttribute("ActionTextRich") then
		textFrame.ActionText.RichText = true
	end

	if instance:GetAttribute("ObjectTextRich") then
		textFrame.ObjectText.RichText = true
	end

	local v5 = { buttonText, textFrame.ActionText, textFrame.ObjectText }
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	if instance:GetAttribute("HighlightModel") then
		highlight.Parent = instance:FindFirstAncestorWhichIsA("Model") or instance.Parent
	else
		highlight.Parent = instance.Parent or instance:FindFirstChildWhichIsA("BasePart")
	end

	local actionTextChangedConnection = instance:GetPropertyChangedSignal("ActionText"):Connect(function()
		textFrame.ActionText.Text = instance.ActionText
	end)
	local objectTextChangedConnection = instance:GetPropertyChangedSignal("ObjectText"):Connect(function()
		textFrame.ObjectText.Text = instance.ObjectText
	end)
	textFrame.ActionText.Text = instance.ActionText
	textFrame.ObjectText.Text = instance.ObjectText

	local function updateUi()
		if p == Enum.ProximityPromptInputType.Gamepad then
			if v[instance.GamepadKeyCode] then
				buttonImage.Image = v[instance.GamepadKeyCode]
			end
		elseif p == Enum.ProximityPromptInputType.Touch then
			buttonImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		else
			buttonImage.Image = "rbxasset://textures/ui/Controls/key_single.png"
			local UserInputService = game:GetService("UserInputService")
			local stringForKeyCode = UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)
			local image = v2[instance.KeyboardKeyCode]

			if image == nil then
				image = v3[stringForKeyCode]
			end

			if image == nil then
				stringForKeyCode = v4[instance.KeyboardKeyCode] or stringForKeyCode
			end

			if image then
				buttonImage.Image = image
			elseif stringForKeyCode == nil or stringForKeyCode == "" then
				error("ProximityPrompt '" .. instance.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(instance.KeyboardKeyCode))
			else
				buttonText.Text = stringForKeyCode
			end
		end

		clone.Active = true
	end

	updateUi()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local v9 = {}

	for _, v10 in pairs(v5) do
		table.insert(v6, TweenService:Create(v10, tweenInfo, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}))
		table.insert(v7, TweenService:Create(v10, tweenInfo, {
			TextTransparency = 0,
			TextStrokeTransparency = 0.65
		}))
	end

	table.insert(v6, TweenService:Create(inputFrame.Frame.RoundFrame, tweenInfo, {
		BackgroundTransparency = 1,
		Visible = false
	}))
	table.insert(v7, TweenService:Create(inputFrame.Frame.RoundFrame, tweenInfo, {
		BackgroundTransparency = 0.65,
		Visible = true
	}))
	table.insert(v6, TweenService:Create(clone, tweenInfo, {
		StudsOffsetWorldSpace = createVector(0, 0.1, 0)
	}))
	table.insert(v7, TweenService:Create(clone, tweenInfo, {
		StudsOffsetWorldSpace = createVector(0, 0, 0)
	}))
	table.insert(v6, TweenService:Create(highlight, tweenInfo, {
		OutlineTransparency = 1
	}))
	table.insert(v7, TweenService:Create(highlight, tweenInfo, {
		OutlineTransparency = 0.3
	}))
	table.insert(v6, TweenService:Create(inputFrame.Frame.ButtonImage, tweenInfo, {
		ImageTransparency = 1,
		Visible = false
	}))
	table.insert(v7, TweenService:Create(inputFrame.Frame.ButtonImage, tweenInfo, {
		ImageTransparency = 0,
		Visible = true
	}))
	highlight.OutlineTransparency = 1
	clone.StudsOffsetWorldSpace = createVector(0, 0.1, 0)
	inputFrame.Frame.RoundFrame.BackgroundTransparency = 1
	inputFrame.Frame.ButtonImage.ImageTransparency = 1

	for _, v10 in pairs(v5) do
		v10.TextTransparency = 1
		v10.TextStrokeTransparency = 1
	end

	if p == Enum.ProximityPromptInputType.Touch or instance.ClickablePrompt == true then
		local v10 = false
		clone.Frame.Active = true
		clone.Frame.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
				instance:InputHoldBegin()
				v10 = true
			end
		end)
		clone.Frame.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and v10 == true then
				instance:InputHoldEnd()
				v10 = false
			end
		end)
		clone.Active = true
	end

	local flag = false
	local triggeredConnection = instance.Triggered:Connect(function()
		if instance:HasTag("altPrompt") and localPlayer:GetAttribute("AB_AlternateProximityPrompt") then
			flag = true
			local lastTime = tick()
			local random = Random.new()
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(41, 255, 130)
			pointLight.Enabled = true
			pointLight.Brightness = 0
			pointLight.Range = 12
			pointLight.Parent = instance.Parent
			local ContentProvider = game:GetService("ContentProvider")
			local preloadAsync = ContentProvider.PreloadAsync
			local ContentProvider2 = game:GetService("ContentProvider")
			task.spawn(preloadAsync, ContentProvider2, instance.Parent:QueryDescendants("ParticleEmitter"))

			for _, sound in instance.Parent:QueryDescendants(".earlyParticle") do
				if sound:IsA("Sound") then
					sound.Volume = 0
					TweenService:Create(sound, TweenInfo.new(1.5), {
						Volume = 0.5
					}):Play()
					sound:Play()
				else
					sound.Enabled = true
				end
			end

			while flag do
				local v10 = tick() - lastTime

				if v10 > 5 then
					for _, instance2 in instance.Parent:QueryDescendants(".activateParticle") do
						if instance2:IsA("ParticleEmitter") then
							instance2:Emit(instance2:GetAttribute("EmitCount") or instance2.Rate)
						elseif instance2:IsA("Sound") then
							instance2:Play()
						end
					end

					for _, v11 in instance.Parent:QueryDescendants(".activeParticle") do
						v11.Enabled = true
					end

					instance.Parent.CanCollide = false
					break
				else
					local v11 = TweenService:GetValue(
						math.clamp((v10 - 0.5) / 4.5, 0, 1),
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.In
					) * 0.5
					frame.Position = UDim2.new(
						0.5 + random:NextNumber(-0.1, 0.1) * v11,
						0,
						random:NextNumber(-0.5, 0.5) * v11,
						0
					)
					pointLight.Brightness = v11 * 25
					task.wait()
				end
			end

			local tween = TweenService:Create(pointLight, TweenInfo.new(0.5), {
				Brightness = 0
			})
			tween.Completed:Once(function()
				tween:Destroy()
				pointLight:Destroy()
			end)
			tween:Play()
			frame.Position = UDim2.fromScale(0.5, 0)

			for _, sound in instance.Parent:QueryDescendants(".earlyParticle") do
				if sound:IsA("Sound") then
					sound:Stop()
					sound.Volume = 0
				else
					sound.Enabled = flag
				end
			end
		else
			for _, v10 in ipairs(v6) do
				v10:Play()
			end
		end
	end)
	local triggerEndedConnection = instance.TriggerEnded:Connect(function()
		if instance:HasTag("altPrompt") and localPlayer:GetAttribute("AB_AlternateProximityPrompt") then
			flag = false

			for _, v10 in ipairs(v8) do
				v10:Play()
			end
		end

		for _, v10 in ipairs(v7) do
			v10:Play()
		end
	end)
	local circularProgressBar = inputFrame:WaitForChild("Frame"):WaitForChild("CircularProgressBar")

	if instance.HoldDuration > 0 then
		circularProgressBar.Visible = true
		setUpCircularProgressBar(circularProgressBar) -- equivalent call inferred; original call site unknown
		table.insert(v9, TweenService:Create(circularProgressBar.Progress, tweenInfo3, {
			Value = 1
		}))
		table.insert(v8, TweenService:Create(circularProgressBar.Progress, tweenInfo2, {
			Value = 0
		}))
		instance.PromptButtonHoldBegan:Connect(function()
			for _, v10 in ipairs(v9) do
				v10:Play()
			end
		end)
		instance.PromptButtonHoldEnded:Connect(function()
			if instance:HasTag("altPrompt") and localPlayer:GetAttribute("AB_AlternateProximityPrompt") then
				task.wait()
			end

			if flag then
				return
			end

			for _, v10 in ipairs(v8) do
				v10:Play()
			end
		end)
	else
		circularProgressBar.Visible = false
	end

	clone.Adornee = instance.Parent
	clone.Parent = parent
	clone.Enabled = true

	for _, v10 in ipairs(v7) do
		v10:Play()
	end

	local function cleanupFunction()
		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()
		actionTextChangedConnection:Disconnect()
		objectTextChangedConnection:Disconnect()

		for _, v10 in ipairs(v6) do
			v10:Play()
		end

		TweenService:Create(highlight, tweenInfo, {
			OutlineTransparency = 1
		}):Play()
		task.wait(0.2)
		highlight:Destroy()
		clone.Parent = nil
	end

	return cleanupFunction
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
	local promptHiddenConnection = nil
	local destroyingConnection = nil

	local function betterCleanupFunction()
		if promptHiddenConnection then
			promptHiddenConnection:Disconnect()
			promptHiddenConnection = nil
		end

		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end

		prompt()
	end

	promptHiddenConnection = instance.PromptHidden:Once(betterCleanupFunction)
	destroyingConnection = instance.Destroying:Once(betterCleanupFunction)
end)