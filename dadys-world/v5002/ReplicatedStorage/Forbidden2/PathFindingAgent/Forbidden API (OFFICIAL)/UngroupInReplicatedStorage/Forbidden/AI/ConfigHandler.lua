require(script.Parent.Types)
local Tables = require(script.Parent.Parent.Libraries.Tables)
local Defaults = require(script.Defaults)
local ConfigHandler = {}
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveMetatable(p)
	Tables.RemoveMetatable(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddMetatable(p)
	Tables.LockKeyInTable(p, "NPC")
end

local fn

local function InitializeConfig(p)
	if v2[p] then
		return
	end

	local v5 = fn(p)
	v2[p] = v5
	v[p] = Tables.DeepCopy(v5)
	v4[p] = {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateCleanConfig(p)
	local copy = Tables.DeepCopy(p)
	RemoveMetatable(copy) -- equivalent call inferred; original call site unknown
	copy.NPC = nil
	return copy
end

function RestoreDefaults(p)
	local NPC = p.NPC
	RemoveMetatable(p) -- equivalent call inferred; original call site unknown
	Tables.DeepCopyPaste(Defaults, p)
	p.NPC = NPC
	AddMetatable(p) -- equivalent call inferred; original call site unknown
end

function RestoreActiveConfig(p)
	RemoveMetatable(v2[p.NPC]) -- equivalent call inferred; original call site unknown
	Tables.DeepCopyPaste(v[p.NPC], v2[p.NPC])
	AddMetatable(v2[p.NPC]) -- equivalent call inferred; original call site unknown
end

function SavePreset(p, p2: string, flag: boolean?)
	if p2 == "" or p2 == nil then
		warn("Preset name cannot be nil or empty.")
		return
	end

	if flag then
		ConfigHandler.SaveGlobalPreset(p2, p)
		return
	end

	local cleanConfig = CreateCleanConfig(p) -- equivalent call inferred; original call site unknown

	if not flag then
		v4[p.NPC][p2] = cleanConfig
	end
end

function LoadPreset(p, p2: string, flag: boolean?)
	if p2 == nil or p2 == "" then
		warn("Preset name cannot be nil or empty.")
		return
	end

	local v5 = v4[p.NPC][p2]
	local v6 = v3[p2]
	local v7

	if flag then
		v7 = v6 or v5
	else
		v7 = v5
	end

	if not v5 then
		v7 = v6
	end

	if not v7 then
		warn((`Preset '{p2}' does not exist locally or globally.`))
		return
	end

	local copy = Tables.DeepCopy(v7)
	copy.NPC = p.NPC
	RemoveMetatable(v2[p.NPC]) -- equivalent call inferred; original call site unknown
	Tables.DeepCopyPaste(copy, p)
	AddMetatable(p) -- equivalent call inferred; original call site unknown
end

function ApplyNow(p)
	if not p.NPC then
		error("Cannot apply config to NPC, NPC field is nil.")
	end

	Tables.DeepCopyPaste(v2[p.NPC], v[p.NPC])
end

fn = function(NPC)
	local copy = Tables.DeepCopy(Defaults)
	copy.NPC = NPC

	function copy.SavePreset(p, p2: string, flag: boolean?)
		SavePreset(p, p2, flag)
	end

	function copy.LoadPreset(p, p2: string, flag: boolean?)
		LoadPreset(p, p2, flag)
	end

	function copy.RestoreDefaults(p)
		RestoreDefaults(p)
	end

	function copy.RestoreActiveConfig(p)
		RestoreActiveConfig(p)
	end

	function copy.ApplyNow(p)
		ApplyNow(p)
	end

	AddMetatable(copy) -- equivalent call inferred; original call site unknown
	return copy
end

function ConfigHandler.SaveGlobalPreset(p: string, p2)
	if p == "" or p == nil then
		warn("Preset name cannot be nil or empty.")
		return
	end

	v3[p] = CreateCleanConfig(p2)
end

function ConfigHandler.GetConfig(p)
	if v2[p] or v2[p] then
		return v2[p]
	end

	local v5 = fn(p)
	v2[p] = v5
	v[p] = Tables.DeepCopy(v5)
	v4[p] = {}
	return v2[p]
end

function ConfigHandler.GetActiveConfig(p)
	if v[p] or v2[p] then
		return v[p]
	end

	local v5 = fn(p)
	v2[p] = v5
	v[p] = Tables.DeepCopy(v5)
	v4[p] = {}
	return v[p]
end

function ConfigHandler.TriggerCleanup(p)
	v[p] = nil
	v2[p] = nil
	v4[p] = nil
end

return ConfigHandler