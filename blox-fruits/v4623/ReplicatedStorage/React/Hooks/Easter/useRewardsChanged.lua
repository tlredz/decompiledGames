local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
require(game.ReplicatedStorage.Modules.Data.EasterEggs)
return function()
	local state, setState = React.useState({})
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local connection = EasterNetwork.OnRewardClaimed(function(...)
			local rewards = {}

			for k, reward in pairs(EasterNetwork.GetData().Rewards) do
				rewards[k] = reward
			end

			setState(rewards)
		end)
		setState(EasterNetwork.GetData().Rewards)
		return function()
			connection:Disconnect()
		end
	end, {})
	return state
end