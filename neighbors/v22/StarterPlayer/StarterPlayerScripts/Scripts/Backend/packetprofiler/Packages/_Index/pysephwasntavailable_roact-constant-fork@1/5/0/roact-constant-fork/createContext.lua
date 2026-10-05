local Symbol = require(script.Parent.Symbol)
local createFragment = require(script.Parent.createFragment)
local createSignal = require(script.Parent.createSignal)
local Children = require(script.Parent.PropMarkers.Children)
local Component = require(script.Parent.Component)

-- equivalent calls inferred from this helper; original call sites unknown
local function createContextEntry(p)
	return {
		value = p,
		onUpdate = createSignal()
	}
end

local function createProvider(p)
	local extended = Component:extend("Provider")

	function extended:init(p2)
		self.contextEntry = createContextEntry(p2.value)
		self:__addContext(p.key, self.contextEntry)
	end

	function extended.willUpdate(p2, p3)
		if p3.value ~= p2.props.value then
			p2.contextEntry.value = p3.value
		end
	end

	function extended.didUpdate(p2, p3)
		if p3.value ~= p2.props.value then
			p2.contextEntry.onUpdate:fire(p2.props.value)
		end
	end

	function extended.render(p2)
		return createFragment(p2.props[Children])
	end

	return extended
end

local function createConsumer(p)
	local extended = Component:extend("Consumer")

	function extended.validateProps(p2)
		if type(p2.render) == "function" then
			return true
		end

		return false, "Consumer expects a `render` function"
	end

	function extended:init(_)
		self.contextEntry = self:__getContext(p.key)
	end

	function extended.render(p2)
		local v

		if p2.contextEntry == nil then
			v = p.defaultValue
		else
			v = p2.contextEntry.value
		end

		return p2.props.render(v)
	end

	function extended:didUpdate()
		if self.contextEntry ~= nil then
			self.lastValue = self.contextEntry.value
		end
	end

	function extended:didMount()
		if self.contextEntry ~= nil then
			self.disconnect = self.contextEntry.onUpdate:subscribe(function(p2)
				if p2 ~= self.lastValue then
					self:setState({})
				end
			end)
		end
	end

	function extended:willUnmount()
		if self.disconnect ~= nil then
			self.disconnect()
			self.disconnect = nil
		end
	end

	return extended
end

local class = {}
class.__index = class

function class.new(defaultValue)
	return (setmetatable({
		defaultValue = defaultValue,
		key = Symbol.named("ContextKey")
	}, class))
end

function class.__tostring(_)
	return "RoactContext"
end

local function createContext(p)
	local v = class.new(p)
	return {
		Provider = createProvider(v),
		Consumer = createConsumer(v)
	}
end

return createContext