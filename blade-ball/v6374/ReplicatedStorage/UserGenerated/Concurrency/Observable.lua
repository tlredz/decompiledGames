local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeepEquals = require(ReplicatedStorage.UserGenerated.Collections.DeepEquals)
local Bindable = require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local frozen = table.freeze({
	Get = function(p)
		return p.Value
	end,
	Set = function(state, p)
		if state.Assertion then
			p = state.Assertion(p)
		end

		local value = state.Value
		state.Value = p

		if not DeepEquals(p, value) then
			state.Changed:Fire(p, value)
		end

		return value
	end
})
local frozen2 = table.freeze({
	__index = frozen
})
return table.freeze({
	new = function(assertion, p)
		assert(type(assertion) == "function")
		local v = assertion(p)
		local readonly = {
			Changed = Bindable.new(),
			Assertion = assertion,
			Value = v
		}
		readonly.Readonly = readonly
		return (setmetatable(readonly, frozen2))
	end,
	Unasserted = function(p)
		local readonly = {
			Changed = Bindable.new(),
			Value = p
		}
		readonly.Readonly = readonly
		return (setmetatable(readonly, frozen2))
	end
})