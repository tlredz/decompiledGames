local v = newproxy()
local v2 = newproxy()
local RunService = game:GetService("RunService")

local function GetObjectCleanupFunction(p, p2)
	local typeName = typeof(p)

	if typeName == "function" then
		return v
	elseif typeName == "thread" then
		return v2
	end

	if p2 then
		return p2
	end

	if typeName == "Instance" then
		return "Destroy"
	elseif typeName == "RBXScriptConnection" then
		return "Disconnect"
	end

	if typeName == "table" then
		if typeof(p.Destroy) == "function" then
			return "Destroy"
		end

		if typeof(p.Disconnect) == "function" then
			return "Disconnect"
		end
	end

	error("Failed to get cleanup function for object " .. typeName .. ": " .. tostring(p), 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AssertPromiseLike(object)
	if type(object) ~= "table" or type(object.getStatus) ~= "function" or type(object.finally) ~= "function" or type(object.cancel) ~= "function" then
		error("Did not receive a Promise as an argument", 3)
	end
end

local Trove = {}
Trove.__index = Trove

function Trove.new()
	local self = setmetatable({}, Trove)
	self._objects = {}
	self._cleaning = false
	return self
end

function Trove:Extend()
	if self._cleaning then
		error("Cannot call trove:Extend() while cleaning", 2)
	end

	return self:Construct(Trove)
end

function Trove:Clone(instance)
	if self._cleaning then
		error("Cannot call trove:Clone() while cleaning", 2)
	end

	return self:Add(instance:Clone())
end

function Trove:Construct(callback, ...)
	if self._cleaning then
		error("Cannot call trove:Construct() while cleaning", 2)
	end

	local v3 = nil
	local typeName = type(callback)

	if typeName == "table" then
		v3 = callback.new(...)
	elseif typeName == "function" then
		v3 = callback(...)
	end

	return self:Add(v3)
end

function Trove:Connect(object, p)
	if self._cleaning then
		error("Cannot call trove:Connect() while cleaning", 2)
	end

	return self:Add(object:Connect(p))
end

function Trove:BindToRenderStep(p: string, p2: number, callback)
	if self._cleaning then
		error("Cannot call trove:BindToRenderStep() while cleaning", 2)
	end

	RunService:BindToRenderStep(p, p2, callback)
	self:Add(function()
		RunService:UnbindFromRenderStep(p)
	end)
end

function Trove:AddPromise(object2)
	if self._cleaning then
		error("Cannot call trove:AddPromise() while cleaning", 2)
	end

	AssertPromiseLike(object2) -- equivalent call inferred; original call site unknown

	if object2:getStatus() == "Started" then
		object2:finally(function()
			if self._cleaning then
				return
			end

			self:_findAndRemoveFromObjects(object2, false)
		end)
		self:Add(object2, "cancel")
	end

	return object2
end

function Trove:Add(p2, p3: string?)
	if self._cleaning then
		error("Cannot call trove:Add() while cleaning", 2)
	end

	local v3 = { p2, (GetObjectCleanupFunction(p2, p3)) }
	table.insert(self._objects, v3)
	return p2
end

function Trove:Remove(p)
	if self._cleaning then
		error("Cannot call trove:Remove() while cleaning", 2)
	end

	return self:_findAndRemoveFromObjects(p, true)
end

function Trove:Clean()
	if self._cleaning then
		return
	end

	self._cleaning = true

	for _, _object in self._objects do
		self:_cleanupObject(_object[1], _object[2])
	end

	table.clear(self._objects)
	self._cleaning = false
end

function Trove:_findAndRemoveFromObjects(p, flag: boolean)
	local _objects = self._objects

	for i, _object in ipairs(_objects) do
		if _object[1] ~= p then
			continue
		end

		local count = #_objects
		_objects[i] = _objects[count]
		_objects[count] = nil

		if flag then
			self:_cleanupObject(_object[1], _object[2])
		end

		return true
	end

	return false
end

function Trove:_cleanupObject(callback, p)
	if p == v then
		callback()
	elseif p == v2 then
		coroutine.close(callback)
	else
		callback[p](callback)
	end
end

function Trove:AttachToInstance(instance2)
	if self._cleaning then
		error("Cannot call trove:AttachToInstance() while cleaning", 2)
	elseif not instance2:IsDescendantOf(game) then
		error("Instance is not a descendant of the game hierarchy", 2)
	end

	return self:Connect(instance2.Destroying, function()
		self:Destroy()
	end)
end

function Trove:Destroy()
	self:Clean()
end

return Trove