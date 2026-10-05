local CollectionService = game:GetService("CollectionService")

local function Create(value, options, ...)
	assert(value, "No Value was given.")
	local v = options or {}
	local instance = nil

	if typeof(value) == "string" then
		instance = Instance.new(value)
	elseif typeof(value) == "Instance" then
		instance = value:Clone()
	end

	if v._Tags then
		for _, tag in pairs(v._Tags) do
			CollectionService:AddTag(instance, tag)
		end

		v._Tags = nil
	end

	for k, v2 in pairs(v) do
		if k ~= "Parent" then
			instance[k] = v2
		end
	end

	for _, v2 in pairs({ ... }) do
		v2.Parent = instance
	end

	instance.Parent = v.Parent or instance.Parent
	return instance
end

return Create