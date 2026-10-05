local GachaClient = {}
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
require(game.ReplicatedStorage.Modules.Util.Signal)
local Net = require(game.ReplicatedStorage.Modules.Net)
local v = nil
local v2 = {}

function GachaClient.GetGachaAsync(boxName)
	if v2[boxName] == nil then
		v2[boxName] = v:InvokeServer({
			Context = "getGachaFromBoxName",
			BoxName = boxName
		})
	end

	return assert(v2[boxName], (`unknown gacha from name: {boxName}`))
end

function GachaClient.TryGetGacha(p)
	return v2[p]
end

function GachaClient.CheckGachaAsync(boxName, spokeNPC: string?)
	return (v:InvokeServer({
		Context = "Check",
		BoxName = boxName,
		SpokeNPC = spokeNPC
	}))
end

function GachaClient.PurchaseGachaAsync(boxName)
	return v:InvokeServer({
		Context = "Purchase",
		BoxName = boxName
	})
end

function GachaClient.OnStart()
	v = Net:RemoteFunction("GachaNetworkRF")
	task.spawn(function()
		local HardPityUtil = require(script.HardPityUtil)
		HardPityUtil.Start()
	end)
end

return GachaClient