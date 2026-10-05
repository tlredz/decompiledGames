local RunService = game:GetService("RunService")
local Signal = require(game.ReplicatedStorage.Util.Signal)
local v = {
	CurrentBuffCardConfigs = {},
	OnUpdate = Signal()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function applyConfigs(p, flag: boolean?)
	v.CurrentBuffCardConfigs = typeof(p) ~= "table" and {} or p

	if flag then
		task.defer(v.OnUpdate.Fire, v.OnUpdate, v.CurrentBuffCardConfigs)
	else
		v.OnUpdate:Fire(v.CurrentBuffCardConfigs)
	end
end

if RunService:IsRunning() and RunService:IsServer() then
	local ConfigService = require(game.ServerScriptService.ConfigService)
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "ConfigUpdate"

	remoteFunction.OnServerInvoke = function()
		return v.CurrentBuffCardConfigs
	end

	remoteFunction.Parent = script
	v.OnUpdate.Event:Connect(function(p)
		for _, v2 in game.Players:GetPlayers() do
			task.spawn(remoteFunction.InvokeClient, remoteFunction, v2, p)
		end
	end)
	local v2 = false
	ConfigService.handleConfigUpdate("BuffCardConfigs", function(p)
		applyConfigs(p, false) -- equivalent call inferred; original call site unknown
		v2 = true
	end)

	if not RunService:IsStudio() then
		while not v2 do
			task.wait()
		end
	end

	return v
else
	if RunService:IsRunning() and RunService:IsClient() then
		local configUpdate = script:WaitForChild("ConfigUpdate")
		configUpdate.OnClientInvoke = applyConfigs
		applyConfigs(configUpdate:InvokeServer(), true) -- equivalent call inferred; original call site unknown
	end

	return v
end