local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local DeepFreeze = require(game.ReplicatedStorage.UserGenerated.Collections.DeepFreeze)
local Lock = require(game.ReplicatedStorage.UserGenerated.Concurrency.Lock)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)

local function ValueAge(p, p2: number)
	local retrievedAt = p.RetrievedAt

	if retrievedAt then
		return p2 - retrievedAt
	end

	return nil
end

local function AttemptAge(p, p2: number)
	local attemptedAt = p.AttemptedAt

	if attemptedAt then
		return p2 - attemptedAt
	end

	return 1e999
end

local v = {
	RemoveUsedAt = function(self, _) end,
	InsertUsedAt = function(self, _) end,
	SetUsedAt = function(self, p, usedAt: number)
		self:RemoveUsedAt(p)
		p.UsedAt = usedAt
		self:InsertUsedAt(p)
	end,
	Get = function(self, p)
		local v2 = self.AssertKey(p)
		local v3 = self.Cache[v2]

		if not v3 then
			return nil
		end

		local now = os.clock()
		local retrievedAt = v3.RetrievedAt
		local v4

		if retrievedAt then
			v4 = now - retrievedAt
		end

		if not v4 or self.MaxAge <= v4 and not self.ReturnStale then
			return nil
		end

		self:SetUsedAt(v3, now)
		return v3.Value
	end
}

function AsyncCallback(object, state, p, attemptedAt: number)
	local retrievedAt = state.RetrievedAt
	local v2

	if retrievedAt then
		v2 = attemptedAt - retrievedAt
	end

	if v2 and v2 < object.MaxAge then
		return state.Value
	end

	local attemptedAt2 = state.AttemptedAt

	if (not attemptedAt2 and 1e999 or attemptedAt - attemptedAt2) < object.FailureRetryDelay then
		if object.ReturnStale then
			return state.Value
		end

		return nil
	else
		state.AttemptedAt = attemptedAt
		local success, result = pcall(object.Callback, p)
		local now = os.clock()
		state.AttemptedAt = now
		object:SetUsedAt(state, now)

		if success then
			if object.Freeze then
				result = DeepFreeze(result)
			end

			state.Value = result
			state.RetrievedAt = now
			object.Updated:Fire(p)
			return result
		elseif object.ReturnStale then
			return state.Value
		else
			return nil
		end
	end
end

function v.GetAsync(object, p)
	local now = os.clock()
	local v2 = object.AssertKey(p)
	local v3 = object.Cache[v2]

	if v3 then
		object:SetUsedAt(v3, now)
	else
		v3 = {
			Lock = Lock.new(),
			UsedAt = now
		}
		object.Cache[v2] = v3
		object:InsertUsedAt(v3)
	end

	return v3.Lock:Call(AsyncCallback, object, v3, p, now)
end

function v.Delete(data, p)
	local v2 = data.AssertKey(p)

	if data.Cache[v2] then
		data.Cache[v2] = nil
		data.Deleted:Fire(p)
	end
end

local frozen = table.freeze({
	__index = table.freeze(v)
})
local table2 = Asserts.Table({
	Callback = Asserts.Function,
	AssertKey = Asserts.Function,
	MaxAge = Asserts.Optional(Asserts.NonNegative),
	FailureRetryDelay = Asserts.Optional(Asserts.NonNegative),
	ReturnStale = Asserts.Optional(Asserts.Boolean),
	Freeze = Asserts.Optional(Asserts.Boolean)
})
return table.freeze({
	new = function(data)
		table2(data)
		local object = setmetatable({
			Updated = Bindable.new(),
			Deleted = Bindable.new(),
			Callback = data.Callback,
			AssertKey = data.AssertKey,
			MaxAge = data.MaxAge or 1e999,
			FailureRetryDelay = data.FailureRetryDelay or 300,
			ReturnStale = data.ReturnStale == nil or data.ReturnStale,
			Freeze = data.Freeze == nil or data.Freeze,
			Cache = {}
		}, frozen)
		table.freeze(object)
		return object
	end
})