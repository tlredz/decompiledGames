local layouts = {
	Default = {
		DisplayName = "Default",
		Description = "The classic aquarium layout.",
		Cost = 0,
		Icon = "rbxassetid://117449732874164",
		ModelName = "PersonalAquarium",
		LayoutOrder = 1
	},
	Example = {
		DisplayName = "Wide",
		Description = "W I D E",
		Cost = 50000,
		Icon = "rbxassetid://117449732874164",
		ModelName = "Wide",
		LayoutOrder = 2
	}
}
local PersonalAquariumLayouts = {}
PersonalAquariumLayouts.Layouts = layouts
PersonalAquariumLayouts.DEFAULT_LAYOUT_ID = "Default"

function PersonalAquariumLayouts.Get(p: string)
	return layouts[p]
end

function PersonalAquariumLayouts.GetSorted()
	local result = {}

	for k, entry in pairs(layouts) do
		table.insert(result, {
			Id = k,
			Entry = entry
		})
	end

	table.sort(result, function(a, b)
		return a.Entry.LayoutOrder < b.Entry.LayoutOrder
	end)
	return result
end

function PersonalAquariumLayouts.IsOwned(p: string, p2)
	return p == "Default" or p2 ~= nil and p2[p] ~= nil
end

return PersonalAquariumLayouts