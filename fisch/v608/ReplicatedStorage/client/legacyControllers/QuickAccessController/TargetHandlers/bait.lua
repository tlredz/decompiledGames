local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
assert(Players.LocalPlayer)
local Net = require(ReplicatedStorage.packages.Net)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(ReplicatedStorage.client.modules.ui.Backpack)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local remoteEvent = Net:RemoteEvent("Bait/Equip")
local bait2 = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("bait")
local value = bait2.Value
local v = value
local Bait = {
	_HasBait = function(p: string)
		if p == "None" then
			return true
		end

		local child = bait2:FindFirstChild((`bait_{p}`))
		return child ~= nil and child.Value > 0
	end
}

function Bait.GetOptions()
	playerDataReplicator:WaitForLoaded()
	local result = {}

	for k, v2 in bait do
		if not (typeof(v2) == "table" and Bait._HasBait(k)) then
			continue
		end

		table.insert(result, k)
	end

	table.sort(result)
	return result
end

function Bait.Select(p: string)
	if value == p and v ~= p and Bait._HasBait(v) then
		p = v
	end

	if value ~= p then
		if Bait._HasBait(p) then
			remoteEvent:FireServer(p)
		else
			anno_localthought:Fire((`You don't have any more "{p}" bait to equip!`))
		end
	end
end

function Bait.GetDisplay(p: string)
	if value == p and v ~= p and Bait._HasBait(v) then
		p = v
	end

	local v2 = bait[p]

	if v2 and v2.Icon and v2.Icon ~= "" then
		return "Icon", v2.Icon
	end

	return "Text", p
end

function Bait.GetDescription(p: string)
	if value == p and v ~= p and Bait._HasBait(v) then
		p = v
	end

	return (`Equip "{p}" Bait`)
end

bait2.Changed:Connect(function(p)
	v = value
	value = p
end)
return Bait