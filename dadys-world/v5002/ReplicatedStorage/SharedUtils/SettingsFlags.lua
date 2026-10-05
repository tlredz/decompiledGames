local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerSettings = require(ReplicatedStorage.SharedData.PlayerSettings)
local SettingsFlags = {
	Changed = ReplicatedStorage:GetAttributeChangedSignal("DisabledSettings")
}
local v = {}
local v2 = nil
local v3 = false
local v4 = {}
local v5 = {}
local v6 = {}

local function parseLive()
	local disabledSettings = ReplicatedStorage:GetAttribute("DisabledSettings")

	if v3 and disabledSettings == v2 then
		return
	end

	v3 = true
	v2 = disabledSettings
	v = {}

	if type(disabledSettings) ~= "string" or disabledSettings == "" then
		return
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(disabledSettings)
	end)

	if not success or type(result) ~= "table" then
		warn("[SettingsFlags] unparseable DisabledSettings; treating as EMPTY:", disabledSettings)
		return
	end

	for _, v7 in ipairs(result) do
		if type(v7) == "string" and v7 ~= "" then
			v[v7] = true
		end
	end
end

ReplicatedStorage:GetAttributeChangedSignal("DisabledSettings"):Connect(parseLive)
parseLive()

local function hierarchyEntry(value: string)
	local hierarchy = PlayerSettings.Hierarchy

	for _, v7 in ipairs(value:split(".")) do
		if type(hierarchy) ~= "table" then
			return nil
		end

		hierarchy = hierarchy[v7]

		if hierarchy == nil then
			return nil
		end
	end

	return hierarchy
end

local function staticDisabled(value: string)
	local parts = value:split(".")

	if parts[1] == "Tabs" and parts[2] then
		return (PlayerSettings.DisabledTabs or {})[parts[2]] == true
	end

	local v7 = hierarchyEntry(value)
	return type(v7) == "table" and v7.Disabled == true
end

function SettingsFlags:IsEnabled(value: string)
	parseLive()
	local v7 = nil

	for _, v8 in ipairs(value:split(".")) do
		if v7 then
			v7 ..= "." .. v8
		else
			v7 = v8
		end

		if v[v7] or staticDisabled(v7) then
			return false
		end
	end

	return true
end

function SettingsFlags.GetEffective(_, p, p2: string)
	if SettingsFlags:IsEnabled(p2) then
		return p
	end

	local v7 = hierarchyEntry(p2)

	if type(v7) == "table" then
		return v7.DefaultValue
	end

	return nil
end

function SettingsFlags.IsTabEnabled(_, p: string)
	return SettingsFlags:IsEnabled("Tabs." .. p)
end

function SettingsFlags.IsRemappingEnabled(_)
	return SettingsFlags:IsEnabled("Keybinds")
end

function SettingsFlags.IsKnownPath(_, value: string)
	local parts = value:split(".")

	if parts[1] == "Tabs" and parts[2] then
		return PlayerSettings.Tabs[parts[2]] ~= nil
	end

	return hierarchyEntry(value) ~= nil
end

function SettingsFlags.GetDisabledList(_)
	parseLive()
	local result = {}

	for k in pairs(v) do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

local function computeEffective()
	local v7 = {}

	for k in pairs(v4) do
		v7[k] = true
	end

	for k in pairs(v5) do
		v7[k] = true
	end

	for k in pairs(v6) do
		v7[k] = nil
	end

	local result = {}

	for k in pairs(v7) do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publish()
	local jSONEncode = HttpService:JSONEncode((computeEffective()))

	if ReplicatedStorage:GetAttribute("DisabledSettings") == jSONEncode then
		return
	end

	ReplicatedStorage:SetAttribute("DisabledSettings", jSONEncode)
end

function SettingsFlags._SetConfigList(_, list)
	assert(RunService:IsServer(), "SettingsFlags:_SetConfigList is server-only")
	v4 = {}

	if type(list) == "table" then
		for _, v7 in ipairs(list) do
			if type(v7) == "string" and v7 ~= "" then
				v4[v7] = true
			end
		end
	end

	publish() -- equivalent call inferred; original call site unknown
end

function SettingsFlags.Disable(_, p: string)
	assert(RunService:IsServer(), "SettingsFlags:Disable is server-only")
	v5[p] = true
	v6[p] = nil
	publish() -- equivalent call inferred; original call site unknown
end

function SettingsFlags.Enable(_, p: string)
	assert(RunService:IsServer(), "SettingsFlags:Enable is server-only")
	v6[p] = true
	v5[p] = nil
	publish() -- equivalent call inferred; original call site unknown
end

function SettingsFlags.ClearOverride(_, p: string)
	assert(RunService:IsServer(), "SettingsFlags:ClearOverride is server-only")
	v5[p] = nil
	v6[p] = nil
	publish() -- equivalent call inferred; original call site unknown
end

function SettingsFlags.ClearAllOverrides(_)
	assert(RunService:IsServer(), "SettingsFlags:ClearAllOverrides is server-only")
	v5 = {}
	v6 = {}
	publish() -- equivalent call inferred; original call site unknown
end

function SettingsFlags.GetFlagSource(_, value: string)
	assert(RunService:IsServer(), "SettingsFlags:GetFlagSource is server-only")
	local v7 = nil

	for _, v8 in ipairs(value:split(".")) do
		if v7 then
			v7 ..= "." .. v8
		else
			v7 = v8
		end

		if staticDisabled(v7) then
			return "static"
		end
	end

	local v8 = nil

	for _, v9 in ipairs(value:split(".")) do
		if v8 then
			v8 ..= "." .. v9
		else
			v8 = v9
		end

		if v6[v8] then
			continue
		end

		if v5[v8] then
			return "override-off"
		end

		if v4[v8] then
			return "config"
		end
	end

	if v6[value] then
		return "override-on"
	end

	return "enabled"
end

function SettingsFlags.GetOverrides(_)
	assert(RunService:IsServer(), "SettingsFlags:GetOverrides is server-only")
	local add = {}
	local remove = {}

	for k in pairs(v5) do
		table.insert(add, k)
	end

	for k in pairs(v6) do
		table.insert(remove, k)
	end

	table.sort(add)
	table.sort(remove)
	return {
		add = add,
		remove = remove
	}
end

return SettingsFlags