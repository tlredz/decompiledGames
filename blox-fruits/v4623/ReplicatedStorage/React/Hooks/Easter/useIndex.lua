local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
return function()
	local state, setState = React.useState({})
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local connection = EasterNetwork.OnItemChanged(function(...)
			setState((table.clone(EasterNetwork.GetData().Index)))
		end)
		setState(table.clone(EasterNetwork.GetData().Index))
		return function()
			connection:Disconnect()
		end
	end, {})
	return state
end