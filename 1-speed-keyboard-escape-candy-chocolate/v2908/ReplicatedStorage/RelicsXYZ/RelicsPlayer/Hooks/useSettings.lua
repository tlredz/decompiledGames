local parent = script.Parent
local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local Settings = require(shared.Settings)
local usePlayerData = require(parent.usePlayerData)

local function useSettings()
	local v = usePlayerData("Settings")
	local clone = table.clone(v.Settings)

	for k, v2 in Settings.GetSettings() do
		if clone[k] == nil then
			clone[k] = v2.Default
		end
	end

	return clone
end

return useSettings