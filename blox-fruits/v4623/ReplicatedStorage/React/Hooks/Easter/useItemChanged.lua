local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
return function(p)
	local state, setState = React.useState(0)
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local connection = EasterNetwork.OnItemChanged(function(p2, p3)
			if p2 == p then
				setState(p3)
			end
		end)
		local thread = task.spawn(function()
			setState(EasterNetwork.GetData().Index[p].Count)
		end)
		return function()
			task.cancel(thread)
			connection:Disconnect()
		end
	end, { p })
	return state
end