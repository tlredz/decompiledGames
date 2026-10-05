local createVector = vector.create
local Piano = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = require(script.Player)

function Piano.GetKeyCodes(_)
	local result = {
		Enum.KeyCode.Zero,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine
	}

	for i = 97, 122 do
		table.insert(result, Enum.KeyCode[string.upper((string.char(i)))])
	end

	return result
end

function Piano.IsBlack(_, p: number)
	return p % 12 == 2 or p % 12 == 4 or p % 12 == 7 or p % 12 == 9 or p % 12 == 11
end

function Piano.GetKeyPart(_, p, value: number)
	local v = math.clamp(value, 1, 61)
	local v2 = math.ceil(v / 12)
	local v3 = (v - 1) % 12 + 1
	return p.Keys[v2][v3]
end

function Piano.HighlightKey(_, p, p2: number)
	local v = math.ceil(p2 / 12)
	local v2 = (p2 - 1) % 12 + 1
	local v3 = p.Keys[v][v2]
	local offset = Piano:IsBlack(p2) and createVector(0.02, -0.15, 0) or createVector(0, -0.05, 0)
	TweenService:Create(v3.Mesh, TweenInfo.new(0.2), {
		Offset = offset
	}):Play()
end

function Piano:RestoreKey(p, p2: number)
	local v = math.ceil(p2 / 12)
	local v2 = (p2 - 1) % 12 + 1
	local v3 = p.Keys[v][v2]
	local offset = Piano:IsBlack(p2) and createVector(0.02, -0.1, 0) or createVector(0, 0, 0)
	TweenService:Create(v3.Mesh, TweenInfo.new(0.2), {
		Offset = offset
	}):Play()
end

function Piano.RestoreAllKeys(_, p)
	for i = 1, 61 do
		Piano:RestoreKey(p, i)
	end
end

function Piano.GetNoteFromKey(_, value: number, flag: boolean?)
	if not value or typeof(value) ~= "number" or not (value >= 97 and value <= 122 or value >= 48 and value <= 57) then
		return
	end

	local v = string.char(value)

	if flag then
		if tonumber(v) then
			v = string.sub(")!@#$%^&*(", tonumber(v) + 1, tonumber(v) + 1)
		else
			v = string.upper(v)
		end
	end

	local v2 = string.find("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm", v, 1, true)
	return v2 or nil
end

function Piano.GetPianoModel(_, p)
	local character = (p or Players.LocalPlayer).Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent) then
		return
	end

	local parent = humanoid.SeatPart.Parent.Parent

	if parent and parent:HasTag("Piano") then
		return parent
	end

	return nil
end

Piano.Player = Player
return Piano