local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
require(shared.Ripple)
local parent = script.Parent
local useClock = require(parent.useClock)
local useMotion = require(parent.useMotion)

-- equivalent calls inferred from this helper; original call sites unknown
local function getBindingValue(object)
	if type(object) == "table" then
		return object:getValue()
	end

	return object
end

local function useSpring(object, p, value: number?)
	local bindingValue = getBindingValue(object) -- equivalent call inferred; original call site unknown
	local v, v2 = useMotion(bindingValue, value)
	local ref = React.useRef(bindingValue)
	useClock(value or 60, function()
		local v3 = object

		if type(v3) == "table" then
			v3 = v3:getValue()
		end

		bindingValue = v3

		if bindingValue ~= ref.current then
			ref.current = bindingValue
			v2:spring(bindingValue, p)
		end
	end, { value })
	return v, v2
end

return useSpring