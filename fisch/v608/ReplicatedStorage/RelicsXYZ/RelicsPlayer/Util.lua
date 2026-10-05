local parent = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = parent.Shared
local UserId = require(shared.UserId)
local v = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true
}
local Util = {}

function Util.IsDemo()
	return ReplicatedStorage:HasTag("__RELICSXYZ_DEMO_PLACE_INTERNAL_ONLY__")
end

function Util.LevenshteinDistance(value: string, value2: string)
	local count = #value
	local count2 = #value2
	local v2 = {}

	for i = 0, count do
		v2[i] = {
			[0] = i
		}
	end

	for i = 0, count2 do
		v2[0][i] = i
	end

	for i = 1, count do
		for i2 = 1, count2 do
			local v3 = value:sub(i, i):lower() == value2:sub(i2, i2):lower() and 0 or 1
			v2[i][i2] = math.min(v2[i - 1][i2] + 1, v2[i][i2 - 1] + 1, v2[i - 1][i2 - 1] + v3)
		end
	end

	return v2[count][count2]
end

Util.GetUserId = UserId.Get

function Util.PlaySound(soundId: string, parent2, value: number?)
	if soundId == "" or soundId == nil then
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Volume = value or 0.5
	sound.SoundId = soundId
	sound.Parent = parent2
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

function Util.ClassNames(...)
	local v2 = {}

	for _, v3 in { ... } do
		if typeof(v3) == "string" and v3 ~= "" then
			table.insert(v2, v3)
		end
	end

	local parts = table.concat(v2, " "):split(" ")
	local v3 = ""

	for k, part in parts do
		if typeof(part) == "string" then
			v3 ..= ` {part}{k < #parts and " " or ""}`
		end
	end

	return v3
end

function Util.FormatTitle(value: string)
	local parts = value:split(" ")
	local v2 = ""

	for k, part in parts do
		v2 ..= ` {string.sub(part, 1, 1):upper()}{string.sub(part, 2, -1):lower()}{k < #parts and " " or ""}`
	end

	return v2
end

function Util.IsPointerInput(p)
	return v[p.UserInputType] ~= nil
end

function Util.IsMoveInput(p)
	local userInputType = p.UserInputType
	return userInputType == Enum.UserInputType.MouseMovement or v[userInputType] ~= nil
end

function Util.CoerceImage(value)
	if type(value) == "string" then
		local match = value:match("^%d+$")

		if match then
			return "rbxassetid://" .. match
		end

		if value == "" or not value then
			value = nil
		end

		return value
	elseif type(value) == "number" and value ~= 0 then
		return "rbxassetid://" .. tostring(value)
	else
		return nil
	end
end

function Util.GetSamplePreviewRange(value: number?)
	local v2, v3

	if type(value) == "number" and value > 0 then
		v2 = math.clamp(value * 0.25 + 15, 0, (math.max(value - 15, 0)))
		v3 = math.max(math.min(15, value - v2), 0)
	else
		v2 = 15
		v3 = 15
	end

	return v2, v3
end

return Util