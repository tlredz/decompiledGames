local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GamepadUI = {}
local v = {}
local count = 0
local v2 = false
local v3 = nil
local v4 = nil

function GamepadUI.UsingGamepad()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

function GamepadUI.CursorActive()
	local success, result = pcall(function()
		return GamepadService.GamepadCursorEnabled
	end)
	return success and result
end

function GamepadUI.IsShowing(parent)
	if not (parent and parent.Parent) then
		return false
	end

	while parent do
		if parent:IsA("GuiObject") and not parent.Visible or parent:IsA("LayerCollector") and not parent.Enabled then
			return false
		end

		if parent:IsA("PlayerGui") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

function GamepadUI.Top()
	local v5 = nil

	for _, v6 in v do
		local v7 = v6.Owner and GamepadUI.IsShowing(v6.Owner) or not v6.Owner and v6.Active

		if v6.Owner and v6.OpenAttribute then
			if v6.Owner:GetAttribute(v6.OpenAttribute) == true then
				v7 = GamepadUI.IsShowing(v6.Owner.Parent)
			else
				v7 = false
			end
		end

		if not (v7 and (not v5 or v6.Priority > v5.Priority or v6.Priority == v5.Priority and v6.Order > v5.Order)) then
			continue
		end

		v5 = v6
	end

	return v5
end

function GamepadUI.GameplayBlocked()
	local localPlayer = Players.LocalPlayer
	return GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() ~= nil or GamepadUI.CursorActive() or (GuiService.SelectedObject ~= nil or GamepadUI.Top() ~= nil or localPlayer and (localPlayer:GetAttribute("FocusFrameDepth") or 0) > 0) and true or false
end

local function FirstButton(button)
	if not (button and button.Parent) then
		return nil
	end

	if button:IsA("GuiButton") and button.Active and GamepadUI.IsShowing(button) then
		return button
	end

	local v5 = 1e999
	local v6 = nil

	for _, button2 in button:GetDescendants() do
		if not (button2:IsA("GuiButton") and button2.Active and button2.Selectable and GamepadUI.IsShowing(button2)) then
			continue
		end

		local absolutePosition = button2.AbsolutePosition
		local v7 = absolutePosition.Y * 4 + absolutePosition.X

		if not (v7 < v5) then
			continue
		end

		v6 = button2
		v5 = v7
	end

	return v6
end

function GamepadUI.Focus(p)
	if not GamepadUI.UsingGamepad() or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
		return
	end

	local selectedObject = FirstButton(p)

	if not selectedObject then
		return
	end

	local cursorActive = GamepadUI.CursorActive()
	GuiService.SelectedObject = nil
	v4 = nil

	if pcall(function()
		GamepadService:EnableGamepadCursor(selectedObject)
	end) and GamepadUI.CursorActive() then
		if not cursorActive then
			v2 = true
		end
	else
		GuiService.SelectedObject = selectedObject
		v4 = selectedObject
	end
end

local function Refresh()
	local top = GamepadUI.Top()

	if top ~= v3 then
		v3 = top

		if top then
			GamepadUI.Focus(top.Target or top.Owner)

			if top.CloseCursor and (GamepadUI.UsingGamepad() or GamepadUI.CursorActive()) then
				v2 = true
			end
		end
	end

	if not top then
		if GuiService.SelectedObject == v4 then
			GuiService.SelectedObject = nil
		end

		v4 = nil

		if v2 and not GuiService.MenuIsOpen then
			GamepadService:DisableGamepadCursor()
			v2 = false
		end
	end
end

function GamepadUI:Watch(close, target, priority, allowed, openAttribute)
	local v5 = v[self]

	if v5 then
		if close then
			v5.Close = close
		end

		if target then
			v5.Target = target
		end

		if priority then
			v5.Priority = priority
		end

		if allowed then
			v5.Allowed = allowed
		end
	else
		count += 1
		local v6 = {
			Owner = self,
			Close = close or function()
				self.Visible = false
			end,
			Target = target,
			Priority = priority or 0,
			Order = count,
			Allowed = allowed or {},
			OpenAttribute = openAttribute
		}
		v[self] = v6

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Changed()
			if GamepadUI.IsShowing(self) then
				count += 1
				v6.Order = count
			end

			task.defer(Refresh)
		end

		local parent = self
		local connections = {}

		while parent and not parent:IsA("PlayerGui") do
			if parent:IsA("GuiObject") then
				table.insert(connections, parent:GetPropertyChangedSignal("Visible"):Connect(Changed))
			elseif parent:IsA("LayerCollector") then
				table.insert(connections, parent:GetPropertyChangedSignal("Enabled"):Connect(Changed))
			end

			parent = parent.Parent
		end

		if openAttribute then
			table.insert(connections, self:GetAttributeChangedSignal(openAttribute):Connect(Changed))
		end

		table.insert(connections, self.Destroying:Connect(function()
			v[self] = nil

			for _, connection in connections do
				connection:Disconnect()
			end

			task.defer(Refresh)
		end))
		Changed() -- equivalent call inferred; original call site unknown
	end
end

function GamepadUI.SetContext(p, p2, close, target)
	count += 1
	v[p] = p2 and {
		Active = true,
		Close = close,
		Target = target,
		Priority = -1,
		Order = count,
		Allowed = {}
	} or nil
	task.defer(Refresh)
end

function GamepadUI.BindMenuShortcut(instance, instance2, p, callback, options)
	local v5 = options or {}
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local GamepadGlyphs = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadGlyphs"))
	local closeButton = v5.CloseButton or instance2:FindFirstChild("Close")
	GamepadUI.Watch(instance2, v5.Close, closeButton, nil, nil, v5.OpenAttribute)
	v[instance2].Group = v5.Group
	v[instance2].CloseCursor = v5.CloseCursor == true
	local v6 = "MenuShortcut_" .. instance.Name
	local flag = false
	ContextActionService:BindActionAtPriority(v6, function(_, p2)
		if p2 == Enum.UserInputState.Begin then
			if flag then
				return Enum.ContextActionResult.Sink
			end

			if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
				return Enum.ContextActionResult.Pass
			end

			local top = GamepadUI.Top()
			local v7 = top and (top.Owner == instance2 or v5.Group and top.Group == v5.Group)

			if not (instance.Active and (GamepadUI.IsShowing(instance) or v7)) or top and not v7 then
				return Enum.ContextActionResult.Pass
			end

			local localPlayer = Players.LocalPlayer

			if not top and localPlayer and (localPlayer:GetAttribute("FocusFrameDepth") or 0) > 0 or v5.CanActivate and not v5.CanActivate() then
				return Enum.ContextActionResult.Pass
			end

			flag = true
			callback()
			return Enum.ContextActionResult.Sink
		else
			local v7 = flag

			if p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
				flag = false
			end

			return v7 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
		end
	end, false, Enum.ContextActionPriority.High.Value + 10, p)

	local function RefreshBadges()
		for _, v7 in {
			{ instance, p, v5.BadgeLeft ~= false },
			{ closeButton, Enum.KeyCode.ButtonB, false }
		} do
			local v8 = v7[1]

			if not (v8 and v8.Parent) then
				continue
			end

			local gamepadBadge = v8:FindFirstChild("GamepadBadge")

			if gamepadBadge then
				gamepadBadge:Destroy()
			end

			if UserInputService.GamepadEnabled then
				GamepadGlyphs.CreateBadge(v8, v7[2], v7[3])
			end
		end
	end

	local v7 = {
		UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(RefreshBadges),
		UserInputService.GamepadConnected:Connect(function()
			task.defer(RefreshBadges)
		end)
	}
	instance.Destroying:Connect(function()
		ContextActionService:UnbindAction(v6)

		for _, connection in v7 do
			connection:Disconnect()
		end
	end)
	RefreshBadges()
end

if not RunService:IsClient() then
	return GamepadUI
end

local v5 = false
ContextActionService:BindActionAtPriority("GamepadMenuBack", function(_, p)
	if p == Enum.UserInputState.Begin then
		if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		local top = GamepadUI.Top()

		if top then
			v5 = true
			top.Close()
		else
			if not GamepadUI.CursorActive() then
				return Enum.ContextActionResult.Pass
			end

			v5 = true
			GamepadService:DisableGamepadCursor()
			v2 = false
		end

		return Enum.ContextActionResult.Sink
	else
		local v6 = v5

		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			v5 = false
		end

		return v6 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	end
end, false, Enum.ContextActionPriority.High.Value + 20, Enum.KeyCode.ButtonB)
local v6 = {}
ContextActionService:BindActionAtPriority("GamepadMenuGameplayGuard", function(_, p, p2)
	local keyCode = p2.KeyCode

	if p == Enum.UserInputState.Begin then
		if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		local top = GamepadUI.Top()
		local gameplayBlocked = GamepadUI.GameplayBlocked()

		if gameplayBlocked then
			gameplayBlocked = not (top and top.Allowed[keyCode])
		end

		v6[keyCode] = gameplayBlocked
		return gameplayBlocked and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	else
		local v7 = v6[keyCode]

		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			v6[keyCode] = nil
		end

		return v7 and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	end
end, false, Enum.ContextActionPriority.High.Value + 20, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1, Enum.KeyCode.DPadDown)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	if GamepadUI.UsingGamepad() then
		v3 = nil
		Refresh()
	end
end)
GuiService.MenuClosed:Connect(function()
	v3 = nil
	task.defer(Refresh)
end)
return GamepadUI