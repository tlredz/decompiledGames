local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local DeepCopyPureUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepCopyPureUnsafe)
local DeepEqualsPureUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepEqualsPureUnsafe)
local DeepFreezeUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepFreezeUnsafe)
local Signal = require(ReplicatedStorage.Packages.Signal)

local function decodeJson(value)
	if type(value) == "string" then
		return pcall(HttpService.JSONDecode, HttpService, value)
	end

	return false, nil
end

local function define(name: string, assertion, p)
	Asserts.String(name)
	assert(string.match(name, "^%w+$") ~= nil, (`live event flag name {name} must be alphanumeric`))
	Asserts.Function(assertion)
	assertion(p)
	Asserts.Storable(p)
	local defaultValue = DeepFreezeUnsafe(DeepCopyPureUnsafe(p))
	local attributeName = "LiveEventFlag_" .. name
	local stepsAttributeName = attributeName .. "_Steps"
	local changed = Signal.new()

	local function decodeAttribute(attribute)
		if attribute == nil then
			return false, defaultValue
		end

		local success, result

		if type(attribute) == "string" then
			success, result = pcall(HttpService.JSONDecode, HttpService, attribute)
		else
			success = false
		end

		if not success then
			warn((`[LiveEventFlags] UndecodableValue '{name}'`))
			return true, defaultValue
		end

		local success2, result2 = pcall(assertion, result)

		if success2 then
			return true, DeepFreezeUnsafe(result)
		end

		warn(`[LiveEventFlags] InvalidStoredValue '{name}':`, result2, result)
		return true, defaultValue
	end

	local v6 = nil
	local v7 = false
	local v8 = defaultValue

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshFromAttribute()
		local attribute = workspace:GetAttribute(attributeName)

		if attribute == v6 then
			return
		end

		v6 = attribute
		v7, v8 = decodeAttribute(attribute)
	end

	refreshFromAttribute() -- equivalent call inferred; original call site unknown
	local v9 = v8
	local v10 = {
		Name = name,
		AttributeName = attributeName,
		StepsAttributeName = stepsAttributeName,
		DefaultValue = defaultValue,
		Assertion = assertion,
		Changed = changed,
		Get = function(_)
			refreshFromAttribute() -- equivalent call inferred; original call site unknown
			return v8
		end,
		IsSynced = function(_)
			refreshFromAttribute() -- equivalent call inferred; original call site unknown
			return v7
		end,
		GetPendingSteps = function(_)
			local result = {}
			local attribute = workspace:GetAttribute(stepsAttributeName)
			local success, result2

			if type(attribute) == "string" then
				success, result2 = pcall(HttpService.JSONDecode, HttpService, attribute)
			else
				success = false
			end

			if not success or type(result2) ~= "table" then
				return result
			end

			local now = os.time()

			for _, v11 in result2 do
				if type(v11) ~= "table" or type(v11.At) ~= "number" or v11.At <= now or not pcall(assertion, v11.Value) then
					continue
				end

				table.insert(result, {
					At = v11.At,
					Value = DeepFreezeUnsafe(v11.Value)
				})
			end

			table.sort(result, function(a, b)
				return a.At < b.At
			end)
			return result
		end
	}
	workspace:GetAttributeChangedSignal(attributeName):Connect(function()
		refreshFromAttribute() -- equivalent call inferred; original call site unknown

		if DeepEqualsPureUnsafe(v8, v9) then
			return
		end

		local v11 = v9
		v9 = v8
		changed:Fire(v8, v11)
	end)
	return table.freeze(v10)
end

local function AssertLightDarkReveal(data)
	if data == false then
		return false
	end

	assert(type(data) == "table", "LightDarkReveal must be false or a table")
	local v2

	if type(data.RevealPeriod) == "number" then
		v2 = data.RevealPeriod % 1 == 0
	else
		v2 = false
	end

	assert(v2, "LightDarkReveal.RevealPeriod must be an integer")
	assert(data.Winner == "Light" or data.Winner == "Dark", "LightDarkReveal.Winner must be Light or Dark")
	local v3

	if data.WinnerPeriod == nil then
		v3 = true
	elseif type(data.WinnerPeriod) == "number" then
		v3 = data.WinnerPeriod % 1 == 0
	else
		v3 = false
	end

	assert(v3, "LightDarkReveal.WinnerPeriod must be nil or an integer")
	return data
end

local v = {
	Directory = table.freeze({
		LightDarkReveal = define("LightDarkReveal", AssertLightDarkReveal, false),
		RiftOpen = define("RiftOpen", Asserts.Boolean, false)
	})
}
local v2 = {}
local v3 = {}

for k, v4 in v.Directory do
	v2[k] = v4
	table.insert(v3, k)
end

table.sort(v3)
v.Names = table.freeze(v3)

function v.Get(p: string)
	local v4 = v2[p]
	assert(v4 ~= nil, (`unknown live event flag {p}`))
	return v4
end

function v.IsKnown(value)
	return type(value) == "string" and v2[value] ~= nil
end

return table.freeze(v)