local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Promise = require(ReplicatedStorage.Utilities.Promise)
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
require(script.Parent.types.Authoring)
require(script.Parent.types.Save)
require(script.Parent.types.Sequence)
local SaveValidator = require(script.Parent.validation.SaveValidator)
local Sequence = require(script.Parent.runtime.Sequence)
local PropertyRegistry = require(script.Parent.strips.PropertyRegistry)
local StripRegistry = require(script.Parent.strips.StripRegistry)

local function checkSaveConfiguration(configuration)
	if configuration:IsA("Configuration") then
		return configuration
	end

	error("Orchestrator SaveFile must be a Configuration.")
end

local function getRoot(p)
	local parent = p.Parent

	if parent ~= nil then
		return parent
	end

	error("Orchestrator SaveFile must have a parent actor root.")
end

local function decodeData(configuration)
	local data = configuration:GetAttribute("Data")

	if type(data) ~= "string" or data == "" then
		error("Orchestrator SaveFile must have a non-empty string Data attribute.")
	end

	local success, result = pcall(TableUtils.DecodeJSON, data)

	if not success then
		error(string.format("Could not decode Orchestrator Data: %s", (tostring(result))))
	end

	local v, v2 = SaveValidator.prepare(result)

	if v ~= nil then
		return v
	end

	error(string.format("Invalid Orchestrator Data: %s", (tostring(v2))))
end

local function resolveExecutionContext(p)
	local v = RunService:IsServer() and "server" or "client"

	if p == nil or p.previewContext == nil then
		return v
	end

	if p.previewContext ~= "server" and p.previewContext ~= "client" then
		error("previewContext must be 'server' or 'client'.")
		return
	end

	if RunService:IsStudio() then
		return p.previewContext
	end

	error("previewContext is available only in Studio.")
end

local function resolveRoot(p, p2)
	if p2 == nil or p2.previewRoot == nil then
		return getRoot(p)
	end

	if RunService:IsStudio() then
		return p2.previewRoot
	end

	error("previewRoot is available only in Studio.")
end

local freezeDeep

freezeDeep = function(list)
	if type(list) == "table" and not table.isfrozen(list) then
		for _, v in list do
			freezeDeep(v)
		end

		table.freeze(list)
	end

	return list
end

local function protectVoid(callback)
	return pcall(function()
		callback()
		return nil
	end)
end

local function preloadStrips(p, p2: string?)
	for _, strip in p.strips do
		local v = PropertyRegistry.get(strip.propertyName)
		local v2 = v == nil and "both" or v.context

		if p2 == nil or v2 == "both" or v2 == p2 then
			StripRegistry.preload(strip)
		end
	end
end

local function preloadData(p, p2: string?)
	return Promise.new(function(callback, callback2)
		local function fn()
			preloadStrips(p, p2)
		end

		local success, result = pcall(function()
			fn()
			return nil
		end)

		if success then
			callback()
		else
			callback2(result)
		end
	end)
end

local Orchestrator = {}

function Orchestrator.getRoot(p)
	return getRoot(checkSaveConfiguration(p))
end

function Orchestrator.getMetadata(configuration)
	if not configuration:IsA("Configuration") then
		error("Orchestrator SaveFile must be a Configuration.")
		configuration = nil
	end

	local v = decodeData(configuration)
	return {
		name = configuration.Name,
		durationSeconds = v.durationSeconds,
		schemaVersion = v.schemaVersion
	}
end

function Orchestrator.load(configuration, p)
	if not configuration:IsA("Configuration") then
		error("Orchestrator SaveFile must be a Configuration.")
		configuration = nil
	end

	local parent

	if p == nil or p.previewRoot == nil then
		parent = configuration.Parent

		if parent == nil then
			error("Orchestrator SaveFile must have a parent actor root.")
			parent = nil
		end
	elseif RunService:IsStudio() then
		parent = p.previewRoot
	else
		error("previewRoot is available only in Studio.")
	end

	local v = decodeData(configuration)
	local executionContext = resolveExecutionContext(p)
	Promise.new(function(callback, callback2)
		local function fn()
			preloadStrips(v, executionContext)
		end

		local success, result = pcall(function()
			fn()
			return nil
		end)

		if success then
			callback()
		else
			callback2(result)
		end
	end):catch(function(p2)
		warn(string.format("Could not preload Orchestrator assets: %s", (tostring(p2))))
	end)
	return (Sequence.new(v, parent, executionContext))
end

function Orchestrator.preload(configuration)
	if not configuration:IsA("Configuration") then
		error("Orchestrator SaveFile must be a Configuration.")
		configuration = nil
	end

	return preloadData(decodeData(configuration), nil)
end

function Orchestrator.getAuthoringCatalog()
	return (freezeDeep({
		properties = PropertyRegistry.getAuthoringDefinitions(),
		strips = {}
	}))
end

function Orchestrator.save(configuration, p)
	if not RunService:IsStudio() then
		error("Orchestrator.save is available only in Studio.")
	end

	if not configuration:IsA("Configuration") then
		error("Orchestrator SaveFile must be a Configuration.")
		configuration = nil
	end

	local clone = table.clone(p)
	clone.name = configuration.Name
	local v, v2 = SaveValidator.prepare(clone)

	if v == nil then
		error(string.format("Invalid Orchestrator Data: %s", (tostring(v2))))
	end

	local success, result = pcall(TableUtils.EncodeJSON, v)

	if not success then
		error(string.format("Could not encode Orchestrator Data: %s", (tostring(result))))
	end

	local success2, result2 = pcall(TableUtils.DecodeJSON, result)

	if not success2 then
		error(string.format("Could not decode Orchestrator Data: %s", (tostring(result2))))
	end

	local v3, v4 = SaveValidator.prepare(result2)

	if v3 == nil then
		error(string.format("Invalid Orchestrator Data: %s", (tostring(v4))))
	end

	local data = configuration:GetAttribute("Data")

	local function fn()
		configuration:SetAttribute("Data", result)
	end

	local success3, result3 = pcall(function()
		fn()
		return nil
	end)

	if not success3 then
		pcall(configuration.SetAttribute, configuration, "Data", data)
		error(string.format("Could not write Orchestrator Data: %s", (tostring(result3))))
	end
end

return Orchestrator