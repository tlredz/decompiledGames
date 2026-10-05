local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local clientReplicatedClasses = CONSTANTS.IS_CLIENT and Players.LocalPlayer and Players.LocalPlayer.PlayerScripts:WaitForChild("Modules"):WaitForChild("ClientReplicatedClasses")
local v = 0
local ReplicatedClass = {}
ReplicatedClass.__index = ReplicatedClass

function ReplicatedClass.new(temp_serial, dont_compress_replication)
	assert(not temp_serial or typeof(temp_serial) == "table", "Argument 1 invalid, expected a table or nil")
	v = (v + 1) % 1000000
	local self = setmetatable({}, ReplicatedClass)
	self.Data = {
		ObjectID = utf8.char(v)
	}
	self.ReplicateToClient = CONSTANTS.IS_SERVER and Signal.new() or nil
	self.ReplicateToClientUnreliable = CONSTANTS.IS_SERVER and Signal.new() or nil
	self._value_changed_events = {}
	self._temp_serial = temp_serial
	self._dont_compress_replication = dont_compress_replication
	self:_Init()
	return self
end

function ReplicatedClass.GetReplicatedClass(_, childName)
	assert(CONSTANTS.IS_CLIENT)
	local child = childName and clientReplicatedClasses:FindFirstChild(childName, true)
	return child and require(child) or ReplicatedClass
end

function ReplicatedClass:Get(p2)
	return self.Data[p2]
end

function ReplicatedClass:Set(p2, p3)
	self.Data[p2] = p3
end

function ReplicatedClass:GetDataChangedSignal(value)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")

	if not self._value_changed_events[value] then
		self._value_changed_events[value] = Signal.new()
	end

	return self._value_changed_events[value]
end

function ReplicatedClass:Replicate(value, p)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	local v2 = self:Get(value)
	local v3 = p and "ReplicateToClientUnreliable" or "ReplicateToClient"

	if self[v3] then
		self[v3]:Fire("DataValueChanged", self._dont_compress_replication and value or self:ToEnum(value) or value, v2)
	end

	if self._value_changed_events[value] then
		self._value_changed_events[value]:Fire(v2, value)
	end
end

function ReplicatedClass:SetReplicate(value, p, p2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	self:Set(value, p)
	self:Replicate(value, p2)
end

function ReplicatedClass:Increment(value, value2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	assert(typeof(value2) == "number", "Argument 2 invalid, expected a number")

	if value2 == 0 then
		return
	end

	self:Set(value, self:Get(value) + value2)
end

function ReplicatedClass:IncrementReplicate(value, value2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	assert(typeof(value2) == "number", "Argument 2 invalid, expected a number")

	if value2 == 0 then
		return
	end

	self:Increment(value, value2)
	self:Replicate(value)
end

function ReplicatedClass:ReplicateFromServer(p, ...)
	if p ~= "DataValueChanged" then
		assert(false, "No implementation for change type: " .. tostring(p))
		return
	end

	local v2, v3 = ...
	self:SetReplicate(self._dont_compress_replication and v2 or self:FromEnum(v2) or v2, v3)
end

function ReplicatedClass:ToEnum(p)
	return EnumLibrary:ToEnum(p)
end

function ReplicatedClass:FromEnum(p)
	return EnumLibrary:FromEnum(p)
end

function ReplicatedClass:Serialize()
	return self:_EncodeSerial({
		ClientReplicatedClassType = nil,
		Data = self:_SerializeData()
	})
end

function ReplicatedClass:Destroy()
	if self.ReplicateToClient then
		self.ReplicateToClient:Destroy()
	end

	if self.ReplicateToClientUnreliable then
		self.ReplicateToClientUnreliable:Destroy()
	end

	for _, _value_changed_event in pairs(self._value_changed_events) do
		_value_changed_event:Destroy()
	end
end

function ReplicatedClass:_DecodeSerial(list)
	if self._dont_compress_replication then
		return list
	end

	local v2 = {}

	for k, v3 in pairs(list) do
		v2[EnumLibrary:ToEnum(k, true) and k or self:FromEnum(k)] = v3
	end

	table.clear(list)

	for k, v3 in pairs(v2) do
		list[k] = v3
	end

	return list
end

function ReplicatedClass:_EncodeSerial(items)
	if self._dont_compress_replication then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		if EnumLibrary:FromEnum(k, true) then
			result[k] = item
		end
	end

	for k, item in pairs(items) do
		if not EnumLibrary:FromEnum(k, true) then
			result[self:ToEnum(k)] = item
		end
	end

	return result
end

function ReplicatedClass:_SerializeData()
	if self._dont_compress_replication then
		return self.Data
	end

	local result = {}

	for k, v2 in pairs(self.Data) do
		result[self:ToEnum(k)] = v2
	end

	return result
end

function ReplicatedClass:_Setup()
	if self._temp_serial then
		self:_DecodeSerial(self._temp_serial)

		for k, v2 in pairs(self._temp_serial.Data) do
			self:SetReplicate(self._dont_compress_replication and k or self:FromEnum(k), v2)
		end
	end

	self._temp_serial = nil
end

function ReplicatedClass:_Init()
	self:_Setup()
end

return ReplicatedClass