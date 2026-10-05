local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
assert(RunService:IsClient())
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local SharedFastFlags = require(ReplicatedStorage.UserGenerated.FastFlags.SharedFastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local DeepEqualsPureUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepEqualsPureUnsafe)
local DeepCopyPureUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepCopyPureUnsafe)
local DeepFreezeUnsafe = require(ReplicatedStorage.UserGenerated.Collections.DeepFreezeUnsafe)
local ObjectPaths = require(ReplicatedStorage.UserGenerated.Strings.ObjectPaths)
local v = {}
local frozen = table.freeze({
	__index = v
})

function v.Get(p)
	return p.Value
end

function v.GetAsync(data)
	if data.ValueLoaded then
		return data.Value
	end

	local thread = coroutine.running()
	local loadedConnection = data.Loaded:Connect(function()
		task.spawn(thread)
	end)
	coroutine.yield()
	loadedConnection:Disconnect()
	return data.Value
end

function v.IsLoaded(p)
	return p.ValueLoaded
end

table.freeze(v)
local nullValue = SharedFastFlags.NullValue
local updateRemote = SharedFastFlags.UpdateRemote
local v2 = {}
local flag = false
local v3 = {}
local loaded = Bindable.new()

local function DecodeValue(p)
	if p == nullValue then
		return nil
	end

	return p
end

local function SetContent(items, flag2: boolean)
	local clone = table.clone(v3)

	for k, item in pairs(items) do
		clone[k] = item
	end

	DeepFreezeUnsafe(clone)
	v3 = clone
	local v5 = {}
	local v6 = {}

	for k, item in pairs(items) do
		local instance = v2[k]

		if not instance then
			continue
		end

		if item == nullValue then
			item = nil
		end

		local prevValue = instance.Value

		if not DeepEqualsPureUnsafe(item, prevValue) then
			instance.Value = item
			table.insert(v6, {
				instance = instance,
				value = item,
				prevValue = prevValue
			})
		end

		if not flag2 or instance.ValueLoaded then
			continue
		end

		instance.ValueLoaded = true
		table.insert(v5, instance)
	end

	local v7 = flag2 and not flag

	if v7 then
		flag = true
	end

	for _, v8 in ipairs(v5) do
		v8.Loaded:Fire()
	end

	if v7 then
		loaded:Fire()
	end

	for _, v8 in ipairs(v6) do
		v8.instance.Changed:Fire(v8.value, v8.prevValue)
	end
end

local function Create(p: string, assertion, p2)
	Asserts.String(p)
	Asserts.Function(assertion)
	assertion(p2)
	Asserts.Optional(Asserts.Storable)(p2)
	local defaultValue = DeepCopyPureUnsafe(p2)
	DeepFreezeUnsafe(defaultValue)
	assert(not v2[p], (`ConflictingKeys: {p}, {p}`))

	for k, _ in pairs(v2) do
		if ObjectPaths.HasHierarchicalOverlap(p, k) then
			error((`ConflictingKeys: {p}, {k}`))
		end
	end

	local v6 = v3[p]
	local valueLoaded

	if v6 == nil then
		v6 = defaultValue
		valueLoaded = false
	else
		if v6 == nullValue then
			v6 = nil
		end

		valueLoaded = flag
	end

	local self = setmetatable({
		Changed = Bindable.new(),
		Loaded = Bindable.new(),
		Replicated = true,
		Key = p,
		DefaultValue = defaultValue,
		Assertion = assertion,
		ValueLoaded = valueLoaded,
		Value = v6
	}, frozen)
	v2[p] = self
	return self
end

local ClientFastFlags = {
	Loaded = loaded,
	IsA = function(p)
		return type(p) == "table" and getmetatable(p) == frozen
	end,
	Assert = function(p)
		local v5

		if type(p) == "table" then
			v5 = getmetatable(p) == frozen
		else
			v5 = false
		end

		if not v5 then
			error("FastFlag", 2)
		end

		return p
	end,
	Replicated = function(p: string, assertion, p2)
		return (Create(p, assertion, p2))
	end,
	Private = function(_: string, _, _)
		error("ServerOnly")
	end,
	Get = function(p: string)
		local v5 = v2[p]

		if v5 then
			return v5
		end

		Asserts.String(p)
		error((`UnknownKey: '{p}'`))
	end,
	IsLoaded = function()
		return flag
	end
}
updateRemote.OnClientEvent:Connect(SetContent)
table.freeze(ClientFastFlags)
return ClientFastFlags