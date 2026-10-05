local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Log = require(ReplicatedStorage.Packages.Log)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local v = Log.new()
local v2 = nil

local function defaultKeyOf(p)
	t.strict(t.instanceIsA("Player"))(p)
	return p.UserId
end

local function locate(data, p)
	local v3 = assert(data.keyOf(p), "the key parser produced nothing for this player")
	return data.store[v3], v3
end

v2 = {
	ProfileRemoving = Signal.new(),
	ProfileAdded = Signal.new(),
	is = function(p)
		return typeof(p) == "table" and getmetatable(p) == v2
	end,
	new = function(options, callback)
		t.strict(t.optional(t.callback))(callback)
		t.strict(t.optional(t.table))(options)
		return (setmetatable({
			id = HttpService:GenerateGUID(false):gsub("-", ""):lower(),
			store = options or {},
			keyOf = callback or defaultKeyOf
		}, v2))
	end,
	Get = function(self, p2)
		local v3 = assert(self.keyOf(p2), "the key parser produced nothing for this player")
		local v4 = self.store[v3]

		if v4 == nil then
			return Promise.reject("no profile is registered under that lookup"), false
		end

		return Promise.resolve(v4), true
	end,
	GetAll = function(p)
		return table.clone(p.store)
	end,
	GetAssert = function(self, p)
		return self:Get(p):expect()
	end,
	GetAsync = function(data, p)
		local v3 = assert(data.keyOf(p), "the key parser produced nothing for this player")
		local v4 = data.store[v3]

		if v4 then
			return v4
		end

		local v5 = select(2, locate(data, p))

		local function mine(p2: string, p3: string, _)
			return p2 == data.id and p3 == v5
		end

		local v6 = { Promise.fromEvent(v2.ProfileAdded, mine):andThen(function(_, _, p2)
				return p2
			end), (Promise.fromEvent(v2.ProfileRemoving, mine):andThen(function()
				return Promise.reject((`player {v5} left before a profile arrived`))
			end)) }
		return Promise.race(v6):expect()
	end,
	IsProfileRegistered = function(p, p2)
		local v3 = assert(p.keyOf(p2), "the key parser produced nothing for this player")
		return p.store[v3] and true or false
	end,
	Set = function(data, p, ...)
		local v3 = assert(data.keyOf(p), "the key parser produced nothing for this player")
		local v4 = data.store[v3]
		data.store[v3] = ...

		if not v4 then
			v2.ProfileAdded:Fire(data.id, v3, ...)
		end
	end,
	Remove = function(data, p)
		local v3 = assert(data.keyOf(p), "the key parser produced nothing for this player")
		local v4 = data.store[v3]

		if v4 == nil then
			return false, v:AtWarning():Log((`nothing to remove for an unloaded player: {v3}`))
		end

		v2.ProfileRemoving:Fire(data.id, v3, v4)
		data.store[v3] = nil
		return true
	end
}
v2.__index = v2
return v2