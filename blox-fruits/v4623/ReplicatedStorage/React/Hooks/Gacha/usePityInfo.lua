local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local HardPityUtil = require(game.ReplicatedStorage.Controllers.GachaClient.HardPityUtil)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {
	{
		RollGuarantee = 1,
		ItemId = IdMap.PhysicalMoveset["Lime Blade"],
		Chance = 0.1
	},
	{
		RollGuarantee = 2,
		ItemId = IdMap.PhysicalMoveset["Red Ghost"],
		Chance = 0.2
	},
	{
		RollGuarantee = 3,
		ItemId = IdMap.PhysicalMoveset["Topaz Diamond"],
		Chance = 0.3
	},
	{
		RollGuarantee = 4,
		ItemId = IdMap.PhysicalMoveset["Yellow Lightning"],
		Chance = 0.4
	},
	{
		RollGuarantee = 5,
		ItemId = IdMap.PhysicalMoveset["Heavenly Gravity"],
		Chance = 0.5
	},
	{
		RollGuarantee = 6,
		ItemId = IdMap.PhysicalMoveset["Sealed Fiend"],
		Chance = 0.7
	},
	{
		RollGuarantee = 7,
		ItemId = IdMap.PhysicalMoveset["Arcsteel Magnet"],
		Chance = 1
	}
}
local v2 = {
	{
		RollGuarantee = 2,
		ItemId = IdMap.ProfileBackground.Beach
	},
	{
		RollGuarantee = 10,
		ItemId = IdMap.Accessory["Coral Crown"]
	},
	{
		RollGuarantee = 20,
		ItemId = IdMap.Accessory["Shark Cape"]
	}
}
return function(boxName)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local connection = nil
		local thread = nil

		if GlobalUtil.FFlags.IsUnitTest == true then
			local pityRewardTrack = {}

			if boxName == "PremiumChromaticMagnetGacha26" then
				for _, v4 in pairs(v) do
					table.insert(pityRewardTrack, {
						ItemId = v4.ItemId,
						RollGuarantee = v4.RollGuarantee,
						Chance = v4.Chance
					})
				end
			else
				for _, v4 in pairs(v2) do
					table.insert(pityRewardTrack, {
						ItemId = v4.ItemId,
						RollGuarantee = v4.RollGuarantee,
						Chance = 0
					})
				end
			end

			setState({
				BoxName = boxName,
				PityRewardTrack = pityRewardTrack,
				CurrentHardPity = math.random(1, 5)
			})
		else
			connection = HardPityUtil.onInfoChanged(function(p2, data)
				if p2 == boxName then
					setState({
						BoxName = data.BoxName,
						PityRewardTrack = data.PityRewardTrack,
						CurrentHardPity = data.CurrentHardPity
					})
				end
			end)
			thread = task.spawn(function()
				setState(HardPityUtil.requestPityInfo(boxName))
			end)
		end

		return function()
			if connection then
				connection:Disconnect()
			end

			if thread then
				task.cancel(thread)
			end
		end
	end, { boxName })
	return state
end