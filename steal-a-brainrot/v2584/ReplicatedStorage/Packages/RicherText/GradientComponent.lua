local CollectionService = game:GetService("CollectionService")
local v = {}

local function registerGradient(instance)
	local name = instance.Name

	if v[name] then
		return
	end

	v[name] = {
		properties = {
			Color = instance.Color,
			Offset = instance.Offset,
			Transparency = instance.Transparency,
			Rotation = instance.Rotation,
			Enabled = instance.Enabled
		},
		tags = instance:GetTags(),
		attributes = instance:GetAttributes()
	}
	instance.Destroying:Connect(function()
		v[name] = nil
	end)
end

for _, v2 in CollectionService:GetTagged("TextGradient") do
	registerGradient(v2)
end

CollectionService:GetInstanceAddedSignal("TextGradient"):Connect(registerGradient)
return {
	apply = function(instance, p: string)
		local v2 = v[p]

		if not v2 then
			return
		end

		instance.Color = v2.properties.Color
		instance.Offset = v2.properties.Offset
		instance.Transparency = v2.properties.Transparency
		instance.Rotation = v2.properties.Rotation
		instance.Enabled = v2.properties.Enabled

		for _, tag in instance:GetTags() do
			instance:RemoveTag(tag)
		end

		for k in instance:GetAttributes() do
			instance:SetAttribute(k, nil)
		end

		for k, attribute in v2.attributes do
			instance:SetAttribute(k, attribute)
		end

		for _, tag in v2.tags do
			if tag ~= "TextGradient" then
				instance:AddTag(tag)
			end
		end
	end
}