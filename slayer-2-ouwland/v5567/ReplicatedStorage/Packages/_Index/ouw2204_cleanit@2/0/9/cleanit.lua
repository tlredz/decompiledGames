local insert = table.insert
local remove = table.remove
local clear = table.clear
local typeof2 = typeof
local find = table.find
local cancel = task.cancel
local spawn = task.spawn
local running = coroutine.running
local yield = coroutine.yield
local v = {}
local class = {}
class.__index = class
local Cleanit = {
	delay = function(p, duration: number, p2: string?)
		if p == nil then
			return
		end

		task.delay(duration, CleanEntity, p, typeof2(p), p2)
	end,
	new = function()
		local v2 = {}
		setmetatable(v2, class)
		return v2
	end
}

function class:Connect(object, callback)
	if object ~= nil and callback ~= nil then
		insert(self, object:Connect(callback))
	end
end

function class:CleanAfter(duration: number)
	if duration == nil then
		return
	end

	task.delay(duration, function()
		if self.Clean ~= nil then
			self:Clean()
		end
	end)
end

function class:DestroyAfter(duration: number)
	if duration == nil then
		return
	end

	task.delay(duration, function()
		if self.Destroy ~= nil then
			self:Destroy()
		end
	end)
end

function class:Extend()
	local v2 = Cleanit.new()
	self:Add(v2)
	return v2
end

function class:Add(entity, deleteFunctionToCall: string?)
	if entity == nil then
		return nil
	end

	if deleteFunctionToCall == nil then
		insert(self, entity)
		return entity
	end

	insert(self, {
		Entity = entity,
		DeleteFunctionToCall = deleteFunctionToCall
	})
	return entity
end

function class.Remove(p, p2)
	if p2 == nil then
		return
	end

	local index = find(p, p2)

	if index == nil then
		return
	end

	remove(p, index)
	return true
end

function CleanEntity(connection, p: string, p2: string?)
	if connection == nil then
		return
	end

	if p2 ~= nil and connection[p2] ~= nil then
		connection[p2](connection)
	elseif p == "table" and connection.Destroy ~= nil or p == "Instance" then
		if connection.ClassName == "AnimationTrack" then
			connection:Stop()
		elseif connection.ClassName == "Tween" then
			connection:Cancel()
		end

		connection:Destroy()
	elseif p == "table" and connection.DeleteFunctionToCall ~= nil then
		connection.Entity[connection.DeleteFunctionToCall](connection.Entity)
		connection.Entity = nil
		connection.DeleteFunctionToCallTxt = nil
	elseif p == "function" then
		task.spawn(connection)
	elseif p == "RBXScriptConnection" then
		connection:Disconnect()
	elseif p == "thread" then
		cancel(connection)
	elseif p == "table" then
		clear(connection)
	end
end

function class:CleanIndividual(p2, p3: string?)
	if self[p2] == nil then
		CleanEntity(p2, typeof2(p2), p3)
		local index = find(self, p2)

		if index ~= nil then
			remove(p2, index)
		end
	else
		local cleanEntity = CleanEntity
		cleanEntity(self[p2], typeof2(self[p2]), p3)
		self[p2] = nil
	end
end

function class.Exists(p, p2)
	return p2 ~= nil and find(p, p2) ~= nil
end

function class.GetAll(p)
	return p
end

function class.Wait(p)
	local v2 = v[p]

	if v2 == nil then
		v2 = {}
		v[p] = v2
	end

	insert(v2, running())
	return yield()
end

function class:Clean()
	for _, item in self do
		local typeName = typeof2(item)
		CleanEntity(item, typeName)
	end

	clear(self)
	local v2 = v[self]

	if v2 then
		v[self] = nil

		for _, v3 in v2 do
			spawn(v3)
		end
	end
end

function class.__tostring()
	return "Cleaner"
end

function class:Destroy()
	self:Clean()
	setmetatable(self, nil)
end

return Cleanit