local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local EasterNetwork = require(game.ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
return function()
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local flag = false
		local connection = EasterNetwork.OnItemChanged(function(...)
			setState(EasterNetwork.GetData())
		end)
		local connection2 = EasterNetwork.OnRewardClaimed(function(...)
			setState(EasterNetwork.GetData())
		end)
		task.spawn(function()
			local data = EasterNetwork.GetData()

			if flag then
				return
			end

			setState(data)
		end)
		return function()
			flag = true
			connection:Disconnect()
			connection2:Disconnect()
		end
	end, {})
	return state
end