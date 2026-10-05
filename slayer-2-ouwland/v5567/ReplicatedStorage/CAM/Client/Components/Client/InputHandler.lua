local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local InputHandler = {}
local v = {
	Toolbar_1st = { Enum.KeyCode.One },
	Toolbar_2nd = { Enum.KeyCode.Two },
	Toolbar_3rd = { Enum.KeyCode.Three },
	Toolbar_4th = { Enum.KeyCode.Four },
	Toolbar_5th = { Enum.KeyCode.Five },
	Skills_1st = { Enum.KeyCode.F, Enum.KeyCode.ButtonX },
	Skills_2nd = { Enum.KeyCode.Z, Enum.KeyCode.ButtonY },
	Skills_3rd = { Enum.KeyCode.X, Enum.KeyCode.ButtonB },
	Skills_4th = {
		Enum.KeyCode.C,
		{
			Input = Enum.KeyCode.ButtonX,
			Modifier = Enum.KeyCode.ButtonL1
		}
	},
	Skills_5th = {
		Enum.KeyCode.V,
		{
			Input = Enum.KeyCode.ButtonY,
			Modifier = Enum.KeyCode.ButtonL1
		}
	},
	Skills_6th = {
		Enum.KeyCode.B,
		{
			Input = Enum.KeyCode.ButtonB,
			Modifier = Enum.KeyCode.ButtonL1
		}
	},
	Skills_7th = { Enum.KeyCode.N, Enum.KeyCode.DPadRight },
	Skills_8th = { Enum.KeyCode.K, Enum.KeyCode.DPadDown },
	Skills_9th = { Enum.KeyCode.L, Enum.KeyCode.DPadLeft },
	Skills_10th = {
		Enum.KeyCode.J,
		{
			Input = Enum.KeyCode.DPadUp,
			Modifier = Enum.KeyCode.ButtonL1
		}
	},
	Menu = { Enum.KeyCode.M, Enum.KeyCode.DPadUp },
	Menu_Close = { Enum.KeyCode.ButtonB },
	Dash = { Enum.KeyCode.ButtonL3 },
	Screen = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.KeyCode.ButtonR2 },
	Combat = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 },
	Slot_Drag = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.KeyCode.ButtonA },
	Jump = { Enum.KeyCode.Space, Enum.KeyCode.ButtonA },
	Run = { Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2 },
	Shiftlock = { Enum.KeyCode.LeftAlt },
	Toolbar_Prev = {
		{
			Input = Enum.KeyCode.ButtonR1,
			Modifier = Enum.KeyCode.ButtonL1,
			Window = 0.08
		}
	},
	Toolbar_Next = { Enum.KeyCode.ButtonR1 },
	Map = { Enum.KeyCode.DPadDown },
	Map_Close = { Enum.KeyCode.ButtonB },
	Zoom_In = { Enum.KeyCode.ButtonL2 },
	Zoom_Out = { Enum.KeyCode.ButtonR2 },
	Tab_Next = { Enum.KeyCode.ButtonR1 },
	Tab_Prev = {
		{
			Input = Enum.KeyCode.ButtonL1,
			Alone = true
		}
	},
	Category_Next = { Enum.KeyCode.ButtonR2 },
	Category_Prev = { Enum.KeyCode.ButtonL2 },
	Spectate_Prev = { Enum.KeyCode.Q, Enum.KeyCode.DPadLeft },
	Spectate_Next = { Enum.KeyCode.E, Enum.KeyCode.DPadRight },
	Emotes = { Enum.KeyCode.E, Enum.KeyCode.DPadLeft },
	Emotes_Prev = {
		Enum.KeyCode.Q,
		{
			Input = Enum.KeyCode.ButtonL1,
			Alone = true
		}
	},
	Emotes_Next = { Enum.KeyCode.R, Enum.KeyCode.ButtonR1 }
}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}

local function getSignal(p: string)
	local v8 = v2[p]

	if v8 == nil then
		v8 = simplesignal.new()
		v2[p] = v8
	end

	return v8
end

local function rebuildLookup()
	table.clear(v4)

	for k, v8 in v do
		for _, v9 in v8 do
			local input, modifier

			if typeof(v9) == "table" then
				input = v9.Input
				modifier = v9.Modifier
			else
				input = v9
			end

			local v10 = v4[input]

			if v10 == nil then
				v10 = {}
				v4[input] = v10
			end

			local window

			if typeof(v9) == "table" then
				window = v9.Window
			end

			local alone

			if typeof(v9) == "table" then
				alone = v9.Alone
			end

			table.insert(v10, {
				Keybind = k,
				Modifier = modifier,
				Window = window,
				Alone = alone
			})
		end
	end
end

local function dispatch(p: string, p2: string, flag: boolean, ...)
	local v8 = v2[p]

	if v8 == nil then
		return
	end

	v8:Fire(p2, flag, ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function identity(p)
	if p.KeyCode == Enum.KeyCode.Unknown then
		return p.UserInputType
	end

	return p.KeyCode
end

local v8 = { "DynamicThumbstickFrame", "ClassicThumbstickFrame", "ThumbstickFrame" }
local v9 = nil
local object = setmetatable({}, {
	__mode = "k"
})
local v10 = 0
InputHandler.Moving = simplesignal.new()

function InputHandler.IsMoving()
	return v10 > 0
end

local function findMoveFrame()
	if v9 ~= nil and v9.Parent ~= nil and v9.Visible then
		return v9
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local touchGui

	if playerGui ~= nil then
		touchGui = playerGui:FindFirstChild("TouchGui")
	end

	local touchControlFrame

	if touchGui ~= nil then
		touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
	end

	v9 = nil

	if touchControlFrame == nil then
		return v9
	end

	for _, childName in v8 do
		local child = touchControlFrame:FindFirstChild(childName)

		if not (child ~= nil and child.Visible) then
			continue
		end

		v9 = child
		break
	end

	return v9
end

local function isMovementTouch(p)
	if p.UserInputType ~= Enum.UserInputType.Touch then
		return false
	end

	local moveFrame = findMoveFrame()

	if moveFrame == nil or not moveFrame.Visible then
		return false
	end

	local absolutePosition = moveFrame.AbsolutePosition
	local v11 = absolutePosition + moveFrame.AbsoluteSize
	local position = p.Position
	return position.X >= absolutePosition.X and position.Y >= absolutePosition.Y and position.X <= v11.X and position.Y <= v11.Y
end

local v11 = {
	Screen = true
}

local function touchPosition(p)
	return Vector2.new(p.Position.X, p.Position.Y)
end

local function tapGated(p: string, p2, flag: boolean)
	return v11[p] == true and p2.UserInputType == Enum.UserInputType.Touch and not flag
end

local function ownsHold(p, p2)
	return p.Object == nil or p.Object.UserInputType ~= Enum.UserInputType.Touch or p.Object == p2
end

local function release(p: string, ...)
	local v12 = v3[p]

	if v12 == nil then
		return
	end

	v3[p] = nil
	dispatch(p, "Up", v12.Processed, ...)
end

function InputHandler.MouseActive()
	local name = UserInputService:GetLastInputType().Name
	return name:match("^Mouse") ~= nil or name == "Keyboard" or name == "TextInput"
end

function InputHandler.IsDown(p: string)
	local v12 = v3[p]
	return v12 ~= nil and v12.Processed ~= true
end

function InputHandler.HeldInput(p: string)
	local v12 = v3[p]
	return v12 and v12.Input
end

function InputHandler.HeldObject(p: string)
	local v12 = v3[p]

	if v12 == nil then
		return nil
	end

	return v12.Object
end

function InputHandler.VirtualPress(p: string, p2)
	if v3[p] ~= nil then
		return
	end

	v3[p] = {
		Input = p2 or Enum.UserInputType.Touch,
		Processed = false
	}
	dispatch(p, "Down", false)
end

function InputHandler.VirtualRelease(p: string)
	local v12 = v3[p]

	if v12 == nil or v12.Object ~= nil then
		return
	end

	release(p)
end

function InputHandler.ListenTo(p: string, callback)
	local v12 = v2[p]

	if v12 == nil then
		v12 = simplesignal.new()
		v2[p] = v12
	end

	return v12:Connect(callback)
end

function InputHandler.ScreenClicked(callback)
	return InputHandler.ListenTo("Screen", callback)
end

InputHandler.Pinch = simplesignal.new()

function InputHandler.Pinched(onPinch)
	return InputHandler.Pinch:Connect(onPinch)
end

local v12 = {}
local object2 = setmetatable({}, {
	__mode = "k"
})
local v13 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function pinchEnd()
	if v13 == nil then
		return
	end

	v13 = nil
	InputHandler.Pinch:Fire("Ended", 1, Vector2.zero, #v12)
end

local function pinchUpdate()
	local v14 = v12[1]
	local v15 = v12[2]

	if v14 == nil or v15 == nil then
		pinchEnd() -- equivalent call inferred; original call site unknown
	else
		local v16 = object2[v14]
		local v17 = object2[v15]

		if v16 == nil or v17 == nil then
			return
		end

		local magnitude = (v16 - v17).Magnitude
		local midpoint = (v16 + v17) / 2

		if v13 == nil then
			v13 = magnitude
			InputHandler.Pinch:Fire("Began", 1, midpoint)
		else
			if v13 <= 0 then
				v13 = magnitude
				return
			end

			local v19 = magnitude / v13
			v13 = magnitude
			InputHandler.Pinch:Fire("Changed", v19, midpoint)
		end
	end
end

UserInputService.TouchStarted:Connect(function(p)
	if object2[p] ~= nil then
		return
	end

	object2[p] = Vector2.new(p.Position.X, p.Position.Y)
	table.insert(v12, p)
	pinchUpdate()
end)
UserInputService.TouchMoved:Connect(function(p)
	if object2[p] == nil then
		return
	end

	object2[p] = Vector2.new(p.Position.X, p.Position.Y)
	pinchUpdate()
end)
UserInputService.TouchEnded:Connect(function(otherPart)
	if object2[otherPart] == nil then
		return
	end

	object2[otherPart] = nil
	local index = table.find(v12, otherPart)

	if index ~= nil then
		table.remove(v12, index)
	end

	pinchEnd() -- equivalent call inferred; original call site unknown
end)
InputHandler.Rebound = simplesignal.new()

function InputHandler.Rebind(p: string, p2)
	release(p)
	v[p] = p2
	rebuildLookup()
	InputHandler.Rebound:Fire(p)
end

function InputHandler.PrettyInput(value: string)
	return (string.gsub(value, "(%l)(%u)", "%1 %2"))
end

function InputHandler.KeyLabel(p: string)
	local v14 = v[p]

	if v14 == nil then
		return nil
	end

	for _, v15 in v14 do
		if not (typeof(v15) ~= "table" and v15.EnumType == Enum.KeyCode) then
			continue
		end

		local name = v15.Name

		if not (string.match(name, "^Button") or string.match(name, "^DPad") or string.match(name, "^Thumbstick")) then
			return InputHandler.PrettyInput(name)
		end
	end

	return nil
end

function InputHandler.GetMapping(p: string)
	return v[p]
end

local function isPadInput(p)
	if typeof(p) ~= "EnumItem" or p.EnumType ~= Enum.KeyCode then
		return false
	end

	local name = p.Name
	return string.match(name, "^Button") ~= nil or string.match(name, "^DPad") ~= nil or string.match(
		name,
		"^Thumbstick"
	) ~= nil
end

local v14 = {}

for k, v15 in v do
	for _, v17 in v15 do
		if typeof(v17) == "table" or isPadInput(v17) then
			continue
		end

		v14[k] = v17
		break
	end
end

function InputHandler.DefaultKey(p: string)
	return v14[p]
end

function InputHandler.BoundKey(p: string)
	return (InputHandler.KeyBinding(p))
end

function InputHandler.KeyBinding(p: string)
	local v15 = v[p]

	if v15 == nil then
		return nil, nil
	end

	local v16 = nil

	for _, v17 in v15 do
		if typeof(v17) == "table" then
			if v17.Modifier ~= nil and not isPadInput(v17.Input) then
				return v17.Input, v17.Modifier
			end
		elseif not isPadInput(v17) and v16 == nil then
			v16 = v17
		end
	end

	return v16, nil
end

function InputHandler.RebindKey(p: string, input, modifier)
	local v15 = v[p]

	if v15 == nil then
		return
	end

	local v16 = {}

	if input ~= nil then
		if modifier == nil then
			table.insert(v16, input)
		else
			table.insert(v16, {
				Input = input,
				Modifier = modifier
			})
		end
	end

	for _, v17 in v15 do
		if typeof(v17) == "table" then
			if isPadInput(v17.Input) then
				table.insert(v16, v17)
			end
		elseif isPadInput(v17) then
			table.insert(v16, v17)
		end
	end

	InputHandler.Rebind(p, v16)
end

function InputHandler.PadBinding(p: string)
	local v15 = v[p]

	if v15 == nil then
		return nil, nil
	end

	local input = nil

	for _, v16 in v15 do
		if typeof(v16) == "table" then
			if v16.Modifier ~= nil then
				return v16.Input, v16.Modifier
			end

			if input == nil and isPadInput(v16.Input) then
				input = v16.Input
			end
		elseif isPadInput(v16) and input == nil then
			input = v16
		end
	end

	return input, nil
end

local v15 = {}

for k in v do
	local padBinding, modifier = InputHandler.PadBinding(k)

	if padBinding ~= nil then
		v15[k] = {
			Input = padBinding,
			Modifier = modifier
		}
	end
end

function InputHandler.PadDefault(p: string)
	local v16 = v15[p]

	if v16 == nil then
		return nil, nil
	end

	return v16.Input, v16.Modifier
end

function InputHandler.RebindPad(p: string, input, modifier)
	local v16 = v[p]

	if v16 == nil then
		return
	end

	local v17 = {}

	for _, v18 in v16 do
		if typeof(v18) == "table" or isPadInput(v18) then
			continue
		end

		table.insert(v17, v18)
	end

	if input ~= nil then
		if modifier == nil then
			table.insert(v17, input)
		else
			table.insert(v17, {
				Input = input,
				Modifier = modifier
			})
		end
	end

	InputHandler.Rebind(p, v17)
end

function InputHandler.KeybindOnPad(p, p2)
	for k in v do
		local padBinding, v16 = InputHandler.PadBinding(k)

		if padBinding == p and v16 == p2 then
			return k
		end
	end

	return nil
end

function InputHandler.KeybindOn(p, p2)
	for k in v do
		local keyBinding, v16 = InputHandler.KeyBinding(k)

		if keyBinding == p and v16 == p2 then
			return k
		end
	end

	return nil
end

local v16 = nil
local v17 = nil
local keyCodes = {}
local v18 = {}

function InputHandler.Capture(callback, callback2)
	local v19 = v17
	v16 = callback
	v17 = callback2
	table.clear(keyCodes)

	if v19 ~= nil then
		v19()
	end

	return function()
		if v16 == callback then
			v16 = nil
			v17 = nil
			table.clear(keyCodes)
		end
	end
end

function InputHandler.IsCapturing()
	return v16 ~= nil
end

rebuildLookup()
local v19 = nil
local v20 = nil
local keyCodes2 = {}
local v21 = {}
local v22 = nil

function InputHandler.CapturePad(callback, callback2, p)
	local v23 = v20
	v19 = callback
	v20 = callback2
	v22 = p
	table.clear(keyCodes2)

	if v23 ~= nil then
		v23()
	end

	return function()
		if v19 == callback then
			v19 = nil
			v20 = nil
			v22 = nil
			table.clear(keyCodes2)
		end
	end
end

function InputHandler.IsCapturingPad()
	return v19 ~= nil
end

function InputHandler.IsRecording()
	return v16 ~= nil or v19 ~= nil
end

local v23 = { "Skills_", "Toolbar_" }
local v24 = 0

local function blocked(value: string)
	if v24 <= 0 then
		return false
	end

	for _, v25 in v23 do
		if string.sub(value, 1, #v25) == v25 then
			return true
		end
	end

	return false
end

function InputHandler.IsBlocked()
	return v24 > 0
end

function InputHandler.Block()
	v24 += 1
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true
		v24 = math.max(0, v24 - 1)
	end
end

local function firePress(input, object3, processed: boolean, flag2: boolean)
	local v25 = v4[input]

	if v25 == nil then
		return
	end

	for _, v26 in v25 do
		if v26.Alone then
			continue
		end

		local v27

		if flag2 then
			if v26.Modifier == nil then
				v27 = false
			else
				v27 = v6[v26.Modifier] == true
			end
		else
			v27 = v26.Modifier == nil
		end

		local keybind = v26.Keybind

		if v27 then
			local flag3

			if v24 <= 0 then
				flag3 = false
			else
				local flag4 = true

				for _, v28 in v23 do
					if string.sub(keybind, 1, #v28) ~= v28 then
						continue
					end

					flag3 = true
					flag4 = false
					break
				end

				if flag4 then
					flag3 = false
				end
			end

			if flag3 then
				continue
			end
		end

		if v27 then
			local v28

			if v11[keybind] == true and object3.UserInputType == Enum.UserInputType.Touch then
				v28 = not processed
			else
				v28 = false
			end

			if v28 then
				continue
			end
		end

		if not (v27 and v3[keybind] == nil) then
			continue
		end

		if flag2 then
			v7[v26.Modifier] = true
		end

		v3[keybind] = {
			Input = input,
			Processed = processed,
			Object = object3
		}
		dispatch(keybind, "Down", processed, object3)
	end
end

local function onInputBegan(input, gameProcessed: boolean)
	if isMovementTouch(input) then
		object[input] = true
		v10 += 1

		if v10 == 1 then
			InputHandler.Moving:Fire(true)
		end
	elseif v16 == nil or gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		if v19 == nil or not isPadInput(input.KeyCode) or v22 ~= nil and v22[input.KeyCode] then
			local input2 = identity(input) -- equivalent call inferred; original call site unknown
			v6[input2] = true

			for k, v26 in v5 do
				local flag = false

				for _, v28 in v4[k] do
					if v28.Modifier ~= input2 then
						continue
					end

					flag = true
					break
				end

				if not flag then
					continue
				end

				task.cancel(v26.Timer)
				v5[k] = nil
				firePress(k, v26.Object, v26.Processed, true)
			end

			local v26 = v4[input2]

			if v26 == nil then
				return
			end

			local v27 = 0
			local v28 = false

			for _, v30 in v26 do
				if v30.Modifier == nil then
					continue
				end

				if v6[v30.Modifier] then
					v28 = true
					break
				elseif v30.Window ~= nil then
					v27 = math.max(v27, v30.Window)
				end
			end

			if v28 or not (v27 > 0) then
				firePress(input2, input, gameProcessed, v28)
			else
				v5[input2] = {
					Object = input,
					Processed = gameProcessed,
					Timer = task.delay(v27, function()
						v5[input2] = nil
						firePress(input2, input, gameProcessed, false)
					end)
				}
			end
		else
			v21[input.KeyCode] = true

			if table.find(keyCodes2, input.KeyCode) == nil then
				table.insert(keyCodes2, input.KeyCode)
				v19(table.clone(keyCodes2))
			end
		end
	else
		v18[input.KeyCode] = true

		if table.find(keyCodes, input.KeyCode) == nil then
			table.insert(keyCodes, input.KeyCode)
			v16(table.clone(keyCodes))
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)

local function onInputEnded(input)
	if isPadInput(input.KeyCode) and v21[input.KeyCode] then
		v21[input.KeyCode] = nil

		if table.find(keyCodes2, input.KeyCode) ~= nil then
			local clone = table.clone(keyCodes2)
			table.clear(keyCodes2)

			if v19 ~= nil then
				v19(clone, true)
			end
		end
	elseif input.UserInputType == Enum.UserInputType.Keyboard and v18[input.KeyCode] then
		v18[input.KeyCode] = nil

		if table.find(keyCodes, input.KeyCode) ~= nil then
			table.clear(keyCodes)
		end
	elseif object[input] then
		object[input] = nil
		v10 = math.max(0, v10 - 1)

		if v10 == 0 then
			InputHandler.Moving:Fire(false)
		end
	else
		local input2 = identity(input) -- equivalent call inferred; original call site unknown
		v6[input2] = nil
		local v26 = v5[input2]

		if v26 ~= nil and v26.Object == input then
			task.cancel(v26.Timer)
			v5[input2] = nil
			firePress(input2, input, v26.Processed, false)
		end

		local v27 = v4[input2]

		if v27 == nil then
			return
		end

		for _, v28 in v27 do
			local keybind = v28.Keybind
			local v29 = v3[keybind]

			if not (v29 ~= nil and v29.Input == input2 and (v29.Object == nil or v29.Object.UserInputType ~= Enum.UserInputType.Touch or v29.Object == input)) then
				continue
			end

			release(keybind, input)
		end

		local v28 = v7[input2]
		v7[input2] = nil

		if not v28 then
			for _, v29 in v27 do
				local keybind = v29.Keybind

				if not (v29.Alone and v3[keybind] == nil) then
					continue
				end

				v3[keybind] = {
					Input = input2,
					Processed = false,
					Object = input
				}
				dispatch(keybind, "Down", false, input)
				release(keybind, input)
			end
		end
	end
end

UserInputService.InputEnded:Connect(onInputEnded)
local v25 = {
	[Enum.KeyCode.ButtonL2] = true,
	[Enum.KeyCode.ButtonR2] = true
}
local v26 = {}
UserInputService.InputChanged:Connect(function(input, gameProcessed: boolean)
	local keyCode = input.KeyCode

	if not v25[keyCode] then
		return
	end

	local Z = input.Position.Z

	if Z >= 0.5 then
		if v26[keyCode] then
			return
		end

		v26[keyCode] = true

		if not v6[keyCode] then
			onInputBegan(input, gameProcessed)
		end
	elseif Z <= 0.25 then
		if not v26[keyCode] then
			return
		end

		v26[keyCode] = nil

		if v6[keyCode] then
			onInputEnded(input)
		end
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	table.clear(v6)
	table.clear(v26)
	table.clear(v7)

	for _, v27 in v5 do
		task.cancel(v27.Timer)
	end

	table.clear(v5)

	for k in v3 do
		release(k)
	end
end)
InputHandler.Available = simplesignal.new()
local v27 = {
	pause_gameplay = true,
	Swapping = true,
	Using_Skill_Switch = true,
	Blocking = true
}

for k in Utility.Cancel_Values do
	v27[k] = true
end

local v28 = false
local flag = false
local v29 = false
local v30 = nil

local function computeAvailable()
	local character = localPlayer.Character

	if character == nil or character.Parent == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	if v30 ~= nil then
		for childName in v27 do
			if v30:FindFirstChild(childName) ~= nil then
				return false
			end
		end
	end

	local SHC = character:FindFirstChild("SHC")
	return SHC == nil or SHC.Value == "" and SHC:GetAttribute("en") ~= true
end

local function evaluate(flag2: boolean?)
	if flag2 == true then
		v29 = true
	end

	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local v31 = v29
		v29 = false
		local v32 = computeAvailable()

		if v32 ~= v28 or v32 and v31 then
			v28 = v32
			InputHandler.Available:Fire(v32)
		end
	end)
end

local function renotify()
	v29 = true

	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local v31 = v29
		v29 = false
		local v32 = computeAvailable()

		if v32 ~= v28 or v32 and v31 then
			v28 = v32
			InputHandler.Available:Fire(v32)
		end
	end)
end

function InputHandler.IsAvailable()
	return v28
end

InputHandler.Dragging = simplesignal.new()
local v31 = false

function InputHandler.IsDragging()
	return v31
end

function InputHandler.SetDragging(flag2: boolean)
	local v32 = flag2 == true

	if v32 == v31 then
		return
	end

	v31 = v32
	InputHandler.Dragging:Fire(v32)
end

local function onValue(p)
	if v27[p.Name] then
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false
			local v32 = v29
			v29 = false
			local v33 = computeAvailable()

			if v33 ~= v28 or v33 and v32 then
				v28 = v33
				InputHandler.Available:Fire(v33)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hookSHC(instance)
	instance.Changed:Connect(evaluate)
	instance:GetAttributeChangedSignal("en"):Connect(evaluate)
	instance.ChildRemoved:Connect(renotify)

	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local v32 = v29
		v29 = false
		local v33 = computeAvailable()

		if v33 ~= v28 or v33 and v32 then
			v28 = v33
			InputHandler.Available:Fire(v33)
		end
	end)
end

local function hookCharacter(character)
	character.ChildAdded:Connect(function(humanoid)
		if humanoid.Name == "SHC" then
			hookSHC(humanoid) -- equivalent call inferred; original call site unknown
		elseif humanoid:IsA("Humanoid") then
			humanoid.Died:Connect(evaluate)

			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				local v32 = v29
				v29 = false
				local v33 = computeAvailable()

				if v33 ~= v28 or v33 and v32 then
					v28 = v33
					InputHandler.Available:Fire(v33)
				end
			end)
		end
	end)
	local SHC = character:FindFirstChild("SHC")

	if SHC ~= nil then
		hookSHC(SHC) -- equivalent call inferred; original call site unknown
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		humanoid.Died:Connect(evaluate)
	end

	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		local v32 = v29
		v29 = false
		local v33 = computeAvailable()

		if v33 ~= v28 or v33 and v32 then
			v28 = v33
			InputHandler.Available:Fire(v33)
		end
	end)
end

if RunService:IsRunning() then
	task.spawn(function()
		v30 = Utility.getvaluesfolder(localPlayer, true)
		v30.ChildAdded:Connect(onValue)
		v30.ChildRemoved:Connect(onValue)
		localPlayer.CharacterAdded:Connect(function(character)
			InputHandler.SetDragging(false)
			hookCharacter(character)
		end)
		localPlayer.CharacterRemoving:Connect(function()
			InputHandler.SetDragging(false)

			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				local v32 = v29
				v29 = false
				local v33 = computeAvailable()

				if v33 ~= v28 or v33 and v32 then
					v28 = v33
					InputHandler.Available:Fire(v33)
				end
			end)
		end)

		if localPlayer.Character ~= nil then
			hookCharacter(localPlayer.Character)
		end
	end)
end

return InputHandler