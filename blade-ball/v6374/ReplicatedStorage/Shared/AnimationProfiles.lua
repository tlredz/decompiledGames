local AnimationProfiles = {}

for _, child in script.Profiles:GetChildren() do
	local v = {}

	for _, child2 in child:GetChildren() do
		local v2 = {}

		for _, child3 in child2:GetChildren() do
			v2[tonumber(child3.Name) or #v2 + 1] = {
				id = child3:GetAttribute(tostring(nil) .. "Id") or child3.AnimationId,
				weight = child3:GetAttribute("Weight"),
				priority = child3:GetAttribute("Priority"),
				speed = child3:GetAttribute("Speed")
			}
		end

		v[child2.Name] = v2
	end

	AnimationProfiles[child.Name] = v
end

return AnimationProfiles