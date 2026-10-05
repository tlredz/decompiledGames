local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local directionsByKeyCode = {}
local GamepadInput = {
	Thumbstick1Flicked = FastSignal.new(),
	Thumbstick2Flicked = FastSignal.new()
}

local function getDeadzoneValue(p: number, p2: number)
	if math.abs(p) < p2 then
		return 0
	end

	if p2 < p then
		return 1
	end

	return -1
end

local function isNeutral(p)
	return p.Position.Magnitude < 0.1
end

local function getFlatPosition(p)
	local X = p.Position.X
	local v = math.abs(X) < 0.3 and 0 or X > 0.3 and 1 or -1
	local Y = p.Position.Y
	local v2 = math.abs(Y) < 0.3 and 0 or Y > 0.3 and 1 or -1
	local Z = p.Position.Z
	return (Vector3.new(v, v2, math.abs(Z) < 0.3 and 0 or Z > 0.3 and 1 or -1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDirection(vector: Vector3)
	if vector.X == 1 then
		return "Right"
	end

	if vector.X == -1 then
		return "Left"
	end

	if vector.Y == 1 then
		return "Up"
	end

	if vector.Y == -1 then
		return "Down"
	end

	return "Neutral"
end

UserInputService.InputChanged:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Thumbstick1 or input.KeyCode == Enum.KeyCode.Thumbstick2 then
		local X = input.Position.X
		local v = math.abs(X) < 0.3 and 0 or X > 0.3 and 1 or -1
		local Y = input.Position.Y
		local v2 = math.abs(Y) < 0.3 and 0 or Y > 0.3 and 1 or -1
		local Z = input.Position.Z
		local direction = getDirection(Vector3.new(v, v2, math.abs(Z) < 0.3 and 0 or Z > 0.3 and 1 or -1)) -- equivalent call inferred; original call site unknown

		if directionsByKeyCode[input.KeyCode] ~= direction and direction ~= "Neutral" and input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
			local _ = input.KeyCode == Enum.KeyCode.Thumbstick2
		end

		directionsByKeyCode[input.KeyCode] = direction
	end
end)
return GamepadInput