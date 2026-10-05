if not game:IsLoaded() then
	game.Loaded:Wait()
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
game:GetService("Workspace")
local HapticEffectsController = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("HapticEffectsController"))
local InputService = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("InputService"))
local v = {
	Xbox = {
		ButtonA = "A",
		ButtonB = "B",
		ButtonX = "X",
		ButtonY = "Y",
		ButtonL1 = "LB",
		ButtonL2 = "LT",
		ButtonL3 = "LS",
		ButtonR1 = "RB",
		ButtonR2 = "RT",
		ButtonR3 = "RS",
		DPadUp = "Up",
		DPadDown = "Down",
		DPadLeft = "Left",
		DPadRight = "Right"
	},
	PlayStation = {
		ButtonA = "Cross",
		ButtonB = "Circle",
		ButtonX = "Square",
		ButtonY = "Triangle",
		ButtonL1 = "L1",
		ButtonL2 = "L2",
		ButtonL3 = "L3",
		ButtonR1 = "R1",
		ButtonR2 = "R2",
		ButtonR3 = "R3",
		DPadUp = "Up",
		DPadDown = "Down",
		DPadLeft = "Left",
		DPadRight = "Right"
	}
}

local function actionKeyWord(p, p2, p3)
	if p2 ~= "Gamepad" then
		local boundKeyCode = InputService:GetBoundKeyCode(p, "Keyboard")
		return boundKeyCode and boundKeyCode.Name or "?"
	end

	local boundKeyCode = InputService:GetBoundKeyCode(p, "Gamepad")
	local name = boundKeyCode and boundKeyCode.Name
	local v2 = v[p3] or v.Xbox
	return not name and "Button" or v2[name] or name or "Button"
end

local screenGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local selectionFrame = screenGui:WaitForChild("SelectionFrame")
local menu = screenGui:WaitForChild("Menu")
local spaceBarPromptText = menu:WaitForChild("SpaceBarPromptText")
local stopGenerator = menu:WaitForChild("StopGenerator")
local buttonDisplay = menu:WaitForChild("Calibrate"):WaitForChild("ButtonDisplay")
local v2 = {
	screenGui:WaitForChild("Ability1"),
	screenGui:WaitForChild("Stickers"),
	screenGui:WaitForChild("Slot1"),
	screenGui:WaitForChild("Slot2"),
	screenGui:WaitForChild("Slot3"),
	screenGui:WaitForChild("Slot4")
}
local v3 = {
	Ability1 = "UseAbility",
	Stickers = "StickerMenu",
	Slot1 = "Item1",
	Slot2 = "Item2",
	Slot3 = "Item3",
	Slot4 = "Item4"
}
local v4 = {
	gamepadTypeFromNewestInput = "none",
	inputTypeThePlayerIsUsing = "KeyboardAndMouse",
	gamepadType = "none"
}
local updateGuiButtonsAndIcons
local v5 = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2
}
local v6 = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect
}
local v7 = {
	ButtonLB = true,
	ButtonLT = true,
	ButtonLS = true,
	ButtonRB = true,
	ButtonRT = true,
	ButtonRS = true
}
local v8 = {
	ButtonCross = true,
	ButtonCircle = true,
	ButtonSquare = true,
	ButtonTriangle = true,
	ButtonOptions = true,
	ButtonTouchpad = true,
	ButtonShare = true
}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	for _, v9 in pairs(v5) do
		if input.KeyCode ~= v9 then
			continue
		end

		local v10 = false

		for _, v12 in pairs(v6) do
			if input.KeyCode ~= v12 then
				continue
			end

			v10 = true
			break
		end

		if not v10 then
			break
		end

		local stringForKeyCode = UserInputService:GetStringForKeyCode(v9)
		local v12 = v7[stringForKeyCode] and "Xbox" or v8[stringForKeyCode] and "PlayStation" or nil

		if not v12 or v12 == v4.gamepadType then
			break
		end

		v4.gamepadTypeFromNewestInput = v12
		v4.gamepadType = v12
		updateGuiButtonsAndIcons(v4.inputTypeThePlayerIsUsing)
		break
	end
end)
local v9 = {
	[Enum.PreferredInput.KeyboardAndMouse] = "MouseKeyboard",
	[Enum.PreferredInput.Gamepad] = "Gamepad",
	[Enum.PreferredInput.Touch] = "Touch"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getInputType()
	return v9[UserInputService.PreferredInput] or "MouseKeyboard"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initializeInputType()
	local inputType = getInputType() -- equivalent call inferred; original call site unknown
	v4.inputTypeThePlayerIsUsing = inputType

	if inputType == "Gamepad" then
	end

	v4.gamepadType = "none"
end

initializeInputType() -- equivalent call inferred; original call site unknown
local inputTypeThePlayerIsUsing = v4.inputTypeThePlayerIsUsing
local v10 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function enableGamepadCursor(_)
	if v10 ~= false then
		GamepadService:DisableGamepadCursor()
		v10 = false
	end
end

updateGuiButtonsAndIcons = function(p)
	local visible = p == "MouseKeyboard"
	local visible2 = p == "Gamepad"
	script:SetAttribute("Gamepad", visible2)
	local gamepadType = v4.gamepadType
	local v13 = (gamepadType == "none" or gamepadType == "unknown") and "Xbox" or gamepadType
	local text

	if p == "Gamepad" then
		local boundKeyCode = InputService:GetBoundKeyCode("GeneratorStop", "Gamepad")
		local name = boundKeyCode and boundKeyCode.Name
		local v15 = v[v13] or v.Xbox
		text = "PRESS " .. (not name and "Button" or v15[name] or name or "Button") .. " TO STOP EXTRACTING"
	else
		text = "STOP EXTRACTING"
	end

	for _, v15 in ipairs(v2) do
		local textLabel = v15:FindFirstChild("TextLabel")
		local gamePadIcons = v15:FindFirstChild("GamePadIcons")

		if textLabel then
			textLabel.Visible = visible
			local v16 = v3[v15.Name]
			local boundKeyCode = v16 and InputService:GetBoundKeyCode(v16, "Keyboard")

			if boundKeyCode then
				local stringForKeyCode = UserInputService:GetStringForKeyCode(boundKeyCode)

				if stringForKeyCode == "" or not stringForKeyCode then
					stringForKeyCode = boundKeyCode.Name
				end

				textLabel.Text = stringForKeyCode
			end
		end

		if not gamePadIcons then
			continue
		end

		for _, child in pairs(gamePadIcons:GetChildren()) do
			child.Visible = visible2

			if child.Name ~= "ConsoleButton" then
				continue
			end

			local keyCode = child:GetAttribute("KeyCode")
			local v16 = v3[v15.Name]

			if v16 then
				local boundKeyCode = InputService:GetBoundKeyCode(v16, "Gamepad")

				if boundKeyCode then
					keyCode = boundKeyCode.Name
				end
			end

			if keyCode and Enum.KeyCode[keyCode] then
				child.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode[keyCode])
			end
		end
	end

	stopGenerator.Text = text
	local boundKeyCode = InputService:GetBoundKeyCode("SkillCheckTap", "Gamepad")
	local name = boundKeyCode and boundKeyCode.Name
	local v15 = v[v13] or v.Xbox
	local v16 = not name and "Button" or v15[name] or name or "Button"
	local boundKeyCode2 = InputService:GetBoundKeyCode("SkillCheckTap", "Keyboard")
	local name2 = boundKeyCode2 and boundKeyCode2.Name or "?"

	if spaceBarPromptText.Visible then
		if p == "Gamepad" then
			buttonDisplay.Text = "PRESS " .. v16 .. " TO SKILLCHECK"
		else
			buttonDisplay.Text = "PRESS " .. string.upper(name2) .. " TO SKILLCHECK"
		end
	elseif p == "Touch" then
		spaceBarPromptText.Text = "Press the 'SKILLCHECK' button when the marker is in the white calibration area!"
	elseif p == "Gamepad" then
		spaceBarPromptText.Text = "Press the " .. v16 .. " Button when the marker is in the white calibration area!"
		buttonDisplay.Text = "PRESS " .. v16 .. " TO SKILLCHECK"
	else
		spaceBarPromptText.Text = "Press " .. name2 .. " when the marker is in the white calibration area!"
		buttonDisplay.Text = "PRESS " .. string.upper(name2) .. " TO SKILLCHECK"
	end
end

local function updateSkillCheckPrompt(p)
	local v11 = inputTypeThePlayerIsUsing or getInputType()
	local gamepadType = v4.gamepadType
	local v12 = (gamepadType == "none" or gamepadType == "unknown") and "Xbox" or gamepadType
	local boundKeyCode = InputService:GetBoundKeyCode("SkillCheckTap", "Gamepad")
	local name = boundKeyCode and boundKeyCode.Name
	local v13 = v[v12] or v.Xbox
	local v14 = not name and "Button" or v13[name] or name or "Button"
	local boundKeyCode2 = InputService:GetBoundKeyCode("SkillCheckTap", "Keyboard")
	local name2 = boundKeyCode2 and boundKeyCode2.Name or "?"
	local text

	if p == "circle" then
		if v11 == "Touch" then
			text = "Press the 'SKILLCHECK' button when the red circle is in the yellow or grey zone!"
		elseif v11 == "Gamepad" then
			text = "Press the " .. v14 .. " Button when the red circle is in the yellow or grey zone!"
		else
			text = "Press " .. name2 .. " when the red circle is in the yellow or grey zone!"
		end
	elseif p == "movement" or p == "MovementTreadmill" then
		if v11 == "Touch" then
			text = "Tap rapidly when prompted to keep running on the treadmill!"
		elseif v11 == "Gamepad" then
			text = "Press " .. v14 .. " rapidly when prompted to keep running on the treadmill!"
		else
			text = "Press " .. name2 .. " rapidly when prompted to keep running on the treadmill!"
		end
	elseif v11 == "Touch" then
		text = "Press the 'SKILLCHECK' button when the marker is in the white calibration area!"
	elseif v11 == "Gamepad" then
		text = "Press the " .. v14 .. " Button when the marker is in the white calibration area!"
	else
		text = "Press " .. name2 .. " when the marker is in the white calibration area!"
	end

	spaceBarPromptText.Text = text
end

local bindableFunction = Instance.new("BindableFunction")
bindableFunction.Name = "UpdateSkillCheckPrompt"
bindableFunction.Parent = script
bindableFunction.OnInvoke = updateSkillCheckPrompt

-- equivalent calls inferred from this helper; original call sites unknown
local function updateGUI(p)
	UserInputService.MouseIconEnabled = p == "MouseKeyboard"

	if p == "Gamepad" then
		local _ = selectionFrame.Visible
	end

	enableGamepadCursor() -- equivalent call inferred; original call site unknown

	if p ~= "Gamepad" and GuiService.SelectedObject then
		GuiService.SelectedObject = nil
	end

	updateGuiButtonsAndIcons(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleInputTypeChange()
	local inputType = getInputType() -- equivalent call inferred; original call site unknown

	if inputType ~= inputTypeThePlayerIsUsing then
		inputTypeThePlayerIsUsing = inputType
		v4.inputTypeThePlayerIsUsing = inputType
		updateGUI(inputTypeThePlayerIsUsing) -- equivalent call inferred; original call site unknown
	end
end

local function handleSelectionFrameVisibilityChange()
	if selectionFrame.Visible then
		if inputTypeThePlayerIsUsing == "Gamepad" then
			enableGamepadCursor() -- equivalent call inferred; original call site unknown
		end
	else
		enableGamepadCursor() -- equivalent call inferred; original call site unknown
	end
end

UserInputService.GamepadConnected:Connect(function()
	v4.gamepadType = "none"
end)
UserInputService.GamepadDisconnected:Connect(function()
	v4.gamepadType = "none"

	if GuiService.SelectedObject then
		GuiService.SelectedObject = nil
	end

	handleInputTypeChange() -- equivalent call inferred; original call site unknown
end)
updateGUI(inputTypeThePlayerIsUsing) -- equivalent call inferred; original call site unknown
local guiObjects = {}

local function refreshHintUI(guiObject)
	local action = guiObject:GetAttribute("Action")
	local console = guiObject:FindFirstChild("Console")
	local keyCode = console and console:GetAttribute("KeyCode")

	if action then
		local boundKeyCode = InputService:GetBoundKeyCode(action, "Gamepad")

		if boundKeyCode then
			keyCode = boundKeyCode.Name
		end
	end

	if keyCode and Enum.KeyCode[keyCode] then
		console.Image = UserInputService:GetImageForKeyCode(Enum.KeyCode[keyCode])
	end

	local keyboard = guiObject:FindFirstChild("Keyboard")
	local keyCode2 = keyboard and keyboard:GetAttribute("KeyCode")

	if action then
		local boundKeyCode = InputService:GetBoundKeyCode(action, "Keyboard")

		if boundKeyCode then
			keyCode2 = boundKeyCode.Name
		end
	end

	if keyCode2 and Enum.KeyCode[keyCode2] then
		local v12, v13

		if keyboard:GetAttribute("WrapInBrackets") then
			v12 = "["
			v13 = "]"
		else
			v12 = ""
			v13 = ""
		end

		keyboard.Text = string.format("%s%s%s", v12, keyCode2, v13)
	end

	local preferredInput = UserInputService.PreferredInput

	if console then
		console.Visible = preferredInput == Enum.PreferredInput.Gamepad
	end

	if keyboard then
		keyboard.Visible = preferredInput == Enum.PreferredInput.KeyboardAndMouse
	end

	guiObject.Visible = console and console.Visible or keyboard and keyboard.Visible or false
end

local function addInputHintUI(guiObject)
	if not guiObject:IsA("GuiObject") then
		return
	end

	guiObjects[#guiObjects + 1] = guiObject
	refreshHintUI(guiObject)
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	handleInputTypeChange() -- equivalent call inferred; original call site unknown

	for _, v12 in pairs(guiObjects) do
		task.spawn(refreshHintUI, v12)
	end
end)
CollectionService:GetInstanceAddedSignal("InputHintUI"):Connect(addInputHintUI)

for _, v12 in pairs(CollectionService:GetTagged("InputHintUI")) do
	task.spawn(addInputHintUI, v12)
end

InputService.BindingChanged:Connect(function()
	updateGuiButtonsAndIcons(inputTypeThePlayerIsUsing)

	for _, v12 in pairs(guiObjects) do
		task.spawn(refreshHintUI, v12)
	end
end)
InputService:OnReady(function()
	updateGuiButtonsAndIcons(inputTypeThePlayerIsUsing)

	for _, v12 in pairs(guiObjects) do
		task.spawn(refreshHintUI, v12)
	end
end)
selectionFrame:GetPropertyChangedSignal("Visible"):Connect(handleSelectionFrameVisibilityChange)

local function handleSelectButtonPress(p, p2)
	if p2 then
		return
	end

	if p.KeyCode == Enum.KeyCode.ButtonSelect and (menu.Visible or selectionFrame.Visible) then
		enableGamepadCursor() -- equivalent call inferred; original call site unknown
	end
end

UserInputService.InputBegan:Connect(handleSelectButtonPress)

local function closeTopPopUp()
	local instances = {}

	for _, instance in pairs(screenGui:GetChildren()) do
		if instance.Name == "TemporaryPopUp" and CollectionService:HasTag(instance, "PopUp") then
			table.insert(instances, instance)
		end
	end

	if #instances > 0 then
		local v12 = instances[math.random(1, #instances)]

		if v12:FindFirstChild("ExitButton") then
			local click = screenGui:FindFirstChild("Click")

			if click and click:IsA("Sound") then
				click:Play()
			end

			HapticEffectsController:Play("UIClickSoft")
			v12:Destroy()
		end
	end
end

local v12 = false
local v13 = nil

local function syncPopupNav()
	if not v12 then
		return
	end

	local flag = false

	for _, instance in pairs(screenGui:GetChildren()) do
		if not (instance.Name == "TemporaryPopUp" and CollectionService:HasTag(instance, "PopUp")) then
			continue
		end

		flag = true
		break
	end

	if flag then
		if not v13 then
			v13 = InputService:RequestContext("PopupNav")
		end
	elseif v13 then
		v13()
		v13 = nil
	end
end

screenGui.ChildAdded:Connect(syncPopupNav)
screenGui.ChildRemoved:Connect(syncPopupNav)
InputService:OnReady(function()
	v12 = true
	InputService:OnAction("PopupClose", closeTopPopUp)
	InputService:OnAction("MenuConfirm", function()
		InputService:ActivateSelected()
	end)
	syncPopupNav()
end)