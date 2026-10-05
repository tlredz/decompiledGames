local BannerClient = {}
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.Modules.Gacha.ClientBannerTypes)
local remoteEvent = Net:RemoteEvent("BannerItemRE")
local remoteFunction = Net:RemoteFunction("BannerItemRF")
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local v = Signal.new()
local v2 = nil

function BannerClient.TryGetBannerItemIfActive()
	return v2
end

function BannerClient.TryGetBannerItemIfActiveAsync()
	local v3 = remoteFunction:InvokeServer()
	local v4 = not v2 and -1 or v2.UID
	local v5 = not v3 and -1 or v3.UID
	v2 = v3

	if v4 ~= v5 then
		v:Fire(v2)
	end

	return v2
end

function BannerClient.ConnectOnBannerItemChanged(callback)
	return v:Connect(callback)
end

function BannerClient.OnStart(_)
	task.spawn(function()
		BannerClient.TryGetBannerItemIfActiveAsync()
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		v2 = p
		v:Fire(p)
	end)
end

return BannerClient