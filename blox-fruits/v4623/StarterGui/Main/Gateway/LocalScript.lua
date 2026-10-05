local requestGateway = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestGateway")
local GatewayController = require(script.Parent.GatewayController)

requestGateway.OnClientInvoke = function(p)
	return GatewayController.LoadListAndAwaitSelection(p)
end