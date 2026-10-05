local v = {
	"Color",
	"Enabled",
	"Name",
	"Offset",
	"Rotation",
	"Transparency"
}

local function gradientsUnder(parent)
	local uIGradients = {}

	for _, uIGradient in parent:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			table.insert(uIGradients, uIGradient)
		end
	end

	return uIGradients
end

local function paint(instance, instance2)
	for _, v2 in v do
		instance[v2] = instance2[v2]
	end

	for k, v2 in instance2:GetAttributes() do
		instance:SetAttribute(k, v2)
	end
end

return function(parent, instance)
	local v2 = gradientsUnder(parent)

	if instance == nil then
		for _, v3 in v2 do
			v3:Destroy()
		end

		return nil
	else
		local v3 = table.remove(v2, 1)

		for _, v4 in v2 do
			v4:Destroy()
		end

		if v3 ~= nil then
			paint(v3, instance)
			return v3
		end

		local clone = instance:Clone()
		clone.Parent = parent
		return clone
	end
end