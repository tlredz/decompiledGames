local Client = require(script.Client)
local Server = require(script.Server)
require(script.Types)
local WandererCrowd = {}

function WandererCrowd.startServer(p)
	return Server.start(p)
end

function WandererCrowd.startClient(p)
	return Client.start(p)
end

return WandererCrowd