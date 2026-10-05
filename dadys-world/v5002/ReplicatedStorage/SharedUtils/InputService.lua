local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local InputConfig = require(ReplicatedStorage.SharedData.InputConfig)
local KeyCodeNames = require(ReplicatedStorage.SharedUtils.KeyCodeNames)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

local function log(...)
	if isStudio then
		print("[InputService]", ...)
	end
end

local v = {
	Disconnect = function() end
}
local InputService = {
	_initialized = false,
	_actions = {},
	_contexts = {},
	_overrides = {},
	_contextStack = {},
	_deps = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function findTouchButton(touchButton)
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	return playerGui and playerGui:FindFirstChild(touchButton, true) or nil
end

local function requireAction(p)
	local _action = InputService._actions[p]

	if not _action then
		warn("[InputService] unknown action:", p)
	end

	return _action
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isReserved(p)
	for _, reservedKey in ipairs(InputConfig.ReservedKeys) do
		if reservedKey == p then
			return true
		end
	end

	return false
end

local function newSignal()
	local bindableEvent = Instance.new("BindableEvent")
	return {
		Connect = function(self, onEvent)
			return bindableEvent.Event:Connect(onEvent)
		end,
		Fire = function(self, ...)
			bindableEvent:Fire(...)
		end
	}
end

local function addKeyBinding(parent, keyCode)
	local inputBinding = Instance.new("InputBinding")
	inputBinding.KeyCode = keyCode
	inputBinding.Parent = parent
	return inputBinding
end

local function applyBindingsForAction(p)
	local _action = InputService._actions[p]

	if not _action then
		return
	end

	for _, inputBinding in ipairs(_action:GetChildren()) do
		if inputBinding:IsA("InputBinding") and inputBinding.UIButton == nil then
			inputBinding:Destroy()
		end
	end

	local action = InputConfig.Actions[p]
	local v2 = not action and {} or action.Bindings or {}
	local v3 = InputService._overrides[p] or {}

	for _, v4 in ipairs({ "Keyboard", "Gamepad" }) do
		if v3[v4] then
			local keyCode = KeyCodeNames.fromName(v3[v4])

			if keyCode then
				local inputBinding = Instance.new("InputBinding")
				inputBinding.KeyCode = keyCode
				inputBinding.Parent = _action
			end
		else
			for _, keyCode in ipairs(v2[v4] or {}) do
				local inputBinding = Instance.new("InputBinding")
				inputBinding.KeyCode = keyCode
				inputBinding.Parent = _action
			end
		end
	end

	local fixedBindings = action and action.FixedBindings

	if fixedBindings then
		for _, v4 in ipairs({ "Keyboard", "Gamepad" }) do
			for _, keyCode in ipairs(fixedBindings[v4] or {}) do
				local inputBinding = Instance.new("InputBinding")
				inputBinding.KeyCode = keyCode
				inputBinding.Parent = _action
			end
		end
	end
end

local function isRemappable(p)
	return p ~= nil and p.Remappable == true and SettingsFlags:IsRemappingEnabled()
end

local function collidesWithFixedAction(k, k2, p)
	local action = InputConfig.Actions[k]
	local context = action and action.Context
	local v2 = context and InputConfig.Contexts[context]
	local conflictGroup = v2 and v2.ConflictGroup

	for k3, action2 in pairs(InputConfig.Actions) do
		if not (k3 ~= k and action2.Remappable ~= true) then
			continue
		end

		local context2 = InputConfig.Contexts[action2.Context]
		local conflictGroup2 = context2 and context2.ConflictGroup
		local v3

		if action2.Context == context then
			v3 = true
		elseif conflictGroup == nil then
			v3 = false
		else
			v3 = conflictGroup2 == conflictGroup
		end

		if not v3 then
			continue
		end

		for _, v4 in ipairs({ action2.Bindings, action2.FixedBindings }) do
			local v5 = v4 and v4[k2]

			if not v5 then
				continue
			end

			for _, v6 in ipairs(v5) do
				if typeof(v6) == "EnumItem" and v6.Name == p then
					return true
				end
			end
		end
	end

	return false
end

local function sanitizeOverrides(_savedBinds)
	local result = {}

	if typeof(_savedBinds) ~= "table" then
		return result
	end

	for k, item in pairs(_savedBinds) do
		local action = InputConfig.Actions[k]
		local v2

		if action == nil or action.Remappable ~= true then
			v2 = false
		else
			v2 = SettingsFlags:IsRemappingEnabled()
		end

		if v2 and typeof(item) == "table" then
			for k2, v3 in pairs(item) do
				if (k2 == "Keyboard" or k2 == "Gamepad") and typeof(v3) == "string" and KeyCodeNames.isValidName(v3) then
					local reserved = isReserved(v3) -- equivalent call inferred; original call site unknown

					if not (reserved or collidesWithFixedAction(k, k2, v3)) then
						result[k] = result[k] or {}
						result[k][k2] = v3
						continue
					end
				end

				log("dropped invalid saved bind:", k, tostring(k2), (tostring(v3)))
			end
		else
			log("dropped saved bind for unknown/non-remappable action:", (tostring(k)))
		end
	end

	return result
end

local function rememberSavedBind(p, p2, p3)
	InputService._savedBinds = InputService._savedBinds or {}
	InputService._savedBinds[p] = InputService._savedBinds[p] or {}
	InputService._savedBinds[p][p2] = p3
end

InputService.PreferredInputChanged = newSignal()
InputService.BindingChanged = newSignal()
InputService.Initialized = newSignal()
InputService.ContextChanged = newSignal()
InputService.GameplayInterrupted = newSignal()

function InputService._buildTree()
	local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")

	for k, context in pairs(InputConfig.Contexts) do
		local inputContext = Instance.new("InputContext")
		inputContext.Name = "CW_" .. k
		inputContext.Priority = context.Priority
		inputContext.Sink = context.Sink == true
		inputContext.Enabled = context.Enabled ~= false
		InputService._contexts[k] = inputContext
	end

	for k, action in pairs(InputConfig.Actions) do
		local _context = InputService._contexts[action.Context]

		if _context then
			local inputAction = Instance.new("InputAction")
			inputAction.Name = k
			inputAction.Type = Enum.InputActionType[action.Type]
			inputAction.Enabled = true
			inputAction.Parent = _context
			InputService._actions[k] = inputAction
			applyBindingsForAction(k)
			local touchButton = (action.Bindings or {}).TouchButton

			if touchButton then
				local touchButton2 = findTouchButton(touchButton) -- equivalent call inferred; original call site unknown

				if touchButton2 then
					local inputBinding = Instance.new("InputBinding")
					inputBinding.UIButton = touchButton2
					inputBinding.Parent = inputAction
				end
			end
		else
			warn("[InputService] unknown context for action", k)
		end
	end

	for _, _context in pairs(InputService._contexts) do
		_context.Parent = playerScripts
	end
end

function InputService._applyCoexistence()
	for _, action in pairs(InputConfig.Actions) do
		if action.DisableShiftLock then
			log(pcall(function()
				StarterPlayer.EnableMouseLockOption = false
			end) and "disabled EnableMouseLockOption (action opt-in)" or "could not set EnableMouseLockOption (non-fatal)")
		end
	end
end

function InputService._refreshTouchButtons()
	local visible = InputService:GetPreferredInput() == "Touch"

	for _, action in pairs(InputConfig.Actions) do
		local touchButton = (action.Bindings or {}).TouchButton

		if not touchButton then
			continue
		end

		local touchButton2 = findTouchButton(touchButton) -- equivalent call inferred; original call site unknown

		if touchButton2 then
			touchButton2.Visible = visible
		end
	end
end

function InputService._initDeviceWatch()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		local preferredInput = InputService:GetPreferredInput()
		log("PreferredInput ->", preferredInput)
		InputService.PreferredInputChanged:Fire(preferredInput)
		InputService._refreshTouchButtons()
	end)
end

function InputService._wirePersistence()
	local events = ReplicatedStorage:FindFirstChild("Events")
	local settingsChangeEvent = events and events:FindFirstChild("SettingsChangeEvent")

	if not settingsChangeEvent then
		log("SettingsChangeEvent missing; persistence disabled")
		return
	end

	function InputService._persist(action, device, keyName)
		settingsChangeEvent:FireServer("Keybind", {
			action = action,
			device = device,
			keyName = keyName
		})
	end

	function InputService._persistReset(action)
		for _, device in ipairs({ "Keyboard", "Gamepad" }) do
			local binding = InputService:GetBinding(action, device)

			if binding then
				settingsChangeEvent:FireServer("Keybind", {
					action = action,
					device = device,
					keyName = binding
				})
			end
		end
	end

	function InputService._persistResetAll()
		settingsChangeEvent:FireServer("KeybindResetAll")
	end
end

local function countActions()
	local count = 0

	for _ in pairs(InputService._actions) do
		count += 1
	end

	return count
end

function InputService.OnAction(_, p, onPressed)
	local _action = InputService._actions[p]

	if not _action then
		warn("[InputService] unknown action:", p)
	end

	if _action then
		return _action.Pressed:Connect(onPressed)
	end

	return v
end

function InputService.OnActionReleased(_, p, onReleased)
	local _action = InputService._actions[p]

	if not _action then
		warn("[InputService] unknown action:", p)
	end

	if _action then
		return _action.Released:Connect(onReleased)
	end

	return v
end

function InputService.OnActionStateChanged(_, p, onStateChanged)
	local _action = InputService._actions[p]

	if not _action then
		warn("[InputService] unknown action:", p)
	end

	if _action then
		return _action.StateChanged:Connect(onStateChanged)
	end

	return v
end

function InputService.GetActionState(_, p)
	local _action = InputService._actions[p]

	if not _action then
		warn("[InputService] unknown action:", p)
	end

	if _action then
		return _action:GetState()
	end

	return nil
end

function InputService:SetContextEnabled(p, p2)
	local _context = InputService._contexts[p]

	if not _context then
		warn("[InputService] unknown context:", p)
		return
	end

	_context.Enabled = p2 == true
	InputService.ContextChanged:Fire(p, _context.Enabled)
end

InputService._contextRefcounts = {}

function InputService.RequestContext(_, p)
	local _contextRefcounts = InputService._contextRefcounts
	_contextRefcounts[p] = (_contextRefcounts[p] or 0) + 1

	if _contextRefcounts[p] == 1 then
		InputService:SetContextEnabled(p, true)
	end

	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		_contextRefcounts[p] = math.max(0, (_contextRefcounts[p] or 1) - 1)

		if _contextRefcounts[p] == 0 then
			InputService:SetContextEnabled(p, false)
		end
	end
end

function InputService:PushContext(name)
	local _context = InputService._contexts[name]

	if not _context then
		warn("[InputService] unknown context:", name)
		return
	end

	table.insert(InputService._contextStack, {
		name = name,
		prev = _context.Enabled
	})
	_context.Enabled = true
	InputService.ContextChanged:Fire(name, true)
end

function InputService:PopContext(p)
	for i = #InputService._contextStack, 1, -1 do
		if InputService._contextStack[i].name ~= p then
			continue
		end

		local v2 = table.remove(InputService._contextStack, i)
		local _context = InputService._contexts[p]

		if _context then
			_context.Enabled = v2.prev
			InputService.ContextChanged:Fire(p, _context.Enabled)
		end

		break
	end
end

function InputService.IsContextEnabled(_, p)
	local _context = InputService._contexts[p]
	return _context ~= nil and _context.Enabled == true
end

function InputService:SuspendGameplay()
	if not InputService._initialized then
		return
	end

	InputService._gameplaySuspend = (InputService._gameplaySuspend or 0) + 1

	if InputService._gameplaySuspend == 1 then
		InputService:SetContextEnabled("Gameplay", false)
		InputService.GameplayInterrupted:Fire()
	end
end

function InputService:ResumeGameplay()
	if not InputService._initialized then
		return
	end

	local _gameplaySuspend = InputService._gameplaySuspend or 0

	if _gameplaySuspend == 0 then
		return
	end

	local gameplaySuspend = _gameplaySuspend - 1
	InputService._gameplaySuspend = gameplaySuspend

	if gameplaySuspend == 0 then
		InputService:SetContextEnabled("Gameplay", true)
	end
end

function InputService.IsGameplaySuspended(_)
	return (InputService._gameplaySuspend or 0) > 0
end

function InputService.OpenMenu(_, p)
	if not InputService._initialized then
		return
	end

	if p then
		InputService:PushContext(p)
	end

	InputService:SuspendGameplay()
end

function InputService.CloseMenu(_, p)
	if not InputService._initialized then
		return
	end

	InputService:ResumeGameplay()

	if p then
		InputService:PopContext(p)
	end
end

function InputService.GetContexts(_)
	local result = {}

	for k, context in pairs(InputConfig.Contexts) do
		local _context = InputService._contexts[k]
		local actions = {}

		for k2, action in pairs(InputConfig.Actions) do
			if action.Context ~= k then
				continue
			end

			local _action = InputService._actions[k2]
			table.insert(actions, {
				action = k2,
				displayName = action.DisplayName,
				category = action.Category,
				type = action.Type,
				remappable = action.Remappable == true,
				keyboard = InputService:GetBinding(k2, "Keyboard"),
				gamepad = InputService:GetBinding(k2, "Gamepad"),
				state = _action and _action:GetState() or nil
			})
		end

		table.sort(actions, function(a, b)
			return (a.displayName or a.action) < (b.displayName or b.action)
		end)
		local v3 = {
			name = k,
			priority = context.Priority,
			sink = context.Sink == true,
			enabled = _context ~= nil and _context.Enabled == true,
			actions = actions
		}
		table.insert(result, v3)
	end

	table.sort(result, function(a, b)
		return a.priority > b.priority
	end)
	return result
end

function InputService:GetPreferredInput()
	return UserInputService.PreferredInput.Name
end

function InputService.IsTyping(_)
	return UserInputService:GetFocusedTextBox() ~= nil
end

function InputService.IsTouchOnly(_)
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function InputService:GetGlyph(p, p2)
	local binding = InputService:GetBinding(
		p,
		(p2 or InputService:GetPreferredInput()) == "Gamepad" and "Gamepad" or "Keyboard"
	)
	local v3 = binding and KeyCodeNames.fromName(binding)

	if v3 then
		return UserInputService:GetImageForKeyCode(v3)
	end

	return ""
end

function InputService.BindLabel(_, instance, p, value, value2)
	if not instance then
		return v
	end

	local v2 = value2 or "Keyboard"
	local v3 = value or "%s"
	local textLabel

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		textLabel = instance
	else
		textLabel = instance:FindFirstChildWhichIsA("TextLabel", true) or instance:FindFirstChildWhichIsA(
			"TextButton",
			true
		) or instance:FindFirstChildWhichIsA("TextBox", true)
	end

	if not textLabel then
		warn("[InputService] BindLabel: no Text element on/under", instance:GetFullName(), "— skipping")
		return v
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local binding = InputService:GetBinding(p, v2)
		textLabel.Text = string.format(v3, KeyCodeNames.toDisplay(binding) or "?")
	end

	update() -- equivalent call inferred; original call site unknown
	return InputService.BindingChanged:Connect(update)
end

function InputService.BindGlyph(_, p, p2, p3)
	if not p then
		return v
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		p.Image = InputService:GetGlyph(p2, p3)
	end

	update() -- equivalent call inferred; original call site unknown
	return InputService.BindingChanged:Connect(update)
end

local object = setmetatable({}, {
	__mode = "k"
})

function InputService.RegisterActivation(_, p, p2)
	if not p then
		return v
	end

	object[p] = p2
	return {
		Disconnect = function()
			if object[p] == p2 then
				object[p] = nil
			end
		end
	}
end

function InputService.ActivateSelected(_)
	if InputService:GetBinding("MenuConfirm", "Gamepad") == "ButtonA" then
		return false
	end

	local selectedObject = GuiService.SelectedObject

	if not selectedObject then
		return false
	end

	local v2 = object[selectedObject]

	if not v2 then
		return false
	end

	v2()
	return true
end

function InputService.BindTouchButton(_, p, uIButton)
	local _action = InputService._actions[p]

	if not (_action and uIButton) then
		return
	end

	for _, inputBinding in ipairs(_action:GetChildren()) do
		if inputBinding:IsA("InputBinding") and inputBinding.UIButton ~= nil then
			inputBinding:Destroy()
		end
	end

	local inputBinding = Instance.new("InputBinding")
	inputBinding.UIButton = uIButton
	inputBinding.Parent = _action
	InputService._refreshTouchButtons()
end

function InputService:GetBinding(p, p2)
	local _override = InputService._overrides[p]

	if _override and _override[p2] then
		return _override[p2]
	end

	local action = InputConfig.Actions[p]
	local v2 = action and action.Bindings and action.Bindings[p2]

	if v2 and v2[1] then
		return KeyCodeNames.toName(v2[1])
	end

	return nil
end

function InputService.GetBoundKeyCode(_, p, p2)
	local binding = InputService:GetBinding(p, p2)
	return binding and KeyCodeNames.fromName(binding) or nil
end

local function contextsConflict(p, p2)
	if p == p2 then
		return true
	end

	local context = InputConfig.Contexts[p]
	local context2 = InputConfig.Contexts[p2]
	return context ~= nil and context2 ~= nil and context.ConflictGroup ~= nil and context.ConflictGroup == context2.ConflictGroup
end

local v2 = {}

for k, list in pairs(InputConfig.ExclusiveSets or {}) do
	for _, v3 in ipairs(list) do
		v2[v3] = k
	end
end

local function actionsShareKeySpace(p, p2, p3, p4)
	local context = p2.Context
	local v3

	if context == p4 then
		v3 = true
	else
		local context2 = InputConfig.Contexts[context]
		local context3 = InputConfig.Contexts[p4]

		if context2 == nil or context3 == nil or context2.ConflictGroup == nil then
			v3 = false
		else
			v3 = context2.ConflictGroup == context3.ConflictGroup
		end
	end

	if v3 then
		return true
	end

	local v4 = v2[p3]
	return v4 ~= nil and v4 == v2[p]
end

function InputService:GetActionForKey(p, p2, p3, p4)
	for k, action in pairs(InputConfig.Actions) do
		local context = action.Context
		local v3

		if context == p3 then
			v3 = true
		else
			local context2 = InputConfig.Contexts[context]
			local context3 = InputConfig.Contexts[p3]

			if context2 == nil or context3 == nil or context2.ConflictGroup == nil then
				v3 = false
			else
				v3 = context2.ConflictGroup == context3.ConflictGroup
			end
		end

		local v4

		if v3 then
			v4 = true
		else
			local v5 = v2[p4]

			if v5 == nil then
				v4 = false
			else
				v4 = v5 == v2[k]
			end
		end

		if v4 and InputService:GetBinding(k, p2) == p then
			return k
		end
	end

	return nil
end

local function otherActionOnKey(p, p2, context, p3, p4, p5)
	for k, action in pairs(InputConfig.Actions) do
		if not (k ~= p4 and k ~= p5) then
			continue
		end

		local context2 = action.Context
		local v3

		if context2 == context then
			v3 = true
		else
			local context3 = InputConfig.Contexts[context2]
			local context4 = InputConfig.Contexts[context]

			if context3 == nil or context4 == nil or context3.ConflictGroup == nil then
				v3 = false
			else
				v3 = context3.ConflictGroup == context4.ConflictGroup
			end
		end

		local v4

		if v3 then
			v4 = true
		else
			local v5 = v2[p3]

			if v5 == nil then
				v4 = false
			else
				v4 = v5 == v2[k]
			end
		end

		if v4 and InputService:GetBinding(k, p2) == p then
			return k
		end
	end

	return nil
end

function InputService.SetBinding(_, p, p2, p3)
	local action = InputConfig.Actions[p]

	if not action then
		return false, "unknown action"
	end

	if not SettingsFlags:IsRemappingEnabled() then
		return false, "remapping disabled"
	end

	if not action.Remappable then
		return false, "not remappable"
	end

	if p2 ~= "Keyboard" and p2 ~= "Gamepad" then
		return false, "invalid device"
	end

	if not KeyCodeNames.isValidName(p3) then
		return false, "invalid key"
	end

	-- equivalent call inferred; original call site unknown
	if isReserved(p3) then
		return false, "reserved key"
	end

	if InputService:GetBinding(p, p2) == p3 then
		return true
	end

	local actionForKey = InputService:GetActionForKey(p3, p2, action.Context, p)
	local displayName

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if InputService._persist then
			InputService._persist(p, p2, p3)
		end

		InputService.BindingChanged:Fire(p)

		if actionForKey then
			InputService.BindingChanged:Fire(actionForKey)
		end

		if displayName then
			return true, "swapped with " .. displayName
		end

		return true
	end

	if actionForKey and actionForKey ~= p then
		local action2 = InputConfig.Actions[actionForKey]
		local binding = InputService:GetBinding(p, p2)
		local context = action2 and action2.Context
		local v3 = otherActionOnKey(p3, p2, action.Context, p, actionForKey, p)
		local v4

		if binding == nil then
			v4 = false
		else
			v4 = otherActionOnKey(binding, p2, context, actionForKey, p, actionForKey)
		end

		if InputService._autoSwap then
			local v5

			if action2 == nil or action2.Remappable ~= true then
				v5 = false
			else
				v5 = SettingsFlags:IsRemappingEnabled()
			end

			if v5 and binding and not (v3 or v4) then
				InputService._overrides[actionForKey] = InputService._overrides[actionForKey] or {}
				InputService._overrides[actionForKey][p2] = binding
				rememberSavedBind(actionForKey, p2, binding)
				applyBindingsForAction(actionForKey)

				if InputService._persist then
					InputService._persist(actionForKey, p2, binding)
				end

				if action2 then
					displayName = action2.DisplayName or actionForKey
				else
					displayName = actionForKey
				end

				InputService._overrides[p] = InputService._overrides[p] or {}
				InputService._overrides[p][p2] = p3
				rememberSavedBind(p, p2, p3)
				applyBindingsForAction(p)
				return deduplicatedTail()
			end
		end

		if action2 then
			actionForKey = action2.DisplayName or actionForKey
		end

		return false, "used by " .. actionForKey
	else
		actionForKey = nil
		displayName = nil
		InputService._overrides[p] = InputService._overrides[p] or {}
		InputService._overrides[p][p2] = p3
		rememberSavedBind(p, p2, p3)
		applyBindingsForAction(p)
		return deduplicatedTail()
	end
end

function InputService.ResetBinding(_, p)
	if not SettingsFlags:IsRemappingEnabled() then
		return
	end

	InputService._overrides[p] = nil

	if InputService._savedBinds then
		InputService._savedBinds[p] = nil
	end

	applyBindingsForAction(p)

	if InputService._persistReset then
		InputService._persistReset(p)
	end

	InputService.BindingChanged:Fire(p)
end

function InputService.ResetAll(_)
	if not SettingsFlags:IsRemappingEnabled() then
		return
	end

	for k in pairs(InputConfig.Actions) do
		if not InputService._overrides[k] then
			continue
		end

		InputService._overrides[k] = nil
		applyBindingsForAction(k)
		InputService.BindingChanged:Fire(k)
	end

	InputService._savedBinds = {}

	if InputService._persistResetAll then
		InputService._persistResetAll()
	end
end

InputService._autoSwap = true

function InputService.SetAutoSwapEnabled(_, p)
	InputService._autoSwap = p == true
end

function InputService.IsAutoSwapEnabled(_)
	return InputService._autoSwap == true
end

local function compareActionEntries(p, p2)
	local v3 = tonumber(p.action:match("%d+$"))
	local v4 = tonumber(p2.action:match("%d+$"))

	if v3 and v4 and v3 ~= v4 then
		return v3 < v4
	end

	return p.displayName < p2.displayName
end

function InputService.GetRemappableActions(_)
	local result = {}

	if not SettingsFlags:IsRemappingEnabled() then
		return {}
	end

	for k, action in pairs(InputConfig.Actions) do
		if not action.Remappable then
			continue
		end

		local category = action.Category or "Other"
		result[category] = result[category] or {}
		table.insert(result[category], {
			action = k,
			displayName = action.DisplayName,
			keyboard = InputService:GetBinding(k, "Keyboard"),
			gamepad = InputService:GetBinding(k, "Gamepad")
		})
	end

	for _, list in pairs(result) do
		table.sort(list, compareActionEntries)
	end

	return result
end

function InputService:RefreshRemapState()
	if not InputService._initialized then
		return
	end

	local isRemappingEnabled = SettingsFlags:IsRemappingEnabled()

	if isRemappingEnabled == InputService._remapEnabled then
		return
	end

	InputService._remapEnabled = isRemappingEnabled
	InputService._overrides = sanitizeOverrides(InputService._savedBinds or {})

	for k in pairs(InputConfig.Actions) do
		applyBindingsForAction(k)
		InputService.BindingChanged:Fire(k)
	end

	log("remap state refreshed; remapping enabled =", isRemappingEnabled)
end

function InputService.Init(options)
	if InputService._initialized then
		return
	end

	local deps = options or {}
	InputService._deps = deps
	InputService._savedBinds = deps.savedBinds or {}
	InputService._overrides = sanitizeOverrides(InputService._savedBinds)
	InputService._remapEnabled = SettingsFlags:IsRemappingEnabled()
	InputService._buildTree()
	InputService._applyCoexistence()
	InputService._initDeviceWatch()
	UserInputService.WindowFocusReleased:Connect(function()
		InputService.GameplayInterrupted:Fire()
	end)
	InputService._refreshTouchButtons()
	InputService._wirePersistence()
	InputService._initialized = true
	InputService.Initialized:Fire()

	if not InputService._flagsConn then
		InputService._flagsConn = SettingsFlags.Changed:Connect(function()
			InputService:RefreshRemapState()
		end)
	end
end

function InputService.OnReady(_, callback)
	if InputService._initialized then
		task.spawn(callback)
		return v
	end

	local initializedConnection = nil
	initializedConnection = InputService.Initialized:Connect(function()
		if initializedConnection then
			initializedConnection:Disconnect()
		end

		callback()
	end)
	return initializedConnection
end

return InputService