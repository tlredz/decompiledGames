local CollectionService = game:GetService("CollectionService")
local v = {
	TeleporterVFX = true,
	Meshs = true,
	Charge = true,
	Player = true,
	Smokes = true
}
local v2 = {
	ParticleEmitter = "Texture",
	Trail = "Texture",
	Decal = "Texture",
	Texture = "Texture"
}

function isTogglable(effect)
	return effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")
end

function stripBakedLayer(instance)
	for _, child in instance:GetChildren() do
		if v[child.Name] then
			if child.Name == "Smokes" then
				for _, child2 in child:GetChildren() do
					child2:Destroy()
				end
			end
		else
			child:Destroy()
		end
	end
end

function decompressTexture(value: string)
	return (value:gsub("%*", "rbxthumb://type=Asset&id="):gsub("%+", "&w=150&h=150"):gsub("%-", "rbxassetid://"))
end

function wakeParkedVisuals(folder)
	for _, descendant in folder:GetDescendants() do
		local enabled = descendant:GetAttribute("Enabled")

		if isTogglable(descendant) and typeof(enabled) == "boolean" then
			descendant.Enabled = enabled
		end

		local v3 = v2[descendant.ClassName]
		local texture = descendant:GetAttribute("Texture")

		if v3 and typeof(texture) == "string" and texture ~= "" and descendant[v3] == "" then
			descendant[v3] = decompressTexture(texture)
		end
	end
end

function restChargeVisuals(instance)
	local charge = instance:FindFirstChild("Charge")

	if not charge then
		return
	end

	for _, descendant in charge:GetDescendants() do
		if isTogglable(descendant) then
			descendant.Enabled = false
		end
	end
end

return {
	copy = function(instance)
		local clone = instance:Clone()

		for _, tag in CollectionService:GetTags(clone) do
			CollectionService:RemoveTag(clone, tag)
		end

		stripBakedLayer(clone)
		wakeParkedVisuals(clone)
		restChargeVisuals(clone)
		return clone
	end
}