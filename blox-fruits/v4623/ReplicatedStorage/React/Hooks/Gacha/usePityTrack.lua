require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local usePityInfo = require(script.Parent.usePityInfo)
return function(p)
	local v = usePityInfo(p)
	local state, setState = React.useState({
		PastItems = {},
		Pity = 0,
		Items = {},
		NextItem = nil
	})
	React.useEffect(function()
		if v then
			local pityRewardTrack = v.PityRewardTrack
			local currentHardPity = v.CurrentHardPity
			local itemIds = {}
			local itemId = nil
			local items = {}

			for i = 1, #pityRewardTrack do
				if pityRewardTrack[i].RollGuarantee <= currentHardPity then
					table.insert(itemIds, pityRewardTrack[i].ItemId)
				end

				if not (currentHardPity + 1 <= pityRewardTrack[i].RollGuarantee) then
					continue
				end

				itemId = pityRewardTrack[i].ItemId
				break
			end

			for k, v3 in pairs(pityRewardTrack) do
				local isNextItem = itemId and itemId == v3.ItemId and true or false
				local isPastItem = table.find(itemIds, v3.ItemId) ~= nil
				table.insert(items, {
					Index = k,
					ItemId = ItemConfig.match(v3.ItemId):unwrap().Index.ItemId,
					Pity = v.CurrentHardPity,
					Chance = v3.Chance,
					RollGuarantee = v3.RollGuarantee,
					IsNextItem = isNextItem,
					IsPastItem = isPastItem
				})
			end

			setState({
				Items = items,
				NextItem = itemId,
				PastItems = itemIds,
				Pity = v.CurrentHardPity
			})
		end
	end, { v })
	return state
end