local RunService = game:GetService("RunService")
local v = newproxy()
local v2 = newproxy()
local frozen = table.freeze({
	"Destroy",
	"Disconnect",
	"destroy",
	"disconnect"
})

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

	if typeName == "Instance" or typeName == "Object" then
		return "Destroy"
	end

	if typeName == "RBXScriptConnection" then
		return "Disconnect"
	end

	if typeName == "table" then
		for _, v3 in frozen do
			if typeof(p[v3]) == "function" then
				return v3
			end
		end
	end

	error(`failed to get cleanup function for object {typeName}: {p}`, 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AssertPromiseLike(object)
	if typeof(object) ~= "table" or typeof(object.getStatus) ~= "function" or typeof(object.finally) ~= "function" or typeof(object.cancel) ~= "function" then
		error("did not receive a promise as an argument", 3)
	end
end

local class = {}
class.__index = class

function class.new()
	local self = setmetatable({}, class)
	self._objects = {}
	self._cleaning = false
	return self
end

function class.is(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function class:Add(p2, p3)
	if self._cleaning then
		error("cannot call trove:Add() while cleaning", 2)
	end

	local v3 = { p2, (GetObjectCleanupFunction(p2, p3)) }
	table.insert(self._objects, v3)
	return p2
end

function class:Clone(instance)
	if self._cleaning then
		error("cannot call trove:Clone() while cleaning", 2)
	end

	return self:Add(instance:Clone())
end

function class:Construct(callback, ...)
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

function class:Connect(object, callback)
	if self._cleaning then
		error("Cannot call trove:Connect() while cleaning", 2)
	end

	return self:Add(object:Connect(callback))
end

function class:BindToRenderStep(p: string, p2: number, callback)
	if self._cleaning then
		error("cannot call trove:BindToRenderStep() while cleaning", 2)
	end

	RunService:BindToRenderStep(p, p2, callback)
	self:Add(function()
		RunService:UnbindFromRenderStep(p)
	end)
end

function class:AddPromise(object2)
	if self._cleaning then
		error("cannot call trove:AddPromise() while cleaning", 2)
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

function class:Remove(p, ...)
	if self._cleaning then
		error("cannot call trove:Remove() while cleaning", 2)
	end

	return self:_findAndRemoveFromObjects(p, true, ...)
end

function class:Extend()
	if self._cleaning then
		error("cannot call trove:Extend() while cleaning", 2)
	end

	return self:Construct(class)
end

function class:Clean()
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

function class:WrapClean()
	return function()
		self:Clean()
	end
end

function class:_findAndRemoveFromObjects(p, flag: boolean, ...)
	local _objects = self._objects

	for k, _object in _objects do
		if _object[1] ~= p then
			continue
		end

		local count = #_objects
		_objects[k] = _objects[count]
		_objects[count] = nil

		if flag then
			self:_cleanupObject(_object[1], _object[2], ...)
		end

		return true
	end

	return false
end

function class:_cleanupObject(callback, callback2: string?, ...)
	if callback2 == v then
		task.spawn(callback)
	elseif callback2 == v2 then
		pcall(task.cancel, callback)
	elseif typeof(callback2) == "function" then
		callback2(callback, ...)
	else
		callback[callback2](callback)
	end
end

function class:AttachToInstance(instance2)
	if self._cleaning then
		error("cannot call trove:AttachToInstance() while cleaning", 2)
	elseif not instance2:IsDescendantOf(game) then
		error("instance is not a descendant of the game hierarchy", 2)
	end

	return self:Connect(instance2.Destroying, function()
		self:Destroy()
	end)
end

function class:Destroy()
	self:Clean()
end

return {
	new = class.new,
	is = class.is
}