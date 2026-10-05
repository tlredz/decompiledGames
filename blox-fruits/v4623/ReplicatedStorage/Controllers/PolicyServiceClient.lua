local PolicyServiceClient = {}
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("PolicyServiceRF")
local v = nil

function PolicyServiceClient.GetAsync()
	if v ~= nil then
		return v, true
	end

	local v2, v3 = remoteFunction:InvokeServer()

	if v3 and v2 then
		v = v2
	end

	return v2, v3
end

function PolicyServiceClient.TryGet()
	return v, v ~= nil
end

function PolicyServiceClient.OnStart(_)
	task.spawn(PolicyServiceClient.GetAsync)
end

return PolicyServiceClient