local Net = require(game.ReplicatedStorage.Modules.Net)
return {
	GetGroupRemoteFunction = Net:RemoteFunction("GetTestingGroup")
}