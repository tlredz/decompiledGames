local RunTimeline = require(game.ReplicatedStorage.RunTimeline)

if RunTimeline.IsInitialized == false then
	RunTimeline.init()
end

local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction(LoggerBuilder.GET_CLIENT_LOGS_KEY)

remoteFunction.OnClientInvoke = function(p)
	return LoggerBuilder.runCommand(p, function(p2)
		print(p2)
	end)
end

local remoteFunction_2 = Net:RemoteFunction(LoggerBuilder.GET_TAG_COUNT_KEY)

remoteFunction_2.OnClientInvoke = function()
	assert(RunTimeline.IsInitialized == true, "bad RunTimeline")
	return RunTimeline:GetTagCounts()
end