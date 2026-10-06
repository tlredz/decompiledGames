local Output = require(script.Parent.Parent.Utilities.Output)
return function(p)
	Output.warn(string.format(
		"Player %*:%* sent an invalid packet. Likely exploiter- or something interacted with the internal BridgeNet API.",
		p.Name,
		p.UserId
	))
end