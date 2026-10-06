local module = require("@game/ReplicatedStorage/Omni")
local userInputService = module.Services.UserInputService
local contextActionService = module.Services.ContextActionService
local GuiService = game:GetService("GuiService")
local keybinds = module.Shared.Keybinds
local buttons = module.Interface:WaitForChild("HUD"):WaitForChild("Left"):WaitForChild("Buttons")
local v = {}
local v2 = {}
local flag = false
local v3 = nil
local v4 = nil
local thread = nil
local v5 = nil
local v6 = 0
local Keybinds = {
	Changed = module.Libs.GoodSignal.new(),
	DeviceChanged = module.Libs.GoodSignal.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearCaptureThread()
	if not thread then
		return
	end

	task.cancel(thread)
	thread = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsGamepad(p)
	return p.UserInputType.Name:match("^Gamepad") ~= nil
end

local function CanEdit(p: string)
	local setting = keybinds.Settings[p]
	return setting ~= nil and setting.Device == Keybinds.GetDevice() and module.Frame:IsFrameOpened("Settings")
end

function Keybinds.GetDevice()
	local preferredInput = userInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Gamepad then
		return "Console"
	end

	if preferredInput == Enum.PreferredInput.Touch then
		return "Mobile"
	end

	return "Computer"
end

function Keybinds.GetLabel(p: string)
	local v7 = Enum.KeyCode[p]
	local success, stringForKeyCode = pcall(userInputService.GetStringForKeyCode, userInputService, v7)

	if success then
		if stringForKeyCode == "" then
			stringForKeyCode = p
		end
	else
		stringForKeyCode = p
	end

	return stringForKeyCode:gsub("^DPad", ""):gsub("^Button", "")
end

function Keybinds.GetStatus(p: string)
	if v4 and v4.Name == p then
		return v4
	end

	return nil
end

function Keybinds.IsCapturing()
	return v4 ~= nil or os.clock() < v6
end

function Keybinds.RefreshIndicators()
	local device = Keybinds.GetDevice()

	for _, v7 in v2 do
		v7.Instance.Visible = device ~= "Mobile"

		if device == "Mobile" then
			continue
		end

		local value = keybinds.GetValue(module.Data.Settings, (`{v7.Name} Keybind {device}`))
		local image = ""

		if device == "Console" then
			local success, imageForKeyCode = pcall(
				userInputService.GetImageForKeyCode,
				userInputService,
				Enum.KeyCode[value]
			)

			if success then
				image = imageForKeyCode
			end
		end

		v7.Icon.Image = image
		v7.Icon.Visible = image ~= ""
		v7.Title.Text = Keybinds.GetLabel(value)
		v7.Title.Visible = image == ""
	end
end

function Keybinds.RefreshDevice()
	local device = Keybinds.GetDevice()

	if v3 ~= device then
		v3 = device
		Keybinds.Cancel()
		Keybinds.DeviceChanged:Fire()
	end

	Keybinds.RefreshIndicators()
end

function Keybinds.RefreshData()
	if v4 and v4.Confirmed and module.Data.Settings[v4.Name] == v4.Value then
		Keybinds.Cancel()
	end

	Keybinds.RefreshIndicators()
	Keybinds.Changed:Fire()
end

function Keybinds.Cancel(p: string?)
	if p and (not v4 or v4.Name ~= p) then
		return
	end

	ClearCaptureThread() -- equivalent call inferred; original call site unknown
	contextActionService:UnbindAction("HUDKeybindCapture")
	v4 = nil
	v5 = nil
	v6 = os.clock() + 0.2
	Keybinds.Changed:Fire()
end

function Keybinds.Save(name: string, p2: string)
	local setting = keybinds.Settings[name]
	local v7

	if setting == nil or setting.Device ~= Keybinds.GetDevice() then
		v7 = false
	else
		v7 = module.Frame:IsFrameOpened("Settings")
	end

	if not v7 or v4 and v4.Pending then
		return
	end

	local v8, message = keybinds.Validate(module.Data.Settings, name, p2)

	if v8 then
		ClearCaptureThread() -- equivalent call inferred; original call site unknown
		contextActionService:UnbindAction("HUDKeybindCapture")
		local v10 = {
			Name = name,
			Pending = true,
			Value = p2,
			Message = "Saving..."
		}
		v4 = v10
		v5 = nil
		v6 = os.clock() + 0.2
		thread = task.delay(10, function()
			thread = nil

			if v4 ~= v10 then
				return
			end

			v10.Pending = false
			v10.Message = "Could not confirm the save. Click to try again."
			Keybinds.Changed:Fire()
		end)
		Keybinds.Changed:Fire()
		task.spawn(function()
			local success, result, v11 = pcall(function()
				return module.Signal:Invoke("General", "Settings", "Set", name, p2)
			end)

			if v4 ~= v10 then
				return
			end

			if success and result == true then
				v10.Confirmed = true
				Keybinds.RefreshData()
			else
				ClearCaptureThread() -- equivalent call inferred; original call site unknown
				v10.Pending = false
				v10.Message = (not success or typeof(v11) ~= "string") and "Could not save. Click to try again." or v11
				Keybinds.Changed:Fire()
			end
		end)
	elseif v4 and v4.Name == name then
		v4.Message = message
		Keybinds.Changed:Fire()
	end
end

function Keybinds.CaptureInput(_, p, p2)
	if not (v4 and p2.KeyCode ~= Enum.KeyCode.ButtonA) then
		return Enum.ContextActionResult.Pass
	end

	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Sink
	end

	if p2.KeyCode == Enum.KeyCode.Escape or p2.KeyCode == Enum.KeyCode.ButtonB then
		Keybinds.Cancel()
		return Enum.ContextActionResult.Sink
	end

	if (IsGamepad(p2) and "Console" or "Computer") ~= keybinds.Settings[v4.Name].Device or v4.Pending then
		return Enum.ContextActionResult.Sink
	end

	Keybinds.Save(v4.Name, p2.KeyCode.Name)
	return Enum.ContextActionResult.Sink
end

function Keybinds.Activate(name: string)
	local setting = keybinds.Settings[name]
	local v7

	if setting == nil or setting.Device ~= Keybinds.GetDevice() then
		v7 = false
	else
		v7 = module.Frame:IsFrameOpened("Settings")
	end

	if not v7 or v4 and v4.Pending then
		return
	end

	local now = os.clock()
	local v8 = v5

	if v8 then
		if v5.Name == name then
			v8 = now - v5.Time <= 0.3
		else
			v8 = false
		end
	end

	if v8 then
		v5 = nil
		Keybinds.Save(name, keybinds.Settings[name].Default)
	else
		if v4 and v4.Name == name and v4.Listening then
			Keybinds.Cancel()
			return
		end

		Keybinds.Cancel()
		local v9 = {
			Name = name,
			Listening = true,
			Message = Keybinds.GetDevice() == "Console" and "Press a button... B to cancel." or "Press a key... Esc to cancel."
		}
		v4 = v9
		v5 = {
			Name = name,
			Time = now
		}
		contextActionService:BindActionAtPriority(
			"HUDKeybindCapture",
			Keybinds.CaptureInput,
			false,
			3000,
			Enum.UserInputType.Keyboard,
			Enum.UserInputType.Gamepad1,
			Enum.UserInputType.Gamepad2,
			Enum.UserInputType.Gamepad3,
			Enum.UserInputType.Gamepad4,
			Enum.UserInputType.Gamepad5,
			Enum.UserInputType.Gamepad6,
			Enum.UserInputType.Gamepad7,
			Enum.UserInputType.Gamepad8
		)
		thread = task.delay(10, function()
			thread = nil

			if v4 == v9 then
				Keybinds.Cancel()
			end
		end)
		Keybinds.Changed:Fire()
	end
end

function Keybinds.OnInput(p, flag2: boolean)
	if flag2 or v4 or os.clock() < v6 then
		return
	end

	if userInputService:GetFocusedTextBox() or GuiService.SelectedObject then
		return
	end

	local v7

	if p.UserInputType == Enum.UserInputType.Keyboard then
		v7 = "Computer"
	elseif IsGamepad(p) then
		v7 = "Console"
	else
		return
	end

	for _, v8 in keybinds.List do
		local value = keybinds.GetValue(module.Data.Settings, (`{v8.Name} Keybind {v7}`))

		if p.KeyCode.Name ~= value then
			continue
		end

		if v8.Action == "Skill" then
			module.Signal:FireSelf("Interface", "HUD", "UseSkill")
			break
		end

		if module.Frame:GetOpenedFramesAmount() == 0 then
			module.Frame:Open(v8.Frame)
		end

		break
	end
end

function Keybinds.Stop()
	Keybinds.Cancel()

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)

	for _, v7 in v2 do
		local original = v7.Original
		v7.Instance.Visible = original.Visible
		v7.Icon.Image = original.Image
		v7.Icon.Visible = original.IconVisible
		v7.Title.Text = original.Text
		v7.Title.Visible = original.TitleVisible
	end

	table.clear(v2)
	flag = false
end

function Keybinds.Init()
	if flag then
		return
	end

	flag = true
	v3 = Keybinds.GetDevice()

	for _, v7 in keybinds.List do
		local v8

		if v7.Action == "Skill" then
			v8 = module.Interface.HUD.Skill
		else
			v8 = buttons:WaitForChild(v7.Frame)
		end

		local keycode = v8:WaitForChild("Main"):WaitForChild("Keycode")
		local icon = keycode:WaitForChild("Icon")
		local title = keycode:WaitForChild("Title")
		table.insert(v2, {
			Name = v7.Name,
			Instance = keycode,
			Icon = icon,
			Title = title,
			Original = {
				Visible = keycode.Visible,
				Image = icon.Image,
				IconVisible = icon.Visible,
				Text = title.Text,
				TitleVisible = title.Visible
			}
		})
	end

	v.Input = userInputService.InputBegan:Connect(Keybinds.OnInput)
	v.Device = userInputService:GetPropertyChangedSignal("PreferredInput"):Connect(Keybinds.RefreshDevice)
	v.Connected = userInputService.GamepadConnected:Connect(Keybinds.RefreshDevice)
	v.Disconnected = userInputService.GamepadDisconnected:Connect(Keybinds.RefreshDevice)
	v.Settings = module:OnDataChanged({ "Settings" }, Keybinds.RefreshData)
	v.Destroying = script.Destroying:Connect(Keybinds.Stop)
	Keybinds.RefreshIndicators()
end

return Keybinds