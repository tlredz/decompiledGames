local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("hud")
local safezone = hud:WaitForChild("safezone")
local topbar = safezone:WaitForChild("topbar")
local polls = safezone:WaitForChild("Polls")
local module = require("../SettingsController")
local GamepadUIController = {}
local buttons = {}
local flag = false
local selectedObjectChangedConnection = nil
local selectablesByButton = {}
local v = {}
local v2 = {}

local function isVisible(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

local function isNavigableButton(button)
	if not button:IsA("GuiButton") then
		return false
	end

	if isVisible(button) then
		return button.Active ~= false
	end

	return false
end

local function clearConnections()
	for k, connection in pairs(v) do
		if connection then
			connection:Disconnect()
		end

		v[k] = nil
	end

	for k, connection in pairs(v2) do
		if connection then
			connection:Disconnect()
		end

		v2[k] = nil
	end
end

local function setOtherUISelectable(flag2: boolean)
	for _, button in ipairs(hud:GetDescendants()) do
		if not button:IsA("GuiButton") or (button:IsDescendantOf(topbar) or button:IsDescendantOf(polls)) then
			continue
		end

		if flag2 then
			local selectable = selectablesByButton[button]

			if selectable ~= nil then
				button.Selectable = selectable
			end
		else
			selectablesByButton[button] = button.Selectable
			button.Selectable = false
		end
	end

	if flag2 then
		table.clear(selectablesByButton)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTopbarGuard()
	if selectedObjectChangedConnection then
		selectedObjectChangedConnection:Disconnect()
		selectedObjectChangedConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function exitTopbar()
	flag = false
	stopTopbarGuard() -- equivalent call inferred; original call site unknown
	clearConnections()
	setOtherUISelectable(true)
	GuiService.SelectedObject = nil
end

local setupTopbarNavigation

setupTopbarNavigation = function()
	table.clear(buttons)
	clearConnections()

	for _, button in ipairs(topbar:GetChildren()) do
		if button:IsA("GuiButton") then
			v[button] = button:GetPropertyChangedSignal("Visible"):Connect(function()
				setupTopbarNavigation()
			end)
		end

		local v3

		if button:IsA("GuiButton") and isVisible(button) then
			v3 = button.Active ~= false
		else
			v3 = false
		end

		if not v3 then
			continue
		end

		button.Selectable = true
		table.insert(buttons, button)
		v2[button] = button.Activated:Connect(function()
			exitTopbar() -- equivalent call inferred; original call site unknown
		end)
	end

	table.sort(buttons, function(a, b)
		return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
	end)

	for i, v3 in ipairs(buttons) do
		v3.NextSelectionLeft = buttons[i - 1] or buttons[#buttons]
		v3.NextSelectionRight = buttons[i + 1] or buttons[1]
		v3.NextSelectionUp = nil
		v3.NextSelectionDown = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTopbarGuard()
	stopTopbarGuard() -- equivalent call inferred; original call site unknown
	selectedObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		if flag then
			if #buttons == 0 then
				setupTopbarNavigation()
			end

			local selectedObject = GuiService.SelectedObject
			local v3 = selectedObject == nil or not (selectedObject:IsDescendantOf(topbar) or selectedObject:IsDescendantOf(polls))
			local v4

			if selectedObject == nil then
				v4 = false
			else
				v4 = selectedObject:IsA("GuiObject") and not isVisible(selectedObject)
			end

			if v3 or v4 then
				setupTopbarNavigation()

				if buttons[1] then
					GuiService.SelectedObject = buttons[1]
				end
			end
		else
			stopTopbarGuard() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function focusTopbar()
	setupTopbarNavigation()

	if #buttons == 0 then
		return
	end

	flag = true
	setOtherUISelectable(false)
	GuiService.SelectedObject = buttons[1]
	startTopbarGuard() -- equivalent call inferred; original call site unknown
end

function GamepadUIController.Start(_)
	setupTopbarNavigation()
	topbar.ChildAdded:Connect(function()
		setupTopbarNavigation()

		if flag and GuiService.SelectedObject and not GuiService.SelectedObject:IsDescendantOf(topbar) and buttons[1] then
			GuiService.SelectedObject = buttons[1]
		end
	end)
	topbar.ChildRemoved:Connect(function()
		setupTopbarNavigation()

		if flag then
			local selectedObject = GuiService.SelectedObject

			if (selectedObject == nil or not selectedObject:IsDescendantOf(topbar)) and buttons[1] then
				GuiService.SelectedObject = buttons[1]
			end
		end
	end)
	topbar:GetPropertyChangedSignal("Visible"):Connect(function()
		if flag and not topbar.Visible then
			exitTopbar() -- equivalent call inferred; original call site unknown
		end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadLeft and not flag and hud.Enabled and not playerGui:FindFirstChild("reel") and not playerGui:FindFirstChild("stab") and not playerGui:FindFirstChild("harpoonMinigame") and not playerGui:FindFirstChild("shakeui") and module:GetSettingValue("consoleHotkeys") and not module:GetSettingValue("quickAccessEnabled") then
			focusTopbar() -- equivalent call inferred; original call site unknown
		else
			if not flag or input.KeyCode ~= Enum.KeyCode.ButtonB then
				return
			end

			exitTopbar() -- equivalent call inferred; original call site unknown
		end
	end)
	hud:GetPropertyChangedSignal("Enabled"):Connect(function()
		if flag and not hud.Enabled then
			exitTopbar() -- equivalent call inferred; original call site unknown
		end
	end)
end

return GamepadUIController