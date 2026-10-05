local GameConfig = {}

function GameConfig.GetClient(_)
	return require("@self/Client")
end

function GameConfig.GetServer(_)
	return require("@self/Server")
end

return GameConfig