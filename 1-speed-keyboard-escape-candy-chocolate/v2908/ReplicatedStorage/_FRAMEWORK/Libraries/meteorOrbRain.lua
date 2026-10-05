local Client = require(script.Client)
local Server = require(script.Server)
require(script.Types)
local MeteorOrbRain = {}

function MeteorOrbRain.startServer(p)
	return Server.start(p)
end

function MeteorOrbRain.startClient(p)
	return Client.start(p)
end

return MeteorOrbRain