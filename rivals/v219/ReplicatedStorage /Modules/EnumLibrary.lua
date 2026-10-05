local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Signal"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.AlwaysReplicateToEveryone = {}
	self._num_enums = 0
	self._to_enum = {}
	self._from_enum = {}
	self._enum_builder_complete = false
	self._enum_builder_completed_internal = Signal.new()
	self:_Init()
	return self
end

function class.EncryptTable(_, p)
	local v = string.reverse(HttpService:JSONEncode(p))
	local v2 = ""

	for i = 1, #v do
		v2 ..= string.char(string.byte((string.sub(v, i, i))) - -1)
	end

	return v2
end

function class.DecryptTable(_, value)
	return pcall(function()
		local v = ""

		for i = #value, 1, -1 do
			v ..= string.char(string.byte((string.sub(value, i, i))) + -1)
		end

		return HttpService:JSONDecode(v)
	end)
end

function class:ToEnum(p2, p3)
	if not p2 then
		return
	end

	local v = self._to_enum[p2]
	assert(p3 or v ~= nil, p2)
	return v
end

function class:FromEnum(p2, p3)
	if not p2 then
		return
	end

	local v = self._from_enum[p2]
	assert(p3 or v ~= nil, p2)
	return v
end

function class:AddEnum(p)
	if self:ToEnum(p, true) then
		return
	end

	local v = utf8.char(self._num_enums)
	self._num_enums += 1
	self._to_enum[p] = v
	self._from_enum[v] = p
end

function class:WaitForEnumBuilder()
	if not self._enum_builder_complete then
		self._enum_builder_completed_internal:Wait()
	end
end

function class:EnumBuilderCompleted()
	self._enum_builder_complete = true
	self._enum_builder_completed_internal:Fire()
end

function class:_Init() end

return class._new()