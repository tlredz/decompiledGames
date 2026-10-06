local createVector = vector.create
local Keymap = {
	EnterVehicleKeyboard = Enum.KeyCode.E,
	EnterVehicleGamepad = Enum.KeyCode.ButtonY,
	Handbrake = {
		{
			KeyCode = Enum.KeyCode.Space
		},
		{
			KeyCode = Enum.KeyCode.ButtonA
		}
	},
	SteerLeft = {
		{
			KeyCode = Enum.KeyCode.A
		},
		{
			KeyCode = Enum.KeyCode.Left
		},
		{
			KeyCode = Enum.KeyCode.Thumbstick1,
			Axis = createVector(-1, 0, 0)
		}
	},
	SteerRight = {
		{
			KeyCode = Enum.KeyCode.D,
			Sign = -1
		},
		{
			KeyCode = Enum.KeyCode.Right,
			Sign = -1
		},
		{
			KeyCode = Enum.KeyCode.Thumbstick1,
			Axis = createVector(-1, 0, 0)
		}
	},
	Throttle = {
		{
			KeyCode = Enum.KeyCode.W
		},
		{
			KeyCode = Enum.KeyCode.Up
		},
		{
			KeyCode = Enum.KeyCode.ButtonR2,
			Axis = createVector(0, 0, 1)
		}
	},
	Brake = {
		{
			KeyCode = Enum.KeyCode.S
		},
		{
			KeyCode = Enum.KeyCode.Down
		},
		{
			KeyCode = Enum.KeyCode.ButtonL2,
			Axis = createVector(0, 0, 1)
		}
	}
}
local v = {}

for _, v2 in pairs(Keymap) do
	if type(v2) ~= "table" then
		continue
	end

	for _, v3 in ipairs(v2) do
		if type(v3) == "table" then
			v[v3.KeyCode] = v3
		end
	end
end

function Keymap.KeysForAction(p)
	local keyCodes = {}

	for i, v2 in ipairs(Keymap[p]) do
		keyCodes[i] = v2.KeyCode
	end

	return keyCodes
end

function Keymap.allKeys()
	local result = {}

	for k, _ in pairs(v) do
		table.insert(result, k)
	end

	return result
end

function Keymap.getData(p)
	return v[p]
end

function Keymap.newInputTable()
	local result = {}

	for k, _ in pairs(v) do
		result[k] = 0
	end

	return result
end

return Keymap