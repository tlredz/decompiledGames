local shared = script.Parent.Parent.Parent.Shared
local Guid = require(shared.Guid)
local React = require(shared.React)
local v = {}

local function getInstanceMemo(instance)
	if not v[instance] then
		v[instance] = {}
		instance.Destroying:Once(function()
			v[instance] = nil
		end)
	end

	return v[instance]
end

local function getAttributeMemo(instance, attributeName: string)
	local instanceMemo = getInstanceMemo(instance)

	if instanceMemo[attributeName] then
		return instanceMemo[attributeName]
	end

	local v2 = {}
	local connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
		local attribute = instance:GetAttribute(attributeName)

		for _, v3 in pairs(v2) do
			v3(attribute)
		end
	end)
	instance.Destroying:Once(function()
		connection:Disconnect()
		table.clear(v2)
		instanceMemo[attributeName] = nil
	end)
	instanceMemo[attributeName] = v2
	return v2
end

local function useAttribute(instance, attributeName: string, callback)
	local v2 = React.useState(Guid.Create())
	local state, setState = React.useState(function()
		return instance and instance:GetAttribute(attributeName)
	end)
	React.useEffect(function()
		local v3 = instance and getAttributeMemo(instance, attributeName)

		if instance and v3 then
			v3[v2] = setState
			setState(instance:GetAttribute(attributeName))
			return function()
				v3[v2] = nil
			end
		else
			return nil
		end
	end, { instance, attributeName })
	return callback(state)
end

return useAttribute