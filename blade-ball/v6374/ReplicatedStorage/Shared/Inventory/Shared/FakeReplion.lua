local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(script.Parent.Parent.InventoryTypes)
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Signal)

local function fn() end

local v3 = {
	Disconnect = fn,
	Destroy = fn,
	Connected = false
}

local function getPathTable(value)
	if type(value) == "table" then
		return table.clone(value)
	end

	if type(value) == "string" then
		return string.split(value, ".")
	end

	return { value }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPathString(value)
	if type(value) == "string" then
		return value
	end

	if type(value) == "table" then
		return table.concat(value, ".")
	end

	return (tostring(value))
end

local FakeReplion = {}
FakeReplion.__index = FakeReplion

function FakeReplion.new(p)
	return (setmetatable({
		Data = p,
		Tags = {},
		Destroyed = false,
		ReplicateTo = {},
		_signal = v2.new()
	}, FakeReplion))
end

function FakeReplion:Find(p, p2)
	local v4 = self:Get(p)

	if not v4 then
		return
	end

	local index = table.find(v4, p2)

	if index then
		return index, p2
	end
end

function FakeReplion:Get(p2)
	return v.Dictionary.getIn(self.Data, getPathTable(p2))
end

function FakeReplion:GetExpect(value, message)
	assert(value, "Path is required!")

	if not message then
		local pathString = getPathString(value) -- equivalent call inferred; original call site unknown
		message = `"{pathString}" is not a valid path!`
	end

	local v4 = self:Get(value)

	if v4 == nil then
		error(message)
	end

	return v4
end

function FakeReplion.__tostring(_)
	return "FakeReplion"
end

function FakeReplion.BeforeDestroy(_, _)
	return v3
end

function FakeReplion.OnDataChange(_, _)
	return v3
end

function FakeReplion.OnChange(_, _, _)
	return v3
end

function FakeReplion.OnDescendantChange(_, _, _)
	return v3
end

function FakeReplion.OnArrayInsert(_, _, _)
	return v3
end

function FakeReplion.OnArrayRemove(_, _, _)
	return v3
end

function FakeReplion:Destroy()
	self.Destroyed = true
end

return FakeReplion