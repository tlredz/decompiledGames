local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local DevProductService = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Market"):WaitForChild("DevProductService"))
local remoteFunction = Net:RemoteFunction("TimedPurchaseOfferState")
local remoteEvent = Net:RemoteEvent("TimedPurchaseOfferUpdate")
local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getState(p: string, player)
	local v3 = v[p]

	if v3 then
		return {
			remaining = v3.getRemaining(player),
			purchased = v3.getPurchased(player)
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushUpdate(key: string, player)
	local state = getState(key, player) -- equivalent call inferred; original call site unknown

	if state then
		remoteEvent:FireClient(player, key, state)
	end
end

local function handlePurchase(data, p)
	local plr = p.plr
	local success, result = pcall(data.grantReward, plr)

	if not success then
		warn((`[TimedPurchaseService] {data.key} 发奖失败：{result}`))
		return
	end

	data.setPurchased(plr, true)
	pushUpdate(data.key, plr) -- equivalent call inferred; original call site unknown
end

local function startCountdown(data, p)
	v2[p] = v2[p] or {}

	if v2[p][data.key] then
		return
	end

	v2[p][data.key] = true
	task.spawn(function()
		if data.waitForData then
			data.waitForData(p)
		end

		if p.Parent and v2[p] and v2[p][data.key] then
			while p.Parent and v2[p] and v2[p][data.key] do
				task.wait(1)

				if not p.Parent or not v2[p] or not v2[p][data.key] or data.getPurchased(p) then
					break
				end

				local remaining = data.getRemaining(p)

				if remaining <= 0 then
					break
				end

				local v3 = remaining - 1
				data.setRemaining(p, v3)
				pushUpdate(data.key, p) -- equivalent call inferred; original call site unknown
			end
		end

		if v2[p] then
			v2[p][data.key] = nil
		end
	end)
end

local function initServer(p)
	v[p.key] = p
	DevProductService.server.bindProduct(p.productKey, function(p2)
		handlePurchase(p, p2)
	end)

	for _, v3 in Players:GetPlayers() do
		startCountdown(p, v3)
	end

	Players.PlayerAdded:Connect(function(player)
		startCountdown(p, player)
	end)
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, p2: string)
		local v3 = v[p2]

		if v3 then
			return {
				remaining = v3.getRemaining(p),
				purchased = v3.getPurchased(p)
			}
		end

		return nil
	end

	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
	end)
end

local function clientSync(p: string, callback)
	local success, result = pcall(function()
		return remoteFunction:InvokeServer(p)
	end)

	if success and result then
		callback(result)
	end

	remoteEvent.OnClientEvent:Connect(function(p2, p3)
		if p2 == p then
			callback(p3)
		end
	end)
end

return {
	server = {
		init = initServer
	},
	client = {
		sync = clientSync
	}
}