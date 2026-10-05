local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local Shared = require(parent.Shared)
local reactSymbols = Shared.ReactSymbols
require(parent.Shared)
local symbol = LuauPolyfill.Symbol
local createSignalroblox = require(script.Parent["createSignal.roblox"])
local v = symbol("BindingImpl")
local Roblox = {}
local v2 = {
	__index = {
		getValue = function(p)
			return Roblox.getValue(p)
		end,
		map = function(p, callback)
			return Roblox.map(p, callback)
		end
	},
	__tostring = function(object)
		return string.format("RoactBinding(%s)", (tostring(object:getValue())))
	end
}

function Roblox.update(p, p2)
	return p[v].update(p2)
end

function Roblox.subscribe(p, callback)
	return p[v].subscribe(callback)
end

function Roblox.getValue(p)
	return p[v]:getValue()
end

function Roblox.create(p)
	local signalroblox, v3 = createSignalroblox()
	local v4 = {
		value = p,
		subscribe = signalroblox
	}

	function v4.update(p2)
		v4.value = p2
		v3(p2)
	end

	function v4.getValue()
		return v4.value
	end

	local source

	if ReactGlobals.__DEV__ then
		source = debug.traceback("Binding created at:", 3)
	end

	return setmetatable({
		["$$typeof"] = reactSymbols.REACT_BINDING_TYPE,
		[v] = v4,
		_source = source
	}, v2), v4.update
end

function Roblox:map(callback)
	if ReactGlobals.__DEV__ then
		local v3

		if typeof(self) == "table" then
			v3 = self["$$typeof"] == reactSymbols.REACT_BINDING_TYPE
		else
			v3 = false
		end

		assert(v3, "Expected `self` to be a binding")
		assert(typeof(callback) == "function", "Expected arg #1 to be a function")
	end

	local source

	if ReactGlobals.__DEV__ then
		source = debug.traceback("Mapped binding created at:", 3)
	end

	return (setmetatable({
		["$$typeof"] = reactSymbols.REACT_BINDING_TYPE,
		[v] = {
			subscribe = function(callback2)
				return Roblox.subscribe(self, function(p)
					callback2(callback(p))
				end)
			end,
			update = function(_)
				error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
			end,
			getValue = function()
				return callback(self:getValue())
			end
		},
		_source = source
	}, v2))
end

function Roblox.join(items)
	if ReactGlobals.__DEV__ then
		assert(typeof(items) == "table", "Expected arg #1 to be of type table")

		for k, item in items do
			if not (typeof(item) ~= "table" or item["$$typeof"] ~= reactSymbols.REACT_BINDING_TYPE) then
				continue
			end

			local formatted = ("Expected arg #1 to contain only bindings, but key %q had a non-binding value"):format((tostring(k)))
			error(formatted, 2)
		end
	end

	local function getValue()
		local result = {}

		for k, item in pairs(items) do
			result[k] = item:getValue()
		end

		return result
	end

	local source

	if ReactGlobals.__DEV__ then
		source = debug.traceback("Joined binding created at:", 2)
	end

	return (setmetatable({
		["$$typeof"] = reactSymbols.REACT_BINDING_TYPE,
		[v] = {
			subscribe = function(callback)
				local v4 = {}

				for k, item in items do
					v4[k] = Roblox.subscribe(item, function(_)
						callback((getValue()))
					end)
				end

				return function()
					if v4 == nil then
						return
					end

					for _, v5 in v4 do
						v5()
					end

					v4 = nil
				end
			end,
			update = function(_)
				error("Bindings created by joinBindings(...) cannot be updated directly", 2)
			end,
			getValue = function()
				return (getValue())
			end
		},
		_source = source
	}, v2))
end

return Roblox