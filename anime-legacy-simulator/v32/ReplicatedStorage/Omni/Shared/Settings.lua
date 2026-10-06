local v = {}
local v2 = {
	List = {},
	Categories = {
		{
			Name = "All",
			Index = -1,
			Icon = "rbxassetid://136371292922830",
			Description = "All the game settings"
		}
	}
}

function v2.GetCategorySettings(p: string?, p2: string?)
	local v3 = {}

	for k, v4 in v2.List do
		if not ((not p2 or not v4.Device or v4.Device == p2) and (p == "All" or v4.Category == p)) then
			continue
		end

		local v5 = v3[v4.Category]

		if not v5 then
			local v6 = v[v4.Category]

			if not v6 then
				continue
			end

			v5 = {
				Index = v6,
				Name = v4.Category,
				List = {}
			}
			v3[v4.Category] = v5
		end

		v5.List[k] = v4
	end

	local result = {}

	for _, v4 in v3 do
		table.insert(result, v4)
	end

	table.sort(result, function(a, b)
		return a.Index < b.Index
	end)
	return result
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if not module then
		continue
	end

	for k, v3 in module.List do
		if not (v3.Name and v3.Type and v3.Default ~= nil) then
			continue
		end

		v3.Index = k
		v3.Category = moduleScript.Name
		v2.List[v3.Name] = v3
	end

	local v3 = {
		Name = moduleScript.Name,
		Index = module.Index or #v2.Categories + 1,
		Icon = module.Icon or "rbxassetid://136371292922830",
		Description = module.Description or "No description given"
	}
	table.insert(v2.Categories, v3)
end

table.sort(v2.Categories, function(a, b)
	return a.Index < b.Index
end)

for k, category in v2.Categories do
	category.Index = k
	v[category.Name] = k
end

return table.freeze(v2)