local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.StockMachineTypes)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local stockCache = ReplicatorClient.get("StockCache")
local remoteEvent = Net:RemoteEvent("StockEventService/SetFocused")
local remoteEvent2 = Net:RemoteEvent("StockEventService/Return")
local remoteEvent3 = Net:RemoteEvent("StockEventService/Redeem")
local remoteFunction = Net:RemoteFunction("StockEventService/ListItems")
Net:RemoteFunction("StockEventService/Delivery")
local v = {}
local v2 = {
	GetStock = function(_, p)
		return stockCache:TryIndex({ "stock", p })
	end,
	OnStockChange = function(_, p, callback)
		return stockCache:Observe({ "stock", p }, callback)
	end,
	Redeem = function(p, p2)
		remoteEvent3:FireServer(p.MachineName, p2)
	end,
	Return = function(p, p2: number)
		remoteEvent2:FireServer(p.MachineName, p2)
	end,
	SetOpen = function(p, flag: boolean)
		remoteEvent:FireServer("807e8871-af8f-40c2-af4e-e9c1372480fe", p.MachineName, flag)
	end,
	ListItems = function(p)
		if v[p.MachineName] then
			return true, v[p.MachineName]
		end

		local v3 = 3
		local v4, v5

		while true do
			v4, v5 = remoteFunction:InvokeServer("f2ec7a10-1531-4127-84cf-3077864740a3", p.MachineName)

			if v4 then
				break
			end

			task.wait(3)

			if v5 == "Retry" then
				continue
			end

			if v3 <= 0 then
				break
			else
				v3 -= 1
			end
		end

		if v4 and typeof(v5) == "table" then
			v[p.MachineName] = v5
		end

		return v4, v5
	end
}
return {
	create = function(machineName: string)
		return (setmetatable({
			MachineName = machineName
		}, {
			__index = v2
		}))
	end
}