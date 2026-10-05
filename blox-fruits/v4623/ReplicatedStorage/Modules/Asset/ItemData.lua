local ItemData = {
	Types = {},
	Items = {}
}

for _, child in pairs(script.Types:GetChildren()) do
	local module = require(child)

	for k, _ in pairs(module) do
		ItemData.Types[k] = child.Name
	end

	ItemData[child.Name] = module
end

ItemData.ItemStats = require(script.ItemStats)
return ItemData