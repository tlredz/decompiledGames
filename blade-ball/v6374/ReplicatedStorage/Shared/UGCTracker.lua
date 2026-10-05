local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local v = require3(ReplicatedStorage2.Packages.Promise)
local remoteEvent = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("UGCTracker/Update")
local v2 = {}
local v3 = {}
local v4 = {}

local function updateItemStock(p: number, remaining: number)
	local v5 = assert(v2[p])

	if RunService:IsServer() then
		remoteEvent:FireAllClients(p, remaining)
	end

	v5.Remaining = remaining
	local v6 = v4[p]

	if not v6 then
		return
	end

	for _, callback in v6 do
		task.spawn(callback, remaining)
	end
end

local function onStockChanged(p: number, callback)
	local v5 = v4[p]

	if v5 then
		table.insert(v5, callback)
	else
		v4[p] = { callback }
	end

	return function()
		local v6 = v4[p]

		if not v6 then
			return
		end

		local index = table.find(v6, callback)

		if not index then
			return
		end

		table.remove(v6, index)

		if #v6 == 0 then
			v4[p] = nil
		end
	end
end

local function addToTracker(p: number, initialStock: number)
	assert(RunService:IsServer(), "Only the server can register new UGC items to be tracked!")

	if table.find(v3, p) then
		return
	end

	v2[p] = {
		InitialStock = initialStock,
		Remaining = 0
	}
	remoteEvent:FireAllClients(p, 0, initialStock)
	table.insert(v3, p)
end

local function removeFromTracker(p: number)
	assert(RunService:IsServer(), "Only the server can remove UGC items from the tracker!")

	if table.find(v3, p) then
		table.remove(v3, p)
	end

	v2[p] = nil
end

local function getStock(p: number)
	return v2[p]
end

if RunService:IsServer() then
	local function getCurrentStock(p: number)
		return v.new(function(callback, callback2)
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(p, Enum.InfoType.Asset)
			end)

			if success then
				callback(result)
			else
				callback2((`Unable to prompt asset purchase of {p}! {result}`))
			end
		end):andThen(function(p2)
			if p2.CollectiblesItemDetails then
				return p2.Remaining or 0
			end

			return 0
		end)
	end

	remoteEvent.OnServerEvent:Connect(function(player)
		for k, v5 in v2 do
			remoteEvent:FireClient(player, k, v5.Remaining, v5.InitialStock)
		end
	end)
	task.defer(function()
		while true do
			if next(v3) then
				for _, v5 in v3 do
					local v6 = v5
					getCurrentStock(v5):andThen(function(remaining)
						updateItemStock(v6, remaining)
					end):catch(warn)
				end

				task.wait(30)
			else
				task.wait(5)
			end
		end
	end)
else
	remoteEvent.OnClientEvent:Connect(function(p, remaining, initialStock)
		local v5 = v2[p]

		if v5 then
			v5.InitialStock = initialStock or v5.InitialStock
		else
			v2[p] = {
				InitialStock = initialStock,
				Remaining = remaining
			}
		end

		updateItemStock(p, remaining)
	end)
	remoteEvent:FireServer()
end

return {
	getStock = getStock,
	addToTracker = addToTracker,
	removeFromTracker = removeFromTracker,
	onStockChanged = onStockChanged
}