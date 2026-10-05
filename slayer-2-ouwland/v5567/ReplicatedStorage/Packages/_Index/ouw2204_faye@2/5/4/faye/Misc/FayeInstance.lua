local ValueClasses = require(script.Parent.Parent.Misc.ValueClasses)
local Compilers = require(script.Parent.Parent.Compile.Compilers)
local Compile = require(script.Parent.Parent.Compile)
local Clean = require(script.Parent.Parent.Clean)
require(script.Parent.Parent.FayeTypes)
local typeof2 = typeof
local remove = table.remove
local find = table.find
local insert = table.insert
local MarkCleanDescriptors

MarkCleanDescriptors = function(items)
	for _, item in pairs(items) do
		if typeof2(item) ~= "table" then
			continue
		end

		local __type = item.__type

		if __type == "Animation" or __type == "Lerp" then
			item.__Destroying = true
		elseif __type == nil then
			MarkCleanDescriptors(item)
		end
	end
end

local function RunClean(callback, p, p2)
	if typeof2(callback) ~= "table" then
		return callback(p, p2)
	end

	MarkCleanDescriptors(callback)
	return callback
end

local FayeInstance = {
	__type = "Instance"
}
FayeInstance.__index = FayeInstance

function removefunc(object, p)
	if object == nil or p == nil then
		return
	end

	if object.Remove then
		return object:Remove(p)
	end

	local index = find(object, p)

	if index ~= nil then
		remove(object, index)
	end

	return false
end

function FayeInstance:SetAttribute(p2: string, p3)
	if self.Instance ~= nil then
		self.Instance:SetAttribute(p2, p3)
	end

	return self
end

function FayeInstance:GetAttribute(attributeName: string)
	if self.Instance == nil then
		return
	else
		return self.Instance:GetAttribute(attributeName)
	end
end

function FayeInstance:GetAttributes(_: string)
	if self.Instance == nil then
		return
	else
		return self.Instance:GetAttributes()
	end
end

function FayeInstance:AddTag(tag: string)
	if self.Instance ~= nil then
		self.Instance:AddTag(tag)
	end

	return self
end

function FayeInstance:RemoveTag(tag: string)
	if self.Instance ~= nil then
		self.Instance:RemoveTag(tag)
	end

	return self
end

function FayeInstance:HasTag(tag: string)
	if self.Instance == nil then
		return
	else
		return self.Instance:HasTag(tag)
	end
end

function FayeInstance:GetTags()
	if self.Instance == nil then
		return
	else
		return self.Instance:GetTags()
	end
end

function FayeInstance:Clone()
	if self.Instance == nil then
		return
	else
		return self.Instance:Clone()
	end
end

local UseCompile = require(script.Parent.UseCompile)

function FayeInstance:Compile()
	local props = self.Props

	if props == nil then
		self:Destroy()
		return self
	end

	local v = nil
	local cleanThread = self.CleanThread or self.Thread
	local v2 = props.CleanDelay ~= nil or props.OnClean ~= nil

	if cleanThread == nil or not (cleanThread._hc or cleanThread._isCleanAncestor) or not v2 or self.CleanThread == nil or not self.CleanThread._isCleanAncestor or cleanThread.ParentThread == nil then
		if v2 then
			if self.Thread ~= nil then
				self.Thread._hc = true
				self.Thread._isCleanAncestor = true
			end

			if self.CleanThread == nil then
				self.CleanThread = self.Thread == nil and {} or self.Thread:Extend(true) or {}
				self.CleanThread._isCleanAncestor = true
			end

			if props.CleanDelay ~= nil then
				self.CleanDelay = props.CleanDelay
				props.CleanDelay = nil
			end

			if props.OnClean ~= nil then
				self.OnClean = props.OnClean
				props.OnClean = nil
			end

			local v3 = props.CleanFunction ~= nil or v
			v = props.CleanFunction ~= nil or v3
		elseif props.CleanFunction ~= nil or props.OnClean ~= nil then
			if props.CleanFunction == nil and props.OnClean ~= nil then
				props.CleanFunction = props.OnClean
			end

			props.OnClean = nil
			props.CleanDelay = nil
			v = true
		end
	else
		if props.CleanFunction == nil and props.OnClean ~= nil then
			props.CleanFunction = props.OnClean
			v = true
		end

		props.CleanDelay = nil
		props.OnClean = nil
	end

	if v == true then
		if self.Thread == nil or not self.Thread._isCleanAncestor or self.CleanDelay ~= nil then
			self.CleanFunction = props.CleanFunction
		else
			local cleanFunction = props.CleanFunction
			local v3 = nil
			local cleanThread2 = self.CleanThread or self.Thread
			local instance2 = self.Instance
			local fn

			fn = function()
				if cleanFunction == nil then
					return
				end

				if self.Cache ~= nil then
					self:ClearCache()
				end

				local v4 = cleanFunction
				local v5 = cleanThread2
				local instance = instance2
				local v7

				if typeof2(v4) == "table" then
					MarkCleanDescriptors(v4)
				else
					v4, v7 = v4(v5, instance)
				end

				UseCompile(v4, v7, self)
				removefunc(v3, fn)
				cleanFunction = nil
				fn = nil
				v3 = nil
			end

			local thread = self.Thread

			if thread.ParentThread ~= nil then
				local parentThread = thread

				while parentThread ~= nil and not parentThread._hc do
					parentThread = parentThread.ParentThread
				end

				thread = parentThread or thread
			end

			thread:Add(fn)
			v3 = thread
		end
	end

	props.CleanFunction = nil
	props.CleanDelay = nil

	if props.Parent ~= nil then
		local parent = props.Parent
		props.Parent = nil
		local v3 = typeof(parent) == "table"
		local v4

		if v3 and parent.__type ~= nil then
			v4 = ValueClasses[parent.__type] and "Value" or parent.__type or nil
		end

		if v4 == nil or v4 == "Instance" then
			if v3 then
				self.Instance.Parent = parent.Instance or parent
			else
				self.Instance.Parent = parent
			end
		else
			Compilers[v4](self, "Parent", parent)
		end
	end

	self.Props = nil
	Compile(self, props)
	return self
end

local CleanPortion = require(script.Parent.CleanPortion)

function FayeInstance:ClearCache()
	if self.Cache == nil then
		return
	end

	if self.Cache.Priority ~= nil then
		CleanPortion(self.Cache.Priority)
		self.Cache.Priority = nil
	end

	CleanPortion(self.Cache)
	self.Cache = nil
end

function FayeInstance:Connect(object, callback)
	return self:Add(object:Connect(callback), true)
end

function FayeInstance:Add(state, flag: boolean?)
	if self.Cache == nil then
		self.Cache = {}
	end

	if flag then
		if self.Cache.Priority == nil then
			self.Cache.Priority = {}
		end

		if typeof2(state) == "table" and state.__simplesignalconnection and state.lists == nil then
			state.lists = self.Cache.Priority
		end

		insert(self.Cache.Priority, state)
		return state
	else
		insert(self.Cache, state)
		return state
	end
end

function FayeInstance:Remove(p2)
	if self.Cache ~= nil then
		local index = find(self.Cache, p2)

		if index == nil then
			if self.Cache.Priority ~= nil and find(self.Cache.Priority, p2) ~= nil then
				remove(self.Cache.Priority, p2)
			end
		else
			remove(self.Cache, index)
		end
	end
end

function FayeInstance:Destroy()
	local v = false

	if self.Thread ~= nil then
		if self.Thread.Remove then
			v = self.Thread:Remove(self)
		else
			local index = find(self.Thread, self)

			if index ~= nil then
				remove(self.Thread, index)
				v = true
			end
		end
	end

	if not v and self.CleanThread ~= nil then
		if self.CleanThread.Remove then
			self.CleanThread:Remove(self)
		else
			local index = find(self.CleanThread, self)

			if index ~= nil then
				remove(self.CleanThread, index)
			end
		end
	end

	if self.Cache ~= nil then
		self:ClearCache()
	end

	if self.CleanFunction ~= nil then
		local cleanFunction = self.CleanFunction
		local cleanThread = self.CleanThread or self.Thread
		local instance = self.Instance
		local v2

		if typeof2(cleanFunction) == "table" then
			MarkCleanDescriptors(cleanFunction)
		else
			cleanFunction, v2 = cleanFunction(cleanThread, instance)
		end

		UseCompile(cleanFunction, v2, self)
	end

	if self.OnClean == nil then
		if self.CleanDelay == nil then
			self.Instance:Destroy()
			self.Instance = nil
			self.CleanFunction = nil
			self.OnClean = nil
			self.CleanThread = nil
		else
			local cleanDelay = self.CleanDelay

			if typeof2(cleanDelay) == "function" then
				cleanDelay = cleanDelay(self.CleanThread, self.Instance)
			end

			task.delay(cleanDelay, function()
				self.Instance:Destroy()
				self.Instance = nil
				Clean(self.CleanThread)
				self.CleanFunction = nil
				self.OnClean = nil
				self.CleanThread = nil
			end)
			self.CleanDelay = nil
		end
	else
		if self.CleanThread.Add then
			self.CleanThread:Add(self.Instance)
		else
			table.insert(self.CleanThread, self.Instance)
		end

		local onClean = self.OnClean
		local cleanThread = self.CleanThread
		local instance = self.Instance
		local v2

		if typeof2(onClean) == "table" then
			MarkCleanDescriptors(onClean)
		else
			onClean, v2 = onClean(cleanThread, instance)
		end

		UseCompile(onClean, v2, self)

		if self.CleanThread ~= nil then
			if self.CleanThread.AnimationsAmount == nil or self.CleanThread.AnimationsAmount <= 0 then
				Clean(self.CleanThread)
			else
				self.CleanThread.CleanWhenDone = true
			end

			self.CleanThread = nil
		end

		self.Instance = nil
		self.OnClean = nil
	end

	self.CleanDelay = nil
	self.Props = nil
	self.Thread = nil
end

local name = script.Name

function FayeInstance.__tostring()
	return name
end

return FayeInstance