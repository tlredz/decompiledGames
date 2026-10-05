local Server = require(script.Server)
local Client = require(script.Client)
local Config = require(script.Config)
require(script.Types)
local FloatingOrbWins = {}

function FloatingOrbWins.startServer(p)
	return Server.start(p)
end

function FloatingOrbWins.startClient(p)
	return Client.start(p)
end

function FloatingOrbWins.defaultConfig()
	return Config.default()
end

function FloatingOrbWins.resolveConfig(p)
	return Config.resolve(p)
end

return FloatingOrbWins