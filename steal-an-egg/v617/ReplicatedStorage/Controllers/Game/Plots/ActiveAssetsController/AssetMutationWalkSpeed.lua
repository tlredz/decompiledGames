local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local ids = Mutations.Ids()

-- equivalent calls inferred from this helper; original call sites unknown
local function hasMutation(p, p2: string)
	return p.BaseMutation == p2 or table.find(p.Mutations, p2) ~= nil
end

return {
	GetMultiplier = function(p)
		assert(AssetItem.AssetItemData(p), "Invalid asset item data")

		if hasMutation(p, ids.Rainbow) then
			return 2
		end

		if hasMutation(p, ids.Golden) then
			return 0.5
		end

		if hasMutation(p, ids.Silver) then
			return 0.7
		end

		return 1
	end
}