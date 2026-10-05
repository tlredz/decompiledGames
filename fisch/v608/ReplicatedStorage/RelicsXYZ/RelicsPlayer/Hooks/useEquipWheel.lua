local parent = script.Parent
local shared = parent.Parent.Parent.Shared
require(shared.EquipWheel)
local usePlayerData = require(parent.usePlayerData)

local function useEquipWheel()
	return usePlayerData("EquipWheel").EquipWheel or {}
end

return useEquipWheel