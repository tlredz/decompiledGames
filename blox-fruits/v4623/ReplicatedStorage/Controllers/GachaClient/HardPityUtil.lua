local HardPityUtil = {}
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Net = require(game.ReplicatedStorage.Modules.Net)
local v = nil
local v2 = nil
local v3 = Signal.new()
local v4 = {}

function HardPityUtil.onInfoChanged(callback)
	if v3 == nil then
		v3 = Signal.new()
	end

	return assert(v3):Connect(callback)
end

function HardPityUtil.requestPityInfo(boxName)
	if v4[boxName] == nil then
		v4[boxName] = {
			BoxName = boxName
		}
	end

	assert(v4[boxName])

	if v4[boxName].PityRewardTrack == nil then
		local pityRewardTrack, currentHardPity = v:InvokeServer({
			Context = "GetPityData",
			BoxName = boxName
		})
		v4[boxName].PityRewardTrack = pityRewardTrack
		v4[boxName].CurrentHardPity = currentHardPity
	end

	return v4[boxName]
end

function HardPityUtil.Start()
	v = Net:RemoteFunction("GachaNetworkRF")
	v2 = Net:RemoteEvent("GachaNetworkRE")
	v2.OnClientEvent:Connect(function(data)
		if data.Context == "UpdateHardPity" then
			assert(data.BoxName, "BoxName is nil")
			assert(data.Value, "Value is nil")
			assert(typeof(data.Value) == "number")

			if v4[data.BoxName] == nil then
				v4[data.BoxName] = {
					BoxName = data.BoxName
				}
			end

			local currentHardPity = v4[data.BoxName].CurrentHardPity
			v4[data.BoxName].CurrentHardPity = data.Value
			print((`UpdateHardPity={currentHardPity}, now={data.Value}`))

			if currentHardPity ~= v4[data.BoxName].CurrentHardPity and v3 then
				v3:Fire(data.BoxName, v4[data.BoxName])
			end
		end
	end)
end

return HardPityUtil