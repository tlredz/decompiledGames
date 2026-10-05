local import = _G.import("categoryDifficultyData")
local CategoryData = {}

for k, v in pairs(import) do
	for k2, v2 in pairs(v) do
		v2.Difficulty = k
		v2.Id = k2
		CategoryData[k2] = v2
	end
end

return CategoryData