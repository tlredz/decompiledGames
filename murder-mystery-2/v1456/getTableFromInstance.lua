return function(instance)
	local v = {}

	local function attachInstances(p, object)
		if p[object.Name] == nil then
			p[object.Name] = {}
		else
			error("Instances cannot have duplicate names: " .. object.Name .. " in " .. instance.Name)
		end

		local attributes = object:GetAttributes()

		for k, attribute in pairs(attributes) do
			p[object.Name][k] = attribute
		end
	end

	attachInstances(v, instance)

	for _, child in pairs(instance:GetChildren()) do
		attachInstances(v[instance.Name], child)
	end

	return v
end