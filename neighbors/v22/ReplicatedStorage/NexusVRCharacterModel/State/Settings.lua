local parent = script.Parent.Parent
local NexusInstance = require(parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local typedEvent = NexusInstance.TypedEvent
local Settings = {}
Settings.__index = Settings
local v = nil

function Settings.new()
	return (setmetatable({
		Defaults = {},
		Overrides = {},
		SettingsChangeEvents = {},
		SettingsCache = {}
	}, Settings))
end

function Settings.GetInstance()
	if not v then
		v = Settings.new()
	end

	return v
end

function Settings.GetSetting(data, value: string)
	if data.SettingsCache[value] ~= nil then
		return data.SettingsCache[value]
	end

	local defaults = data.Defaults
	local overrides = data.Overrides
	local v2 = string.split(value, ".")

	for i = 1, #v2 - 1 do
		defaults = defaults[v2[i]] or {}
		overrides = overrides[v2[i]] or {}
	end

	local override = overrides[v2[#v2]]

	if override == nil then
		override = defaults[v2[#v2]]
	end

	data.SettingsCache[value] = override
	return override
end

function Settings.SetSetting(data, value: string, p)
	local overrides = data.Overrides
	local v2 = string.split(value, ".")

	for i = 1, #v2 - 1 do
		if not overrides[v2[i]] then
			overrides[v2[i]] = {}
		end

		overrides = overrides[v2[i]]
	end

	overrides[v2[#v2]] = p
	data.SettingsCache[value] = p
	local settingsChangeEvent = data.SettingsChangeEvents[string.lower(value)]

	if settingsChangeEvent then
		settingsChangeEvent:Fire()
	end
end

function Settings:SetDefaults(defaults)
	self.Defaults = defaults
	self.SettingsCache = {}

	for _, settingsChangeEvent in self.SettingsChangeEvents do
		settingsChangeEvent:Fire()
	end
end

function Settings:SetOverrides(overrides)
	self.Overrides = overrides
	self.SettingsCache = {}

	for _, settingsChangeEvent in self.SettingsChangeEvents do
		settingsChangeEvent:Fire()
	end
end

function Settings.GetSettingsChangedSignal(p, value: string)
	local v2 = string.lower(value)

	if not p.SettingsChangeEvents[v2] then
		p.SettingsChangeEvents[v2] = typedEvent.new()
	end

	return p.SettingsChangeEvents[v2]
end

function Settings:Destroy()
	for _, settingsChangeEvent in self.SettingsChangeEvents do
		settingsChangeEvent:Destroy()
	end

	self.SettingsChangeEvents = {}
end

return Settings