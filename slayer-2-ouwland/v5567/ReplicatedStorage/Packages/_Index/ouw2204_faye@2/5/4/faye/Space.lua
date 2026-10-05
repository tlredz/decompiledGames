require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class2:SetId(id)
	self.Id = id
	return self
end

function class2:Connect(object)
	if self.__connections == nil then
		self.__connections = {}
	end

	local connection = object:Connect(self.Call, self.__connections)
	FayeUtility.tins(self.__connections, connection)
	return connection
end

function class2:AddParameter(p2, p3)
	if p3 == nil and p2 == nil or p2 == nil then
		return
	end

	if p3 == nil then
		FayeUtility.tins(self, p2)
		return self
	end

	self[p2] = p3
	return self
end

function class2:Destroy()
	local v = FayeUtility.tf(self.__holder.Tasks, self)

	if v ~= nil then
		FayeUtility.tr(self.__holder.Tasks, v)
	end

	if self.__thread ~= nil then
		FayeUtility.RemoveFromThread(self.__thread, self)
	end

	if self.__connections ~= nil then
		for i = #self.__connections, 1, -1 do
			self.__connections[i]:Disconnect()
			self.__connections[i] = nil
		end
	end

	self.__holder = nil
	self.Call = nil
end

function class.Call(p, p2)
	if p.Cleaning then
		return
	end

	if p.Tasks == nil then
		return p
	end

	for i = #p.Tasks, 1, -1 do
		if p2 == nil then
			p.Tasks[i].Call()
		elseif p.Tasks[i].Id == p2 then
			p.Tasks[i].Call()
			return p
		end
	end

	return p
end

function class.Add(holder, p, p2, flag: boolean?)
	if holder.Cleaning == true then
		return
	end

	local v = p == nil and {} or p
	local thread = p2 or holder.Thread
	v.__holder = holder
	v.__thread = thread

	function v.Call()
		if flag then
			v.__holder.func(v)
		else
			v.__holder.func(table.unpack(v))
		end

		return v
	end

	if thread ~= holder.Thread then
		FayeUtility.AddToThread(thread, v)
	end

	setmetatable(v, class2)
	FayeUtility.tins(holder.Tasks, v)
	v.SpaceIndex = #holder.Tasks
	return v
end

function class.Remove(p, p2)
	if not (p.Cleaning ~= true and p2 ~= nil) then
		return
	end

	local v = FayeUtility.tf(p.Tasks, p2)

	if v ~= nil then
		p.Tasks[v]:Destroy()
	end
end

function class:Connect(object, p)
	if self.Cleaning then
		return
	end

	if p ~= nil then
		task.spawn(function()
			task.wait()

			if self.Tasks == nil or self.Cleaning then
				return
			end

			for i = 1, #self.Tasks do
				if self.Tasks[i].Id ~= p then
					continue
				end

				if self.Tasks[i].__connections == nil then
					self.Tasks[i].__connections = {}
				end

				local connection = object:Connect(self.Tasks[i].Call, self.Tasks[i].__connections)
				FayeUtility.tins(self.Tasks[i].__connections, connection)
				return connection
			end
		end)
		return
	end

	local connection = object:Connect(self.ReceiverFunction)

	if self.Thread ~= nil then
		FayeUtility.AddToThread(self.Thread, connection)
	end

	return connection
end

function class:Destroy()
	self.Cleaning = true
	self.func = nil
	self.ReceiverFunction = nil

	if self.Thread ~= nil then
		FayeUtility.RemoveFromThread(self.Thread, self)
		self.Thread = nil
	end

	if self.Tasks ~= nil then
		for i = #self.Tasks, 1, -1 do
			self.Tasks[i]:Destroy()
		end
	end

	self.Tasks = nil
	self.Cleaning = nil
end

local name = script.Name

function class.__tostring()
	return name
end

function class2.__tostring()
	return "Space Task"
end

return function(func, thread)
	local v = {
		func = func,
		Thread = thread,
		Tasks = {},
		Cleaning = nil
	}

	function v.ReceiverFunction()
		if v.Cleaning then
			return
		end

		for _, task2 in ipairs(v.Tasks) do
			task2.Call()
		end
	end

	if thread ~= nil then
		FayeUtility.AddToThread(thread, v)
	end

	setmetatable(v, class)
	return v
end