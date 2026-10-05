local function fn() end

local InstanceWatch = {}
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local Events = require(script.Events)
	Events(InstanceWatch)
end

local InstanceEventWrapper = require(script.InstanceEventWrapper)
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local wrap_t_in_function

wrap_t_in_function = function(items)
	local v = {}
	return (setmetatable(items, {
		__index = function(_, p)
			return function(_, ...)
				for _, item in pairs(items) do
					local v2 = item[p]

					if typeof(v2) == "function" then
						table.insert(v, v2(item, ...))
					end
				end

				return wrap_t_in_function(v)
			end
		end
	}))
end

function InstanceWatch:Watch(p2)
	if self.__childwatches[p2] then
		return
	end

	self.__childwatches[p2] = self.__maid:GiveTask(InstanceWatch.new(self, p2))
	return self.__childwatches[p2]
end

function InstanceWatch:WatchManyWithHandlers(items)
	for k, item in pairs(items) do
		self.__childwatches[k] = self.__maid:GiveTask(InstanceWatch.new(self, k))
		item(self.__childwatches[k])
	end
end

function InstanceWatch:RequirePrimaryPart(requiresPrimaryPart)
	self.RequiresPrimaryPart = requiresPrimaryPart
	return self
end

function InstanceWatch:CollectDictionaryAsync(...)
	local v = {}

	for _, v2 in pairs({ ... }) do
		v[v2] = self:Watch(v2)
	end

	local thread = coroutine.running()
	local result = {}
	local v2 = false

	for k, v3 in pairs(v) do
		result[k] = false
		local connection = nil
		local v4 = k
		connection = v3:ConnectOnce(function(p, p2, p3)
			if not result then
				connection:Disconnect()
				return
			end

			result[v4] = p

			for k2, v5 in pairs(result) do
				if v5 ~= false then
					continue
				end

				connection:Disconnect()
				return
			end

			connection:Disconnect()
			v2 = true
			coroutine.resume(thread)
		end)
	end

	if not v2 then
		coroutine.yield()
	end

	return result
end

function InstanceWatch:Destroy()
	self.__maid:DoCleaning()
	self.__maid = nil
end

function InstanceWatch:WatchMany(...)
	local v = { ... }
	local v2 = v[1]

	if typeof(v2) == "table" then
		self:WatchManyWithHandlers(v2)
		return
	end

	local v3 = {}

	for _, v4 in pairs(v) do
		local __childwatch = self.__childwatches[v4]

		if __childwatch then
			v3[v4] = __childwatch
		else
			self.__childwatches[v4] = InstanceWatch.new(self, v4)
			v3[v4] = self.__childwatches[v4]
		end
	end

	return (wrap_t_in_function(v3))
end

local v = {
	__index = {
		set = function(p, p2, p3)
			p[p2] = p3
		end
	}
}

function InstanceWatch.buildenv()
	return (setmetatable({
		watches = {},
		seen = {}
	}, v))
end

function InstanceWatch:Chain(...)
	local v2 = self

	for _, v3 in pairs({ ... }) do
		v2 = InstanceWatch.new(v2, v3, self.__env)
	end

	return v2
end

function InstanceWatch:first()
	local _, v2 = next(self.__registered)
	return v2
end

function InstanceWatch:firstInstance()
	local _, v2 = next(self.__registered)
	return v2 and v2.object
end

function InstanceWatch:foreach(callback)
	for _, v2 in pairs(self.__registered) do
		callback(v2)
	end
end

function InstanceWatch.chain(p, p2, ...)
	for _, v2 in pairs({ ... }) do
		p = InstanceWatch.new(p, v2, p2)
	end

	return p
end

local v2 = {}
local class = {}
local maxn = table.maxn

function class:__index(p2)
	if v2[p2] then
		return v2[p2]
	end

	local __array = self.__array

	if maxn(__array) > 0 then
		local v3 = __array[1][p2]

		if typeof(v3) == "function" then
			local function fn2(_, ...)
				for i = 1, maxn(__array) do
					pcall(v3, __array[i], ...)
				end
			end

			rawset(self, p2, fn2)
			return fn2
		end
	end
end

function v2:num()
	return maxn(self.__array)
end

function v2:array()
	return self.__array
end

function v2:first()
	return self.__array[1]
end

function v2:firstInstance()
	local v3 = self.__array[1]
	return v3 and v3.object
end

function v2:foreach(callback)
	for _, v3 in pairs(self.__array) do
		callback(v3)
	end
end

function class:__newindex(p2, p3)
	local __array = self.__array

	for i = 1, maxn(__array) do
		__array[i][p2] = p3
	end
end

function InstanceWatch.make_seen_object()
	local v3 = {
		__array = {},
		added = Signal2.new()
	}
	setmetatable(v3, class)
	return v3
end

function InstanceWatch:AddToCurrentlySeen(p2, p3)
	local seen = self.__env.seen
	local v3 = seen[p2]

	if v3 then
		table.insert(v3.__array, p3)
	else
		seen[p2] = InstanceWatch.make_seen_object()
		table.insert(seen[p2].__array, p3)
	end

	seen[p2].added:Fire(p3)
end

function InstanceWatch:RemoveFromCurrentlySeen(p2, p3)
	local v3 = self.__env.seen[p2]

	if not v3 then
		return
	end

	local index = table.find(v3.__array, p3)

	if index then
		table.remove(v3.__array, index)
	end
end

local object = setmetatable({}, {
	__mode = "k"
})
local v3 = {
	__index = InstanceWatch
}

function InstanceWatch:new(name, p)
	assert(typeof(name) == "string", "what are you looking for?")
	local v4 = object[self]

	if v4 and v4[name] then
		return v4[name]
	end

	local env = p or typeof(self) == "table" and self.__env or InstanceWatch.buildenv()
	local v6 = {
		__childwatches = {},
		__firstf = {},
		__seenf = {},
		__unseenf = {},
		__registered = {},
		__maid = Maid.new(),
		__env = env,
		__name = name,
		__parent = self
	}

	if v4 then
		object[self][name] = v6
	else
		object[self] = {
			[name] = v6
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getParentName()
		if typeof(self) == "table" then
			return self.__name
		end

		return self.name
	end

	table.insert(v6.__env.watches, v6)

	local function register_child(instance)
		local __registered = v6.__registered
		local v7 = __registered[instance]

		if v7 then
			return v7
		end

		__registered[instance] = {
			object = instance,
			maid = Maid.new()
		}
		local v8 = __registered[instance]
		v6:DoOnce(instance, v8, v6.__env)
		return v8
	end

	local function ChildAdded(instance)
		local parentName = getParentName() -- equivalent call inferred; original call site unknown
		fn(`[{parentName}] STREAMED: [{instance}].`)

		if v6.RequiresPrimaryPart and not instance.PrimaryPart then
			local thread = coroutine.running()
			local parentName2 = getParentName() -- equivalent call inferred; original call site unknown
			fn(`[{parentName2}] WATIING PRIMARYPART FOR: [{instance}].`)
			local primaryPartChangedConnection = instance:GetPropertyChangedSignal("PrimaryPart"):Once(function()
				coroutine.resume(thread)
			end)
			local ancestryChangedConnection = nil
			ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					primaryPartChangedConnection:Disconnect()
					ancestryChangedConnection:Disconnect()
					coroutine.resume(thread)
				end
			end)
			coroutine.yield()
			ancestryChangedConnection:Disconnect()
			primaryPartChangedConnection:Disconnect()

			if not instance.PrimaryPart then
				return
			end
		end

		local v9 = register_child(instance)
		v6:See(instance, v9, v6.__env)
		v6:AddToCurrentlySeen(name, v9)
	end

	local function ChildRemoved(p2)
		local parentName = getParentName() -- equivalent call inferred; original call site unknown
		fn(`{parentName}: UNLOADED: {p2}.`)
		local v9 = v6.__registered[p2]

		if v9 then
			v6:RemoveFromCurrentlySeen(name, v9)
			v6:Unsee(p2, v9, v6.__env)
			v9.maid:DoCleaning()
		end
	end

	setmetatable(v6, v3)

	if typeof(self) == "table" then
		self:Once(function(p2, _)
			local v7 = InstanceEventWrapper.Get(p2)
			v7:ChildAdded(name, ChildAdded)
			v7:ChildRemoved(name, ChildRemoved)
		end)
		return v6
	end

	local v7 = InstanceEventWrapper.Get(self)
	v7:ChildAdded(name, ChildAdded)
	v7:ChildRemoved(name, ChildRemoved)
	return v6
end

local v4 = {}

function InstanceWatch.group(p)
	if p and v4[p] then
		return v4[p]
	end

	local v5 = {
		watches = {},
		__env = InstanceWatch.buildenv()
	}
	local v6 = {
		add = function(p2, p3, _)
			fn(`[{p2} -> {p3}] GROUPED`)
			local v7 = InstanceWatch.new(p2, p3, v5.__env)
			table.insert(v5.watches, v7)
			return v7
		end,
		chain = function(p2, ...)
			local chain = InstanceWatch.chain(p2, v5.__env, ...)
			table.insert(v5.watches, chain)
			return chain
		end,
		getseen = function(p2)
			local v7 = v5.__env.seen[p2]

			if not v7 then
				v7 = InstanceWatch.make_seen_object()
				v5.__env.seen[p2] = v7
			end

			return v7
		end
	}
	v6.ObjectsOfType = v6.getseen
	setmetatable(v5, {
		__index = v6
	})

	if p then
		v4[p] = v5
	end

	return v5
end

InstanceWatch.NewGroup = InstanceWatch.group
return InstanceWatch