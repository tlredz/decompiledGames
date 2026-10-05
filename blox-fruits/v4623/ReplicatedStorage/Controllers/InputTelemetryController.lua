local UserInputService = game:GetService("UserInputService")
local InputTelemetry = require(game.ReplicatedStorage.Modules.InputTelemetry)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Net = require(game.ReplicatedStorage.Modules.Net)
local MAX_BATCH_EVENTS = InputTelemetry.MAX_BATCH_EVENTS
local lastTime = os.clock()
local v = {
	buffer = {},
	codes = {},
	enabled = false,
	flushSeconds = 2,
	lastFlush = 0,
	remote = nil,
	connections = {}
}

local function deviceFor(instance)
	local device = InputTelemetry.Device

	if typeof(instance) == "Instance" then
		local userInputType = instance.UserInputType

		if userInputType == Enum.UserInputType.Touch then
			return device.Touch
		end

		if string.match(userInputType.Name, "^Gamepad") then
			return device.Gamepad
		end

		return device.Desktop
	else
		local v2 = LastInput:Get()

		if v2 == "Touch" then
			return device.Touch
		elseif v2 == "Gamepad" then
			return device.Gamepad
		elseif v2 == "MouseKeyboard" then
			return device.Desktop
		end

		return device.Unknown
	end
end

local function triggerFor(instance)
	local trigger = InputTelemetry.Trigger

	if typeof(instance) == "Instance" then
		local userInputType = instance.UserInputType

		if userInputType == Enum.UserInputType.Keyboard or string.match(userInputType.Name, "^Gamepad") then
			return trigger.Keybind
		end

		if userInputType == Enum.UserInputType.Touch then
			return trigger.Tap
		end

		return trigger.Pointer
	else
		local device = InputTelemetry.Device
		local v2 = LastInput:Get()
		local touch

		if v2 == "Touch" then
			touch = device.Touch
		elseif v2 == "Gamepad" then
			touch = device.Gamepad
		elseif v2 == "MouseKeyboard" then
			touch = device.Desktop
		else
			touch = device.Unknown
		end

		if touch == InputTelemetry.Device.Touch then
			return trigger.Tap
		end

		if touch == InputTelemetry.Device.Gamepad then
			return trigger.Keybind
		end

		if touch == InputTelemetry.Device.Desktop then
			return trigger.Pointer
		end

		return trigger.Unknown
	end
end

local function flush()
	local remote = v.remote

	if not remote or #v.buffer == 0 then
		return
	end

	local buffer = v.buffer
	v.buffer = {}
	v.lastFlush = os.clock()
	remote:FireServer(buffer)
end

local function push(p: number, p2: number, p3: number, p4: number)
	if not v.enabled or MAX_BATCH_EVENTS <= #v.buffer then
		return
	end

	local v3 = math.floor((os.clock() - lastTime) * 1000)
	table.insert(v.buffer, InputTelemetry.newEvent(p, p2, v3, p3, p4))

	if #v.buffer >= 48 and os.clock() - v.lastFlush >= 0.5 then
		flush()
	end
end

local function observe(input, p: number)
	local v2

	if input.KeyCode == Enum.KeyCode.Unknown then
		v2 = InputTelemetry.codeForInputType(input.UserInputType)
	else
		v2 = InputTelemetry.codeForKeyCode(input.KeyCode)
	end

	if not v.codes[v2] then
		return
	end

	push(InputTelemetry.Kind.Input, v2, deviceFor(input), p)
end

local function setListening(enabled: boolean)
	if enabled == (#v.connections > 0) then
		return
	end

	if enabled then
		table.insert(v.connections, UserInputService.InputBegan:Connect(function(input)
			observe(input, InputTelemetry.InputState.Begin)
		end))
		table.insert(v.connections, UserInputService.InputEnded:Connect(function(input)
			observe(input, InputTelemetry.InputState.End)
		end))
	else
		for _, connection in v.connections do
			connection:Disconnect()
		end

		table.clear(v.connections)
	end
end

local function applyConfig(result)
	if typeof(result) ~= "table" then
		return
	end

	v.enabled = result.Enabled == true
	v.flushSeconds = math.clamp(tonumber(result.FlushSeconds) or 2, 0.5, 30)

	if typeof(result.Codes) == "table" then
		local codes = {}

		for _, code in result.Codes do
			if typeof(code) == "number" then
				codes[code] = true
			end
		end

		v.codes = codes
	end

	if not v.enabled then
		table.clear(v.buffer)
	end

	setListening(v.enabled)
end

local InputTelemetryController = {}

function InputTelemetryController.recordAbilityIntent(p: string, p2)
	local abilityIdFor = InputTelemetry.abilityIdFor(p)

	if not abilityIdFor then
		return
	end

	push(InputTelemetry.Kind.Ability, abilityIdFor, deviceFor(p2), triggerFor(p2))
end

function InputTelemetryController.OnStart(_)
	task.spawn(function()
		local remoteEvent = Net:RemoteEvent(InputTelemetry.REMOTE_EVENT)
		local remoteFunction = Net:RemoteFunction(InputTelemetry.REMOTE_FUNCTION)
		v.remote = remoteEvent
		remoteEvent.OnClientEvent:Connect(applyConfig)

		for i = 1, 5 do
			local success, result = pcall(function()
				return remoteFunction:InvokeServer()
			end)

			if success and result ~= nil then
				applyConfig(result)
				break
			elseif i < 5 then
				task.wait(5)
			end
		end

		while true do
			task.wait(v.flushSeconds)
			flush()
		end
	end)
end

return InputTelemetryController