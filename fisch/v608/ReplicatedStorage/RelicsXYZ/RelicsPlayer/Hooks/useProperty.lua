local shared = script.Parent.Parent.Parent.Shared
local Guid = require(shared.Guid)
local React = require(shared.React)
local useRef = React.useRef
local useState = React.useState
local useEffect = React.useEffect
local object = setmetatable({}, {
	__mode = "k"
})

local function getInstanceMemo(instance)
	if not object[instance] then
		object[instance] = {}
		instance.Destroying:Once(function()
			object[instance] = nil
		end)
	end

	return object[instance]
end

local function getPropertyMemo(instance, current: string)
	local instanceMemo = getInstanceMemo(instance)

	if instanceMemo[current] then
		return instanceMemo[current]
	end

	local v = {}
	local connection = instance:GetPropertyChangedSignal(current):Connect(function()
		local v2 = instance[current]

		for _, v3 in pairs(v) do
			v3(v2)
		end
	end)
	instance.Destroying:Once(function()
		connection:Disconnect()
		table.clear(v)
		instanceMemo[current] = nil
	end)
	instanceMemo[current] = v
	return v
end

local function useProperty(instance, callback)
	local v = useRef("")
	local state, setState = useState(nil)
	local current = useRef(Guid.Create()).current
	assert(instance == nil or typeof(instance) == "Instance", "useProperty must be called with an instance")

	if v.current == "" then
		local v2 = false
		state = callback((setmetatable({}, {
			__index = function(_, current2: string)
				assert(not v2, "useProperty can only read one property.")
				local v3

				if instance ~= nil then
					v3 = instance[current2]
					assert(type(v3) ~= "function", "useProperty cannot read functions.")
					assert(typeof(v3) ~= "RBXScriptSignal", "useProperty cannot read events.")
				end

				v.current = current2
				v2 = true
				return v3
			end
		})))
		setState(state)
	end

	useEffect(function()
		local current2 = v.current
		local v2 = instance and getPropertyMemo(instance, current2)

		if not v2 then
			return nil
		end

		local v3 = instance[current2]

		if v3 ~= state then
			setState(v3)
		end

		v2[current] = setState
		return function()
			v2[current] = nil
		end
	end, { instance })
	return state
end

return useProperty