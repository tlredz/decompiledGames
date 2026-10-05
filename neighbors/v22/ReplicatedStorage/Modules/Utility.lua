local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ControlModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

local function safe_unit_vector(p)
	if p.magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.unit
end

local Utility = {}

function Utility:GetMoveVector()
	if UserInputService.VREnabled then
		local moveVector = localPlayer:GetAttribute("MoveVector") or createVector(0, 0, 0)

		if moveVector.magnitude == 0 then
			return createVector(0, 0, 0)
		end

		return moveVector.unit
	else
		local moveVector = ControlModule:GetMoveVector()

		if moveVector.magnitude == 0 then
			return createVector(0, 0, 0)
		end

		return moveVector.unit
	end
end

function Utility.IsToolCooldown(_, p, p2, p3)
	local child = game.ReplicatedStorage.Cooldowns[p.Name]:FindFirstChild(p2.Name)

	if not p3 and child then
		script.Error:Play()
	end

	return child
end

function Utility.FormatString(_, value: string, items)
	for k, item in items do
		value = value:gsub(`\{{k}}`, item)
	end

	return value
end

function Utility.FailSafeFunction(_, callback, value: number?, value2: number?)
	local v = nil

	for _ = 1, value or 1 do
		v = table.pack(pcall(callback))

		if v[1] then
			break
		else
			task.wait(value2 or 1)
		end
	end

	if not v[1] then
		return false
	end

	table.remove(v, 1)
	return table.unpack(v)
end

return Utility