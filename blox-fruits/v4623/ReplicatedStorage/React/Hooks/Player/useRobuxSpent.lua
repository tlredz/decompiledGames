local Net = require(game.ReplicatedStorage.Modules.Net)
local React = require(game.ReplicatedStorage.Packages.React)
return function()
	local state, setState = React.useState(0)
	React.useEffect(function()
		local flag = false
		local onClientEventConnection = Net:RemoteEvent("ShopNetwork").OnClientEvent:Connect(function(p)
			if p.Context == "RobuxSpent" then
				local total = p.Total

				if flag then
					return
				else
					setState(total)
				end
			end
		end)
		task.spawn(function()
			local v = Net:RemoteFunction("ShopNetworkRequest"):InvokeServer({
				Context = "RobuxSpent"
			})

			if v and typeof(v) == "number" then
				setState(v)
			end
		end)
		return function()
			flag = true
			onClientEventConnection:Disconnect()
		end
	end, {})
	return state
end