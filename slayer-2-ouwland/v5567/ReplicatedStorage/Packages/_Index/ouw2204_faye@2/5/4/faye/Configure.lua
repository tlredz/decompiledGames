require(script.Parent.FayeTypes)
local ValueClasses = require(script.Parent.Misc.ValueClasses)
local insert = table.insert
local typeof2 = typeof
local FayeInstance = require(script.Parent.Misc.FayeInstance)
return function(instance, thread)
	return function(props)
		if typeof2(instance) == "table" then
			if instance.__type == "Instance" then
				instance = instance.Instance
			elseif ValueClasses[instance.__type] then
				instance = instance:Get()

				if typeof2(instance) == "table" and instance.__type == "Instance" then
					instance = instance.Instance
				end
			end
		end

		if instance == nil or typeof2(instance) ~= "Instance" then
			warn((`Entity must be an instance for configure or a value that gives an instance - {debug.traceback()}`))
			return
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
		object2:Compile()

		if thread == nil then
			return object2
		end

		if thread.Add then
			thread:Add(object2)
			return object2
		end

		insert(thread, object2)
		return object2
	end
end