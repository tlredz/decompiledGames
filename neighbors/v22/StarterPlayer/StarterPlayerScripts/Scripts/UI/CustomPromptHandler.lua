local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local newPrompt = script:WaitForChild("NewPrompt")
local v = {
	[Enum.KeyCode.ButtonX] = "http://www.roblox.com/asset/?id=429501348",
	[Enum.KeyCode.ButtonY] = "http://www.roblox.com/asset/?id=429501346",
	[Enum.KeyCode.ButtonA] = "http://www.roblox.com/asset/?id=429479022",
	[Enum.KeyCode.ButtonB] = "http://www.roblox.com/asset/?id=429501329",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "http://www.roblox.com/asset/?id=429501340",
	[Enum.KeyCode.ButtonR1] = "http://www.roblox.com/asset/?id=429501341",
	[Enum.KeyCode.ButtonL2] = "http://www.roblox.com/asset/?id=429501325",
	[Enum.KeyCode.ButtonR2] = "http://www.roblox.com/asset/?id=429501338"
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
local _ = {
	TouchTapIcon = "rbxasset://textures/ui/Controls/TouchTapIcon.png",
	key_single = "http://www.roblox.com/asset/?id=7310154850"
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

function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

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

local function createPrompt(instance, p, parent)
	local clone = newPrompt:Clone()
	local inputFrame = clone:WaitForChild("InputFrame")
	local actionText = clone:WaitForChild("ActionText")
	local touchBox = inputFrame:WaitForChild("TouchBox")
	local progressFrame = inputFrame:WaitForChild("ProgressFrame")
	local inputIcon = inputFrame:WaitForChild("InputIcon")
	local inputText = inputFrame:WaitForChild("InputText")
	clone.StudsOffset = Vector3.new(0, instance.UIOffset.Y)
	TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(
		progressFrame,
		TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(1, 0, 1, 0)
		}
	)

	local function updateUIFromPrompt()
		actionText.Text = instance.ActionText

		if p == Enum.ProximityPromptInputType.Gamepad then
			if v[instance.GamepadKeyCode] then
				inputIcon.Image = v[instance.GamepadKeyCode]
			end
		else
			if p == Enum.ProximityPromptInputType.Touch then
				inputIcon.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
				return
			end

			inputIcon.Image = "http://www.roblox.com/asset/?id=7310154850"
			local stringForKeyCode = UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)
			local image = v2[instance.KeyboardKeyCode]

			if image == nil then
				image = v3[stringForKeyCode]
			end

			if image == nil then
				stringForKeyCode = v4[instance.KeyboardKeyCode] or stringForKeyCode
			end

			if image then
				inputIcon.Image = image
			elseif stringForKeyCode == nil or stringForKeyCode == "" then
				inputText.Visible = false
				error("ProximityPrompt '" .. instance.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(instance.KeyboardKeyCode))
			else
				inputText.Text = stringForKeyCode
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function show()
		clone.Enabled = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hide()
		clone.Enabled = false
	end

	updateUIFromPrompt()
	inputIcon.ImageTransparency = 1
	hide() -- equivalent call inferred; original call site unknown
	script.PopupAudio:Play()
	show() -- equivalent call inferred; original call site unknown
	local v5 = true

	local function fn()
		local lastTime = tick()
		local v6 = 0
		local v7 = false

		while v6 < instance.HoldDuration and v5 == true do
			local RunService = game:GetService("RunService")
			RunService.Stepped:wait()

			if v7 == false then
				tween:Play()
				v7 = true
			end

			v6 = tick() - lastTime
		end

		tween:Cancel()
		v5 = true
		TweenService:Create(progressFrame, TweenInfo.new(0.1), {
			Size = UDim2.new(1, 0, 0, 0)
		}):Play()
	end

	if p == Enum.ProximityPromptInputType.Touch or instance.ClickablePrompt then
		local v6 = false
		touchBox.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
				instance:InputHoldBegin()
				v6 = true
			end
		end)
		touchBox.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and v6 then
				v6 = false
				instance:InputHoldEnd()
			end
		end)
		clone.Active = true
	end

	local thread = coroutine.create(fn)
	instance.PromptButtonHoldBegan:Connect(function()
		v5 = true
		thread = coroutine.create(fn)
		coroutine.resume(thread)
	end)
	instance.PromptButtonHoldEnded:Connect(function()
		v5 = false
		tween:Cancel()
		coroutine.yield(thread)
	end)
	local keyboard = Enum.UserInputType.Keyboard
	UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.Keyboard and keyboard ~= input.UserInputType then
			keyboard = input.UserInputType
			updateUIFromPrompt()
		elseif input.UserInputType == Enum.UserInputType.Touch and keyboard ~= input.UserInputType then
			keyboard = input.UserInputType
			updateUIFromPrompt()
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 and keyboard ~= input.UserInputType then
			keyboard = input.UserInputType
			updateUIFromPrompt()
		end
	end)
	local triggeredConnection = instance.Triggered:Connect(function()
		hide() -- equivalent call inferred; original call site unknown
		script.ClickSound:Play()
	end)
	local triggerEndedConnection = instance.TriggerEnded:Connect(function()
		show() -- equivalent call inferred; original call site unknown
	end)
	clone.Adornee = instance.Parent
	clone.Parent = parent

	local function cleanupFunction()
		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()
		hide() -- equivalent call inferred; original call site unknown
		wait(0.2)
		clone:Destroy()
	end

	return cleanupFunction
end

ProximityPromptService.PromptShown:Connect(function(p, p2)
	if p.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	local v5 = playerGui:FindFirstChild("ProximityPrompts")

	if v5 == nil then
		v5 = Instance.new("ScreenGui")
		v5.Name = "ProximityPrompts"
		v5.ResetOnSpawn = false
		v5.Parent = playerGui
	end

	local prompt = createPrompt(p, p2, v5)
	p.PromptHidden:Wait()
	prompt()
end)