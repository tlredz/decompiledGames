require(script.Parent.FayeTypes)
local Defaults = require(script.Defaults)
local insert = table.insert
local typeof2 = typeof
local FayeInstance = require(script.Parent.Misc.FayeInstance)
return function(className, thread)
	return function(props)
		local instance = Instance.new(className)

		if Defaults[className] ~= nil then
			Defaults[className](instance)
		end

		local flag = true

		if props.Properties ~= nil then
			for k, property in pairs(props.Properties) do
				props[k] = property
			end

			props.Properties = nil
		end

		for k, valueBase in pairs(props) do
			local typeName = typeof2(valueBase)

			if typeName == "function" or typeName == "table" or typeName == "Instance" and valueBase:IsA("ValueBase") or k == "CleanDelay" or k == "Parent" or typeof2(k) == "number" then
				flag = false
			else
				instance[k] = valueBase
				props[k] = nil
			end
		end

		if flag then
			return instance
		end

		local object2 = setmetatable({
			Instance = instance,
			Props = props,
			Thread = thread
		}, FayeInstance)

		if props.Parent then
			object2:Compile()
		end

		if thread == nil then
			return object2
		end

		if thread.Add then
			thread:Add(object2, true)
			return object2
		else
			insert(thread, object2)
		end

		return object2
	end
end