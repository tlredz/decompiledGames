local parentModule = require(script.Parent)

script.Parent.RemotePing.OnClientInvoke = function(p: number)
	parentModule._Set(game.Players.LocalPlayer, p)
end