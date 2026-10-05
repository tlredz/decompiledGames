local v = {
	["Fountain City"] = { "Sewers" },
	["Floating Turtle"] = { "Mansion", "l'Église de Prophétie" },
	["Hydra Island"] = {
		"Friendly Arena",
		"Beautiful Pirate Domain",
		"Secret Temple",
		"Dragon Dojo"
	},
	["Temple of Time"] = { "Ancient Clock" }
}
local group = {}

for _, child in pairs(workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations"):GetChildren()) do
	v[child.Name] = v[child.Name] or {}
end

for k, v3 in pairs(v) do
	local v4 = {}

	for _, v5 in pairs(v3) do
		v4[v5] = true
		group[v5] = group[v5] or {}
		group[v5][k] = true
	end

	if not group[k] then
		group[k] = v4
	end
end

return {
	Group = group
}