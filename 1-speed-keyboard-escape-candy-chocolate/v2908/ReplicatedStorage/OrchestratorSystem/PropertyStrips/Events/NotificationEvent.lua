local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.OrchestratorState)
local v = nil

local function GetNotificationSystem()
	if not v then
		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		v = NotificationSystem
	end

	return v
end

local function ParseColor(color)
	if color == nil then
		return Color3.new(1, 1, 1), nil
	end

	if type(color) ~= "string" then
		return nil, "Notification color must be a hex string."
	end

	local v2 = string.match(color, "^#?(%x%x%x%x%x%x)$")

	if v2 then
		return
			Color3.fromRGB(
				assert((tonumber(string.sub(v2, 1, 2), 16))),
				assert((tonumber(string.sub(v2, 3, 4), 16))),
				assert((tonumber(string.sub(v2, 5, 6), 16)))
			),
			nil
	end

	return nil, "Notification color must use #RRGGBB format."
end

local function NormalizeDuration(value)
	if value == nil then
		return 4, nil
	end

	if type(value) == "number" and value == value and math.abs(value) ~= 1e999 and not (value <= 0 or value > 60) then
		return value, nil
	end

	return nil, "Notification duration must be greater than 0 and at most 60 seconds."
end

local function ValidateCommand(value)
	if type(value) ~= "table" then
		return false, "Notification events must contain a command table."
	end

	if type(value.Text) ~= "string" or value.Text == "" then
		return false, "Notification text must be a non-empty string."
	end

	if #value.Text > 300 then
		return false, "Notification text cannot exceed 300 bytes."
	end

	local _, v2 = ParseColor(value.Color)

	if v2 then
		return false, v2
	end

	local duration = value.Duration
	local v3

	if duration ~= nil then
		v3 = (type(duration) ~= "number" or duration ~= duration or math.abs(duration) == 1e999 or duration <= 0 or duration > 60) and "Notification duration must be greater than 0 and at most 60 seconds." or nil
	end

	return v3 == nil, v3
end

local NotificationEvent = {}
NotificationEvent.Type = "NotificationEvent"
NotificationEvent.DisplayName = "Notification Event"
NotificationEvent.GlobalEvent = true
NotificationEvent.CreateInitialKeyframe = false
NotificationEvent.HasKeyframeEasing = false
NotificationEvent.EditableProperties = {
	{
		Path = { "Value", "Text" },
		DisplayName = "Text",
		ValueType = "string",
		Default = "Notification"
	},
	{
		Path = { "Value", "Color" },
		DisplayName = "Color (#RRGGBB)",
		ValueType = "string",
		Default = "#FFFFFF"
	},
	{
		Path = { "Value", "Duration" },
		DisplayName = "Duration",
		ValueType = "number",
		Default = 4,
		Min = 0.1,
		Max = 60,
		Step = 0.1
	}
}

function NotificationEvent.Supports(p)
	return p == game
end

function NotificationEvent.ValidateKeyframe(p)
	return ValidateCommand(p.Value)
end

function NotificationEvent.Capture(_)
	return {
		Text = "Notification",
		Color = "#FFFFFF",
		Duration = 4
	}
end

function NotificationEvent.Evaluate(data)
	if not RunService:IsRunning() or not data.IsServer or data.IsSeeking or data.TimePosition <= data.PreviousTimePosition then
		return
	end

	if not v then
		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		v = NotificationSystem
	end

	local v2 = v

	for _, keyframe in data.Strip.Keyframes do
		local v3

		if keyframe.Time <= data.TimePosition then
			if keyframe.Time > data.PreviousTimePosition then
				v3 = true
			elseif keyframe.Time == 0 then
				v3 = data.PreviousTimePosition == 0
			else
				v3 = false
			end
		else
			v3 = false
		end

		if not v3 then
			continue
		end

		local value = keyframe.Value
		local v4, v5 = ParseColor(value.Color)

		if not v4 then
			error(v5 or "Notification event has an invalid color.")
		end

		local duration = value.Duration
		local v6

		if duration == nil then
			duration = 4
		elseif not (type(duration) == "number" and duration == duration and math.abs(duration) ~= 1e999 and not (duration <= 0 or duration > 60)) then
			duration = nil
			v6 = "Notification duration must be greater than 0 and at most 60 seconds."
		end

		if not duration then
			error(v6 or "Notification event has an invalid duration.")
		end

		v2:ShowGeneralNotificationForEveryone(value.Text, v4, duration)
	end
end

return NotificationEvent