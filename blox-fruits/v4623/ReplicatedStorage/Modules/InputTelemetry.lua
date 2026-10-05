local InputTelemetry = {
	REMOTE_EVENT = "InputTelemetry",
	REMOTE_FUNCTION = "InputTelemetryConfig",
	EVENT_STRIDE = 5,
	MAX_BATCH_EVENTS = 150,
	MAX_OFFSET_MS = 86400000,
	Field = {
		Kind = 1,
		Code = 2,
		Offset = 3,
		Device = 4,
		Detail = 5
	},
	Kind = {
		Input = 1,
		Ability = 2
	},
	Device = {
		Unknown = 0,
		Desktop = 1,
		Gamepad = 2,
		Touch = 3
	},
	InputState = {
		Begin = 0,
		End = 1
	},
	Trigger = {
		Unknown = 0,
		Keybind = 1,
		Pointer = 2,
		Tap = 3
	}
}
local v = {
	"Z",
	"X",
	"C",
	"V",
	"F",
	"TAP"
}
local v2 = {
	Z = Enum.KeyCode.Z,
	X = Enum.KeyCode.X,
	C = Enum.KeyCode.C,
	V = Enum.KeyCode.V,
	F = Enum.KeyCode.F,
	TAP = Enum.KeyCode.G
}
local v3 = {
	Z = Enum.KeyCode.ButtonX,
	X = Enum.KeyCode.ButtonY,
	C = Enum.KeyCode.ButtonB,
	V = Enum.KeyCode.ButtonL2,
	F = Enum.KeyCode.DPadRight,
	TAP = Enum.KeyCode.ButtonR2
}
local v4 = {
	Enum.KeyCode.Q,
	Enum.KeyCode.E,
	Enum.KeyCode.R,
	Enum.KeyCode.T,
	Enum.KeyCode.Space,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five
}
local v5 = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

function InputTelemetry.codeForKeyCode(p)
	return p.Value
end

function InputTelemetry.codeForInputType(p)
	return -(p.Value + 1)
end

local v6 = {}

for k, v7 in v do
	v6[v7] = k
end

local v7 = {}

for _, v8 in v do
	local v9 = { InputTelemetry.codeForKeyCode(v2[v8]), InputTelemetry.codeForKeyCode(v3[v8]) }

	if v8 == "TAP" then
		table.insert(v9, InputTelemetry.codeForInputType(Enum.UserInputType.MouseButton1))
		table.insert(v9, InputTelemetry.codeForInputType(Enum.UserInputType.Touch))
	end

	v7[v8] = v9
end

local v8 = {}
local v9 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function add(p: number)
	if not v9[p] then
		v9[p] = true
		table.insert(v8, p)
	end
end

for _, v10 in v7 do
	for _, v11 in v10 do
		add(v11) -- equivalent call inferred; original call site unknown
	end
end

for _, v10 in v4 do
	add(InputTelemetry.codeForKeyCode(v10)) -- equivalent call inferred; original call site unknown
end

for _, v10 in v5 do
	add(InputTelemetry.codeForInputType(v10)) -- equivalent call inferred; original call site unknown
end

table.sort(v8)

function InputTelemetry.newEvent(p: number, p2: number, p3: number, p4: number, p5: number)
	return {
		p,
		p2,
		p3,
		p4,
		p5
	}
end

function InputTelemetry.abilityIdFor(p: string)
	return v6[p]
end

function InputTelemetry.abilityKeyFor(p: number)
	return v[p]
end

function InputTelemetry.rawCodesFor(p: string)
	return v7[p]
end

function InputTelemetry.defaultCodes()
	return table.clone(v8)
end

local function nameFor(items, p: number)
	for k, item in items do
		if item == p then
			return k
		end
	end

	return "Unknown"
end

function InputTelemetry.deviceName(p: number)
	for k, v10 in InputTelemetry.Device do
		if v10 == p then
			return k
		end
	end

	return "Unknown"
end

function InputTelemetry.triggerName(p: number)
	for k, v10 in InputTelemetry.Trigger do
		if v10 == p then
			return k
		end
	end

	return "Unknown"
end

return InputTelemetry