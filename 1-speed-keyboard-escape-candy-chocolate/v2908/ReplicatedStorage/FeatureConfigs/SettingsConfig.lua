local SettingsConfig = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)
local _, _ = PlaceRegistry.locate()

local function Title(text)
	return {
		kind = "title",
		text = text
	}
end

local function Boolean(p, label, default, description, options)
	local result = {
		kind = "toggle",
		key = p,
		label = label,
		default = default,
		description = description
	}

	for k, v in pairs(options or {}) do
		result[k] = v
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Slider(p, label, default, min, max, step, description, suffix)
	return {
		kind = "slider",
		key = p,
		label = label,
		default = default,
		min = min,
		max = max,
		step = step,
		description = description,
		suffix = suffix
	}
end

local function buildMap(...)
	local result = {}

	for i = 1, select("#", ...) do
		local v = select(i, ...)

		if v then
			table.insert(result, v)
		end
	end

	return result
end

SettingsConfig.MAP = buildMap({
	kind = "title",
	text = "General"
}, Boolean("TrophyEnabled", "Trophy", false, "Trophy fly animations on wins."), Boolean(
	"SpeedrunEnabled",
	"Speedrun",
	false,
	"Race chrono display."
), {
	kind = "title",
	text = "Sounds"
}, Slider("MusicAAVolume", "Music Admin Abuse", 100, 0, 100, 5, "Volume of the Admin Abuse musics.", "%"), Slider(
	"KeycapsVolume",
	"Keycaps",
	100,
	0,
	100,
	5,
	"Volume of the keycap sounds.",
	"%"
), {
	kind = "title",
	text = "Other"
}, Boolean("HideTag", "Hide Tag", false, "Hide your group tag above your head.", {
	visibleIf = "HasGroupTag"
}), Boolean("HideGiftNotifications", "Hide Gifts", false, "Hide gift received notification popups."), (Boolean(
	"DisableTradeRequests",
	"Disable Trade Requests",
	false,
	"Block incoming item trade requests from other players."
)))
SettingsConfig.SETTINGS = {}

for _, v in ipairs(SettingsConfig.MAP) do
	if v.key then
		SettingsConfig.SETTINGS[v.key] = v
	end
end

function SettingsConfig.GetDefaults()
	local defaults = {}

	for k, v in pairs(SettingsConfig.SETTINGS) do
		defaults[k] = v.default
	end

	return defaults
end

local function snapToStep(data, value)
	if data.step and data.step > 0 then
		value = data.min + math.floor((value - data.min) / data.step + 0.5) * data.step
	end

	return (math.clamp(value, data.min, data.max))
end

function SettingsConfig.Validate(p, value)
	local v = SettingsConfig.SETTINGS[p]

	if not v then
		return nil
	end

	if v.kind == "toggle" then
		if type(value) == "boolean" then
			return value
		end

		return nil
	else
		if v.kind ~= "slider" or (type(value) ~= "number" or value ~= value) then
			return nil
		end

		if v.step and v.step > 0 then
			value = v.min + math.floor((value - v.min) / v.step + 0.5) * v.step
		end

		return (math.clamp(value, v.min, v.max))
	end
end

SettingsConfig.SnapToStep = snapToStep
return SettingsConfig