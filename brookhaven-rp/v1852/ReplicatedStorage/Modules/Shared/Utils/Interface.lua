local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
return {
	GetImplementation = function(instance, data)
		local component = instance:GetAttribute("Component")
		assert(typeof(component) == "string", "Component name must be a string")
		local component2 = ComponentUtil.GetComponentFromInstance(
			assert(instance.Value, "ObjectValue must have a value"),
			assert(ComponentUtil.FindAndWaitForComponentByTag(nil, component, RunService:IsServer()))
		)

		if data.HasContract and not data.HasContract(component2) and data.Name then
			local _, v = data.HasContract(component2)
			error((`{component} does not have the required methods/properties for interface {data.Name} : {v}`))
		end

		return data.Cast(component2)
	end
}